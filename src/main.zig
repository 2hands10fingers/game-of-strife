/// This is a simple implementation of Conway's Game of Life using Zig and raylib.
const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const os = std.os;
const rl = @import("raylib");

/// *** KNOWN BUGS ***
/// - Neighbor counting is not working properly.
/// - Cell (0, 0) will not highlight or let me draw on it.
pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const row_and_column_count = 20; // Row and column count determin winwdow size. I wouldn't go above 100 for now.
    const num_rows = row_and_column_count;
    const num_cols = row_and_column_count;
    const padding = 2;
    const cell_width = 20;
    const cell_height = 20;
    const screenWidth = padding + num_cols * (cell_width + padding);
    const screenHeight = padding + num_rows * (cell_height + padding);
    var runGame = false;
    var isLoggingEnabled = false;
    const update_delay_ms = 100;

    rl.initWindow(screenWidth, screenHeight, "game of strife");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    var myButtons: [num_rows * num_cols]Cell = .{Cell{ .x = 0, .y = 0, .alive = false }} ** (num_rows * num_cols);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.gray);

        if (rl.isKeyPressed(.space)) // Press space to start the game
            runGame = !runGame;

        if (rl.isKeyPressed(.escape)) // Press Esc to exit the game
            std.process.exit(1);

        if (rl.isKeyPressed(.c)) { // Press c to clear the grid
            for (myButtons, 0..) |cell, i| {
                myButtons[i] = Cell{ .x = cell.x, .y = cell.y, .alive = false };
            }
        }

        if (rl.isKeyPressed(.l)) // Press l to toggle logging
            isLoggingEnabled = !isLoggingEnabled;

        const mouse_pos = rl.getMousePosition();

        // creates grid
        for (0..num_rows) |x| {
            for (0..num_cols) |y| {
                const yCast: i32 = @intCast(x);
                const xCast: i32 = @intCast(y);
                const posX = padding + yCast * (cell_width + padding);
                const posY = padding + xCast * (cell_height + padding);

                rl.drawRectangle(posX, posY, cell_width, cell_height, .black);
            }
        }

        // determines where if a cell index has been found and handles the collision logic
        if (!runGame) {
            const yInt = @as(i32, @intFromFloat(mouse_pos.y));
            const xInt = @as(i32, @intFromFloat(mouse_pos.x));
            const gridBoxPosition = @divFloor(yInt, (cell_height + padding));
            const gridBoxPosition2 = @divFloor(xInt, (cell_width + padding));
            const index = toIndex(gridBoxPosition, gridBoxPosition2, num_cols, num_rows);

            if (index) |i| {
                const cellX: i32 = @intCast(i % num_cols);
                const cellY: i32 = @intCast(i / num_cols);
                const cellPosX = padding + cellY * (cell_width + padding);
                const cellPosY = padding + cellX * (cell_height + padding);
                
                const posVector = rl.Vector2{ .x = mouse_pos.x, .y = mouse_pos.y };
                const rectangle = rl.Rectangle{ .x = @as(f32, @floatFromInt(cellPosX)), .y = @as(f32, @floatFromInt(cellPosY)), .width = @as(f32, @floatFromInt(cell_width)), .height = @as(f32, @floatFromInt(cell_height)) };
                // check if the mouse is inside the cell

                if (isLoggingEnabled) {
                    print("INDEX: {?}", .{index});
                    print("Mouse Position: ( x:{d}, y:{d} )\n", .{ mouse_pos.x, mouse_pos.y });
                    print("Grid Box Position: ( x:{d}, y:{d} )\n", .{ gridBoxPosition, gridBoxPosition2 });
                    print("Index: {d}\n", .{i});
                    print("Cell Position: ( x:{d}, y:{d} )\n", .{ cellX, cellY });
                    print("{?}\n", .{&myButtons[i]});
                    print("Cell neighbors: {d}\n", .{myButtons[i].countNeighbors(&myButtons, num_cols, num_rows)});
                    print("Cell should stay alive: {?}\n", .{myButtons[i].staysAlive(myButtons[i].countNeighbors(&myButtons, num_cols, num_rows))});
                }

                // collision logic
                if (rl.checkCollisionPointRec(posVector, rectangle) and !myButtons[i].alive) {
                    print("Collision Detected\n", .{});
                    rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .red);
                } else {
                    rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .black);
                }

                if ((rl.isMouseButtonDown(.left) and rl.isKeyDown(.d) or rl.isMouseButtonPressed(.left)) and !runGame) {
                    // make the cell alive
                    if (myButtons[i].alive) {
                        myButtons[i] = Cell{ .x = cellX, .y = cellY, .alive = false };
                    } else {
                        myButtons[i] = Cell{ .x = cellX, .y = cellY, .alive = true };
                    }
                }
            }
        }

        // Logic to update cell movments
        if (runGame) {
            var nextGrid: [num_rows * num_cols]Cell = myButtons; // Copy current state
            for (myButtons, 0..) |cell, i| {
                const neighbors = cell.countNeighbors(&myButtons, num_cols, num_rows);
                const meetsAliveConditions = cell.staysAlive(neighbors);
                nextGrid[i] = Cell{ .x = cell.x, .y = cell.y, .alive = meetsAliveConditions };
            }
            myButtons = nextGrid; // Update the main grid
        }

        for (myButtons) |cell| {
            const cellPosX = padding + cell.y * (cell_width + padding);
            const cellPosY = padding + cell.x * (cell_height + padding);
            if (cell.alive) {
                rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .blue);
            } else {
                rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .black);
            }
        }

        // slow down game loop to observe cellular automata behvaior
        if (runGame) {
            std.time.sleep(update_delay_ms * std.time.ns_per_ms);
        }

        rl.drawFPS(0, 0); // Draw FPS
        //----------------------------------------------------------------------------------
    }
}

