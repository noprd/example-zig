const testing = @import("std").testing;
const users = @import("../../../src/models/users.zig");

test "user" {
    const user = users.User {.name = "James"};
    const message = user.greet();
    try testing.expectEqual(message, "Hello, James");
}
