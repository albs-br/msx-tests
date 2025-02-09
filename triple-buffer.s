FNAME "triple-buffer.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

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

    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    Set212Lines

    call    SetColor0ToNonTransparent


    
    ; load 32-byte palette data
    ld      hl, Palette
    call    LoadPalette

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a
    
    ; write to VRAM bitmap area

    ; SC 5 - page 0
    ld      a, 0000 0000 b
    ld      hl, 0x0000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 1
    ld      a, 0000 0000 b
    ld      hl, 0x8000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 2
    ld      a, 0000 0001 b
    ld      hl, 0x0000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 3
    ld      a, 0000 0001 b
    ld      hl, 0x8000
    call    LoadImageTo_SC5_Page


	; ; enable page 2
    ; ld	    a, 2
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData_2      				    ; RAM address (source)
    ; ld		de, 16384			                    ; VRAM address (destiny)
    ; ld		bc, ImageData_2.size					; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory



    call    BIOS_ENASCR

    jp      $ ; endless loop

; ----------

; Input:
;   AHL: 17-bit VRAM address
LoadImageTo_SC5_Page:
    call    SetVdp_Write
    ld      hl, ImageData
    ld      c, PORT_0
    ld      d, 0 + (ImageData.size / 256)
    ld      b, 0 ; 256 bytes
.loop_10:    
    otir
    dec     d
    jp      nz, .loop_10

    ret

End:

Palette:
    INCBIN "Images/mk.pal"

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
ImageData:
    INCBIN "Images/mk-bg-top.sc5"
.size:      equ $ - ImageData
	ds PageSize - ($ - 0x8000), 255

; ; ------- Page 2
; 	org	0x8000, 0xBFFF
; ImageData_2:
;     INCBIN "Images/aerofighters-xab"
; .size:      equ $ - ImageData_2
; .palette:   equ $ - 32
; 	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

