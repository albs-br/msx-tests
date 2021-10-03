FNAME "show-image-screen11.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-0xBFFF (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:
    call    EnableRomPage2

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a

    ; change to screen 11
    ; it's needed to set screen 8 and change the YJK and YAE bits of R#25 manually
    ld      a, 8
    call    BIOS_CHGMOD
    ld      b, 0001 1000 b  ; data
    ld      c, 25            ; register #
    call    BIOS_WRTVDP


    call    BIOS_DISSCR

REG8SAV: equ 0xFFE7
REG9SAV: equ 0xFFE8

    ; set 192 lines
    ld      b, 0000 0000 b  ; data
    ld      c, 9            ; register #
    call    BIOS_WRTVDP
    ; ld      a,(REG9SAV) 
    ; ;and     07Fh	
    ; and     0111 1111 b
    ; ld      b, a
    ; ld      c, 9            ; register #
    ; call    BIOS_WRTVDP

    ; set color 0 to transparent
    ld      b, 0000 1000 b  ; data
    ld      c, 8            ; register #
    call    BIOS_WRTVDP
    ; ld      a,(REG8SAV) 
    ; ; and     0DFh	
    ; and     1101 1111 b
    ; ld      b, a
    ; ld      c, 8            ; register #
    ; call    BIOS_WRTVDP

    ; set NAMTBL to 0x00000
    ; ld      b, 0011 1111 b  ; data
    ; ld      c, 2            ; register #
    ; call    BIOS_WRTVDP

NAMTBL:     equ 0x00000

; --------- Load screen     
    ld	    a, 1
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_1        			        ; RAM address (source)
    ld		de, NAMTBL + (0 * (256 * 64))           ; VRAM address (destiny)
    ld		bc, ImageData_1.size				    ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            

    call    BIOS_ENASCR

; --------- 




.eternalLoop:
    jp      .eternalLoop


End:

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
ImageData_1:
    INCBIN "Images/aerofighters_0.sra.new"
    ;INCBIN "Images/aerofighters_0.sr8.new"
.size:      equ $ - ImageData_1
	ds PageSize - ($ - 0x8000), 255




; RAM
	org     0xc000, 0xe5ff

