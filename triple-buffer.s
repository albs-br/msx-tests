FNAME "triple-buffer.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:
    call    EnableRomPage2

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a

    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    Set212Lines

    call    SetColor0ToNonTransparent

    call    DisableSprites


    
    ; load 32-byte palette data
    ld      hl, Palette
    call    LoadPalette

   
    ; --- Write to VRAM bitmap area

    ; SC 5 - page 0
    ld      a, 0000 0000 b
    ld      hl, 0x0000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 1
    ld      a, 0000 0000 b
    ld      hl, 0x8000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 2
    ld      a, 0000 0001 b
    ld      hl, 0x0000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 3
    ld      a, 0000 0001 b
    ld      hl, 0x8000
    call    LoadImageTo_SC5_Page



    call    BIOS_ENASCR


    ; ------------- Copy player 1 sprite to page 0

    ; init vars
    ld      hl, 0
    ld      (Last_NAMTBL_Addr), hl

    ld      hl, List
    
.loop:


    ld      a, (hl)     ; C = increment
    or      a
    jp      z, .endFrame ; if (increment == 0) endFrame
    ld      c, a

    inc     hl
    ld      a, (hl)     ; A = length

    inc     hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)     ; DE = slice data address

    inc     hl
    push    hl
        ; --- set VRAM addr

        ; HL = (Last_NAMTBL_Addr) + increment
        ld      hl, (Last_NAMTBL_Addr)
        ld      b, 0
        add     hl, bc
        ld      (Last_NAMTBL_Addr), hl

        ld      b, a

        ; set R#14 to 0
        ; set remaining bits of VRAM addr to HL
        xor     a
        di
            ; write bits a14-16 of address to R#14
            out     (PORT_1), a ; data
            ld      a, 14 + 128
            out     (PORT_1), a ; register #

            ; write the other address bits to VDP PORT_1
            ld      a, l
            nop
            out     (PORT_1), a ; addr low
            ld      a, h
            or      64
        ei
        out     (PORT_1),a ; addr high


        ; HL = Data + slice addr
        ld      hl, Data
        add     hl, de

        ld      c, PORT_0
        otir
    pop     hl
    jp      .loop

    ; ---

.endFrame:


    ld      hl, Restore_BG_HMMM_Parameters
    call    Execute_VDP_HMMM	    ; High speed move VRAM to VRAM


    jp      $ ;.loop ; endless loop

; ----------

; Input:
;   AHL: 17-bit VRAM address
LoadImageTo_SC5_Page:
	; enable page 1
    push    af
        ld	    a, 1
        ld	    (Seg_P8000_SW), a
    pop     af

    ; first 16kb (top 128 lines)
    push    af, hl
        call    SetVdp_Write
        ld      hl, Bg_Top
        ld      c, PORT_0
        ld      d, 0 + (Bg_Top.size / 256)
        ld      b, 0 ; 256 bytes
    .loop_10:    
        otir
        dec     d
        jp      nz, .loop_10
    pop     hl, af

	; enable page 2
    push    af
        ld	    a, 2
        ld	    (Seg_P8000_SW), a
    pop     af

    ; lines below 128
    ld      bc, 16 * 1024
    add     hl, bc

    call    SetVdp_Write
    ld      hl, Bg_Bottom
    ld      c, PORT_0
    ld      d, 0 + (Bg_Bottom.size / 256)
    ld      b, 0 ; 256 bytes
.loop_20:    
    otir
    dec     d
    jp      nz, .loop_20


    ret



Palette:
    INCBIN "Images/mk.pal"

