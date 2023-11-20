FNAME "sprite-or-color.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-0xBFFF (ASCII 16k Mapper)

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

    call    Screen11

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    Set192Lines

    call    SetColor0ToTransparent

    ; set Video RAM active (instead of Expansion RAM)
    ; ld      b, 0000 0000 b  ; data
    ; ld      c, 45            ; register #
    ; call    BIOS_WRTVDP



; ---- set SPRATR to 0x1fa00 (SPRCOL is automatically set 512 bytes before SPRATR, so 0x1f800)
    ; bits:    16 14        7
    ;           |  |        |
    ; 0x1fa00 = 1 1111 1010 0000 0000
    ; low bits (aaaaa111: bits 14 to 10)
    ld      b, 1111 0111 b  ; data          ; In sprite mode 2 the least significant three bits in register 5 should be 1 otherwise mirroring will occur. ; https://www.msx.org/forum/msx-talk/development/strange-behaviour-bug-on-spratr-base-addr-register-on-v993858
    ld      c, 5            ; register #
    call    BIOS_WRTVDP
    ; high bits (000000aa: bits 16 to 15)
    ld      b, 0000 0011 b  ; data
    ld      c, 11           ; register #
    call    BIOS_WRTVDP

; ---- set SPRPAT to 0x1f000
    ; bits:    16     11
    ;           |      |
    ; 0x1f000 = 1 1111 0000 0000 0000
    ; high bits (00aaaaaa: bits 16 to 11)
    ld      b, 0011 1110 b  ; data
    ld      c, 6            ; register #
    call    BIOS_WRTVDP

NAMTBL:     equ 0x0000
SPRPAT:     equ 0xf000 ; actually 0x1f000, but 17 bits address are not accepted
SPRCOL:     equ 0xf800
SPRATR:     equ 0xfa00




    ld      hl, PaletteData
    call    LoadPalette



; --------- Load sprites

    ; Spr 0 and 1 patterns
    ld      a, 0000 0001 b
    ld      hl, SPRPAT
    call    SetVdp_Write
    ld      b, SpritePattern_0_and_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePattern_0_and_1
    otir

    ; ; Spr 2 and 3 patterns
    ; ld      a, 0000 0001 b
    ; ld      hl, SPRPAT + 64
    ; call    SetVdp_Write
    ; ld      b, SpritePattern_2_and_3.size
    ; ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ; ld      hl, SpritePattern_2_and_3
    ; otir


    ; Spr 0 and 1 colors
    ld      a, 0000 0001 b
    ld      hl, SPRCOL
    call    SetVdp_Write
    ld      b, SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_1
    otir

    ; ; Spr 2 and 3 colors
    ; ld      a, 0000 0001 b
    ; ld      hl, SPRCOL + 32
    ; call    SetVdp_Write
    ; ld      b, SpriteColors_2.size
    ; ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ; ld      hl, SpriteColors_2
    ; otir

    ; Atributes of all sprites
    ld      a, 0000 0001 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      b, SpriteAttributes_top.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes_top
    otir

; -----------

    ; Load test bg image
    ld		hl, ImageData_1        			        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, NAMTBL + (1 * (256 * 64))           ; VRAM address (destiny, bits 15-0)
    ld		c, 0 + (ImageData_1.size / 256)         ; Block length * 256
    call    LDIRVM_MSX2

    call    BIOS_ENASCR


.endlessLoop:
    jp      .endlessLoop


End:


SpritePattern_0_and_1:
    ;INCBIN "Images/player_plane_0.pat"
    ;INCBIN "Images/enemy_plane_1.pat"
    ;INCBIN "Images/enemy_plane_2.pat"
    ;INCBIN "Images/enemy_plane_3.pat"
    ;INCBIN "Images/enemy_plane_4.pat"
    ;INCBIN "Images/enemy_plane_5.pat"
    ;INCBIN "Images/player_plane_left_0_bottom.pat"
    ;INCBIN "Images/player_plane_left_0_top.pat"
    ; INCBIN "Images/player_plane_left_1_top.pat"
    ;INCBIN "Images/player_plane_left_1_bottom.pat"
    ; INCLUDE "Images/item_p_patterns.s"
    ; INCLUDE "Images/font_char_0_patterns.s"
    ; INCBIN "Images/enemy_plane_turning_0.pat"
    ; INCLUDE "Images/item_bomb_0_patterns.s"
    INCBIN "Images/enemy_chopper_1_bottom_left.pat"
    INCBIN "Images/enemy_chopper_1_bottom_right.pat"
    INCBIN "Images/enemy_chopper_1_top_left.pat"
