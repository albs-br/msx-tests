FNAME "sprite-or-color.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0x7fff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:


    ; change to screen 11
    ; it's needed to set screen 8 and change the YJK and YAE bits of R#25 manually
    ld      a, 8
    call    BIOS_CHGMOD
    ld      b, 0001 1000 b      ; data
    ld      c, 25               ; register #
    call    BIOS_WRTVDP

    call    BIOS_DISSCR

    ; set 192 lines
    ld      b, 0000 0000 b  ; data
    ld      c, 9            ; register #
    call    BIOS_WRTVDP

    ; set color 0 to transparent
    ld      b, 0000 1000 b  ; data
    ld      c, 8            ; register #
    call    BIOS_WRTVDP

    ; set NAMTBL to 0x00000
    ; ld      b, 0011 1111 b  ; data
    ; ld      c, 2            ; register #
    ; call    BIOS_WRTVDP

; ; ---- set SPRATR to 0x1fa00 (SPRCOL is automatically set 512 bytes before SPRATR, so 0x1f800)
;     ; bits:    16 14        7
;     ;           |  |        |
;     ; 0x1fa00 = 1 1111 1010 1000 0000
;     ; low bits (aaaaaaaa: bits 14 to 7)
;     ld      b, 1111 0101 b  ; data
;     ld      c, 5            ; register #
;     call    BIOS_WRTVDP
;     ; high bits (000000aa: bits 16 to 15)
;     ld      b, 0000 0011 b  ; data
;     ld      c, 11           ; register #
;     call    BIOS_WRTVDP

; ; ---- set SPRPAT to 0x1f000
;     ; bits:    16     11
;     ;           |      |
;     ; 0x1fa00 = 1 1111 0000 0000 0000
;     ; high bits (00aaaaaa: bits 16 to 11)
;     ld      b, 0011 1110 b  ; data
;     ld      c, 6            ; register #
;     call    BIOS_WRTVDP

NAMTBL:     equ 0x0000
SPRPAT:     equ 0xf000 ; actually 0x1f000, but 17 bits address are not accepted
SPRCOL:     equ 0xf800
SPRATR:     equ 0xfa00

; --------- Load first screen     
    ; ld	    a, 14
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData_14        			    ; RAM address (source)
    ; ld		de, NAMTBL + (0 * (256 * 64))           ; VRAM address (destiny)
    ; ld		bc, ImageData_14.size				    ; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            
    ; ; -- Load middle part of first image on last 64 lines
    ; ld	    a, 15
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData_15      				    ; RAM address (source)
    ; ld		de, NAMTBL + (1 * (256 * 64))           ; VRAM address (destiny)
    ; ld		bc, ImageData_15.size					; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    ; ; -- Load bottom part of first image on last 64 lines
    ; ld	    a, 16
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData_16      				    ; RAM address (source)
    ; ld		de, NAMTBL + (2 * (256 * 64))           ; VRAM address (destiny)
    ; ld		bc, ImageData_16.size					; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    call    BIOS_ENASCR


; --------- Load sprites

    ; set VRAM to second page (addresses started at 0x10000)
    ; high bits (00000aaa: bits 16 to 14)
    ld      b, 0000 0100 b  ; data
    ld      c, 14            ; register #
    call    BIOS_WRTVDP


    ld		hl, SpritePattern_1   				    ; RAM address (source)
    ld		de, SPRPAT + (0 * 32)                   ; VRAM address (destiny)
    ld		bc, 32					                ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    ld		hl, SpriteColors_1   				    ; RAM address (source)
    ld		de, SPRCOL + (0 * 16)                   ; VRAM address (destiny)
    ld		bc, 16					                ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    ld		hl, SpriteAttributes_1 				    ; RAM address (source)
    ld		de, SPRATR + (0 * 4)                    ; VRAM address (destiny)
    ld		bc, SpriteAttributes_1.size             ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

; -----------

    ; set VRAM to first page (addresses started at 0x10000)
    ; high bits (00000aaa: bits 16 to 14)
    ld      b, 0000 0000 b  ; data
    ld      c, 14            ; register #
    call    BIOS_WRTVDP

    ; load test image
    ld		hl, ImageTest 				            ; RAM address (source)
    ld		de, NAMTBL                              ; VRAM address (destiny)
    ld		bc, ImageTest.size                      ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

.endlessLoop:
    jp      .endlessLoop


End:

SpritePattern_1:
    DB 11111111b
    DB 11000011b
    DB 11000011b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b
    DB 11111111b

SpriteColors_1:
    db 0x02, 0x0a, 0x03, 0x03, 0x08, 0x08, 0x03, 0x0a, 0x04, 0x07, 0x0a, 0x0a, 0x0a, 0x0a, 0x0f, 0x0f

SpriteAttributes_1:
    db 88, 120, 0, 0
.size:  equ $ - SpriteAttributes_1


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


; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