; --- Slice index list
; increment in bytes, length in bytes, address of the slice on the Data
List:
	db	782-(256*3),	4	dw	0
	db	127,	5	dw	4
	db	128,	5	dw	9
	db	128,	5	dw	14
	db	127,	7	dw	19
	db	128,	7	dw	26
	db	128,	7	dw	33
	db	123,	3	dw	40
	db	5,	7	dw	43
	db	122,	4	dw	50
	db	6,	7	dw	54
	db	122,	4	dw	61
	db	6,	7	dw	65
	db	121,	5	dw	72
	db	7,	7	dw	77
	db	120,	6	dw	84
	db	8,	7	dw	90
	db	120,	6	dw	97
	db	7,	8	dw	103
	db	120,	16	dw	111
	db	128,	16	dw	127
	db	128,	17	dw	143
	db	127,	21	dw	160
	db	128,	21	dw	181
	db	128,	21	dw	202
	db	128,	21	dw	223
	db	128,	21	dw	244
	db	128,	21	dw	265
	db	129,	19	dw	286
	db	133,	14	dw	305
	db	128,	14	dw	319
	db	128,	14	dw	333
	db	128,	14	dw	347
	db	129,	13	dw	361
	db	128,	14	dw	374
	db	128,	14	dw	388
	db	128,	14	dw	402
	db	129,	13	dw	416
	db	128,	13	dw	429
	db	128,	14	dw	442
	db	128,	14	dw	456
	db	128,	15	dw	470
	db	128,	10	dw	485
	db	11,	4	dw	495
	db	117,	9	dw	499
	db	11,	4	dw	508
	db	117,	9	dw	512
	db	11,	4	dw	521
	db	117,	9	dw	525
	db	12,	4	dw	534
	db	116,	9	dw	538
	db	12,	4	dw	547
	db	116,	9	dw	551
	db	12,	4	dw	560
	db	116,	10	dw	564
	db	13,	3	dw	574
	db	115,	10	dw	577
	db	13,	3	dw	587
	db	115,	10	dw	590
	db	13,	3	dw	600
	db	115,	10	dw	603
	db	14,	2	dw	613
	db	113,	12	dw	615
	db	14,	3	dw	627
	db	114,	12	dw	630
	db	14,	4	dw	642
	db	114,	12	dw	646
	db	14,	4	dw	658
	db	114,	12	dw	662
	db	14,	4	dw	674
	db	114,	12	dw	678
	db	14,	4	dw	690
	db	114,	12	dw	694
	db	15,	2	dw	706
	db	113,	12	dw	708
	db	127,	14	dw	720
	db	128,	14	dw	734
	db	128,	14	dw	748
	db	128,	14	dw	762
	db	128,	14	dw	776
	db	128,	15	dw	790
	db	128,	15	dw	805
	db	128,	15	dw	820
	db	128,	15	dw	835
	db	128,	15	dw	850
	db	128,	15	dw	865
	db	128,	15	dw	880
	db	128,	16	dw	895
	db	127,	7	dw	911
	db	9,	8	dw	918
	db	119,	7	dw	926
	db	10,	7	dw	933
	db	118,	7	dw	940
	db	10,	7	dw	947
	db	118,	7	dw	954
	db	10,	7	dw	961
	db	118,	6	dw	968
	db	10,	7	dw	974
	db	118,	6	dw	981
	db	11,	6	dw	987
	db	117,	6	dw	993
	db	11,	6	dw	999
	db	117,	6	dw	1005
	db	11,	6	dw	1011
	db	117,	6	dw	1017
	db	12,	5	dw	1023
	db	116,	5	dw	1028
	db	12,	5	dw	1033
	db	116,	5	dw	1038
	db	12,	5	dw	1043
	db	116,	5	dw	1048
	db	12,	5	dw	1053
	db	116,	5	dw	1058
	db	13,	4	dw	1063
	db	115,	5	dw	1067
	db	13,	4	dw	1072
	db	115,	5	dw	1076
	db	13,	4	dw	1081
	db	115,	4	dw	1085
	db	13,	4	dw	1089
	db	115,	4	dw	1093
	db	13,	4	dw	1097
	db	115,	4	dw	1101
	db	13,	4	dw	1105
	db	116,	3	dw	1109
	db	13,	3	dw	1112
	db	115,	3	dw	1115
	db	13,	3	dw	1118
	db	115,	3	dw	1121
	db	13,	3	dw	1124
	db	115,	3	dw	1127
	db	13,	3	dw	1130
	db	115,	3	dw	1133
	db	13,	3	dw	1136
	db	115,	3	dw	1139
	db	13,	3	dw	1142
	db	115,	3	dw	1145
	db	13,	4	dw	1148
	db	114,	4	dw	1152
	db	14,	5	dw	1156
	db	113,	5	dw	1161
	db	15,	5	dw	1166
	db	113,	5	dw	1171
	db	15,	5	dw	1176
	db	113,	4	dw	1181
	db	16,	4	dw	1185
	db	112,	4	dw	1189
	db	16,	4	dw	1193
	db	112,	3	dw	1197
	db	17,	3	dw	1200
    db  0 ; end of frame

