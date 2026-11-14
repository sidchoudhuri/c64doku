# Puzzle collection framework

Shared by Hex64 and C64Doku (and C64Sweeper next), so the games feel the same and can later share one disk.

## Memory map

| Address | What |
|---|---|
| $0801 | Loader (BASIC). Top of memory $2400 while it runs. When it is loaded back from a game it lands at $4001, so it sets the top to $9000 instead: `POKE 56,36-108*(PEEK(44)>63)` |
| $2400-$2BFF | Game screen ($2400) and colours ($2800) saved while the instructions show |
| $2C00-$33FF | Instructions screen ($2C00) and colours ($3000), ready-made (`...HELP`) |
| $3400 | Copy routine: `POKE 780,from page:POKE 782,to page:SYS 13312` copies 4 pages |
| $3800-$3FFF | Character set (`...CHARS`) |
| $4001-$8FFF | Game (and demo), BASIC. The loader sets `POKE 44,64:POKE 16384,0` before `LOAD`; the game starts with `POKE 45,PEEK(174):POKE 46,PEEK(175):POKE 55,0:POKE 56,144:CLR` |
| $9000-$9EFF | Music player and tunes (`...MUSIC`): $9000 start, $9003 stop, $9006 two-SID flag, $9007 song, $9009 init, $900C play, $900F volume |
| $9F00 | Settings shared by the loader and the game (below) |
| $C000-$C7FF | Menu background screen ($C000) and colours ($C400) (`...BG`) |
| $C800 | Background helper, `SYS 51200` |

## Settings (40704-40711)

| Byte | Meaning |
|---|---|
| 40704 | 80 = settings are set (SID detection done) |
| 40705 | 1 = two SIDs in use |
| 40706 | Music volume + 1 (0 = not set) |
| 40707 | Sound FX volume + 1 |
| 40708 | SID mode: 0 auto, 1 one SID, 2 two SIDs |
| 40709 | 82 = coming back from a game: the loader fixes the BASIC pointers |
| 40710 | Number of SIDs found |
| 40711 | Tune + 1 (0 = not set; each game picks its calm tune by default) |

## Techniques

- Music on SID 1 voices 1-2. Sound FX: with two SIDs on $D420, with one SID on voice 3. Waveforms are cleared a second after a sound (6581 noise).
- Every tune has a calm version with only the long tones; T switches tunes in SID setup and the game.
- Integer arrays (`%`) everywhere; screen addresses and other per-cell values worked out once into tables; no arithmetic per keypress.
- The menu background is a ready-made screen copied by machine code; animation changes one or two characters at a time.
- Instructions in the game: save the screen, copy the help screen in, any key copies the board back. Nothing is redrawn in BASIC.
- Moving into an edge does nothing but clear the keyboard buffer (`POKE 198,0`).
- Control codes typed inline in strings; mixed-case text (lowercase letters at 129-154, printed with reverse on).

## Rules for each game

- Nothing may draw on the screen while the instructions show (pause animations, timers and cursor effects; a timer must not count that time).
- Sprites are switched off while the instructions show and back on after.
- The instructions screen must suit one or two SIDs (e.g. "V - Volume (M / E with two SIDs)").
- The help file is rebuilt whenever the instructions text changes.
- For one collection disk: the loader's "already loaded?" checks must look at bytes that differ between games (today the music and background checks would pass for any game's files).
