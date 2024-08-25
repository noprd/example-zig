// ----------------------------------------------------------------
// IMPORTS
// ----------------------------------------------------------------

const std = @import("std");

// ----------------------------------------------------------------
// CLASSES
// ----------------------------------------------------------------

pub const User = struct {
    name: ?[]const u8,

    pub fn init() User {
        return User{ .name = undefined };
    }

    pub fn greet(self: User) ![]u8 {
        var text: ?[]u8 = undefined;
        if (self.name) |name| {
            const allocator = std.heap.page_allocator;
            text = try std.fmt.allocPrint(allocator, "Hello, {s}!", .{name}) catch undefined;
        }
        return text orelse "Hello, World! There is nobody here to greet!";
    }
};
