// --------------------------------
// IMPORTS
// --------------------------------

const std = @import("std");

// --------------------------------
// CLASSES
// --------------------------------

pub const User = struct {
    name: []const u8,

    pub fn init() User {
        return User{ .name = undefined };
    }

    pub fn greet(self: User) void {
        std.debug.print("Hello {s}!\n", .{self.name});
    }
};
