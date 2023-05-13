FNAME "ibm-pc-font.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 2
NAMTBL:     equ 0x1800  ; to 0x1aff (768 bytes)
PATTBL:     equ 0x0000  ; to 0x17ff (6144 bytes)
COLTBL:     equ 0x2000  ; to 0x37ff (6144 bytes)
SPRPAT:     equ 0x3800  ; to 0x3fff (2048 bytes)
SPRATR:     equ 0x1b00  ; to 0x1b7f (128 bytes)


    INCLUDE "Fonts/ibm-pc-font_pattern.s"
    ; lots of 8x8 fonts here:
    ; https://damieng.com/typography/zx-origins/
 

Execute:

    ; it only works with this block on start:
    ld 		a, 15      	        ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 1  		        ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld      a, 1                ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR         ; Change Screen Color

    call    BIOS_INIGRP                 ; screen 2

    ; load PATTBL (first third)
    ld		hl, IBM_PC_FONT         ; RAM address (source)
    ld		de, PATTBL		        ; VRAM address (destiny)
    ld		bc, IBM_PC_FONT.size	; Block length
    call 	BIOS_LDIRVM        	    ; Block transfer to VRAM from memory

    ; load PATTBL (second third)
    ld		hl, IBM_PC_FONT         ; RAM address (source)
    ld		de, PATTBL + (256 * 8)  ; VRAM address (destiny)
    ld		bc, IBM_PC_FONT.size	; Block length
    call 	BIOS_LDIRVM        	    ; Block transfer to VRAM from memory

    ; fill COLTBL (first third)
    ld      hl, COLTBL
    call    BIOS_SETWRT
    ld      bc, 256 * 8
.loop_1:
    ld      a, 0xf1         ; foreground white, background black
    out     (PORT_0), a
    dec     bc
    ld      a, b
    or      c
    jp      nz, .loop_1

    ; fill COLTBL (second third)
    ld      hl, COLTBL + (256 * 8)
    call    BIOS_SETWRT
    ld      bc, 256 * 8
.loop_1a:
    ld      a, 0x1f         ; foreground black, background white
    out     (PORT_0), a
    dec     bc
    ld      a, b
    or      c
    jp      nz, .loop_1a

    ; fill NAMTBL (first and second third)
    ld      hl, NAMTBL
    call    BIOS_SETWRT
    ld      b, 0
    ld      de, 256 * 2
    ld      c, PORT_0
.loop_2:
    out     (c), b
    inc     b
    dec     de
    ld      a, d
    or      e
    jp      nz, .loop_2

    jp      $ ; eternal loop

    db      "End ROM started at 0x4000"

    ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff
