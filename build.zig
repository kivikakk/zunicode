const Build = @import("std").Build;

pub fn build(b: *Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    _ = b.addModule("zunicode", .{
        .root_source_file = b.path("src/zunicode.zig"),
        .optimize = optimize,
    });
    var main_tests = b.addTest(.{
        .root_source_file = b.path("src/all_test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    b.default_step.dependOn(test_step);
}
