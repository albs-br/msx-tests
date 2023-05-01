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
    ld      de, SpritePatterns_Factor_5.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePatterns_Factor_5
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
    ld      d, 5          ; number of repetitions (same as factor)
.loop_colors:
    ld      hl, SpriteColors_Factor_5
    ld      b, SpriteColors_Factor_5.size
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
    ld      b, SpriteAttributes_Factor_5.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes_Factor_5
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

;

SpritePatterns_Factor_4:
    INCLUDE "Images/msx-wings-stage-clear-sprites/patterns_S_factor_4.s"
.size: equ $ - SpritePatterns_Factor_4

SpriteColors_Factor_4:
    INCLUDE "Images/msx-wings-stage-clear-sprites/colors_factor_4.s"
.size: equ $ - SpriteColors_Factor_4

;

SpritePatterns_Factor_5:
    INCLUDE "Images/msx-wings-stage-clear-sprites/patterns_S_factor_5.s"
.size: equ $ - SpritePatterns_Factor_5

SpriteColors_Factor_5:
    INCLUDE "Images/msx-wings-stage-clear-sprites/colors_factor_5.s"
.size: equ $ - SpriteColors_Factor_5



SpriteAttributes_Factor_2:
    ;   Y, X, Pattern, Reserved
    db   0,  0, 0 * 4, 0
    db  16,  0, 1 * 4, 0
    db   0, 16, 2 * 4, 0
    db  16, 16, 3 * 4, 0

    db  216, 0, 0, 0 ; hide all sprites from here onwards
.size:  equ $ - SpriteAttributes_Factor_2

SpriteAttributes_Factor_3:
    ;   Y, X, Pattern, Reserved
    db   0,  0, 0 * 4, 0
    db  16,  0, 1 * 4, 0
    db  32,  0, 2 * 4, 0

    db   0, 16, 3 * 4, 0
    db  16, 16, 4 * 4, 0
    db  32, 16, 5 * 4, 0
    
    db   0, 32, 6 * 4, 0
    db  16, 32, 7 * 4, 0
    db  32, 32, 8 * 4, 0

    db  216, 0, 0, 0 ; hide all sprites from here onwards

.size:  equ $ - SpriteAttributes_Factor_3

SpriteAttributes_Factor_4:
    ;   Y, X, Pattern, Reserved
    db   0,  0,  0 * 4, 0
    db  16,  0,  1 * 4, 0
    db  32,  0,  2 * 4, 0
    db  48,  0,  3 * 4, 0

    db   0, 16,  4 * 4, 0
    db  16, 16,  5 * 4, 0
    db  32, 16,  6 * 4, 0
    db  48, 16,  7 * 4, 0

    db   0, 32,  8 * 4, 0
    db  16, 32,  9 * 4, 0
    db  32, 32, 10 * 4, 0
    db  48, 32, 11 * 4, 0

    db   0, 48, 12 * 4, 0
    db  16, 48, 13 * 4, 0
    db  32, 48, 14 * 4, 0
    db  48, 48, 15 * 4, 0

    db  216, 0, 0, 0 ; hide all sprites from here onwards

.size:  equ $ - SpriteAttributes_Factor_4

SpriteAttributes_Factor_5:
    ;   Y, X, Pattern, Reserved
    db   0,  0,  0 * 4, 0
    db  16,  0,  1 * 4, 0
    db  32,  0,  2 * 4, 0
    db  48,  0,  3 * 4, 0
    db  64,  0,  4 * 4, 0

    db   0, 16,  5 * 4, 0
    db  16, 16,  6 * 4, 0
    db  32, 16,  7 * 4, 0
    db  48, 16,  8 * 4, 0
    db  64, 16,  9 * 4, 0

    db   0, 32, 10 * 4, 0
    db  16, 32, 11 * 4, 0
    db  32, 32, 12 * 4, 0
    db  48, 32, 13 * 4, 0
    db  64, 32, 14 * 4, 0

    db   0, 48, 15 * 4, 0
    db  16, 48, 16 * 4, 0
    db  32, 48, 17 * 4, 0
    db  48, 48, 18 * 4, 0
    db  64, 48, 19 * 4, 0

    db   0, 64, 20 * 4, 0
    db  16, 64, 21 * 4, 0
    db  32, 64, 22 * 4, 0
    db  48, 64, 23 * 4, 0
    db  64, 64, 24 * 4, 0

    db  216, 0, 0, 0 ; hide all sprites from here onwards

.size:  equ $ - SpriteAttributes_Factor_5


PaletteData:
    INCBIN "Images/msx-wings.pal"


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF
