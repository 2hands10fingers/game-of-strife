const rl = @import("raylib");
const generators = @import("generators.zig");

pub const black = rl.Color.black;
pub const white = rl.Color.white;
pub const red = rl.Color.red;
pub const green = rl.Color.green;

pub fn randomColor(alpha: ?u8) rl.Color {
    return .{
        .r = generators.generateRandom8bitInteger(),
        .g = generators.generateRandom8bitInteger(),
        .b = generators.generateRandom8bitInteger(),
        .a = alpha orelse 255,
    };
}
