FNAME "v9990_p1_test.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/V9990.s"


Execute:

    call    V9.Mode_P1



    ; ------- set scroll control registers (R#17 to R#24)
    ld      a, 17           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 18           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 19           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 20           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 21           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 22           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 23           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ld      a, 24           ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister



    call    V9.ClearVRAM



    ; ------- set tile patterns layer A
    ; ld		hl, Tile_0        				        ; RAM address (source)
    ; ld		a, V9.P1_PATTBL_LAYER_A >> 16	        ; VRAM address bits 18-16 (destiny)
    ; ld		de, V9.P1_PATTBL_LAYER_A AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ; ld		bc, Tile_0.size					        ; Block length
    ; call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

    ld		hl, Tile_Empty        				            ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_A >> 16	                ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_A AND 0xffff             ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern

    ld		hl, Tile_0        				                ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_A + 4) >> 16         ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_A + 4) AND 0xffff   ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern

    ld		hl, Tile_1        				                ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_A + 8) >> 16         ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_A + 8) AND 0xffff   ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern



    ; ------- set tile patterns layer B

    ld		hl, Tile_Empty        				        ; RAM address (source)
    ld		a, V9.P1_PATTBL_LAYER_B >> 16	            ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_PATTBL_LAYER_B AND 0xffff         ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern

    ld		hl, Tile_0        				                ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_B + 4) >> 16         ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_B + 4) AND 0xffff   ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern

    ld		hl, Tile_1        				                ; RAM address (source)
    ld		a, 0 + (V9.P1_PATTBL_LAYER_B + 8) >> 16         ; VRAM address bits 18-16 (destiny)
    ld		de, 0 + (V9.P1_PATTBL_LAYER_B + 8) AND 0xffff   ; VRAM address bits 15-0 (destiny)
    call 	V9.SetTilePattern


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



    ; ------- set palette control register (R#13)
    
    ; Background colors are specified by Pattern data plus a palette offset in R#13.
    ; P1 layer "A" and P2 pattern pixels 0,1,4,5 use offset specified in R#13 PLTO3-2.
    ; P1 layer "B" and P2 pattern pixels 2,3,6,7 use offset specified in R#13 PLTO5-4.

    ; set PLTM to 00 on R#13 (bits 7-6)
    ; set YAE to 0 on R#13 (bit 5)
    ; set PLTAIH to 0 on R#13 (bit 4)
    ; set PLTO2-5 to 0 on R#13 (bits 0-3)
    ld      a, 13           ; register number
    ld      b, 0000 01 00 b  ; value
    call    V9.SetRegister


    ; --------- set palette #0

    ; set 0000 1110 b to P#4
    ld      a, 0000 1110 b
    out     (V9.PORT_4), a

    ; set palette number (6 higher bits) to P#3; 2 lower bits to 00
    ld      a, 0000 0000 b
    out     (V9.PORT_3), a

    ; set RED value (5 bits, 0-31 value) to P#1
    ; set GREEN value (5 bits, 0-31 value) to P#1
    ; set BLUE value (5 bits, 0-31 value) to P#1
    ld      hl, Palette_test_0
    ld      c, V9.PORT_1
    ld      b, 16 * 3   ; number of colors * 3
    otir



    ; --------- set palette #1

    ; set 0000 1110 b to P#4
    ld      a, 0000 1110 b
    out     (V9.PORT_4), a

    ; set palette number (6 higher bits) to P#3; 2 lower bits to 00
    ld      a, 0100 0000 b
    out     (V9.PORT_3), a

    ; set RED value (5 bits, 0-31 value) to P#1
    ; set GREEN value (5 bits, 0-31 value) to P#1
    ; set BLUE value (5 bits, 0-31 value) to P#1
    ld      hl, Palette_test_1
    ld      c, V9.PORT_1
    ld      b, 16 * 3   ; number of colors * 3
    otir

    
    ; --------
    jp      $   ; eternal loop


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


NamesTable_test:
    dw  0x0000, 0x0001, 0, 2, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1
    dw  0x0001, 0x0000, 0, 2, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1
.size:      equ $ - NamesTable_test

NamesTable_B_test:
    dw  1, 1, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    dw  1, 1, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    dw  1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.size:      equ $ - NamesTable_B_test

Palette_test_0:
    ;   R   G   B   (5 bits, 0-31 value)
    db  0,   0,  0
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
    ;   R   G   B   (5 bits, 0-31 value)
    db  0,  0,  0
    db  2,  2,  2
    db  4,  4,  4
    db  6,  6,  6

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


; -------------------------
	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF
