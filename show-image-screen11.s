FNAME "show-image-screen11.rom"      ; output file

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

    call    Set192Lines

    call    SetColor0ToTransparent


NAMTBL:     equ 0x00000

; --------- Load screen     
    ld	    a, 1
	ld	    (Seg_P8000_SW), a
    ld		hl, ImageData_1        			        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, NAMTBL + (0 * (256 * 64))           ; VRAM address (destiny, bits 15-0)
    ld		c, 0 + (ImageData_1.size / 256)         ; Block length * 256
    call    LDIRVM_MSX2

    ld	    a, 2
	ld	    (Seg_P8000_SW), a
    ld		hl, ImageData_2        			        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, NAMTBL + (1 * (256 * 64))           ; VRAM address (destiny, bits 15-0)
    ld		c, 0 + (ImageData_2.size / 256)         ; Block length * 256
    call    LDIRVM_MSX2

    ld	    a, 3
	ld	    (Seg_P8000_SW), a
    ld		hl, ImageData_3        			        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, NAMTBL + (2 * (256 * 64))           ; VRAM address (destiny, bits 15-0)
    ld		c, 0 + (ImageData_3.size / 256)         ; Block length * 256
    call    LDIRVM_MSX2


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

; ------- Page 2
	org	0x8000, 0xBFFF
ImageData_2:
    INCBIN "Images/aerofighters_1.sra.new"
    ;INCBIN "Images/aerofighters_1.sr8.new"
.size:      equ $ - ImageData_2
	ds PageSize - ($ - 0x8000), 255

; ------- Page 3
	org	0x8000, 0xBFFF
ImageData_3:
    INCBIN "Images/aerofighters_2.sra.new"
    ;INCBIN "Images/aerofighters_2.sr8.new"
.size:      equ $ - ImageData_3
	ds PageSize - ($ - 0x8000), 255




; RAM
	org     0xc000, 0xe5ff

