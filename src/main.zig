const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const os = std.os;
const person = @import("./person.zig");
const rl = @import("raylib");
pub fn main() void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "game of strife");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();
        //draw grid
        for (1..screenHeight) |i| {
            const my_int = @as(i32, @intCast(i));
            const space_multiplier = 10;
            rl.drawLine(1 + my_int * space_multiplier, 0, 1 + my_int * space_multiplier, screenHeight, .white);
            rl.drawLine(0, 1 + my_int * space_multiplier, screenWidth, 1 + my_int * space_multiplier, .white);
        }

        rl.clearBackground(.black);
        //----------------------------------------------------------------------------------
    }
}
