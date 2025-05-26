/// This is a simple implementation of Conway's Game of Life using Zig and raylib.
// Controls:
// - Space: Start/Stop simulation
// - C: Clear grid
// - L: Toggle logging
// - R: Randomize creating alive cells on the grid
// - D: (Draw Mode) - While holding this key, draw cells in a fluid motion while clicking
// - Esc: Exit game
const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const os = std.os;
const rl = @import("raylib");
const random = std.crypto.random;
const automata = @import("./automata.zig");
const Cell = automata.Cell;
const indexing = @import("./utils/indexing.zig");
const grid = @import("./objects/grid.zig");
const Grid = grid.Grid;
/// *** KNOWN BUGS ***
/// - Neighbor counting is not working properly.
pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const realSceenH = rl.getScreenHeight();
    const realScrenW = rl.getScreenWidth();

    //game states
    var runGame = false;
    var isLoggingEnabled = false;
    var isGridOn = true;
    var isFPSShowing = false;
    var gridAllocator = std.heap.page_allocator;
    var gameGrid = try Grid.init(
        400,
        400,
        1,
        4,
        4,
        30500,
        &gridAllocator,
    );
    defer gameGrid.deinit();

    rl.initWindow(
        realScrenW,
        realSceenH,
        "GAME OF STRIFE",
    );
    defer rl.closeWindow();
    errdefer rl.closeWindow();
    rl.setTargetFPS(60);

    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        const background = if (isGridOn) rl.Color.gray else rl.Color.black;
        rl.clearBackground(background);

        if (rl.isKeyPressed(.space)) { // Press space to start the game
            runGame = !runGame;
            isGridOn = if (runGame) false else true;
        }

        if (rl.isKeyPressed(.escape)) // Press Esc to exit the game
            std.process.exit(1);

        if (rl.isKeyPressed(.c)) // Press c to clear the grid
            gameGrid.clearGrid();

        if (rl.isKeyPressed(.g)) // pess g to toggle grid
            isGridOn = !isGridOn;

        if (rl.isKeyPressed(.f)) // press f to show the FPS
            isFPSShowing = !isFPSShowing;

        if (rl.isKeyPressed(.r)) // Press r to randomize the grid
            gameGrid.addRandomCells();

        if (isFPSShowing) rl.drawFPS(0, 0); // Draw FPS
        if (rl.isKeyPressed(.l)) // Press l to toggle logging
            isLoggingEnabled = !isLoggingEnabled;

        // creates grid
        gameGrid.initialGridPainting();
        gameGrid.drawGrid();

        const mouse_pos = rl.getMousePosition();
        // determines where if a cell index has been found and handles the collision logic
        if (!runGame) {
            const index = gameGrid.calculateGridIndex(mouse_pos);

            if (index) |i| {
                const mousePosAttrs = gameGrid.calculateCollisionAttributes(
                    i,
                    mouse_pos,
                );
                const isPaintingOnGrid = (rl.isMouseButtonDown(.left) and rl.isKeyDown(.d) or rl.isMouseButtonPressed(.left));

                // collision logic
                gameGrid.executeCollisionLogic(
                    i,
                    mousePosAttrs,
                );

                if (isPaintingOnGrid)
                    gameGrid.myButtons[i].toggleCellLife();
            }
        }

        if (runGame) {
            gameGrid.updateGridMovements();
        }
        //----------------------------------------------------------------------------------
    }
}
