const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");
const indexing = @import("../utils/indexing.zig");

const Offset = struct { dx: i32, dy: i32 };

const offsets: [8]Offset = [_]Offset{
    Offset{ .dx = -1, .dy = -1 },
    Offset{ .dx = 0, .dy = -1 },
    Offset{ .dx = 1, .dy = -1 },
    Offset{ .dx = -1, .dy = 0 },
    Offset{ .dx = 1, .dy = 0 },
    Offset{ .dx = -1, .dy = 1 },
    Offset{ .dx = 0, .dy = 1 },
    Offset{ .dx = 1, .dy = 1 },
};

const CellPosition = struct { x: i32, y: i32 };
pub const Coordinates = struct { x: i32, y: i32 };

pub const Cell = struct {
    coords: Coordinates,
    alive: bool = false,
    padding: u8,
    height: i32,
    width: i32,

    pub fn getNeighbors(
        self: *Cell,
        grid: std.AutoHashMap(Coordinates, Cell),
        buffer: []*Cell,
    ) []Cell {
        var count: usize = 0;

        for (offsets) |o| {
            const neighborX = self.coords.x + o.dx;
            const neighborY = self.coords.y + o.dy;
            const neighbor = grid.getPtr(.{ .x = neighborX, .y = neighborY });

            if (neighbor) |n| {
                if (count < buffer.len) {
                    buffer[count] = n;
                    count += 1;
                }
            }
        }
        return buffer[0..count];
    }

    pub fn calcCellPosition(self: Cell, cellPos: i32, cellDimension: i32) i32 {
        return self.padding + cellPos * (cellDimension + self.padding);
    }

    pub fn getSelfPosition(self: Cell) CellPosition {
        return CellPosition{
            .x = self.calcCellPosition(self.coords.y, self.width),
            .y = self.calcCellPosition(self.coords.x, self.height),
        };
    }

    pub fn draw(self: Cell, color: rl.Color) void {
        const pos = self.getSelfPosition();

        rl.drawRectangle(pos.x, pos.y, self.width, self.width, color);
    }

    pub fn countNeighbors(
        self: *Cell,
        grid: std.AutoHashMap(Coordinates, Cell),
    ) u8 {
        var count: u8 = 0;

        for (offsets) |o| {
            const neighborX = self.coords.x + o.dx;
            const neighborY = self.coords.y + o.dy;
            const neighbor = grid.get(.{ .x = neighborX, .y = neighborY });

            if (neighbor) |n| {
                if (n.alive) {
                    count += 1;
                }
            }
        }

        return count;
    }

    pub fn resetState(self: *Cell) void {
        self.alive = false;
    }

    pub fn toggleCellLife(self: *Cell) void {
        self.alive = !self.alive;
    }

    pub fn staysAlive(self: Cell, neighbors: u8) bool {
        if (self.alive) {
            return neighbors == 2 or neighbors == 3;
        } else {
            return neighbors == 3;
        }
    }
};
