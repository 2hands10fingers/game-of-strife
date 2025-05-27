const std = @import("std");
const print = std.debug.print;
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

pub const Cell = struct {
    x: i32,
    y: i32,
    alive: bool,

    pub fn countNeighbors(
        self: Cell,
        grid: []Cell,
        cols: usize,
        rows: usize,
    ) u8 {
        var count: u8 = 0;

        for (offsets) |o| {
            const cellndex = indexing.toIndex(
                self.x + o.dx, // new x position
                self.y + o.dy, // new y position
                cols,
                rows,
            );

            if (cellndex) |index| {
                if (grid[index].alive) {
                    count += 1;
                }
            }
        }

        return count;
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
