FNAME "vertical-scroll-screen8.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

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

    ; change to screen 8
    ld      a, 8
    call    BIOS_CHGMOD

    ; set 192 lines
    ld      b, 0000 0000 b  ; data
    ld      c, 0x09         ; register #
    call    BIOS_WRTVDP

    
	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData        				    ; RAM address (source)
    ld		de, 0 * 16384		                    ; VRAM address (destiny)
    ld		bc, ImageData.size					    ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            
	; enable page 2
    ld	    a, 2
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_2      				    ; RAM address (source)
    ld		de, 1 * 16384		                    ; VRAM address (destiny)
    ld		bc, ImageData_2.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

	; enable page 3
    ld	    a, 3
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_3      				    ; RAM address (source)
    ld		de, 2 * 16384		                    ; VRAM address (destiny)
    ld		bc, ImageData_3.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

	; IS OVERIDING SPR TABL 
    ; enable page 4
    ; ld	    a, 4
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData_4      				    ; RAM address (source)
    ; ld		de, 3 * 16384		                    ; VRAM address (destiny)
    ; ld		bc, ImageData_4.size					; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory


    xor     a
    ld      (VerticalScroll), a

.loop:
    ld      a, (BIOS_JIFFY)
    ld      b, a
.waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, .waitVBlank

    ; vertical scroll
    ld      hl, VerticalScroll
    dec     (hl)
    ld      b, (hl)         ; data
    ld      c, 23           ; register #
    call    BIOS_WRTVDP



    jp      .loop


End:

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
ImageData:
    INCBIN "Images/aerofighters_0.sr8.new"
.size:      equ $ - ImageData
	ds PageSize - ($ - 0x8000), 255

; ------- Page 2
	org	0x8000, 0xBFFF
ImageData_2:
    INCBIN "Images/aerofighters_1.sr8.new"
.size:      equ $ - ImageData_2
	ds PageSize - ($ - 0x8000), 255

; ------- Page 3
	org	0x8000, 0xBFFF
ImageData_3:
    INCBIN "Images/aerofighters_2.sr8.new"
.size:      equ $ - ImageData_3
	ds PageSize - ($ - 0x8000), 255

; ------- Page 4
	org	0x8000, 0xBFFF
ImageData_4:
    INCBIN "Images/aerofighters_3.sr8.new"
.size:      equ $ - ImageData_4
	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)


VerticalScroll:     rb 1

debug_0:    rb 1
debug_1:    rb 1
