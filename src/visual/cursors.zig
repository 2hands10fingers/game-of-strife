const rl = @import("raylib");

pub fn displayMainCursor(mouse_pos: rl.Vector2) void {
    const yInt = @as(i32, @intFromFloat(mouse_pos.y));
    const xInt = @as(i32, @intFromFloat(mouse_pos.x));
    const cursorSize = 10;

    rl.drawLine(xInt - cursorSize, yInt, xInt + cursorSize, yInt, .yellow);
    rl.drawLine(xInt, yInt - cursorSize, xInt, yInt + cursorSize, .yellow);
}
