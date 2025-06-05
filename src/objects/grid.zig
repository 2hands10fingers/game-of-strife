const automata = @import("./automata.zig");
const indexing = @import("../utils/indexing.zig");
const rl = @import("raylib");
const std = @import("std");
const generators = @import("../utils/generators.zig");
const Cell = automata.Cell;
const Coordinates = automata.Coordinates;
const random = std.crypto.random;
const assert = std.debug.assert;
const colors = @import("../utils/colors.zig");

const MousPositionAttributes = struct {
    rectangle: rl.Rectangle,
    vectorPosition: rl.Vector2,
};

pub const Grid = struct {
    num_rows: i32,
    num_cols: i32,
    cells_to_add: i32,
    myButtons: std.AutoHashMap(automata.Coordinates, Cell),
    padding: i32,
    cell_width: i32,
    cell_height: i32,
    allocator: *std.mem.Allocator,
    rainbowMode: bool = false,

    pub fn init(
        rowCount: comptime_int,
        colCount: comptime_int,
        padding: u8,
        cell_width: i32,
        cell_height: i32,
        cells_to_add: i32,
        allocator: *std.mem.Allocator,
    ) !Grid {
        var cellMap = std.AutoHashMap(automata.Coordinates, Cell).init(allocator.*);

        for (0..rowCount) |row| {
            for (0..colCount) |col| {

                // const index = col * colCount + row;
                const coords = automata.Coordinates{
                    .x = @as(i32, @intCast(row)),
                    .y = @as(i32, @intCast(col)),
                };
                const cell = Cell{
                    .coords = coords,
                    .padding = padding,
                    .width = cell_width,
                    .height = cell_height,
                };

                try cellMap.put(coords, cell);
            }
        }

        return .{
            .myButtons = cellMap,
            .num_rows = rowCount,
            .num_cols = colCount,
            .padding = padding,
            .cell_width = cell_width,
            .cell_height = cell_height,
            .cells_to_add = cells_to_add,
            .allocator = allocator,
        };
    }

    pub fn toggleRainbowMode(self: *Grid) void {
        self.rainbowMode = !self.rainbowMode;
    }

    fn handleCellState(_: Grid, cell: *Cell) void {
        //TODO: implement game state logic so to maintain generic method.
        const isCellDead = !cell.alive;
        const cellColor = if (isCellDead) colors.red else colors.black;

        cell.draw(cellColor);
    }

    pub fn executeCollisionLogic(self: *Grid, cell: *Cell, mousePosAttributes: MousPositionAttributes) void {
        const hasCollision = rl.checkCollisionPointRec(
            mousePosAttributes.vectorPosition,
            mousePosAttributes.rectangle,
        );

        if (hasCollision) {
            self.handleCellState(cell);
        }
    }

    pub fn getCell(self: *Grid, coords: Coordinates) ?*Cell {
        return self.myButtons.getPtr(coords);
    }

    pub fn calculateGridCoordinates(self: *Grid, mousePos: rl.Vector2) Coordinates {
        const yInt = @as(i32, @intFromFloat(mousePos.y));
        const xInt = @as(i32, @intFromFloat(mousePos.x));

        const gridBoxPosition = @divFloor(yInt, (self.cell_height + self.padding));
        const gridBoxPosition2 = @divFloor(xInt, (self.cell_width + self.padding));
        const coords = Coordinates{
            .x = gridBoxPosition,
            .y = gridBoxPosition2,
        };

        return coords;
    }

    pub fn calculateCollisionAttributes(_: Grid, cell: *Cell, vec2: rl.Vector2) MousPositionAttributes {
        const position = cell.getSelfPosition();

        const rectangle: rl.Rectangle = .{
            .x = @as(f32, @floatFromInt(position.x)),
            .y = @as(f32, @floatFromInt(position.y)),
            .width = @as(f32, @floatFromInt(cell.width)),
            .height = @as(f32, @floatFromInt(cell.height)),
        };

        return .{ .rectangle = rectangle, .vectorPosition = vec2 };
    }

    pub fn initialGridPainting(self: *Grid) void {
        var it = self.myButtons.valueIterator();

        while (it.next()) |c| {
            c.draw(.black);
        }
    }

    pub fn drawGrid(self: *Grid) void {
        var it = self.myButtons.valueIterator();

        while (it.next()) |c| {
            if (self.rainbowMode and c.alive) {
                const randomColor = colors.randomColor(null);
                c.draw(randomColor);
            } else {
                const lifeColor = if (c.alive) colors.green else colors.black;
                c.draw(lifeColor);
            }
        }
    }

    pub fn clearGrid(self: *Grid) void {
        var it = self.myButtons.valueIterator();

        while (it.next()) |c| {
            c.resetState();
        }
    }

    fn getRandomCoordinates(self: *Grid) Coordinates {
        const row = rl.getRandomValue(0, self.num_rows - 1);
        const col = rl.getRandomValue(0, self.num_cols - 1);

        return .{ .x = row, .y = col };
    }

    pub fn addRandomCells(self: *Grid) void {
        var cells_to_add = self.cells_to_add;
        self.clearGrid();

        while (cells_to_add > 0) {
            const cell = self.getCell(self.getRandomCoordinates());

            if (cell) |c| {
                if (c.alive) continue; // Skip if the cell is already alive
                c.alive = true;
                cells_to_add -= 1;
            }
        }
    }

    // Logic to update cell movments
    pub fn updateGridMovements(self: *Grid) !void {
        var clone = try self.myButtons.clone();

        var it = clone.valueIterator();

        while (it.next()) |c| {
            const count = c.countNeighbors(self.myButtons);
            const staysAlive = c.staysAlive(count);
            c.alive = staysAlive;
        }
        self.myButtons = clone;
    }

    pub fn deinit(self: *Grid) void {
        self.myButtons.deinit();
    }
};
