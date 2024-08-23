[![Zig version: 0.14.0](https://img.shields.io/badge/zig%20version-0.14-gold)](https://ziglang.org)

[![qa manual:main](https://github.com/noprd/example-zig/actions/workflows/manual.yaml/badge.svg?branch=main)](https://github.com/noprd/example-zig/actions/workflows/manual.yaml)
[![qa manual:staging](https://github.com/noprd/example-zig/actions/workflows/manual.yaml/badge.svg?branch=staging)](https://github.com/noprd/example-zig/actions/workflows/manual.yaml)

[![qa auto:staging](https://github.com/noprd/example-zig/actions/workflows/auto.yaml/badge.svg?branch=staging)](https://github.com/noprd/example-zig/actions/workflows/auto.yaml)
[![qa auto:current](https://github.com/noprd/example-zig/actions/workflows/auto.yaml/badge.svg)](https://github.com/noprd/example-zig/actions/workflows/auto.yaml)

# Example Zig #

This repository provides a simple Hello-World example for the [zig](https://ziglang.org) language,
which in recent times has become quite a hot option
as a simpler alternative to Rust and C++.

## Installation of Zig ##

- Unpack an appropriate distribution from <https://ziglang.org/download> to an appropriate location on your machine.

- Add the directory in which the zig-binary lies to your system `PATH`:

    ```bash
    touch ${HOME}/.bash_profile # ensures this exists
    echo "# path for zig" >> ${HOME}/.bash_profile
    echo "export PATH=\"/path/to/your zig binaries:\${PATH}\";" >> ${HOME}/.bash_profile
    ```

    for linux.
    Or edit the file directly, adding the lines

    ```bash
    ...
    # path for zig
    export PATH="/path/to/your zig binaries:${PATH}";
    ```

    For windows, do this via the system environment variables (which requires admin access);
    or just install [bash for windows](https://gitforwindows.org)
    and simply perform the above.

- Clone the **ZLS** (_zig langauge server_) repository <https://github.com/zigtools/zls> and run

    ```bash
    zig build
    ```

   This will generate a folder **zig-out/bin**.
   Copy just the binary from here to the same path where your zig-compiler binary is stored.
   (Otherwise choose your own location and add this to `PATH`.)

### Intellisense ###

If you are using VSCode, install the [Zig Language](https://marketplace.visualstudio.com/items?itemName=ziglang.vscode-zig) extension.
For this to work, it needs to detect your **ZLS** binary.

Open the _User Settings JSON_ (e.g. via command palette)
and add the following attributes to the dictionary:

```js
{
    ...
    // NOTE: remove the .exe extension for windows
    "zig.path": "/path/to/your zig binaries/zig.exe",
    "zig.zls.zigLibPath": "/path/to/your zig binaries/lib",
    "zig.zls.path": "/path/to/your ZLS binaries/zls.exe",
    // optional
    "zig.zls.buildOnSaveStep": "",
    "zig.checkForUpdate": false,
    "zig.zls.checkForUpdate": false,
}
```

## Build and run ##

Install the [justfile](https://github.com/casey/just?tab=readme-ov-file#installation) tool.
Run

```bash
just setup # only needed once - then adjust the created .env file
just build # compiles the binary
just run {args} # runs without the compiled binary
just run-exe {args} # runs the compiled binary
```

NOTE: The hello-world example was taken from <https://zig-by-example.com/hello-world>
