const testing = @import("std").testing;
pub const tests_users = @import("tests_users.zig");

test "models" {
    testing.refAllDecls(@This());
}