.size:  equ $ - SpritePattern_0_and_1

; SpritePattern_2_and_3:
;     INCBIN "Images/player_plane_1.pat"
; .size:  equ $ - SpritePattern_2_and_3



SpriteColors_1:
    ;INCBIN "Images/player_plane_0.col"
    ;INCBIN "Images/enemy_plane_1.col"
    ;INCBIN "Images/enemy_plane_2.col"
    ;INCBIN "Images/enemy_plane_3.col"
    ;INCBIN "Images/enemy_plane_4.col"
    ;INCBIN "Images/enemy_plane_5.col"
    ;INCBIN "Images/player_plane_left_0_bottom.col"
    ;INCBIN "Images/player_plane_left_0_top.col"
    ;INCBIN "Images/player_plane_left_1_top.col"
    ; INCBIN "Images/player_plane_left_1_bottom.col"
    ; INCLUDE "Images/item_p_colors.s"
    ; INCLUDE "Images/font_char_0_colors.s"
    ; INCBIN "Images/enemy_plane_turning_0.col"
    ; INCLUDE "Images/item_bomb_0_colors.s"
    INCBIN "Images/enemy_chopper_1_bottom_left.col"
    INCBIN "Images/enemy_chopper_1_bottom_right.col"
    INCBIN "Images/enemy_chopper_1_top_left.col"
.size:  equ $ - SpriteColors_1

; SpriteColors_2:
;     INCBIN "Images/player_plane_1.col"
; .size:  equ $ - SpriteColors_2



SpriteAttributes_top:
    ;   Y, X, Pattern, Reserved

    ; sprites 0 and 1
    db  90,         100,        0 * 4,      0
    db  90,         100,        1 * 4,      0

    ; sprites 2 and 3
    db  90,    100 + 16,        2 * 4,      0
    db  90,    100 + 16,        3 * 4,      0

    ; sprites 4 and 5
    db  90-16,      100,        4 * 4,      0
    db  90-16,  100 + 8,        5 * 4,      0

.size:  equ $ - SpriteAttributes_top


; ImageTest:
;     db  0xff, 0xff, 0xff, 0xff
;     db  0xff, 0xff, 0xff, 0xff
;     db  0xff, 0xff, 0xff, 0xff
;     db  0xff, 0xff, 0xff, 0xff
;     db  0xff, 0xff, 0xff, 0xff
;     db  0xff, 0xff, 0xff, 0xff
;     db  0xff, 0xff, 0xff, 0xff
;     db  0xff, 0xff, 0xff, 0xff
; .size:  equ $ - ImageTest



; TODO: put correct palette here
PaletteData:
    ;INCBIN "Images/player_plane_0.pal"
    INCBIN "Images/msx-wings.pal"

    ; ;  data 1 (red 0-7; blue 0-7); data 2 (0000; green 0-7)
    ; db 0x00, 0x00 ; Color index 0
    ; db 0x77, 0x00 ; Color index 1
    ; db 0x10, 0x00 ; Color index 2
    ; db 0x20, 0x00 ; Color index 3
    ; db 0x30, 0x00 ; Color index 4
    ; db 0x40, 0x00 ; Color index 5
    ; db 0x50, 0x00 ; Color index 6
    ; db 0x60, 0x00 ; Color index 7
    ; db 0x70, 0x00 ; Color index 8
    ; db 0x11, 0x01 ; Color index 9
    ; db 0x22, 0x02 ; Color index 10
    ; db 0x33, 0x03 ; Color index 11
    ; db 0x77, 0x07 ; Color index 12
    ; db 0x66, 0x06 ; Color index 13
    ; db 0x55, 0x05 ; Color index 14
    ; db 0x44, 0x04 ; Color index 15



    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF




	org	0x8000, 0xBFFF
ImageData_1:
    INCBIN "Images/aerofighters_0.sra.new"
    ;INCBIN "Images/aerofighters_0.sr8.new"
    ;INCBIN "Images/metalslug-xaa"
.size:      equ $ - ImageData_1
	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)



