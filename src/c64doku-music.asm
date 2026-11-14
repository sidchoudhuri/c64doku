; C64DOKU MUSIC - "NUMBERS" BY M0NDE - HTTPS://M0NDE.ITCH.IO/C64DOKU
; Player at $9000 with the same entry points as the Hex64 and C64 Circuits players:
;   $9000 start (init + hook IRQ)   $9003 stop (unhook, silence voices 1-2)
;   $9006 two-SID flag (unused here) $9009 init   $900C play   $900F volume 0-15
; Music uses SID 1 voices 1 and 2 only. Voice 3 is left free for sound effects.
; Voice 1: soft triangle plucks. Voice 2: triangle bass with a slow attack.
; Tempo comes from the KERNAL 60 Hz IRQ, so it is the same on PAL and NTSC;
; init picks the PAL or NTSC pitch table from $02A6.
; Every bar is 9 eighths (9/8): the tune counts through 9 steps, like a row 1-9.
; Song 0: Numbers. Song 1: Numbers Calm, only the long tones (the default).
; Tune data: note (C1=1 ... B6=72, +128 = glide into it, 0 = rest),
;            duration in ticks, gate ticks (255 = hold); 255 as a note = loop.
        * = $9000
        jmp start
        jmp stop
s2      !byte 0
song    !byte 1                 ; $9007: 0 = Numbers, 1 = Numbers Calm (only the long tones)
        !byte 0
        jmp init
        jmp play
vol     !byte 12

start   sei
        jsr init
        lda $0315
        cmp #>irq
        beq +
        lda $0314
        sta old
        lda $0315
        sta old+1
        lda #<irq
        sta $0314
        lda #>irq
        sta $0315
+       cli
        rts

stop    sei
        lda $0315
        cmp #>irq
        bne +
        lda old
        sta $0314
        lda old+1
        sta $0315
+       lda #0
        sta $d404
        sta $d40b
        cli
        rts

irq     jsr play
        jmp (old)
old     !word $ea31

init    ldx #71                 ; copy the PAL or NTSC pitch table
-       lda $02a6
        beq +
        lda pallo,x
        sta flo,x
        lda palhi,x
        sta fhi,x
        jmp ++
+       lda ntsclo,x
        sta flo,x
        lda ntschi,x
        sta fhi,x
++      dex
        bpl -
        lda song
        and #1
        tax
        lda t1l,x
        sta st1l
        sta v1g+1
        lda t1h,x
        sta st1h
        sta v1g+2
        lda t2l,x
        sta st2l
        sta v2g+1
        lda t2h,x
        sta st2h
        sta v2g+2
        lda ad1,x
        sta $d405
        lda sr1,x
        sta $d406
        lda #1
        sta cnt1
        sta cnt2
        lda #0
        sta gc1
        sta gc2
        lda #$fe
        sta off1
        sta off2
        lda #$a8                ; voice 2 pad: slow attack 10, decay 8
        sta $d40c
        lda #$8b                ; sustain 8, long release 11
        sta $d40d
        lda #0
        sta $d404
        sta $d40b
        rts

play    lda vol
        and #15
        sta $d418
        jsr v1tick
        jmp v2tick

; ---- voice 1: SID register offset 0 ----
v1tick
        lda gc1               ; glide in progress?
        beq ++
        clc
        lda cl1
        adc sl1
        sta cl1
        lda ch1
        adc sh1
        sta ch1
        dec gc1
        bne +
        lda tl1               ; glide finished: land exactly on the note
        sta cl1
        lda th1
        sta ch1
+       lda cl1
        sta $d400+0
        lda ch1
        sta $d401+0
++      dec cnt1
        lda cnt1
        cmp off1
        bne +
        lda #16
        sta $d404+0           ; gate off: the release fades out
+       lda cnt1
        beq v1next
        rts
v1next
        jsr v1get
        cmp #$ff
        bne +
        lda st1l              ; end of data: loop to the song's start
        sta v1g+1
        lda st1h
        sta v1g+2
        jmp v1next
