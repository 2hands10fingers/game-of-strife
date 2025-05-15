/// This is a simple implementation of Conway's Game of Life using Zig and raylib.
/// /// Controls:
/// - Space: Start/Stop simulation
/// - C: Clear grid
/// - L: Toggle logging
/// - R: Randomize creating alive cells on the grid
/// - Esc: Exit game
const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const os = std.os;
const rl = @import("raylib");
const random = std.crypto.random;

/// *** KNOWN BUGS ***
/// - Neighbor counting is not working properly.
/// - Cell (0, 0) will not highlight or let me draw on it.
pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------

    // const shdrOutline:  = try rl.loadShader(null, "resources/shaders/glsl330/outline.fs");

    const row_and_column_count = 80; // Row and column count determin winwdow size. I wouldn't go above 100 for now.
    const num_rows = row_and_column_count;
    const num_cols = row_and_column_count;
    const padding = 2;
    const cell_width = 10;
    const cell_height = 10;
    const screenWidth = padding + num_cols * (cell_width + padding);
    const screenHeight = padding + num_rows * (cell_height + padding);
    // const update_delay_ms = 100;
    //game states
    var runGame = false;
    var isLoggingEnabled = false;
    var isGridOn = true;
    var isFPSShowing = false;
    const useShader = false;

    // var frame_counter: u32 = 0;
    // const frames_per_update = 30; // Adjust for speed

    rl.initWindow(
        screenWidth,
        screenHeight,
        "game of strife",
    );
    const target = try rl.loadRenderTexture(
        screenWidth,
        screenHeight,
    );
    const bloomShader = try rl.loadShader(
        null,
        "src/shaders/bloom.fs",
    );
    defer rl.unloadShader(bloomShader);
    defer rl.closeWindow(); // Close window and OpenGL context
    errdefer rl.closeWindow(); // Close window and OpenGL context

    const windowSizeUniformValue = rl.Vector2{ .x = 10.0, .y = 10.0 };
    const windowSize = rl.getShaderLocation(
        bloomShader,
        "size",
    );
    const coldDiffuse = rl.getShaderLocation(
        bloomShader,
        "coldDiffuse",
    );
    var coldDiffuseUniformValue = rl.Vector4{
        .x = 0.0,
        .y = 0.0,
        .w = 10.0,
        .z = 0,
    };

    rl.setShaderValue(
        bloomShader,
        coldDiffuse,
        &coldDiffuseUniformValue,
        .vec4,
    );
    rl.setShaderValue(
        bloomShader,
        windowSize,
        &windowSizeUniformValue,
        .vec2,
    );
    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    var myButtons: [num_rows * num_cols]Cell = undefined;
    for (0..num_rows) |row| {
        for (0..num_cols) |col| {
            const index = col * num_cols + row;
            myButtons[index] = Cell{
                .x = @intCast(row),
                .y = @intCast(col),
                .alive = false,
            };
        }
    }

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        const background = if (isGridOn) rl.Color.gray else rl.Color.black;
        rl.clearBackground(background);

        if (rl.isKeyPressed(.space)) { // Press space to start the game
            runGame = !runGame;
            isGridOn = if (isGridOn) false else true;
            // if (runGame) {
            //     isGridOn = false;
            // } else {
            //     isGridOn = true;
            // }
        }

        if (rl.isKeyPressed(.escape)) // Press Esc to exit the game
            std.process.exit(1);

        if (rl.isKeyPressed(.c)) { // Press c to clear the grid
            for (myButtons, 0..) |cell, i| {
                myButtons[i] = .{
                    .x = cell.x,
                    .y = cell.y,
                    .alive = false,
                };
                const posX = padding + cell.y * (cell_width + padding);
                const posY = padding + cell.x * (cell_height + padding);

                rl.drawRectangle(
                    posX,
                    posY,
                    cell_width,
                    cell_height,
                    .black,
                );
            }
        }

        if (rl.isKeyPressed(.g)) // pess g to toggle grid
            isGridOn = !isGridOn;

        if (rl.isKeyPressed(.f))
            isFPSShowing = !isFPSShowing;

        if (rl.isKeyPressed(.r)) { // Press r to randomize the grid
            // Clear the grid first
            for (myButtons, 0..) |cell, i| {
                myButtons[i] = Cell{
                    .x = cell.x,
                    .y = cell.y,
                    .alive = false,
                };
            }

            // Add 100 random live cells
            var cells_to_add: usize = 800;
            while (cells_to_add > 0) {
                const row = random.intRangeAtMost(usize, 0, num_rows - 1);
                const col = random.intRangeAtMost(usize, 0, num_cols - 1);
                const index = row * num_cols + col;

                if (!myButtons[index].alive) {
                    myButtons[index].alive = true;
                    cells_to_add -= 1;
                }
            }
        }

        if (rl.isKeyPressed(.l)) // Press l to toggle logging
            isLoggingEnabled = !isLoggingEnabled;

        const mouse_pos = rl.getMousePosition();

        for (0..num_rows) |x| {
            for (0..num_cols) |y| {
                const yCast: i32 = @intCast(x);
                const xCast: i32 = @intCast(y);
                const posX = padding + yCast * (cell_width + padding);
                const posY = padding + xCast * (cell_height + padding);

                rl.drawRectangle(
                    posX,
                    posY,
                    cell_width,
                    cell_height,
                    .black,
                );
            }
        }

        // creates grid
        for (myButtons) |cell| {
            const cellPosX = padding + cell.y * (cell_width + padding);
            const cellPosY = padding + cell.x * (cell_height + padding);
            const floatPosX = @as(f32, @floatFromInt(cellPosX));
            const floatPosY = @as(f32, @floatFromInt(cellPosY));
            if (cell.alive) {
                const rec = rl.Rectangle{
                    .x = floatPosX,
                    .y = floatPosY,
                    .width = @as(f32, @floatFromInt(cell_width)),
                    .height = @as(f32, @floatFromInt(cell_height)),
                };
                const myvec2 = rl.Vector2{
                    .x = floatPosX,
                    .y = floatPosY,
                };
                {
                    rl.drawRectangle(
                        cellPosX,
                        cellPosY,
                        cell_width,
                        cell_height,
                        .green,
                    );
                    if (useShader) {
                        rl.beginShaderMode(bloomShader);
                        defer rl.endShaderMode();
                        rl.drawTextureRec(
                            target.texture,
                            rec,
                            myvec2,
                            .blue,
                        );
                    }
                }
            } else {
                rl.drawRectangle(
                    cellPosX,
                    cellPosY,
                    cell_width,
                    cell_height,
                    .black,
                );
            }
        }

        // determines where if a cell index has been found and handles the collision logic
        if (!runGame) {
            const yInt = @as(i32, @intFromFloat(mouse_pos.y));
            const xInt = @as(i32, @intFromFloat(mouse_pos.x));
            const gridBoxPosition = @divFloor(yInt, (cell_height + padding));
            const gridBoxPosition2 = @divFloor(xInt, (cell_width + padding));
            const index = toIndex(
                gridBoxPosition,
                gridBoxPosition2,
                num_cols,
                num_rows,
            );

            if (index) |i| {
                const cellX: i32 = @intCast(i % num_cols);
                const cellY: i32 = @intCast(i / num_cols);
                const cellPosX = padding + cellY * (cell_width + padding);
                const cellPosY = padding + cellX * (cell_height + padding);

                const posVector = rl.Vector2{
                    .x = mouse_pos.x,
                    .y = mouse_pos.y,
                };
                const rectangle = rl.Rectangle{
                    .x = @as(f32, @floatFromInt(cellPosX)),
                    .y = @as(f32, @floatFromInt(cellPosY)),
                    .width = @as(f32, @floatFromInt(cell_width)),
                    .height = @as(f32, @floatFromInt(cell_height)),
                };

                // check if the mouse is inside the cell
                if (isLoggingEnabled) {
                    rl.drawRectangle(
                        xInt + 10,
                        yInt + 10,
                        175,
                        100,
                        .blue,
                    );

                    // var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
                    // defer _ = gpa.deinit();
                    // const alloc = gpa.allocator();
                    // const mousePos = try std.fmt.allocPrintZ(alloc, "Mouse Position: {d}, {d}", .{ xInt, yInt });
                    // defer alloc.free(mousePos);

                    var buffer: [200]u8 = undefined;
                    const neighorCount = myButtons[i].countNeighbors(
                        &myButtons,
                        num_cols,
                        num_rows,
                        false,
                    );
                    const cellShouldStayAlive = myButtons[i].staysAlive(myButtons[i].countNeighbors(
                        &myButtons,
                        num_cols,
                        num_rows,
                        false,
                    ));
                    const mousePos = std.fmt.bufPrintZ(
                        &buffer,
                        "Mouse Position: {d}, {d}\nGrid Box Position: ( x:{d}, y:{d} )\nIndex: {d}\nCell neighbors: {d}\nCell should stay alive: {any}\nIs alive: {any}",
                        .{
                            xInt,
                            yInt,
                            gridBoxPosition,
                            gridBoxPosition2,
                            i,
                            neighorCount,
                            cellShouldStayAlive,
                            myButtons[i].alive,
                        },
                    ) catch "Error";

                    rl.drawText(
                        mousePos,
                        xInt + 20,
                        yInt + 25,
                        1,
                        .black,
                    );
                }

                // collision logic
                const hasCollision = rl.checkCollisionPointRec(
                    posVector,
                    rectangle,
                );
                const isCellDead = !myButtons[i].alive;
                if (hasCollision and isCellDead) {
                    rl.drawRectangle(
                        cellPosX,
                        cellPosY,
                        cell_width,
                        cell_height,
                        .red,
                    );
                } else {
                    rl.drawRectangle(
                        cellPosX,
                        cellPosY,
                        cell_width,
                        cell_height,
                        .black,
                    );
                }
                // zig fmt: off
                if ((rl.isMouseButtonDown(.left) and 
                     rl.isKeyDown(.d) or rl.isMouseButtonPressed(.left)) and
                     !runGame) {
                    // make the cell alive
                    if (myButtons[i].alive) {
                        myButtons[i] = Cell{
                            .x = cellX,
                            .y = cellY,
                            .alive = false,
                        };
                    } else {
                        myButtons[i] = Cell{
                            .x = cellX,
                            .y = cellY,
                            .alive = true,
                        };
                    }
                }
            }
        }

        // Logic to update cell movments
        if (runGame) {
            var nextGrid: [num_rows * num_cols]Cell = myButtons; // Copy current state
            for (myButtons, 0..) |cell, i| {
                const neighbors = cell.countNeighbors(
                    &myButtons,
                    num_cols,
                    num_rows,
                    false,
                );
                const meetsAliveConditions = cell.staysAlive(neighbors);

                nextGrid[i] = Cell{
                    .x = cell.x,
                    .y = cell.y,
                    .alive = meetsAliveConditions,
                };
            }
            myButtons = nextGrid; // Update the main grid
        }
        // slow down game loop to observe cellular automata behvaior
        // if (runGame) std.time.sleep(update_delay_ms * std.time.ns_per_ms);
        if (isFPSShowing) rl.drawFPS(0, 0); // Draw FPS
        //----------------------------------------------------------------------------------
    }
}

// Given a row and a column, find the index of the tile in the tile list
// credit to slightknack for the original code of this function
// https://github.com/slightknack/scrabble/blob/master/src/main.zig
fn toIndex(
    x: i32,
    y: i32,
    cols: usize,
    rows: usize,
) ?usize {
    if (0 > x or x >= cols) {
        return null;
    }
    if (0 > y or y >= rows) {
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

    pub fn countNeighbors(
        self: Cell,
        grid: []Cell,
        cols: usize,
        rows: usize,
        print_ths: bool,
    ) u8 {
        var count: u8 = 0;
        if (print_ths) {
            print("GRID: {any}\n", .{grid});
        }

        for (offsets) |o| {
            const newX = self.x + o.dx;
            const newY = self.y + o.dy;
            const cellndex = toIndex(newX, newY, cols, rows);
            
            if (cellndex) |index| {
                if (grid[index].alive) {
                    count += 1;
                }
            }
        }

        return count;
    }

    pub fn staysAlive(self: Cell, neighbors: u8) bool {
        if (self.alive) {
            return neighbors == 2 or neighbors == 3;
        } else {
            return neighbors == 3;
        }
    }
};
