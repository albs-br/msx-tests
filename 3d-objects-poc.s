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
    ; init interrupt mode and stack pointer (in case the ROM isn't the first thing to be loaded)
	di                          ; disable interrupts
	im      1                   ; interrupt mode 1
    ld      sp, (BIOS_HIMEM)    ; init SP

    call    BIOS_DISSCR

    ld      hl, RamStart        ; RAM start address
    ld      de, RamEnd + 1      ; RAM end address
    call    ClearRam_WithParameters


    call    EnableRomPage2

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a

    ; change to screen 4
    ld      a, 4
    call    BIOS_CHGMOD

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

    ; load SPRATR_Buffer
    ld		hl, SPRATR_Data             ; RAM address (source)
    ld		de, SPRATR_Buffer   		; VRAM address (destiny)
    ld		bc, SPRATR_Data.size	    ; Block length
    ldir        		                ; Block transfer to VRAM from memory


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

    call    Wait_Vblank

    ; Update SPRATR from buffer
    ld      a, 0000 0000 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      hl, SPRATR_Buffer
    ld      c, PORT_0
    outi outi outi outi ; update 1 sprite

    ; Read input
    ld      a, 8                    ; 8th line
    call    BIOS_SNSMAT             ; Read Data Of Specified Line From Keyboard Matrix
    bit     4, a                    ; 4th bit (left)
    call   	z, .left
    ; TODO



    ; Update SPRATR buffer
    ld      hl, SPRATR_Buffer

    ld      a, (Player.Y + 1) ; high byte
    ; convert from 16 bits to 6 bits (0-63)
    srl     a               ; shift right register
    srl     a
    add     128
    ld      (hl), a

    inc     hl
    ld      a, (Player.X + 1) ; high byte
    ; convert from 16 bits to 6 bits (0-63)
    srl     a               ; shift right register
    srl     a
    ld      (hl), a




    jp      .loop

.left:
    ; if (Player.X == 0) ret; else Player.X--;
    ld      hl, (Player.X)
    ld      de, 0
    call    BIOS_DCOMPR
    ret     z

    ld      bc, -256
    add     hl, bc
    ; dec     hl
    ld      (Player.X), hl

    ret

; .right:
;     ; if (Player.X == 0) ret; else Player.X--;
;     ld      hl, (Player.X)
;     ld      de, 0
;     call    BIOS_DCOMPR
;     ret     z

;     ld      bc, -256
;     add     hl, bc
;     ; dec     hl
;     ld      (Player.X), hl

;     ret

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
    db      0x08, 0x08, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      0x04, 0x04, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.size:  equ $ - SPRCOL_Data

SPRATR_Data:
    ;       y, x, pattern, unused
    db      0, 0, 0, 0
    db      0, 0, 0, 0
.size:  equ $ - SPRATR_Data

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

RamStart:

SavedJiffy:     rb 1

SPRATR_Buffer:  rb 128

Player:
.X:             rw 1 ; 0-65535
.Y:             rw 1 ; 0-65535
.angle:         rw 1 ; 0-359 degrees, 0 is up
.walk_DX:       rw 1 ; 8.8 fixed point
.walk_DY:       rw 1 ; 8.8 fixed point

Object_0:
.X:             rw 1 ; 0-65535
.Y:             rw 1 ; 0-65535

RamEnd: