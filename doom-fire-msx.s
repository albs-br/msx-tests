FNAME "doom-fire-msx.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0x7fff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    ; Common
    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"


; Default VRAM tables for Screen 5
NAMTBL:     equ 0x0000  ; to 0x???? (768 bytes)
SPRPAT:     equ 0x7800  ; to 0x???? (2048 bytes)
SPRCOL:     equ 0x7400  ; to 0x???? (512 bytes)
SPRATR:     equ 0x7600  ; to 0x???? (128 bytes)

;SPRCOL_2:   equ 0xfc00  ; to 0xfdff (512 bytes);
;SPRATR_2:   equ 0xfe00  ; to 0xfe80 (128 bytes)



Execute:


    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    SetSpritesMagnified

    call    Set192Lines

    call    SetColor0ToNonTransparent


    ; -------------------------------------------------------

    ; Load sprite pattern #0
    ld      a, 0000 0000 b
    ld      hl, SPRPAT
    call    SetVdp_Write
    ld      b, SpritePattern_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePattern_1
    otir


    ; -------------------------------------------------------
    ; Load sprite colors table

    ld      a, 0000 0000 b
    ld      hl, SPRCOL
    call    SetVdp_Write
    ld      b, 0; 256 bytes SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_a
    otir

    ; -------------------------------------------------------
    ; Load sprite atributes table

    ld      a, 0000 0000 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      b, SpriteAttributes_top.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes_top
    otir

    ; -------------------------------------------------------

    call    BIOS_ENASCR

    call    BIOS_BEEP

    ; Main loop
MainLoop:
    jp      MainLoop

    ; -------------------------------------------------------
    ; Data
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

SpriteColors_a:
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08

    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08

    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08

    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
.size:  equ $ - SpriteColors_a


SpriteAttributes_top:
    db  -1 + (191 - (32 * 4)), (32 * 0), 0, 0 ; -1 to compensate the Y+1 bug/feature of VDP
    db  -1 + (191 - (32 * 3)), (32 * 0), 0, 0
    db  -1 + (191 - (32 * 2)), (32 * 0), 0, 0
    db  -1 + (191 - (32 * 1)), (32 * 0), 0, 0

    db  -1 + (191 - (32 * 4)), (32 * 1), 0, 0
    db  -1 + (191 - (32 * 3)), (32 * 1), 0, 0
    db  -1 + (191 - (32 * 2)), (32 * 1), 0, 0
    db  -1 + (191 - (32 * 1)), (32 * 1), 0, 0

    db  216, 0, 0, 0 ; hide all sprites from this onwards
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

.size:  equ $ - SpriteAttributes_top

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF




; ----------------- Variables
    org 0xc000

