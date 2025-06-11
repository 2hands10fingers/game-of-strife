const rl = @import("raylib");
const AppState = @import("../states/app-state.zig");

pub fn displayGameMenu(appState: *u2) void {
    while (!rl.windowShouldClose() and appState.* == AppState.INIT_MENU) {
        // Draw the main menu
        rl.beginDrawing();
        defer rl.endDrawing();
        const divFloorScreenW = @divFloor(rl.getScreenWidth(), 2);
        const divFloorScreenH = @divFloor(rl.getScreenHeight(), 2);
        rl.clearBackground(rl.Color.black);
        rl.drawText("GAME OF STRIFE", divFloorScreenW - 180, divFloorScreenH - 120, 40, rl.Color.red);
        rl.drawText("Press SPACE to start the game", divFloorScreenW - 160, divFloorScreenH - 58, 20, rl.Color.white);
        rl.drawText("Press ESC to exit", divFloorScreenW - 104, divFloorScreenH - 18, 20, rl.Color.white);

        if (rl.isKeyPressed(.space)) {
            appState.* = AppState.GAME;
            break;
        }
    }
}