// Given a row and a column, find the index of the tile in the tile list
// credit to slightknack for the original code of this function
// https://github.com/slightknack/scrabble/blob/master/src/main.zig
fn toIndex(x: i32, y: i32, cols: usize, rows: usize) ?usize {
    if (0 > x or x >= rows) {
        return null;
    }
    if (0 > y or y >= cols) {
        return null;
    }
    const index: usize = @intCast(y * @as(i32, @intCast(cols)) + x);
    return index;
}

const Offset = struct {
    dx: i32,
    dy: i32,
};
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

const Cell = struct {
    x: i32,
    y: i32,
    alive: bool,

    pub fn countNeighbors(self: Cell, grid: []Cell, cols: usize, rows: usize) u8 {
        var count: u8 = 0;
        // print("Checking neighbors for cell at ({d}, {d})\n", .{ self.x, self.y });
        // Check the 8 neighbors
        for (offsets) |o| {
            const newX = self.x + o.dx;
            const newY = self.y + o.dy;

            if (toIndex(newX, newY, cols, rows)) |index| {
                // print("Checking neighbor at ({d}, {d}) -> Index: {d}, Alive: {?}\n", .{ newX, newY, index, grid[index].alive });
                if (grid[index].alive) {
                    count += 1;
                }
            }
        }

        return count;
    }

    pub fn staysAlive(self: Cell, neighbors: u8) bool {
        // Any live cell with fewer than two live neighbours dies, as if by underpopulation.
        // Any live cell with two or three live neighbours lives on to the next generation.
        // Any live cell with more than three live neighbours dies, as if by overpopulation.
        // Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        // if (neighbors > 0) print("NEIGHBORS: {d}\n", .{neighbors});

        if (self.alive) {
            if (neighbors == 1) return false; // Underpopulation
            if (neighbors == 0) return false; // Underpopulation
            if (neighbors == 2) return true; // Lives on
            if (neighbors == 3) return true; // Lives on
            if (neighbors > 3) return false; // Overpopulation

        } else if (neighbors == 3) return true; // Reproduction
        // if (neighbors == 4) return false; // Overpopulation
        return false; // Default case
    }
};
