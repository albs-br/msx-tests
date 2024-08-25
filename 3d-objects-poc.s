FNAME "3d-objects-poc.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 4
NAMTBL:     equ 0x1800  ; to 0x1aff (768 bytes)
PATTBL:     equ 0x0000  ; to 0x17ff (6144 bytes)
COLTBL:     equ 0x2000  ; to 0x37ff (6144 bytes)
SPRPAT:     equ 0x3800  ; to 0x3fff (2048 bytes)
SPRCOL:     equ 0x1c00  ; to 0x1dff (512 bytes)
SPRATR:     equ 0x1e00  ; to 0x1e7f (128 bytes)

Execute:
    call    EnableRomPage2

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a

    ; change to screen 4
    ld      a, 4
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    Set192Lines

    call    SetColor0ToNonTransparent

    ; load NAMTBL (third part)
    ld		hl, NAMTBL_Data             ; RAM address (source)
    ld		de, NAMTBL + (32*16)	    ; VRAM address (destiny)
    ld		bc, NAMTBL_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load PATTBL (third part)
    ld		hl, PATTBL_Data             ; RAM address (source)
    ld		de, PATTBL + (32*16*8)		; VRAM address (destiny)
    ld		bc, PATTBL_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load COLTBL (third part)
    ld		hl, COLTBL_Data             ; RAM address (source)
    ld		de, COLTBL + (32*16*8)		; VRAM address (destiny)
    ld		bc, COLTBL_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load SPRPAT
    ld		hl, SPRPAT_Data             ; RAM address (source)
    ld		de, SPRPAT   		        ; VRAM address (destiny)
    ld		bc, SPRPAT_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load SPRCOL
    ld		hl, SPRCOL_Data             ; RAM address (source)
    ld		de, SPRCOL   		        ; VRAM address (destiny)
    ld		bc, SPRCOL_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

   
    call    BIOS_ENASCR

; ------------------------------------

    ; Init vars
    ld      hl, 32768
    ld      (Player.X), hl
    ld      (Player.Y), hl
    xor     a
    ld      (Player.angle), a



; ------------------------------------

.loop:

    jp      loop

End:

; Palette:
;     ; INCBIN "Images/title-screen.pal"
;     INCBIN "Images/plane_rotating.pal"

NAMTBL_Data:
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.size:  equ $ - NAMTBL_Data

PATTBL_Data:
    db      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    db      0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.size:  equ $ - PATTBL_Data

COLTBL_Data:
    db      0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11
    db      0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.size:  equ $ - COLTBL_Data

SPRPAT_Data:
    db      11000000 b
    db      11000000 b
    db      00000000 b
    db      00000000 b
    db      00000000 b
    db      00000000 b
    db      00000000 b
    db      00000000 b
.size:  equ $ - SPRPAT_Data

SPRCOL_Data:
    db      0x08 b
    db      0x08 b
.size:  equ $ - SPRCOL_Data

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; ; MegaROM pages at 0x8000
; ; ------- Page 1
; 	org	0x8000, 0xBFFF
; ImageData:
;     ;INCBIN "Images/aerofighters-xaa"
; .size:      equ $ - ImageData
; 	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff

SavedJiffy:     rb 1

Player:
.X:         dw 1 ; 0-65535
.Y:         dw 1 ; 0-65535
.angle:     dw 1 ; 0-359 degrees

Object_0:
.X:         dw 1 ; 0-65535
.Y:         dw 1 ; 0-65535
