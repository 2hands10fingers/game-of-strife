const std = @import("std");
const rl = @import("raylib");

pub fn displayScore(deadCellsCount: u64, aliveCellsCount: u64) void {
    var buffer: [200]u8 = undefined;
    const score = std.fmt.bufPrintZ(&buffer, "Cells dead: {d}\nCells born: {d}", .{ deadCellsCount, aliveCellsCount }) catch "ERROR";
    const divFloorScreenW = @divFloor(rl.getScreenWidth(), 2);
    const divFloorScreenH = @divFloor(rl.getScreenHeight(), 2);
    rl.drawRectangle(divFloorScreenW + 500, divFloorScreenH - 600, 500, 100, rl.Color.sky_blue);
    rl.drawText(score, divFloorScreenW + 510, divFloorScreenH - 550, 20, rl.Color.white);
}