; --- Slice data
Data:
	db	0,	3,	51,	3
	db	48,	0,	51,	51,	51
	db	1,	19,	51,	51,	51
	db	17,	19,	51,	51,	51
	db	48,	17,	3,	51,	51,	51,	3
	db	49,	17,	51,	51,	51,	51,	3
	db	49,	16,	51,	51,	51,	206,	3
	db	1,	16,	3
	db	49,	16,	51,	51,	60,	203,	195
	db	49,	17,	192,	204
	db	48,	16,	51,	60,	204,	235,	67
	db	3,	0,	14,	187
	db	48,	16,	51,	52,	187,	187,	195
	db	48,	51,	51,	203,	187
	db	1,	0,	48,	51,	239,	251,	195
	db	48,	3,	51,	51,	59,	187
	db	1,	1,	3,	51,	204,	207,	195
	db	177,	3,	51,	51,	52,	236
	db	48,	1,	1,	3,	60,	204,	207,	195
	db	59,	187,	3,	51,	51,	60,	204,	251,	179,	49,	0,	3,	60,	204,	207,	195
	db	187,	187,	176,	48,	207,	187,	187,	187,	0,	49,	3,	51,	60,	207,	252,	195
	db	187,	187,	195,	203,	187,	187,	191,	195,	3,	51,	3,	51,	12,	251,	255,	188,	19
	db	62,	187,	176,	12,	48,	204,	204,	204,	204,	51,	51,	51,	51,	63,	191,	187,	251,	187,	177,	28,	3
	db	59,	187,	179,	0,	3,	204,	204,	204,	204,	252,	195,	51,	51,	60,	207,	255,	187,	187,	187,	255,	192
	db	59,	187,	192,	204,	0,	204,	204,	204,	204,	251,	195,	51,	51,	51,	60,	187,	187,	187,	187,	187,	252
	db	59,	187,	12,	196,	3,	60,	207,	204,	204,	207,	240,	51,	51,	51,	60,	251,	187,	187,	187,	191,	204
	db	59,	187,	4,	204,	51,	60,	207,	204,	204,	207,	252,	51,	51,	51,	60,	187,	187,	187,	187,	191,	195
	db	60,	228,	76,	64,	51,	3,	207,	252,	204,	207,	252,	51,	51,	51,	60,	251,	187,	187,	187,	252,	195
	db	206,	236,	204,	48,	48,	207,	252,	204,	204,	252,	51,	51,	51,	60,	187,	187,	187,	187,	188
	db	204,	255,	204,	204,	252,	51,	51,	51,	59,	187,	187,	187,	187,	252
	db	60,	251,	252,	204,	207,	3,	51,	51,	11,	187,	187,	187,	191,	176
	db	60,	207,	191,	204,	207,	51,	51,	51,	203,	187,	187,	191,	251,	179
	db	48,	203,	251,	252,	207,	195,	51,	51,	203,	187,	187,	251,	187,	177
	db	207,	191,	191,	207,	195,	51,	51,	203,	255,	187,	191,	251,	180
	db	11,	251,	251,	252,	243,	51,	51,	203,	191,	251,	187,	187,	187,	3
	db	63,	255,	191,	255,	243,	51,	51,	203,	252,	255,	191,	75,	187,	195
	db	60,	251,	251,	191,	240,	51,	51,	251,	188,	207,	252,	12,	187,	179
	db	207,	187,	251,	252,	51,	51,	251,	255,	204,	195,	60,	187,	180
	db	203,	251,	187,	187,	51,	51,	255,	187,	207,	51,	3,	238,	187
	db	12,	187,	187,	187,	195,	60,	251,	187,	188,	51,	64,	76,	187,	3
	db	48,	251,	187,	187,	195,	60,	187,	187,	240,	51,	51,	12,	190,	0
	db	51,	191,	187,	255,	195,	60,	251,	191,	179,	51,	48,	51,	227,	48,	3
	db	48,	203,	191,	252,	195,	59,	255,	187,	195,	3
	db	3,	67,	51,	3
	db	51,	60,	204,	204,	195,	15,	187,	255,	3
	db	51,	3,	51,	48
	db	51,	48,	204,	204,	195,	59,	191,	188,	48
	db	51,	51,	51,	51
	db	48,	207,	204,	204,	195,	207,	251,	252,	204
	db	51,	51,	51,	3
	db	48,	27,	252,	204,	204,	204,	252,	187,	192
	db	51,	51,	51,	3
	db	48,	15,	255,	252,	207,	191,	251,	191,	195
	db	48,	51,	51,	3
	db	51,	48,	204,	204,	251,	251,	191,	188,	51,	51
	db	51,	51,	3
	db	3,	51,	51,	204,	204,	204,	204,	51,	51,	3
	db	3,	51,	51
	db	51,	51,	51,	204,	203,	251,	191,	3,	51,	51
	db	48,	51,	48
	db	51,	51,	51,	204,	255,	191,	251,	195,	51,	51
	db	51,	48
	db	51,	51,	51,	51,	204,	251,	251,	191,	195,	51,	51,	3
	db	60,	51,	192
	db	51,	51,	51,	51,	204,	255,	191,	251,	195,	51,	51,	51
	db	204,	62,	195,	3
	db	3,	51,	51,	51,	204,	251,	251,	191,	195,	51,	51,	51
	db	30,	11,	188,	3
	db	3,	51,	51,	51,	204,	255,	191,	251,	195,	51,	51,	48
	db	12,	203,	188,	195
	db	51,	51,	51,	51,	204,	251,	251,	191,	243,	51,	51,	51
	db	60,	203,	188,	67
	db	51,	51,	51,	51,	204,	255,	191,	251,	243,	51,	51,	51
	db	76,	4
	db	51,	51,	51,	51,	204,	251,	251,	191,	243,	51,	51,	51
	db	51,	51,	51,	51,	51,	204,	255,	191,	251,	243,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	204,	251,	251,	191,	243,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	204,	255,	191,	251,	243,	51,	51,	51,	48
	db	51,	51,	51,	51,	51,	204,	251,	251,	191,	243,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	204,	255,	191,	251,	243,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	204,	251,	251,	191,	243,	51,	51,	51,	51,	3
	db	51,	51,	51,	51,	51,	204,	255,	191,	251,	243,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	204,	251,	251,	191,	179,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	204,	255,	191,	251,	243,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	204,	255,	251,	191,	179,	51,	51,	51,	51,	48
	db	51,	51,	51,	51,	51,	204,	207,	255,	255,	243,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	12,	204,	204,	204,	195,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51,	0,	204,	192,	51,	51,	51,	51,	51,	51,	51
	db	48,	51,	51,	51,	51,	51,	48
	db	48,	51,	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51,	51
	db	3,	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	48
	db	51,	51,	51,	51,	51,	48
	db	51,	51,	51,	51,	51,	48
	db	51,	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	51,	48
	db	51,	51,	51,	51,	51,	3
	db	51,	51,	51,	51,	48
	db	51,	51,	51,	51,	51
	db	51,	51,	51,	51,	48
	db	51,	51,	51,	51,	48
	db	51,	51,	51,	48,	204
	db	51,	51,	51,	51,	48
	db	48,	51,	51,	60,	204
	db	51,	51,	51,	51,	51
	db	51,	51,	12,	204
	db	51,	51,	51,	51,	3
	db	51,	51,	12,	204
	db	48,	48,	204,	192,	51
	db	51,	48,	12,	204
	db	51,	48,	12,	204
	db	51,	51,	12,	204
	db	48,	0,	12,	204
	db	51,	51,	12,	204
	db	48,	51,	12,	204
	db	51,	51,	12,	204
	db	3,	12,	204
	db	51,	12,	204
	db	48,	12,	204
	db	51,	204,	204
	db	3,	12,	204
	db	48,	204,	192
	db	0,	48,	204
	db	48,	204,	192
	db	51,	0,	204
	db	48,	204,	48
	db	0,	48,	204
	db	51,	3,	51
	db	51,	51,	48
	db	51,	51,	51,	51
	db	3,	51,	51,	48
	db	51,	51,	51,	51,	3
	db	48,	51,	51,	51,	51
	db	51,	51,	51,	51,	48
	db	51,	51,	51,	51,	3
	db	51,	51,	51,	51,	51
	db	51,	51,	51,	48
	db	3,	51,	51,	51
	db	51,	51,	51,	51
	db	48,	51,	51,	51
	db	0,	51,	51
	db	48,	51,	48

    db 0 ; end of frame