+       sta note
        jsr v1get
        sta cnt1
        jsr v1get             ; gate length; 255 = hold to the end
        sta tmp
        lda cnt1
        sec
        sbc tmp
        beq +
        bcc +
        sta off1
        jmp ++
+       lda #$fe
        sta off1
++      lda note
        and #$7f
        tax
        bne +
        lda #$fe                ; rest
        sta off1
        rts
+       lda flo-1,x
        sta tl1
        lda fhi-1,x
        sta th1
        lda note
        bmi v1gl
        lda tl1               ; plain note: jump to pitch and re-attack
        sta cl1
        sta $d400+0
        lda th1
        sta ch1
        sta $d401+0
        lda #0
        sta gc1
        lda #16
        sta $d404+0
        lda #16+1
        sta $d404+0
        rts
v1gl  sec                     ; glide: step = (target - current) / 32
        lda tl1
        sbc cl1
        sta sl1
        lda th1
        sbc ch1
        sta sh1
        ldx #5
-       lda sh1
        cmp #$80                ; carry = sign, for an arithmetic shift
        ror sh1
        ror sl1
        dex
        bne -
        lda #32
        sta gc1
        lda #16+1              ; keep the gate on (legato)
        sta $d404+0
        rts
v1get
v1g   lda $ffff
        inc v1g+1
        bne +
        inc v1g+2
+       rts


; ---- voice 2: SID register offset 7 ----
v2tick
        lda gc2               ; glide in progress?
        beq ++
        clc
        lda cl2
        adc sl2
        sta cl2
        lda ch2
        adc sh2
        sta ch2
        dec gc2
        bne +
        lda tl2               ; glide finished: land exactly on the note
        sta cl2
        lda th2
        sta ch2
+       lda cl2
        sta $d400+7
        lda ch2
        sta $d401+7
++      dec cnt2
        lda cnt2
        cmp off2
        bne +
        lda #16
        sta $d404+7           ; gate off: the release fades out
+       lda cnt2
        beq v2next
        rts
v2next
        jsr v2get
        cmp #$ff
        bne +
        lda st2l              ; end of data: loop to the song's start
        sta v2g+1
        lda st2h
        sta v2g+2
        jmp v2next
+       sta note
        jsr v2get
        sta cnt2
        jsr v2get             ; gate length; 255 = hold to the end
        sta tmp
        lda cnt2
        sec
        sbc tmp
        beq +
        bcc +
        sta off2
        jmp ++
+       lda #$fe
        sta off2
++      lda note
        and #$7f
        tax
        bne +
        lda #$fe                ; rest
        sta off2
        rts
+       lda flo-1,x
        sta tl2
        lda fhi-1,x
        sta th2
        lda note
        bmi v2gl
        lda tl2               ; plain note: jump to pitch and re-attack
        sta cl2
        sta $d400+7
        lda th2
        sta ch2
        sta $d401+7
        lda #0
        sta gc2
        lda #16
        sta $d404+7
        lda #16+1
        sta $d404+7
        rts
v2gl  sec                     ; glide: step = (target - current) / 32
        lda tl2
        sbc cl2
        sta sl2
        lda th2
        sbc ch2
        sta sh2
        ldx #5
-       lda sh2
        cmp #$80                ; carry = sign, for an arithmetic shift
        ror sh2
        ror sl2
        dex
        bne -
        lda #32
        sta gc2
        lda #16+1              ; keep the gate on (legato)
        sta $d404+7
        rts
v2get
v2g   lda $ffff
        inc v2g+1
        bne +
        inc v2g+2
+       rts

