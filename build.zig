// ----------------------------------------------------------------
// IMPORTS
// ----------------------------------------------------------------

const std = @import("std");

// ----------------------------------------------------------------
// BUILD METHOD
// ----------------------------------------------------------------

/// Declarative construction of a build graph to be executed by external runner.
///
/// The target + optimisation options allow the person running `zig build` to
/// - choose target to build for.
///   Here we do not override the defaults,
///   i.e.  any target is allowed, and default is native;
/// - select between `Debug`, `ReleaseSafe`, `ReleaseFast`, and `ReleaseSmall`.
///
/// The build graph is defined by making the run commmand
/// depends on the installation step.
/// This ensures that it runs from the installation directory
/// rather than the cache directory.
/// This ensures that dependencies are present and in the expected location.
/// We also allow user to pass arguments to the application in build command,
/// e.g.: `zig build run -- arg1 arg2 etc`
///
/// NOTE: Call`zig build --help` to see all steps
pub fn build(builder: *std.Build) void {
    // prepare target + optimiser
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    // prepare options
    const opt_libraries = builder.addStaticLibrary(.{
        .name = "example-zig",
        .root_source_file = builder.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const opt_exe = builder.addExecutable(.{
        .name = "example-zig",
        .root_source_file = builder.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const opt_unit_tests = builder.addTest(.{
        .root_source_file = builder.path("tests/unit/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Ensures library + exe install in standard location
    builder.installArtifact(opt_libraries);
    builder.installArtifact(opt_exe);

    // Intialise steps
    const run_init = builder.addRunArtifact(opt_exe);
    run_init.step.dependOn(builder.getInstallStep());
    if (builder.args) |args| run_init.addArgs(args);

    // Run step
    const run_step = builder.step("run", "Run the application");
    run_step.dependOn(&run_init.step);

    // Test step
    const run_unit_tests = builder.addRunArtifact(opt_unit_tests);
    const test_step = builder.step("test-unit", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
