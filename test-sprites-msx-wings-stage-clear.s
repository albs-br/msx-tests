FNAME "test-sprites-msx-wings-stage-clear.rom"      ; output file

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

    ; All sprite patterns
    ld      a, 0000 0000 b
    ld      hl, SPRPAT
    call    SetVdp_Write
    ld      de, SpritePatterns_Factor_2.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePatterns_Factor_2
.loop:    
    outi
    dec     de
    ld      a, e
    or      d
    jp      nz, .loop

    ; ; Spr 0 color (top left)
    ; ld      a, 0000 0000 b
    ; ld      hl, SPRCOL + (16 * 0)
    ; call    SetVdp_Write
    ; ld      b, SpriteColors_Factor_2_0.size
    ; ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ; ld      hl, SpriteColors_Factor_2_0
    ; otir
    ; ; Spr 1 color (bottom left)
    ; ld      a, 0000 0000 b
    ; ld      hl, SPRCOL + (16 * 1)
    ; call    SetVdp_Write
    ; ld      b, SpriteColors_Factor_2_1.size
    ; ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ; ld      hl, SpriteColors_Factor_2_1
    ; otir
    ; ; Spr 2 color (top right)
    ; ld      a, 0000 0000 b
    ; ld      hl, SPRCOL + (16 * 2)
    ; call    SetVdp_Write
    ; ld      b, SpriteColors_Factor_2_0.size
    ; ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ; ld      hl, SpriteColors_Factor_2_0
    ; otir
    ; ; Spr 3 color (bottom right)
    ; ld      a, 0000 0000 b
    ; ld      hl, SPRCOL + (16 * 3)
    ; call    SetVdp_Write
    ; ld      b, SpriteColors_Factor_2_1.size
    ; ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ; ld      hl, SpriteColors_Factor_2_1
    ; otir

    ; Set sprite colors
    ld      a, 0000 0000 b
    ld      hl, SPRCOL
    call    SetVdp_Write
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      d, 2          ; number of repetitions (same as factor)
.loop_colors:
    ld      hl, SpriteColors_Factor_2
    ld      b, SpriteColors_Factor_2.size
    otir
    dec     d
    jp      nz, .loop_Colors

;     ; Set all Spr colors to 0x0f
;     ld      a, 0000 0000 b
;     ld      hl, SPRCOL
;     call    SetVdp_Write
;     ld      de, 32 * 16
;     ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
; .loop_fixedcolor:
;     ld      a, 0x04
;     out     (c), a
;     dec     de
;     ld      a, e
;     or      d
;     jp      nz, .loop_fixedcolor

    ; Atributes of all sprites
    ld      a, 0000 0000 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      b, SpriteAttributes_Factor_2.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes_Factor_2
    otir


    ld      hl, PaletteData
    call    LoadPalette

    call    BIOS_ENASCR


.endlessLoop:
    jp      .endlessLoop


End:


SpritePatterns_Factor_2:
    INCLUDE "Images/msx-wings-stage-clear-sprites/patterns_G_factor_2.s"
.size:  equ $ - SpritePatterns_Factor_2

SpriteColors_Factor_2:
    INCLUDE "Images/msx-wings-stage-clear-sprites/colors_factor_2.s"
.size:  equ $ - SpriteColors_Factor_2

;

SpritePatterns_Factor_3:
    INCLUDE "Images/msx-wings-stage-clear-sprites/patterns_S_factor_3.s"
.size: equ $ - SpritePatterns_Factor_3

SpriteColors_Factor_3:
    INCLUDE "Images/msx-wings-stage-clear-sprites/colors_factor_3.s"
.size: equ $ - SpriteColors_Factor_3

SpriteAttributes_Factor_2:
    ;   Y, X, Pattern, Reserved
    db  0,  16, 0 * 4, 0
    db  16, 16, 1 * 4, 0
    db  0,  32, 2 * 4, 0
    db  16, 32, 3 * 4, 0

    db  216, 0, 0, 0 ; hide all sprites from here onwards
.size:  equ $ - SpriteAttributes_Factor_2

SpriteAttributes_Factor_3:
    ;   Y, X, Pattern, Reserved
    db  16 * 3, 16, 0 * 4, 0
    db  16 * 4, 16, 1 * 4, 0
    db  16 * 5, 16, 2 * 4, 0

    db  16 * 3, 32, 3 * 4, 0
    db  16 * 4, 32, 4 * 4, 0
    db  16 * 5, 32, 5 * 4, 0
    
    db  16 * 3, 48, 6 * 4, 0
    db  16 * 4, 48, 7 * 4, 0
    db  16 * 5, 48, 8 * 4, 0

    db  216, 0, 0, 0 ; hide all sprites from here onwards

.size:  equ $ - SpriteAttributes_Factor_3

PaletteData:
    INCBIN "Images/msx-wings.pal"


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF
