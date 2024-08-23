# ----------------------------------------------------------------
# NOTE: Setting shell does not work!
# For GitHub-actions we need "bash", but
# for Windows we need "sh".
# The solution is to ensure tasks are written with bash-shebang
# if they involve bash-syntax, e.g. 'if [[ ... ]] then else fi'.
# ----------------------------------------------------------------
# set shell := [ "bash", "-c" ]
_default:
    @- just --unsorted --list
menu:
    @- just --unsorted --choose
# ----------------------------------------------------------------
# Justfile
# Recipes for various workflows.
# ----------------------------------------------------------------

set dotenv-load := true
set positional-arguments := true

# --------------------------------
# VARIABLES
# --------------------------------

PATH_ROOT := justfile_directory()
CURRENT_DIR := invocation_directory()
OS := if os_family() == "windows" { "windows" } else { "linux" }
EXE := if os_family() == "windows" { ".exe" } else { "" }

# --------------------------------
# Macros
# --------------------------------

_create-file-if-not-exists fname:
    #!/usr/bin/env bash
    touch "{{fname}}";
    exit 0;

_create-folder-if-not-exists path:
    #!/usr/bin/env bash
    if ! [[ -d "{{path}}" ]]; then
        mkdir -p "{{path}}";
    fi
    exit 0;

_create-temp-folder path="." name="tmp":
    #!/usr/bin/env bash
    k=-1;
    tmp_folder="{{path}}/{{name}}";
    while [[ -d "${tmp_folder}" ]] || [[ -f "${tmp_folder}" ]]; do
        k=$(( $k + 1 ));
        tmp_folder="{{path}}/{{name}}_${k}";
    done
    mkdir "${tmp_folder}";
    echo "${tmp_folder}";
    exit 0;

_delete-if-file-exists fname:
    #!/usr/bin/env bash
    if [[ -f "{{fname}}" ]]; then
        rm "{{fname}}";
    fi
    exit 0;

_delete-if-folder-exists path:
    #!/usr/bin/env bash
    if [[ -d "{{path}}" ]]; then
        rm -rf "{{path}}";
    fi
    exit 0;

_clean-all-files path pattern:
    #!/usr/bin/env bash
    find {{path}} -type f -name "{{pattern}}" -exec basename {} \; 2> /dev/null
    find {{path}} -type f -name "{{pattern}}" -exec rm {} \; 2> /dev/null
    exit 0;

_clean-all-folders path pattern:
    #!/usr/bin/env bash
    find {{path}} -type d -name "{{pattern}}" -exec basename {} \; 2> /dev/null
    find {{path}} -type d -name "{{pattern}}" -exec rm -rf {} \; 2> /dev/null
    exit 0;

_check-tool tool name:
    #!/usr/bin/env bash
    success=false
    {{tool}} --version >> /dev/null 2> /dev/null && success=true;
    {{tool}} --help >> /dev/null 2> /dev/null && success=true;
    # NOTE: if exitcode is 251 (= help or print version), then render success.
    if [[ "$?" == "251" ]]; then success=true; fi
    # FAIL tool not installed
    if ( $success ); then
        echo -e "Tool \x1b[2;3m{{name}}\x1b[0m installed correctly.";
        exit 0;
    else
        echo -e "Tool \x1b[2;3m{{tool}}\x1b[0m did not work." >> /dev/stderr;
        echo -e "Ensure that \x1b[2;3m{{name}}\x1b[0m (-> \x1b[1mjust build\x1b[0m) installed correctly and system paths are set." >> /dev/stderr;
        exit 1;
    fi

_docker-build-and-log service:
    @echo "RUN DOCKER BUILD+LOG {{service}}"
    @docker compose logs -f --tail=0 {{service}} && docker compose up --build -d {{service}}

_docker-build-and-interact service container:
    @echo "RUN DOCKER BUILD+INTERACT {{service}} / {{container}}"
    @docker compose up --build -d {{service}} && docker attach {{container}}

_docker-run service cmd:
    @echo "RUN DOCKER CMD {{service}} / {{cmd}}"
    @docker compose run --service-ports {{service}} "{{cmd}}"

_docker-run-interactive service cmd:
    @echo "RUN DOCKER CMD (it) {{service}} / {{cmd}}"
    @docker compose run --interactive --service-ports {{service}} "{{cmd}}"

# ----------------------------------------------------------------
# TARGETS
# ----------------------------------------------------------------

# --------------------------------
# TARGETS: build
# --------------------------------

setup:
    @echo "TASK: SETUP"
    @mkdir -p "setup"
    @- cp -n "templates/template.env" ".env"

build:
    @echo "TASK: BUILD"
    @zig build-exe src/main.zig
    @mv main{{EXE}} dist/${ARTEFACT}-v$(cat dist/VERSION){{EXE}}
    @- rm main{{EXE}}.obj 2> /dev/null
    @- rm main.pdb 2> /dev/null

# --------------------------------
# TARGETS: execution
# --------------------------------

run *args:
    @zig run src/main.zig

run-exe *args:
    @./dist/${ARTEFACT}-v$(cat dist/VERSION){{EXE}} {{args}}

# --------------------------------
# TARGETS: clean
# --------------------------------

clean log_path="logs" session_path=".session":
    @echo "All system artefacts will be force removed."
    @- just _clean-all-files "." ".DS_Store" 2> /dev/null
    @echo "All execution artefacts will be force removed."
    @- just _delete-if-folder-exists "{{session_path}}" 2> /dev/null
    @- just _delete-if-folder-exists "{{log_path}}" 2> /dev/null
    @echo "All build artefacts will be force removed."
    @- just _delete-if-file-exists "main{{EXE}}.obj" 2> /dev/null
    @- just _delete-if-file-exists "main.pdb" 2> /dev/null

# --------------------------------
# TARGETS: logging, session
# --------------------------------

_clear-logs log_path="logs":
    @just _delete-if-folder-exists "{{log_path}}"

_create-logs log_path="logs":
    @just _create-logs-part "debug" "{{log_path}}"
    @just _create-logs-part "out" "{{log_path}}"
    @just _create-logs-part "err" "{{log_path}}"

_create-logs-part part log_path="logs":
    @just _create-folder-if-not-exists "{{log_path}}"
    @just _create-file-if-not-exists "{{log_path}}/{{part}}.log"

_reset-logs log_path="logs":
    @just _delete-if-folder-exists "{{log_path}}"
    @just _create-logs "{{log_path}}"

_reset-test-logs kind:
    @just _delete-if-folder-exists "tests/{{kind}}/logs"
    @just _create-logs-part "debug" "tests/{{kind}}/logs"

_display-logs:
    @echo ""
    @echo "Content of logs/debug.log:"
    @echo "----------------"
    @echo ""
    @- cat logs/debug.log
    @echo ""
    @echo "----------------"

watch-logs n="10":
    @tail -f -n {{n}} logs/out.log

watch-logs-err n="10":
    @tail -f -n {{n}} logs/err.log

watch-logs-debug n="10":
    @tail -f -n {{n}} logs/debug.log

watch-logs-all n="10":
    @just watch-logs {{n}} &
    @just watch-logs-err {{n}} &
    @just watch-logs-debug {{n}} &

# --------------------------------
# TARGETS: requirements
# --------------------------------

check-system:
    @echo "Operating System detected:  {{os_family()}}"
    @echo "zig:                        $( which zig )"
    @echo "zig version:                $( zig version )"
