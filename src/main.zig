const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const os = std.os;
const rl = @import("raylib");

pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const row_and_column_count = 20; // Row and column count determin winwdow size. I wouldn't go above 100 for now.
    const num_rows = row_and_column_count;
    const num_cols = row_and_column_count;
    const padding = 1;
    const cell_width = 20;
    const cell_height = 20;
    const screenWidth = padding + num_cols * (cell_width + padding);
    const screenHeight = padding + num_rows * (cell_height + padding);

    rl.initWindow(screenWidth, screenHeight, "game of strife");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    var myButtons: [num_rows * num_cols]Cell = .{Cell{ .x = 0, .y = 0, .alive = false }} ** (num_rows * num_cols);

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.gray);

        const mouse_pos = rl.getMousePosition();

        print("Mouse Position: ( x:{d}, y:{d} )\n", .{ mouse_pos.x, mouse_pos.y });

        //creates grid
        for (0..num_rows) |x| {
            for (0..num_cols) |y| {
                const yCast: i32 = @intCast(x);
                const xCast: i32 = @intCast(y);
                const posX = padding + yCast * (cell_width + padding);
                const posY = padding + xCast * (cell_height + padding);

                rl.drawRectangle(posX, posY, cell_width, cell_height, .black);
            }
        }

        const yInt = @as(i32, @intFromFloat(mouse_pos.y));
        const xInt = @as(i32, @intFromFloat(mouse_pos.x));

        const gridBoxPosition = @divFloor(yInt, (cell_height + padding));
        const gridBoxPosition2 = @divFloor(xInt, (cell_width + padding));
        const index = toIndex(gridBoxPosition, gridBoxPosition2, num_cols, num_rows);
        print("Grid Box Position: ( x:{d}, y:{d} )\n", .{ gridBoxPosition, gridBoxPosition2 });
        // determines where if a cell index has been found and handles the collision logic
        if (index) |i| {
            const cellX: i32 = @intCast(i % num_cols);
            const cellY: i32 = @intCast(i / num_cols);
            const cellPosX = padding + cellY * (cell_width + padding);
            const cellPosY = padding + cellX * (cell_height + padding);
            const cellPosXF32 = @as(f32, @floatFromInt(cellPosX));
            const cellPosYF32 = @as(f32, @floatFromInt(cellPosY));
            const cellWidthF32 = @as(f32, @floatFromInt(cell_width));
            const cellHeightF32 = @as(f32, @floatFromInt(cell_height));
            // check if the mouse is inside the cell
            const hasCollision = rl.checkCollisionPointRec(.{ .x = mouse_pos.x, .y = mouse_pos.y }, .{ .x = cellPosXF32, .y = cellPosYF32, .width = cellWidthF32, .height = cellHeightF32 });

            print("Index: {d}\n", .{i});
            print("Cell Position: ( x:{d}, y:{d} )\n", .{ cellX, cellY });
            print("{?}\n", .{myButtons[i]});
            // collision logic
            if (hasCollision and !myButtons[i].alive) {
                print("Collision Detected\n", .{});
                rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .red);
            } else if (myButtons[i].alive) { //TODO: Check if I need this
                rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .blue);
            } else {
                rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .black);
            }

            if (rl.isMouseButtonDown(.left)) {
                // make the cell alive
                myButtons[i] = Cell{ .x = cellX, .y = cellY, .alive = true };
                rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .blue);
            }
        } else {
            print("Index: null\n", .{});
        }

        //update cell states
        for (myButtons) |cell| {
            if (cell.alive) {
                const cellPosX = padding + cell.y * (cell_width + padding);
                const cellPosY = padding + cell.x * (cell_height + padding);
                rl.drawRectangle(cellPosX, cellPosY, cell_width, cell_height, .blue);
            }
        }
        //----------------------------------------------------------------------------------
    }
}

// Given a row and a column, find the index of the tile in the tile list
// credit to slightknack for the original code of this function
// https://github.com/slightknack/scrabble/blob/master/src/main.zig
fn toIndex(x: i32, y: i32, cols: usize, rows: usize) ?usize {
    if (0 > x or x >= cols) {
        return null;
    }
    if (0 > y or y >= rows) {
        return null;
    }
    const index: usize = @intCast(y * @as(i32, @intCast(cols)) + x);
    return index;
}

const Cell = struct {
    x: i32,
    y: i32,
    alive: bool,
};
