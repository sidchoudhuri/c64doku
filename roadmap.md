# C64Doku roadmap

Status: **DONE**, **TO DO**, **TO DO LATER**, **MAYBE**.

## C64Doku

| Status | Item |
|---|---|
| DONE | v1: random puzzles, Easy/Medium/Hard, symmetric clue removal, rule-based check, restart and new puzzle |
| DONE | v1: sounds for moving, placing a number, and a bell for a finished row, column or box |
| DONE | v2: loader with menu, SID detection, PAL/NTSC, instructions and credits; Q goes back to the menu |
| DONE | v2: character set with a full grid, Hex64 font and mixed-case text; `c64doku.d64` with directory art; license CC BY-NC-SA 4.0 |
| DONE | v3: music "Numbers", SID setup with one or two SIDs and volumes, in-game volume keys, sound FX on $D420 with two SIDs or voice 3 with one |
| DONE | v3: pulsing sprite outline around the cursor cell; 6581 noise fix |
| DONE | v4: equal 15x15 cells (solid box lines, dotted cell lines); notes (candidate numbers) with N, side panel, dot on the cell; I shows the instructions |
| DONE | v5: "Numbers Calm" (only the long tones, the default), T switches tunes; edges clear the keyboard buffer; quicker moving |
| DONE | v6: Hex64-style menu (sudoku grid with numbers coming and going); collection framework memory map, game at $4001; instant instructions; integer arrays and tables (`framework.md`) |
| TO DO | v7: self-playing demo |
| TO DO | v8: Easy, Normal and Hard boards made by how hard they are to solve, not just by how many numbers are given |
| TO DO | v9: tutorial that teaches how to play, starting with just a 6x6 board |
| TO DO | Test on real hardware, including two SIDs and NTSC (only tested in VICE so far) |
| TO DO | Update the itch.io page (the .d64 instead of the single .prg, new screenshots) |
| MAYBE | Puzzles checked by a solver so each has exactly one solution |
