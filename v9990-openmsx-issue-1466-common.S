

    ld      a, 0    ; palette number for layer A (0-3)
    ld      b, 1    ; palette number for layer B (0-3)
    call    V9.SetPaletteControlRegister

    ld      a, 0
    call    V9.SetSpriteGeneratorBaseAddrRegister

    ; ------- set names table layer A
    ld		hl, NamesTable_A_test				        ; RAM address (source)
    ld		a, V9.P1_NAMTBL_LAYER_A >> 16	        ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_NAMTBL_LAYER_A AND 0xffff     ; VRAM address bits 15-0 (destiny)
    ld		bc, NamesTable_A_test.size		        ; Block length
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



    ld      a, 0
    ld      hl, Palette_layer_A
    call    V9.LoadPalette

    ld      a, 1
    ld      hl, Palette_layer_B
    call    V9.LoadPalette

    ld      a, 2
    ld      hl, Palette_sprites
    call    V9.LoadPalette





    ; load sprite patterns

    ; load SPRATR table
    ld		hl, SPRATR_Table_Test				    ; RAM address (source)
    ld		a, V9.P1_SPRATR >> 16	                ; VRAM address bits 18-16 (destiny)
    ld		de, V9.P1_SPRATR AND 0xffff             ; VRAM address bits 15-0 (destiny)
    ld		bc, SPRATR_Table_Test.size		        ; Block length
    call 	V9.LDIRVM        					    ; Block transfer to VRAM from memory

    
    ; --------

    call    V9.EnableScreen



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
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
.size:      equ $ - Tile_0

; ----------------

NamesTable_A_test:
    dw  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    dw  0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
    dw  1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
.size:      equ $ - NamesTable_A_test

NamesTable_B_test:
    dw  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    dw  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    dw  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    dw  1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0
.size:      equ $ - NamesTable_B_test

; ----------------

Palette_layer_A:
    ;    R   G   B   (5 bits, 0-31 value)
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0, 31,  0

Palette_layer_B:
    ;    R   G   B   (5 bits, 0-31 value)
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0, 31

Palette_sprites:
    ;    R   G   B   (5 bits, 0-31 value)
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0

    db   0,  0,  0
    db   0,  0,  0
    db   0,  0,  0
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
    db  106,   0, 128, 10 0 0 0 0 00 b
.size:  equ $ - SPRATR_Table_Test
