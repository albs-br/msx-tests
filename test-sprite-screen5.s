FNAME "test-sprite-screen5.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:
    ; screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    Set192Lines

    call    SetColor0ToTransparent


NAMTBL:     equ 0x0000
SPRPAT:     equ 0x7800
SPRCOL:     equ 0x7400
SPRATR:     equ 0x7600





; --------- Load sprites

    ; Spr 0 pattern
    ld      a, 0000 0000 b
    ld      hl, SPRPAT
    call    SetVdp_Write
    ld      b, SpritePattern_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePattern_1
    otir

    ; Spr 0 color
    ld      a, 0000 0000 b
    ld      hl, SPRCOL
    call    SetVdp_Write
    ld      b, SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_1
    otir

    ; Atributes of all sprites
    ld      a, 0000 0000 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      b, SpriteAttributes.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes
    otir



    call    BIOS_ENASCR


.endlessLoop:
    jp      .endlessLoop


End:


SpritePattern_1:
    DB 00000111b
    DB 00011111b
    DB 00111111b
    DB 01111111b
    DB 01110011b
    DB 11110011b
    DB 11111111b
    DB 11111111b

    DB 11111111b
    DB 11111111b
    DB 11110111b
    DB 01111011b
    DB 01111100b
    DB 00111111b
    DB 00011111b
    DB 00000111b

    DB 11100000b
    DB 11111000b
    DB 11111100b
    DB 11111110b
    DB 11001110b
    DB 11001111b
    DB 11111111b
    DB 11111111b
    
    DB 11111111b
    DB 11111111b
    DB 11101111b
    DB 11011110b
    DB 00111110b
    DB 11111100b
    DB 11111000b
    DB 11100000b
.size:  equ $ - SpritePattern_1

; SpritePattern_2:
;     DB 00000111b
;     DB 00011000b
;     DB 00100000b
;     DB 01000000b
;     DB 01001100b
;     DB 10001100b
;     DB 10000000b
;     DB 10000000b

;     DB 11111111b
;     DB 11111111b
;     DB 11110111b
;     DB 01111011b
;     DB 01111100b
;     DB 00111111b
;     DB 00011111b
;     DB 00000111b

;     DB 11100000b
;     DB 11111000b
;     DB 11111100b
;     DB 11111110b
;     DB 11001110b
;     DB 11001111b
;     DB 11111111b
;     DB 11111111b
    
;     DB 11111111b
;     DB 11111111b
;     DB 11101111b
;     DB 11011110b
;     DB 00111110b
;     DB 11111100b
;     DB 11111000b
;     DB 11100000b
; .size:  equ $ - SpritePattern_2


SpriteColors_1:
    ;db 0x02, 0x0a, 0x03, 0x03, 0x08, 0x08, 0x03, 0x0a, 0x04, 0x07, 0x0a, 0x0a, 0x0a, 0x0a, 0x0f, 0x0f
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
    db  4
.size:  equ $ - SpriteColors_1

; SpriteColors_2:
;     ; Only the sprite on the lower layer should have the bit 6 set to enable the OR-color
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
;     db  0100 0000 b + 2
; .size:  equ $ - SpriteColors_2

SpriteAttributes:
    ;   Y, X, Pattern, Reserved
    ;db  220, 0, 0, 0
    db  10, 10, 0, 0
    db  10, 128, 0, 0 ; sprite not showing
.size:  equ $ - SpriteAttributes


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF
