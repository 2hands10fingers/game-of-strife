const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const os = std.os;
const person = @import("./person.zig");

pub fn main() void {
    var p = person.Person{
        .age = 20.0,
        .name = "Bob",
    };

    for (0..10) |_| {
        p.degradeHealth();
    }

    print("Health: {d:.1}", .{p.health});
}
