// ----------------------------------------------------------------
// IMPORTS
// ----------------------------------------------------------------

const std = @import("std");
const users = @import("models/users.zig");

// ----------------------------------------------------------------
// MAIN
// ----------------------------------------------------------------

/// Entry point with hello-world method
pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var args = try std.process.ArgIterator.initWithAllocator(allocator);
    defer args.deinit();

    // ignore first argument
    _ = args.next() orelse "";

    // get second argument
    var message: []u8 = "";
    const name = args.next() orelse "";
    const user = users.User{ .name = name };
    message = user.greet() orelse "";
    std.debug.print("{s}\n", .{message});
}
