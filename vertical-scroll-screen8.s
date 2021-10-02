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

    call    BIOS_DISSCR

    ; set 192 lines
    ld      b, 0000 0000 b  ; data
    ld      c, 0x09         ; register #
    call    BIOS_WRTVDP

    ; set SPRPAT to 0xF000

    ; set SPRCOL to 0xF800

    ; set SPRATR to 0xFA00



; --------- Load first screen     
	; enable page 1
    ld	    a, 13
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_13        			    ; RAM address (source)
    ld		de, 0 + (0 * (256 * 64))                ; VRAM address (destiny)
    ld		bc, ImageData_13.size				    ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            
    ; -- Load middle part of first image on last 64 lines
    ld	    a, 14
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_14      				    ; RAM address (source)
    ld		de, 0 + (1 * (256 * 64))                ; VRAM address (destiny)
    ld		bc, ImageData_14.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

	
    ; -- Load bottom part of first image on last 64 lines
    ; enable page 15
    ld	    a, 15
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_15      				    ; RAM address (source)
    ld		de, 0 + (2 * (256 * 64))                ; VRAM address (destiny)
    ld		bc, ImageData_15.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    call    BIOS_ENASCR

; --------- 

	; IS OVERIDING SPR TABL 
    ; enable page 4
    ; ld	    a, 4
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData_4      				    ; RAM address (source)
    ; ld		de, 3 * 16384		                    ; VRAM address (destiny)
    ; ld		bc, ImageData_4.size					; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    ; initialize variables for scrolling on last line of the next page
    ld      a, 12
    ld      (CurrentMegaROMPage), a
    ld      hl, 63 * 256
    ld      (CurrentAddrLineScroll), hl
    ld      hl, 255 * 256
    ld      (CurrentVRAMAddrLineScroll), hl


    xor     a
    ld      (VerticalScroll), a

.loop:
    ld      a, (BIOS_JIFFY)
    ld      b, a
.waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, .waitVBlank

    ;call    Wait

    ; load next line from bitmap on the last line of virtual screen (256 lines)
    ; that will be the next to be shown on top of screen
    ; ld	    a, (CurrentMegaROMPage)
	; ld	    (Seg_P8000_SW), a
    ; ld      hl, (CurrentAddrLineScroll)             ; RAM address (source)
    ; ld		de, (CurrentVRAMAddrLineScroll)         ; VRAM address (destiny)
    ; ld		bc, 256					                ; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
	ld	    hl, (CurrentVRAMAddrLineScroll)		; VRAM start address
    ld      bc, 256                             ; number of bytes
    ld      a, 00011100 b                       ; value
    call    BIOS_FILVRM                         ; Fill VRAM

    ; update vars
    ld      de, (CurrentVRAMAddrLineScroll)
    dec     d                                       ; de = de - 256
    ld      hl, (CurrentAddrLineScroll)
    dec     h                                       ; hl = hl - 256
.endlessLoop:
    jp      z, .endlessLoop
    ld      (CurrentAddrLineScroll), hl
    ld      (CurrentVRAMAddrLineScroll), de


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
ImageData_1:
    INCBIN "Images/aerofighters_0.sr8.new"
.size:      equ $ - ImageData_1
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

; ------- Page 5
	org	0x8000, 0xBFFF
ImageData_5:
    INCBIN "Images/aerofighters_4.sr8.new"
.size:      equ $ - ImageData_5
	ds PageSize - ($ - 0x8000), 255

; ------- Page 6
	org	0x8000, 0xBFFF
ImageData_6:
    INCBIN "Images/aerofighters_5.sr8.new"
.size:      equ $ - ImageData_6
	ds PageSize - ($ - 0x8000), 255

; ------- Page 7
	org	0x8000, 0xBFFF
ImageData_7:
    INCBIN "Images/aerofighters_6.sr8.new"
.size:      equ $ - ImageData_7
	ds PageSize - ($ - 0x8000), 255

; ------- Page 8
	org	0x8000, 0xBFFF
ImageData_8:
    INCBIN "Images/aerofighters_7.sr8.new"
.size:      equ $ - ImageData_8
	ds PageSize - ($ - 0x8000), 255

; ------- Page 9
	org	0x8000, 0xBFFF
ImageData_9:
    INCBIN "Images/aerofighters_8.sr8.new"
.size:      equ $ - ImageData_9
	ds PageSize - ($ - 0x8000), 255

; ------- Page 10
	org	0x8000, 0xBFFF
ImageData_10:
    INCBIN "Images/aerofighters_9.sr8.new"
.size:      equ $ - ImageData_10
	ds PageSize - ($ - 0x8000), 255

; ------- Page 11
	org	0x8000, 0xBFFF
ImageData_11:
    INCBIN "Images/aerofighters_10.sr8.new"
.size:      equ $ - ImageData_11
	ds PageSize - ($ - 0x8000), 255

; ------- Page 12
	org	0x8000, 0xBFFF
ImageData_12:
    INCBIN "Images/aerofighters_11.sr8.new"
.size:      equ $ - ImageData_12
	ds PageSize - ($ - 0x8000), 255

; ------- Page 13
	org	0x8000, 0xBFFF
ImageData_13:
    INCBIN "Images/aerofighters_12.sr8.new"
.size:      equ $ - ImageData_13
	ds PageSize - ($ - 0x8000), 255

; ------- Page 14
	org	0x8000, 0xBFFF
ImageData_14:
    INCBIN "Images/aerofighters_13.sr8.new"
.size:      equ $ - ImageData_14
	ds PageSize - ($ - 0x8000), 255

; ------- Page 15
	org	0x8000, 0xBFFF
ImageData_15:
    INCBIN "Images/aerofighters_14.sr8.new"
.size:      equ $ - ImageData_15
	ds PageSize - ($ - 0x8000), 255

; ------- Page 16
	org	0x8000, 0xBFFF
ImageData_16:
    INCBIN "Images/aerofighters_15.sr8.new"
.size:      equ $ - ImageData_16
	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)


VerticalScroll:             rb 1
CurrentMegaROMPage:         rb 1
CurrentAddrLineScroll:      rw 1
CurrentVRAMAddrLineScroll:  rw 1


debug_0:    rb 1
debug_1:    rb 1
