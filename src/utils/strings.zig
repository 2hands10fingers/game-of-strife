const std = @import("std");

fn concatAndReturnBuffer(allocator: *std.mem.Allocator, one: []const u8, two: []const u8) !std.Buffer {
    var b = try std.Buffer.init(allocator, one);
    try b.append(two);
    return b;
}
