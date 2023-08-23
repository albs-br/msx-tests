FNAME "v9990_p1_test.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/V9990.s"


Execute:

    ;  debug
    ld      hl, STR_PROG_START
    call    PrintString


    call    V9.Mode_P1

    call    V9.DisableScreen


    ; ; WARNING: NOT FINISHED
    ; ld      hl, 0   ; X scroll value (11 bits)
    ; ld      de, 0   ; Y scroll value (13 bits)
    ; call    V9.SetScroll_Layer_A

    ; ; WARNING: NOT FINISHED
    ; ld      hl, 0   ; X scroll value (9 bits)
    ; ld      de, 0   ; Y scroll value (9 bits)
    ; call    V9.SetScroll_Layer_B



    ; Clear VRAM is crashing openmsx (but not webmsx)
    ;  debug 
    ld      hl, STR_CLR_VRAM
    call    PrintString

    call    V9.ClearVRAM



    ;  debug
    ld      hl, STR_SET_PAL_CTRL_REG
    call    PrintString

    ld      a, 0    ; palette number for layer A (0-3)
    ld      b, 1    ; palette number for layer B (0-3)
    call    V9.SetPaletteControlRegister



    ld      a, 0
    call    V9.SetSpriteGeneratorBaseAddrRegister




    ; ------- set names table layer A
    ld		hl, NamesTable_test				        ; RAM address (source)
    ld		a, V9.P1_NAMTBL_LAYER_A >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_NAMTBL_LAYER_A AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, NamesTable_test.size		        ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

    ; ------- set names table layer B
    ld		hl, NamesTable_B_test				    ; RAM address (source)
    ld		a, V9.P1_NAMTBL_LAYER_B >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_NAMTBL_LAYER_B AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, NamesTable_B_test.size		        ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory




    ; ------- set tile patterns layer A

    ; set tile pattern #0
    ld		hl, Tile_Empty        				            ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_A >> 16	                ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_A AND 0xffff             ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern

    ; set tile pattern #1
    ld		hl, Tile_0        				                ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_A + 4) >> 16         ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_A + 4) AND 0xffff   ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern

    ; set tile pattern #32
    ld		hl, Tile_1        				                      ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_A + 0x00400) >> 16         ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_A + 0x00400) AND 0xffff   ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern



    ; ------- set tile patterns layer B

    ; set tile pattern #0
    ld		hl, Tile_Empty        				        ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_B >> 16	            ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_B AND 0xffff         ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern

    ; set tile pattern #1
    ld		hl, Tile_0        				                ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_B + 4) >> 16         ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_B + 4) AND 0xffff   ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern

    ; set tile pattern #32
    ld		hl, Tile_1        				                      ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_B + 0x00400) >> 16         ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_B + 0x00400) AND 0xffff   ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern





    ld      a, 0
    ld      hl, Palette_test_0
    call    V9.LoadPalette

    ld      a, 1
    ld      hl, Palette_test_1
    call    V9.LoadPalette

    ld      a, 2
    ld      hl, Palette_test_2
    call    V9.LoadPalette

    ld      a, 3
    ld      hl, Palette_test_3
    call    V9.LoadPalette



    ; set R#25 SPRITE GENERATOR BASE ADDRESS (READ/WRITE)
    ; Sprite pattern: Selected from among 256 patterns
    ; The pattern data is shared with the pattern layer (the base address should be set in register R#25.)
    ; SGBA17-15: bits 3-1
    ld      a, 25           ; register number
    ;ld     b, 0000 sss0 b  ; value
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ; load sprite patterns

    ; load SPRATR table
    ld		hl, SPRATR_Table_Test				    ; RAM address (source)
    ld		a, V9.P1_SPRATR >> 16	                ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_SPRATR AND 0xffff             ; VRAM address bits 15-0 (destiny)
    ld		bc, SPRATR_Table_Test.size		        ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

    
    ; --------

    call    V9.EnableScreen

    ; debug
    ld      hl, STR_PROG_END
    call    PrintString


    jp      $   ; eternal loop



; debug
PrintString:
    ld      a, (hl)
    or      a
    ret     z
    call    BIOS_CHPUT
    inc     hl
    jp      PrintString

STR_PROG_START:         db 'PROG_START', 13, 10, 0
STR_CLR_VRAM:           db 'CLR_VRAM', 13, 10, 0
STR_SET_PAL_CTRL_REG:   db 'SET_PAL_CTRL_REG', 13, 10, 0
STR_PROG_END:           db 'PROG_END', 13, 10, 0

; -------------------------------------------------------------

; To write a value in VRAM, set the target address to VRAM Write Base Address registers (R#0-R#2) 
; and have the data output at VRAM DATA port (P#0). As the bit 7 (MSB) of R#2 functions as
; AII (Address Increment Inhibit), if it is "1", automatic address increment by writing the data is inhibited.

; To read the data of VRAM, set the target address to VRAM Read Base Address registers (R#3-R#5) and read 
; in the data of VRAM DATA port (P#0). As the bit 7 (MSB) of R#5 functions as AII (Address Increment Inhibit), 
; if it is "1", automatic address increment by reading in the data is inhibited.

; The address can be specified up to 19 bits (512K bytes), with lower 8 bits set to R#0 (or R#3), center 8 
; bits to R#1 (or R#4) and upper 3 bits to R#2 (or R#5).

; Note: Always the full address must be written. Specifying partial addresses will not work correctly.

; ----- Write to VRAM:
; set P#4 to 0000 0000 b
; set P#3 to VRAM lower addr (bits 0-7)
; set P#3 to VRAM center addr (bits 8-15)
; set P#3 to VRAM upper addr (bits 16-18) --> warning: higher bit here is AII (explained above)
; set P#0 to value to be written
; if AII is 0, write next bytes to sequentially P#0



; -----------------------------------------------------------------
; VRAM data

; ----------------

; 8x8 x 4bpp tiles

Tile_Empty:
    db  0x00, 0x00, 0x00, 0x00
    db  0x00, 0x00, 0x00, 0x00
    db  0x00, 0x00, 0x00, 0x00
    db  0x00, 0x00, 0x00, 0x00
    db  0x00, 0x00, 0x00, 0x00
    db  0x00, 0x00, 0x00, 0x00
    db  0x00, 0x00, 0x00, 0x00
    db  0x00, 0x00, 0x00, 0x00
.size:      equ $ - Tile_Empty

Tile_0:
    db  0x1f, 0xff, 0xff, 0xff
    db  0x20, 0x00, 0x00, 0xff
    db  0x30, 0x00, 0x0f, 0x0f
    db  0x40, 0x00, 0xf0, 0x0f
    db  0x50, 0x0f, 0x00, 0x0f
    db  0x60, 0xf0, 0x00, 0x0f
    db  0x7f, 0x00, 0x00, 0x0f
    db  0x8f, 0xff, 0xff, 0xff
.size:      equ $ - Tile_0

Tile_1:
    db  0x00, 0x11, 0x22, 0x33
    db  0x00, 0x11, 0x22, 0x33
    db  0x44, 0x55, 0x66, 0x77
    db  0x44, 0x55, 0x66, 0x77
    db  0x88, 0x99, 0xaa, 0xbb
    db  0x88, 0x99, 0xaa, 0xbb
    db  0xcc, 0xdd, 0xee, 0xff
    db  0xcc, 0xdd, 0xee, 0xff
.size:      equ $ - Tile_Empty

; ----------------

NamesTable_test:
    dw  0, 1, 0,32, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1
    dw  1, 0, 0,32, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1
.size:      equ $ - NamesTable_test

NamesTable_B_test:
    ; dw  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ; dw  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ; dw  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    dw  1, 1, 1, 0,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    dw  1, 1,32, 0,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    dw  1,32,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.size:      equ $ - NamesTable_B_test

; ----------------

Palette_test_0:
    ;    R   G   B   (5 bits, 0-31 value)
    db   0,  0,  0
    db  15,  0,  0
    db  15, 31, 31
    db  15,  0, 31

    db   0,  0, 15
    db  31,  0,  0
    db   0, 31,  0
    db   0,  0, 31

    db  31, 15, 15
    db  15, 31, 15
    db  15, 15, 31
    db  15,  0,  0

    db   0, 15,  0
    db   0,  0, 15
    ; db   0,  7,  0
    ; db   0,  0,  7
    db  6, 5, 4
    db  31, 31, 31

Palette_test_1:
    ;    R   G   B   (5 bits, 0-31 value)
    db   0,  0,  0
    db   2,  2,  2
    db   4,  4,  4
    db   6,  6,  6

    db   8,  8,  8
    db  10, 10, 10
    db  12, 12, 12
    db  14, 14, 14

    db  16, 16, 16
    db  18, 18, 18
    db  20, 20, 20
    db  22, 22, 22

    db  24, 24, 24
    db  26, 26, 26
    db  28, 28, 28
    db  31, 31, 31

Palette_test_2:
    ;    R   G   B   (5 bits, 0-31 value)
    db   0,  0,  0
    db   2,  2,  0
    db   4,  4,  0
    db   6,  6,  0

    db   8,  8,  0
    db  10, 10,  0
    db  12, 12,  0
    db  14, 14,  0

    db  16, 16,  0
    db  18, 18,  0
    db  20, 20,  0
    db  22, 22,  0

    db  24, 24,  0
    db  26, 26,  0
    db  28, 28,  0
    db  31, 31,  0

Palette_test_3:
    ;    R   G   B   (5 bits, 0-31 value)
    db   0,  0,  0
    db   2,  0,  0
    db   4,  0,  0
    db   6,  0,  0

    db   8,  0,  0
    db  10,  0,  0
    db  12,  0,  0
    db  14,  0,  0

    db  16,  0,  0
    db  18,  0,  0
    db  20,  0,  0
    db  22,  0,  0

    db  24,  0,  0
    db  26,  0,  0
    db  28,  0,  0
    db  31,  0,  0

; ----------------

SPRATR_Table_Test:
    ;     +--- Sprite Y-coordinate (Actual display position is one line below specified)
    ;     |    +--- Sprite Pattern Number (Pattern Offset is specified in R#25 SGBA)
    ;     |    |    +--- X (bit 7-0)
    ;     |    |    |  +-------------- Palette offset for sprite colors.
    ;     |    |    |  |  +----------- Sprite is in front of the front layer when P=0, sprite is behind the front layer when P=1.
    ;     |    |    |  |  | +--------- Sprite is disabled when D=1
    ;     |    |    |  |  | |     +--- X (bit 9-8)
    ;     |    |    |  |  | |     |
    ;     Y, PAT,   X, nn p d - - X
    db  106,   0, 128, 00 0 0 0 0 00 b
    db  106,   0, 128 + 32, 01 0 0 0 0 00 b
    db  106 + 32,   0, 128, 10 0 0 0 0 00 b
    db  106 + 32,   0, 128 + 32, 11 0 0 0 0 00 b
.size:  equ $ - SPRATR_Table_Test

; ----------------

; sprite patterns (16x16 x 4bpp)
SpritePattern_Test_1:
    db  0x11, 0x11, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33
    db  0x22, 0x22, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33
    db  0x11, 0x11, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33
    db  0x22, 0x22, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33

    db  0x11, 0x11, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99
    db  0x22, 0x22, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99
    db  0x11, 0x11, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99
    db  0x22, 0x22, 0xee, 0xdd, 0xcc, 0xbb, 0xaa, 0x99

    db  0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f
    db  0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f
    db  0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f
    db  0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f

    db  0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f
    db  0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f
    db  0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f
    db  0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.size:  equ $ - SpritePattern_Test_1

; -------------------------
	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF
