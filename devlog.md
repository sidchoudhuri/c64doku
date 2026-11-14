# C64Doku devlog

## v6 - 2026-11-14

**Menu**
- New menu like Hex64's: a sudoku grid over the whole screen, with numbers appearing in its cells and disappearing, around a framed panel with the menu. The grid is a ready-made screen (`C64DOKUBG`) put up by machine code (`SYS 51200`).
- With two SIDs the menu text fits inside the panel.

**Instructions in the game**
- I swaps the instructions in and out instantly: the screen is saved, the ready-made instructions (`C64DOKUHELP`, made from the loader's instructions screen) are copied in, and any key copies the board back exactly as it was.
- The volume line reads "V - Volume (M / E with two SIDs)", so one instructions screen suits one or two SIDs.

**Memory and speed (the collection framework, the same as Hex64)**
- The game now loads at $4001 with the top of memory at $9000 (about 20 KB, was 12 KB at $0801); screen save $2400, instructions $2C00, copy routine $3400, characters $3800, music $9000, settings $9F00, menu background $C000. See `framework.md`.
- All arrays are integer; every cell's screen address and the cursor sprite positions are in tables, so moving does no arithmetic.

**Version**
- Title, instructions and credits say V6; disk ID 06.

## v5 - 2026-11-14

**Music**
- "Numbers Calm", only the long tones: each group of plucks becomes one held note that swells in, over the same chords and bass. It plays by default.
- T switches between Numbers Calm and Numbers, in SID setup and in the game; the choice is kept and shown under the menu. `sid/` has both as subtunes (subtune 2, Numbers Calm, first).
- The volume bar on the status line goes away after 2 seconds.

**Moving**
- Moving into an edge does nothing but clear the keyboard buffer, like walking into a wall in PETSCII Pit.
- The notes panel is only redrawn when it changes, so moving is quicker.

## v4 - 2026-11-14

**Board**
- Every grid line is 1 pixel: solid around the 3x3 boxes, dotted between cells, so every cell is exactly 15x15 with its number centred. The cursor outline touches the cell's lines on all four sides.

**Notes**
- N on any cell that isn't given opens notes for it: 1-9 switch candidate numbers on and off, 0 clears them, N or RETURN closes. A panel right of the board shows the cursor cell's candidates as a 3x3 keypad, and a cell with notes gets a small dot in its top-right corner.
- Notes stay when you type a number into the cell (you might be wrong about it) and are all cleared once the puzzle is solved. R clears them along with your numbers.
- After solving, N starts a new puzzle ("Solved! N for a new puzzle.").

**Instructions in the game**
- I shows the instructions at any time; any key puts the board back.

## v3 - 2026-11-14

**Music**
- New tune, "Numbers" by m0nde: calm and steady, in 9/8, so every bar counts through 9 steps like a row. Soft triangle plucks over a triangle bass, about 92 seconds before it loops.
- Plays in the menu and the game, on SID 1 voices 1 and 2, with the Hex64 player (KERNAL 60 Hz IRQ, the same tempo on PAL and NTSC). `sid/` has it as .sid files for PAL and NTSC.
- Sound effects: with two SIDs the click, blip and bell keep their own voices on $D420; with one SID they share voice 3.
- SID setup like Hex64: auto detect, one SID or two SIDs, with music and sound FX volume. In the game, M / E (two SIDs) or V (one SID) change the volume, shown on the status line.
- A second after the last sound effect its waveform is switched off, so the 6581 no longer leaks a faint noise.

**Cursor**
- A sprite outline around the cell under the cursor pulses light blue to white; a number there still turns light red.

## v2 - 2026-11-14

**Loader**
- New loader, `C64DOKU`, is the first program on the disk: menu with Play, Instructions, Credits, SID setup and Quit.
- SID detection (a second SID at $D420), the same way as Hex64 and C64 Circuits. PAL or NTSC shows under the menu.
- Instructions and credits screens.

**Board**
- New character set: a full grid with lines between all the cells and around the 3x3 boxes, the Hex64 digits, and a small dot for an empty cell.
- The board sits under a 2-row header (name, difficulty, keys), with the status line under the board.
- Colors stay the same: given numbers white, yours yellow, the cell under the cursor light red, empty cells grey.

**Game**
- Q asks "Quit to the menu? Y/N" and goes back to the loader. Q on the difficulty screen goes back to the menu too.
- R clears the status line along with your numbers.

**Text and font**
- Hex64 font: capitals, digits and symbols, plus lowercase letters in characters 129-154, printed with reverse on. All the text is in mixed case.
- Control codes are typed inline in the strings.

**Disk**
- `c64doku.d64`: the loader first, then directory art (a whole 9x9 puzzle in PETSCII lines, made the same way the game makes its puzzles), then the game and its files.

**License**
- CC BY-NC-SA 4.0, the same as PETSCII Pit (the repo had CC0, the itch.io page said GPL v3).

## v1 - 2026-08-15

- First release: one program, `c64doku.prg`.
- Random puzzles (band/stack shuffle), Easy, Medium and Hard (41, 31 and 23 given numbers), clues removed in rotationally symmetric pairs.
- C checks the whole grid by the rules. R restarts the puzzle, N starts a new one.
- Sounds: a click when moving, a blip when placing a number, a bell when a row, column or box is finished.
