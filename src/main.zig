// --------------------------------
// IMPORTS
// --------------------------------

const std = @import("std");
const users = @import("models/users.zig");

// --------------------------------
// MAIN
// --------------------------------

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var args = try std.process.ArgIterator.initWithAllocator(allocator);
    defer args.deinit();
    _ = args.next();
    if (args.next()) |name| {
        const user = users.User{ .name = name };
        user.greet();
    } else {
        std.debug.print("Hello, World! There is nobody to greet!\n", .{});
    }
}
