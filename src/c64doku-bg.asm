; C64DOKUBG - the C64Doku menu background and its helper - SYS 51200
; Screen at $C000, colours at $C400: a sudoku grid over the whole screen with
; a panel in the middle for the menu. The helper at $C800 copies both to the screen.
        * = $c000
        !binary "c64doku-bg-screen.bin"
        * = $c400
        !binary "c64doku-bg-colours.bin"
        * = $c800
        ldx #0
-       lda $c000,x
        sta $0400,x
        lda $c100,x
        sta $0500,x
        lda $c200,x
        sta $0600,x
        lda $c2e8,x
        sta $06e8,x
        lda $c400,x
        sta $d800,x
        lda $c500,x
        sta $d900,x
        lda $c600,x
        sta $da00,x
        lda $c6e8,x
        sta $dae8,x
        inx
        bne -
        rts