cnt1    !byte 0
cnt2    !byte 0
off1    !byte 0
off2    !byte 0
gc1     !byte 0
gc2     !byte 0
cl1     !byte 0
ch1     !byte 0
cl2     !byte 0
ch2     !byte 0
tl1     !byte 0
th1     !byte 0
tl2     !byte 0
th2     !byte 0
sl1     !byte 0
sh1     !byte 0
sl2     !byte 0
sh2     !byte 0
note    !byte 0
tmp     !byte 0
st1l    !byte 0
st1h    !byte 0
st2l    !byte 0
st2h    !byte 0
t1l     !byte <s1v1,<s2v1       ; per-song start of voice 1 data
t1h     !byte >s1v1,>s2v1
t2l     !byte <s1v2,<s1v2       ; voice 2 (the bass) is the same in both
t2h     !byte >s1v2,>s1v2
ad1     !byte $19,$5a           ; voice 1 attack/decay: plucks; Calm swells in (attack 5)
sr1     !byte $0a,$6b           ; voice 1 sustain/release: Calm holds at 6, long release
flo     !fill 72,0
fhi     !fill 72,0
pallo !byte 45,78,113,150,190,231,20,66,116,169,224,27,90,156,226,45,123,207,39,133,232,81,193,55
      !byte 180,56,196,89,247,157,78,10,208,162,129,109,103,112,137,178,237,59,156,19,160,69,2,218
      !byte 206,224,17,100,218,118,57,38,64,137,4,180,156,192,35,200,180,235,114,76,128,18,8,104
palhi !byte 2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,5,5,5,6,6,6,7,7,8
      !byte 8,9,9,10,10,11,12,13,13,14,15,16,17,18,19,20,21,23,24,26,27,29,31,32
      !byte 34,36,39,41,43,46,49,52,55,58,62,65,69,73,78,82,87,92,98,104,110,117,124,131
ntsclo !byte 24,56,90,126,164,204,247,36,84,134,188,245,49,113,180,252,72,152,237,72,167,12,120,233
       !byte 98,226,105,248,144,48,219,143,78,25,240,211,196,195,209,240,31,97,182,30,157,50,223,166
       !byte 136,134,163,224,63,194,107,61,58,100,190,76,15,12,70,191,125,132,214,122,115,200,125,151
ntschi !byte 2,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,5,5,5,6,6,7,7,7
       !byte 8,8,9,9,10,11,11,12,13,14,14,15,16,17,18,19,21,22,23,25,26,28,29,31
       !byte 33,35,37,39,42,44,47,50,53,56,59,63,67,71,75,79,84,89,94,100,106,112,119,126
