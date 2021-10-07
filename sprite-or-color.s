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
    ; 0x1fa00 = 1 1111 1010 1000 0000
    ; low bits (aaaaaaaa: bits 14 to 7)
    ld      b, 1111 0101 b  ; data
    ld      c, 5            ; register #
    call    BIOS_WRTVDP
    ; high bits (000000aa: bits 16 to 15)
    ld      b, 0000 0011 b  ; data
    ld      c, 11           ; register #
    call    BIOS_WRTVDP

; ---- set SPRPAT to 0x1f000
    ; bits:    16     11
    ;           |      |
    ; 0x1fa00 = 1 1111 0000 0000 0000
    ; high bits (00aaaaaa: bits 16 to 11)
    ld      b, 0011 1110 b  ; data
    ld      c, 6            ; register #
    call    BIOS_WRTVDP

NAMTBL:     equ 0x0000
SPRPAT:     equ 0xf000 ; actually 0x1f000, but 17 bits address are not accepted
SPRCOL:     equ 0xf800
SPRATR:     equ 0xfa00


; --------- Load sprites

    ; Spr 0 pattern
    ld      a, 0000 0001 b
    ld      hl, SPRPAT
    call    SetVdp_Write
    ld      b, SpritePattern_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePattern_1
    otir

    ; Spr 1 pattern
    ld      a, 0000 0001 b
    ld      hl, SPRPAT + 32
    call    SetVdp_Write
    ld      b, SpritePattern_2.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePattern_2
    otir


    ; Spr 0 color
    ld      a, 0000 0001 b
    ld      hl, SPRCOL
    call    SetVdp_Write
    ld      b, SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_1
    otir

    ; Spr 1 color
    ld      a, 0000 0001 b
    ld      hl, SPRCOL + 16
    call    SetVdp_Write
    ld      b, SpriteColors_2.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_2
    otir

    ; Atributes of all sprites
    ld      a, 0000 0001 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      b, SpriteAttributes.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes
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

SpritePattern_2:
    DB 00000111b
    DB 00011000b
    DB 00100000b
    DB 01000000b
    DB 01001100b
    DB 10001100b
    DB 10000000b
    DB 10000000b

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
.size:  equ $ - SpritePattern_2

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

SpriteColors_2:
    ; Only the sprite on the lower layer should have the bit 6 set to enable the OR-color
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
    db  0100 0000 b + 2
.size:  equ $ - SpriteColors_2

SpriteAttributes:
    ;   Y, X, Pattern, Reserved
    db  90, 100, 0, 0
    db  90, 100, 4, 0
.size:  equ $ - SpriteAttributes


ImageTest:
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
.size:  equ $ - ImageTest

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

