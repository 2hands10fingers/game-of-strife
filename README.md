# game-of-strife

Conway's Game of Life written in Zig with some added rules.

> [!WARNING]  
> Currently only implementing Conway's Game of Life. No added rules at this time of development.



https://github.com/user-attachments/assets/01a2b0ca-0ef9-4d1b-8537-9332df176f27



## Installation

1. [Install Zig](https://ziglang.org/download/)
2. Fetch raylib

```
$   zig fetch --save git+https://github.com/Not-Nik/raylib-zig#devel
```

### Controls

- Space: Start/Stop simulation
- C: Clear grid
- L: Toggle logging
- R: Randomize creating alive cells on the grid
- D: (Draw Mode) - While holding this key, draw cells in a fluid motion while clicking
- G: Toggle grid visibility
- Q: Toggle rainbow mode (changes cell colors randomly)
- F: Toggle FPS display
- Left Click: Toggle cell life (alive/dead) on the grid
- Esc: Exit game
