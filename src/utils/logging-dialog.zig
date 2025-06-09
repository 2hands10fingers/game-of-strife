const rl = @import("raylib");
const Grid = @import("../objects/grid.zig").Grid;
const std = @import("std");

pub fn displayLogginDialog(i: usize, gameGrid: Grid, mouse_pos: rl.Vector2) void {
    const yInt = @as(i32, @intFromFloat(mouse_pos.y));
    const xInt = @as(i32, @intFromFloat(mouse_pos.x));
    const cell = gameGrid.myButtons[i];
    var buffer: [200]u8 = undefined;
    const neighorCount = cell.countNeighbors(gameGrid.myButtons, gameGrid.num_cols, gameGrid.num_rows);
    const cellShouldStayAlive = cell.staysAlive(neighorCount);
    const meta = std.fmt.bufPrintZ(&buffer, "Mouse Position: {d}, {d}\nGrid Box Position: ( x:{d}, y:{d} )\nCell neighbors: {d}\nCell should stay alive: {any}\nIs alive: {any}", .{
        mouse_pos.x,
        mouse_pos.y,
        cell.x,
        cell.y,
        neighorCount,
        cellShouldStayAlive,
        cell.alive,
    }) catch "Error";

    rl.drawRectangle(xInt + 10, yInt + 10, 200, 90, .blue);
    rl.drawText(meta, xInt + 20, yInt + 25, 1, .black);
}
