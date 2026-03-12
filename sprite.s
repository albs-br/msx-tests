FNAME "sprite.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 5
NAMTBL:     equ 0x0000  ; to 0x???? (??? bytes)
SPRPAT:     equ 0x7800  ; to 0x7fff (2048 bytes)
SPRCOL:     equ 0x7400  ; to 0x75ff (512 bytes)
SPRATR:     equ 0x7600  ; to 0x767f (128 bytes)

Execute:

    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    SetSpritesMagnified

    call    Set192Lines

    call    SetColor0ToTransparent




    ld      hl, Palette
    call    LoadPalette

    ; -------------------------------------------------------
    ; Load sprite patterns

    ld      a, 0x00
    ld      hl, SPRPAT
    call    SetVdp_Write
    ld      b, SpritePatterns.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePatterns
    otir


    ; -------------------------------------------------------
    ; Load sprite colors table

    ld      a, 0x00
    ld      hl, SPRCOL
    call    SetVdp_Write
    ld      b, SpriteColors.size
    ld      c, PORT_0
    ld      hl, SpriteColors
    otir

    ; -------------------------------------------------------
    ; Load sprite atributes table

    ld      a, 0x00
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      b, SpriteAttributes.size
    ld      c, PORT_0
    ld      hl, SpriteAttributes
    otir

    ; -------------------------------------------------------

    call    BIOS_ENASCR

    call    BIOS_BEEP


    jp $ ; endless loop


; -------------- Data

SpritePatterns:
 ; Pattern 0
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000001 b
	db	00000111 b
	db	00001011 b
	db	00001110 b
	db	00001111 b
	db	00011110 b
	db	00011100 b
	db	00100111 b
	db	00111100 b
	db	00111100 b
	db	01111100 b
	db	01111000 b
	db	01111000 b
	db	11111000 b
	db	11111000 b
	db	11111111 b
 ; Pattern 1
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000000 b
	db	00000100 b
	db	00000001 b
	db	00000000 b
	db	00000001 b
	db	00000011 b
	db	00011000 b
	db	00000011 b
	db	00000011 b
	db	00000011 b
	db	00000111 b
	db	00000111 b
	db	00000111 b
	db	00000111 b
	db	00000000 b
SpritePatterns.size: equ $ - SpritePatterns

SpriteColors:
 ; Color 0
	db	2
	db	1
	db	1
	db	1
	db	1
	db	1
	db	1
	db	2
	db	1
	db	1
	db	1
	db	1
	db	1
	db	1
	db	1
	db	1
 ; Color 1
	db	2
	db	1
	db	2
	db	2
	db	1
	db	2
	db	2
	db	3
	db	2
	db	2
	db	2
	db	2
	db	2
	db	2
	db	2
	db	1
SpriteColors.size: equ $ - SpriteColors


SpriteAttributes:
    ;   y       x       pattern     unused
    db  192/2,  256/2,  0,          0
    db  192/2,  256/2,  4,          0
    db  216 ; hide all sprites from here
SpriteAttributes.size: equ $ - SpriteAttributes


Palette:
    INCBIN "sprite.pal"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF
