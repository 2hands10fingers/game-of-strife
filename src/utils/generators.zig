const std = @import("std");
const random = std.crypto.random;

pub fn generateRandom8bitInteger() u8 {
    return random.intRangeAtMost(u8, 0, 255);
}
