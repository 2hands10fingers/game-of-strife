const automata = @import("./automata.zig");
const indexing = @import("../utils/indexing.zig");
const rl = @import("raylib");
const std = @import("std");
const Cell = automata.Cell;
const random = std.crypto.random;

const MousPositionAttributes = struct {
    rectangle: rl.Rectangle,
    vectorPosition: rl.Vector2,
};

pub const Grid = struct {
    num_rows: u64,
    num_cols: u64,
    cells_to_add: u64,
    girdCells: []Cell,
    girdCellsNext: []Cell,
    padding: i32,
    cell_width: i32,
    cell_height: i32,
    allocator: *std.mem.Allocator,
    rainbowMode: bool = false,
    cellsDead: u32 = 0,
    cellsAlive: u32 = 0,

    pub fn init(
        rowCount: comptime_int,
        colCount: comptime_int,
        padding: u8,
        cell_width: i32,
        cell_height: i32,
        cells_to_add: u64,
        allocator: *std.mem.Allocator,
    ) !Grid {
        std.debug.assert(rowCount == colCount);
        const total = rowCount * colCount;
        const buttons = try allocator.alloc(Cell, total);
        const buttonsNext = try allocator.alloc(Cell, total);

        for (0..rowCount) |row| {
            for (0..colCount) |col| {
                const index = col * colCount + row;

                buttons[index] = Cell{
                    .x = @as(i32, @intCast(row)),
                    .y = @as(i32, @intCast(col)),
                    .alive = false,
                };
                buttonsNext[index] = Cell{
                    .x = @as(i32, @intCast(row)),
                    .y = @as(i32, @intCast(col)),
                    .alive = false,
                };
            }
        }

        return .{
            .girdCells = buttons,
            .girdCellsNext = buttonsNext,
            .num_rows = rowCount,
            .num_cols = colCount,
            .padding = padding,
            .cell_width = cell_width,
            .cell_height = cell_height,
            .cells_to_add = cells_to_add,
            .allocator = allocator,
            .rainbowMode = false,
        };
    }

    pub fn toggleRainbowMode(self: *Grid) void {
        self.rainbowMode = !self.rainbowMode;
    }

    fn handleCellState(self: *Grid, cellIndex: usize, mousePosAttributes: MousPositionAttributes) void {
        const hasCollision = rl.checkCollisionPointRec(
            mousePosAttributes.vectorPosition,
            mousePosAttributes.rectangle,
        );
        const x = self.girdCells[cellIndex].x;
        const y = self.girdCells[cellIndex].y;
        const cellPosX = self.calculatePosition(y, self.cell_width);
        const cellPosY = self.calculatePosition(x, self.cell_height);

        const isCellDead = !self.girdCells[cellIndex].alive;
        const cellColor = if (hasCollision and isCellDead) rl.Color.red else rl.Color.black;

        rl.drawRectangle(
            cellPosX,
            cellPosY,
            self.cell_width,
            self.cell_height,
            cellColor,
        );
    }

    pub fn executeCollisionLogic(self: *Grid, cellIndex: usize, mousePosAttributes: MousPositionAttributes) void {
        self.handleCellState(cellIndex, mousePosAttributes);
    }

    pub fn generateRandom8bitInteger(_: Grid) u8 {
        return random.intRangeAtMost(u8, 0, 255);
    }

    pub fn calculatePosition(self: Grid, cellPos: i32, cellDimension: i32) i32 {
        //TODO: Potentially make this a cell method
        return self.padding + cellPos * (cellDimension + self.padding);
    }

    pub fn calculateGridIndex(self: *Grid, mouse_pos: rl.Vector2) ?usize {
        const yInt = @as(i32, @intFromFloat(mouse_pos.y));
        const xInt = @as(i32, @intFromFloat(mouse_pos.x));
        const gridBoxPosition = @divFloor(yInt, (self.cell_height + self.padding));
        const gridBoxPosition2 = @divFloor(xInt, (self.cell_width + self.padding));
        const index = indexing.toIndex(
            gridBoxPosition,
            gridBoxPosition2,
            self.num_cols,
            self.num_rows,
        );

        return index;
    }

    pub fn calculateCollisionAttributes(self: *Grid, cellIndex: usize, mouse_pos: rl.Vector2) MousPositionAttributes {
        const cellX: i32 = @intCast(cellIndex % self.num_cols);
        const cellY: i32 = @intCast(cellIndex / self.num_cols);
        const cellPosX = self.calculatePosition(cellY, self.cell_width);
        const cellPosY = self.calculatePosition(cellX, self.cell_height);

        const posVector = rl.Vector2{
            .x = mouse_pos.x,
            .y = mouse_pos.y,
        };
        const rectangle = rl.Rectangle{
            .x = @as(f32, @floatFromInt(cellPosX)),
            .y = @as(f32, @floatFromInt(cellPosY)),
            .width = @as(f32, @floatFromInt(self.cell_width)),
            .height = @as(f32, @floatFromInt(self.cell_height)),
        };

        return .{ .rectangle = rectangle, .vectorPosition = posVector };
    }

    pub fn initialGridPainting(self: *Grid) void {
        for (0..self.num_rows) |x| {
            for (0..self.num_cols) |y| {
                const yCast: i32 = @as(i32, @intCast(x));
                const xCast: i32 = @as(i32, @intCast(y));
                const posX = self.calculatePosition(yCast, self.cell_width);
                const posY = self.calculatePosition(xCast, self.cell_height);

                rl.drawRectangle(
                    posX,
                    posY,
                    self.cell_width,
                    self.cell_height,
                    .black,
                );
            }
        }
    }

    pub fn drawGrid(self: *Grid) void {
        for (self.girdCells) |c| {
            const cellPosX = self.calculatePosition(c.y, self.cell_width);
            const cellPosY = self.calculatePosition(c.x, self.cell_height);

            const randomColor = if (c.alive) rl.Color{
                .r = self.generateRandom8bitInteger(),
                .g = self.generateRandom8bitInteger(),
                .b = self.generateRandom8bitInteger(),
                .a = 255,
            } else rl.Color.black;
            const lifeColor = if (c.alive) rl.Color.green else rl.Color.black;
            const cellColor = if (self.rainbowMode) randomColor else lifeColor;

            // TODO: get life color may need to come from cell.
            rl.drawRectangle(
                cellPosX,
                cellPosY,
                self.cell_width,
                self.cell_height,
                cellColor,
            );
        }
    }

    pub fn clearGrid(self: *Grid) void {
        for (self.girdCells, 0..) |c, i| {
            self.girdCells[i] = .{
                .x = c.x,
                .y = c.y,
                .alive = false,
            };

            const posX = self.calculatePosition(c.y, self.cell_width);
            const posY = self.calculatePosition(c.x, self.cell_height);

            rl.drawRectangle(
                posX,
                posY,
                self.cell_width,
                self.cell_height,
                .black,
            );
        }
    }

    pub fn addRandomCells(self: *Grid) void {
        // Clear the grid first
        // const initial_cell_count = self.cells_to_add;
        var cells_to_add = self.cells_to_add;
        std.debug.print("{d}", .{cells_to_add});
        for (self.girdCells, 0..) |c, i| {
            self.girdCells[i] = .{
                .x = c.x,
                .y = c.y,
                .alive = false,
            };
        }

        while (cells_to_add > 0) {
            const row = random.intRangeAtMost(
                usize,
                0,
                self.num_rows - 1,
            );
            const col = random.intRangeAtMost(
                usize,
                0,
                self.num_cols - 1,
            );
            const index = row * self.num_cols + col;

            if (!self.girdCells[index].alive) {
                self.girdCells[index].alive = true;
                cells_to_add -= 1;
            }
        }
    }

    // Logic to update cell movments
    pub fn updateGridMovements(self: *Grid) !void {
        for (self.girdCells, 0..) |c, i| {
            const neighbors = c.countNeighbors(
                self.girdCells,
                self.num_cols,
                self.num_rows,
            );
            const staysAlive = c.staysAlive(neighbors);
            self.girdCellsNext[i] = Cell{
                .x = c.x,
                .y = c.y,
                .alive = staysAlive,
            };

            if (staysAlive) {
                self.cellsAlive += 1;
            } else {
                self.cellsDead += 1;
            }
        }
        // optimization updating cell state.
        std.mem.swap(
            []Cell,
            &self.girdCells,
            &self.girdCellsNext,
        );
    }

    pub fn deinit(self: *Grid) void {
        self.allocator.free(self.girdCells);
        self.allocator.free(self.girdCellsNext);
    }
};