Restore_BG_HMMM_Parameters:
.Source_X:   dw    0 	            ; Source X (9 bits)
.Source_Y:   dw    0 + (256*3) 	    ; Source Y (10 bits)
.Destiny_X:  dw    0 	    ; Destiny X (9 bits)
.Destiny_Y:  dw    0 	    ; Destiny Y (10 bits)
.Cols:       dw    32       ; number of cols (9 bits)
.Lines:      dw    64       ; number of lines (10 bits)
.NotUsed:    db    0
.Options:    db    0        ; select destination memory and direction from base coordinate
.Command:    db    VDP_COMMAND_HMMM
Restore_BG_HMMM_Parameters_size: equ $ - Restore_BG_HMMM_Parameters



    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF








; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
Bg_Top:
    INCBIN "Images/mk-bg-top.sc5"
.size:      equ $ - Bg_Top
	ds PageSize - ($ - 0x8000), 255

; ------- Page 2
	org	0x8000, 0xBFFF
Bg_Bottom:
    INCBIN "Images/mk-bg-bottom.sc5"
.size:      equ $ - Bg_Bottom
	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

Last_NAMTBL_Addr:   rw 1


; ----------------------------
; Player_1:
; .Restore_BG_X:              rb 1
; .Restore_BG_Y:              rb 1
; .Restore_BG_WidthInPixels:  rb 1
; .Restore_BG_HeightInPixels:  rb 1

; ;frame data
; ;.frame_data_slices:     rb (Frame_Data_Slice.size) * 256



; ; ----------------------------

; ; for each slice:
; Frame_Data_Slice:
; .offset:    rb 1 ; offset in bytes from top left of frame/last slice start
; .length:    rb 1 ; length in bytes (can be changed to pointer to unrolled OUTI's)
; .address:   rw 1 ; address of bytes to be plotted to screen

; .size: $ - Frame_Data_Slice