s1v1 !byte 41,22,18,42,22,15,46,22,15,49,22,18,46,22,15,42,22,15,41,22,18,42,22,15
     !byte 46,22,15,39,22,18,42,22,15,46,22,15,49,22,18,46,22,15,42,22,15,39,22,18
     !byte 42,22,15,46,22,15,39,22,18,42,22,15,46,22,15,47,22,18,46,22,15,42,22,15
     !byte 39,22,18,42,22,15,46,22,15,41,22,18,44,22,15,46,22,15,49,22,18,46,22,15
     !byte 44,22,15,41,22,18,44,22,15,46,22,15,41,22,18,42,22,15,46,22,15,49,22,18
     !byte 46,22,15,42,22,15,41,22,18,42,22,15,46,22,15,41,22,18,44,22,15,46,22,15
     !byte 49,22,18,46,22,15,44,22,15,41,22,18,44,22,15,46,22,15,39,22,18,42,22,15
     !byte 46,22,15,47,22,18,46,22,15,42,22,15,39,22,18,42,22,15,46,22,15,39,22,18
     !byte 42,22,15,44,22,15,49,22,18,44,22,15,42,22,15,39,22,18,42,22,15,44,22,15
     !byte 51,66,50,47,66,50,44,66,50,49,66,50,53,66,50,56,66,50,51,66,50,47,66,50
     !byte 46,66,50,49,66,50,53,66,50,54,66,50,51,66,50,47,66,50,44,66,50,49,66,50
     !byte 53,66,50,56,66,50,51,66,50,47,66,50,46,66,50,49,66,50,51,66,50,54,66,50
     !byte 39,22,18,46,22,15,42,22,15,49,22,18,46,22,15,51,22,15,49,22,18,46,22,15
     !byte 42,22,15,41,22,18,46,22,15,44,22,15,49,22,18,46,22,15,53,22,15,49,22,18
     !byte 46,22,15,44,22,15,39,22,18,46,22,15,42,22,15,47,22,18,46,22,15,51,22,15
     !byte 47,22,18,46,22,15,42,22,15,41,22,18,46,22,15,42,22,15,49,22,18,46,22,15
     !byte 53,22,15,49,22,18,46,22,15,42,22,15,39,22,18,46,22,15,42,22,15,49,22,18
     !byte 46,22,15,51,22,15,49,22,18,46,22,15,42,22,15,39,22,18,44,22,15,42,22,15
     !byte 47,22,18,44,22,15,51,22,15,47,22,18,44,22,15,42,22,15,39,22,18,46,22,15
     !byte 42,22,15,47,22,18,46,22,15,51,22,15,47,22,18,46,22,15,42,22,15,39,22,18
     !byte 44,22,15,41,22,15,49,22,18,44,22,15,51,22,15,49,22,18,44,22,15,41,22,15
     !byte 42,22,18,46,22,15,49,22,15,53,22,18,49,22,15,46,22,15,42,22,18,46,22,15
     !byte 49,22,15,42,22,18,46,22,15,47,22,15,51,22,18,47,22,15,46,22,15,42,22,18
     !byte 46,22,15,47,22,15,42,22,18,46,22,15,49,22,15,53,22,18,49,22,15,46,22,15
     !byte 42,22,18,46,22,15,49,22,15,42,22,18,44,22,15,49,22,15,51,22,18,49,22,15
     !byte 44,22,15,42,22,18,44,22,15,49,22,15,255
s1v2 !byte 18,198,180,27,198,180,23,198,180,25,198,180,18,198,180,22,198,180,23,198,180,25,198,180
     !byte 20,132,120,27,66,55,22,132,120,29,66,55,23,132,120,30,66,55,18,132,120,25,66,55
     !byte 20,132,120,27,66,55,22,132,120,29,66,55,23,132,120,30,66,55,25,132,120,32,66,55
     !byte 27,198,180,22,198,180,23,198,180,18,198,180,27,198,180,20,198,180,23,198,180,25,198,180
     !byte 18,198,180,23,198,180,18,198,180,25,198,180,255
s2v1 !byte 41,66,56,49,66,56,41,66,56,39,66,56,49,66,56,39,66,56,39,66,56,47,66,56
     !byte 39,66,56,41,66,56,49,66,56,41,66,56,41,66,56,49,66,56,41,66,56,41,66,56
     !byte 49,66,56,41,66,56,39,66,56,47,66,56,39,66,56,39,66,56,49,66,56,39,66,56
     !byte 51,66,56,47,66,56,44,66,56,49,66,56,53,66,56,56,66,56,51,66,56,47,66,56
     !byte 46,66,56,49,66,56,53,66,56,54,66,56,51,66,56,47,66,56,44,66,56,49,66,56
     !byte 53,66,56,56,66,56,51,66,56,47,66,56,46,66,56,49,66,56,51,66,56,54,66,56
     !byte 39,66,56,49,66,56,49,66,56,41,66,56,49,66,56,49,66,56,39,66,56,47,66,56
     !byte 47,66,56,41,66,56,49,66,56,49,66,56,39,66,56,49,66,56,49,66,56,39,66,56
     !byte 47,66,56,47,66,56,39,66,56,47,66,56,47,66,56,39,66,56,49,66,56,49,66,56
     !byte 42,66,56,53,66,56,42,66,56,42,66,56,51,66,56,42,66,56,42,66,56,53,66,56
     !byte 42,66,56,42,66,56,51,66,56,42,66,56,255

; entry points used only by the .sid files (set PAL/NTSC, then init)
sidpal  sta song
        lda #1
        sta $02a6
        jmp init
sidntsc sta song
        lda #0
        sta $02a6
        jmp init
