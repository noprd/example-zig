const testing = @import("std").testing;
pub const tests_models = @import("tests_models/root.zig");

test "all" {
    testing.refAllDecls(@This());
}
