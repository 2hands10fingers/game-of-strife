const std = @import("std");
const rl = @import("raylib");
const print = std.debug.print;
const mem = std.mem;
const os = std.os;
const random = std.crypto.random;
const automata = @import("../objects/automata.zig");
const grid = @import("../objects/grid.zig");
const indexing = @import("../utils/indexing.zig");
const displayGameMenu = @import("../visual/game-menu.zig").displayGameMenu;
const displayScore = @import("../visual/score.zig").displayScore;
const loggingDialog = @import("../utils/logging-dialog.zig").displayLogginDialog;
const cursors = @import("../visual/cursors.zig");
const Cell = automata.Cell;
const Grid = grid.Grid;
const mainState = @import("main-state.zig");
const AppState = @import("./app-state.zig");

var state = mainState.state{};

pub fn gameState(appState: *u2) !void {
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
    while (!rl.windowShouldClose() and appState.* == AppState.GAME) {
        const background = if (state.isGridOn) rl.Color.gray else rl.Color.black;
        const mouse_pos = rl.getMousePosition();

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(background);

        // Controls
        if (rl.isKeyPressed(.space)) { // Press space to start the game
            state.runGame = !state.runGame;
            state.isGridOn = if (state.runGame) false else true;
        }
        if (rl.isKeyPressed(.c)) // Press c to clear the grid
            gameGrid.clearGrid();
        if (rl.isKeyPressed(.g)) // pess g to toggle grid
            state.isGridOn = !state.isGridOn;
        if (rl.isKeyPressed(.q)) // pess g to toggle grid
            gameGrid.toggleRainbowMode();
        if (rl.isKeyPressed(.f)) // press f to show the FPS
            state.isFPSShowing = !state.isFPSShowing;
        if (rl.isKeyPressed(.r)) // Press r to randomize the grid
            gameGrid.addRandomCells();
        if (rl.isKeyPressed(.l)) // Press l to toggle logging
            state.isLoggingEnabled = !state.isLoggingEnabled;

        if (state.isFPSShowing) // Draw FPS
            rl.drawFPS(0, 0);

        // Init grid state
        gameGrid.initialGridPainting();
        gameGrid.drawGrid();

        // Determines where a cell index has been collided with and handles the collision logic
        if (!state.runGame) {
            const index = gameGrid.calculateGridIndex(mouse_pos);

            if (index) |i| {
                const mousePosAttrs = gameGrid.calculateCollisionAttributes(
                    i,
                    mouse_pos,
                );

                if (state.isLoggingEnabled)
                    loggingDialog(i, &gameGrid, mouse_pos);

                // zig fmt: off
                const isPaintingOnGrid = (
                    rl.isMouseButtonDown(.left) and rl.isKeyDown(.d) or 
                    rl.isMouseButtonPressed(.left));

                gameGrid.executeCollisionLogic(
                    i,
                    mousePosAttrs,
                );

                cursors.displayMainCursor(mouse_pos);
                
                if (isPaintingOnGrid)
                    gameGrid.girdCells[i].toggleCellLife();
            }
        }

        if (state.runGame) {
            try gameGrid.updateGridMovements();
            displayScore(
                gameGrid.cellsDead, 
                gameGrid.cellsAlive,
            );
            }
        }
}
 