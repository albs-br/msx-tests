FNAME "vertical-scroll-screen11.rom"      ; output file

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

NAMTBL:     equ 0x00000

; --------- Load first screen     
    ld	    a, 14
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_14        			    ; RAM address (source)
    ld		de, NAMTBL + (0 * (256 * 64))                ; VRAM address (destiny)
    ld		bc, ImageData_14.size				    ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            
    ; -- Load middle part of first image on last 64 lines
    ld	    a, 15
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_15      				    ; RAM address (source)
    ld		de, NAMTBL + (1 * (256 * 64))                ; VRAM address (destiny)
    ld		bc, ImageData_15.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    ; -- Load bottom part of first image on last 64 lines
    ld	    a, 16
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_16      				    ; RAM address (source)
    ld		de, NAMTBL + (2 * (256 * 64))                ; VRAM address (destiny)
    ld		bc, ImageData_16.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    call    BIOS_ENASCR

; --------- 

ADDR_LAST_LINE_OF_PAGE: equ 0x8000 + (63 * 256)


.start:
    ; initialize variables for scrolling on last line of the next page
    ld      a, 13
    ld      (CurrentMegaROMPage), a
    ld      hl, ADDR_LAST_LINE_OF_PAGE
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
; .endlessLoop:
;     jp  .endlessLoop

    ; load next line from bitmap on the last line of virtual screen (256 lines)
    ; that will be the next to be shown on top of screen
    ld	    a, (CurrentMegaROMPage)
	ld	    (Seg_P8000_SW), a
    ld      hl, (CurrentAddrLineScroll)             ; RAM address (source)
    ld		de, (CurrentVRAMAddrLineScroll)         ; VRAM address (destiny)
    ld		bc, 256					                ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
	; ld	    hl, (CurrentVRAMAddrLineScroll)		; VRAM start address
    ; ld      bc, 256                             ; number of bytes
    ; ld      a, 00011100 b                       ; value
    ; call    BIOS_FILVRM                         ; Fill VRAM

    ; update vars
    ld      de, (CurrentVRAMAddrLineScroll)
    dec     d                                       ; de = de - 256
    ld      hl, (CurrentAddrLineScroll)
    dec     h                                       ; hl = hl - 256
    ld      a, h
    cp      0x80 - 1
    jp      z, .decPage
    jp      .dontDecPage
.decPage:
    ld      a, (CurrentMegaROMPage)
    dec     a
    jp      z, .stopScroll
    ld      (CurrentMegaROMPage), a
    ld      hl, ADDR_LAST_LINE_OF_PAGE
.dontDecPage:
    ld      (CurrentAddrLineScroll), hl
    ld      (CurrentVRAMAddrLineScroll), de


    ; vertical scroll
    ld      hl, VerticalScroll
    dec     (hl)
    ld      b, (hl)         ; data
    ld      c, 23           ; register #
    call    BIOS_WRTVDP



    jp      .loop

.stopScroll:
    jp      .stopScroll


End:

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
ImageData_1:
    ; INCBIN "Images/aerofighters_0.sra.new"
    INCBIN "Images/aerofighters-bg2_0.sra.new"
.size:      equ $ - ImageData_1
	ds PageSize - ($ - 0x8000), 255

; ------- Page 2
	org	0x8000, 0xBFFF
ImageData_2:
    ; INCBIN "Images/aerofighters_1.sra.new"
    INCBIN "Images/aerofighters-bg2_1.sra.new"
.size:      equ $ - ImageData_2
	ds PageSize - ($ - 0x8000), 255

; ------- Page 3
	org	0x8000, 0xBFFF
ImageData_3:
    ; INCBIN "Images/aerofighters_2.sra.new"
    INCBIN "Images/aerofighters-bg2_2.sra.new"
.size:      equ $ - ImageData_3
	ds PageSize - ($ - 0x8000), 255

; ------- Page 4
	org	0x8000, 0xBFFF
ImageData_4:
    ; INCBIN "Images/aerofighters_3.sra.new"
    INCBIN "Images/aerofighters-bg2_3.sra.new"
.size:      equ $ - ImageData_4
	ds PageSize - ($ - 0x8000), 255

; ------- Page 5
	org	0x8000, 0xBFFF
ImageData_5:
    ; INCBIN "Images/aerofighters_4.sra.new"
    INCBIN "Images/aerofighters-bg2_4.sra.new"
.size:      equ $ - ImageData_5
	ds PageSize - ($ - 0x8000), 255

; ------- Page 6
	org	0x8000, 0xBFFF
ImageData_6:
    ; INCBIN "Images/aerofighters_5.sra.new"
    INCBIN "Images/aerofighters-bg2_5.sra.new"
.size:      equ $ - ImageData_6
	ds PageSize - ($ - 0x8000), 255

; ------- Page 7
	org	0x8000, 0xBFFF
ImageData_7:
    ; INCBIN "Images/aerofighters_6.sra.new"
    INCBIN "Images/aerofighters-bg2_6.sra.new"
.size:      equ $ - ImageData_7
	ds PageSize - ($ - 0x8000), 255

; ------- Page 8
	org	0x8000, 0xBFFF
ImageData_8:
    ; INCBIN "Images/aerofighters_7.sra.new"
    INCBIN "Images/aerofighters-bg2_7.sra.new"
.size:      equ $ - ImageData_8
	ds PageSize - ($ - 0x8000), 255

; ------- Page 9
	org	0x8000, 0xBFFF
ImageData_9:
    ; INCBIN "Images/aerofighters_8.sra.new"
    INCBIN "Images/aerofighters-bg2_8.sra.new"
.size:      equ $ - ImageData_9
	ds PageSize - ($ - 0x8000), 255

; ------- Page 10
	org	0x8000, 0xBFFF
ImageData_10:
    ; INCBIN "Images/aerofighters_9.sra.new"
    INCBIN "Images/aerofighters-bg2_9.sra.new"
.size:      equ $ - ImageData_10
	ds PageSize - ($ - 0x8000), 255

; ------- Page 11
	org	0x8000, 0xBFFF
ImageData_11:
    ;INCBIN "Images/aerofighters_10.sra.new"
    INCBIN "Images/aerofighters-bg2_10.sra.new"
.size:      equ $ - ImageData_11
	ds PageSize - ($ - 0x8000), 255

; ------- Page 12
	org	0x8000, 0xBFFF
ImageData_12:
    ; INCBIN "Images/aerofighters_11.sra.new"
    INCBIN "Images/aerofighters-bg2_11.sra.new"
.size:      equ $ - ImageData_12
	ds PageSize - ($ - 0x8000), 255

; ------- Page 13
	org	0x8000, 0xBFFF
ImageData_13:
    ; INCBIN "Images/aerofighters_12.sra.new"
    INCBIN "Images/aerofighters-bg2_12.sra.new"
.size:      equ $ - ImageData_13
	ds PageSize - ($ - 0x8000), 255

; ------- Page 14
	org	0x8000, 0xBFFF
ImageData_14:
    ; INCBIN "Images/aerofighters_13.sra.new"
    INCBIN "Images/aerofighters-bg2_13.sra.new"
.size:      equ $ - ImageData_14
	ds PageSize - ($ - 0x8000), 255

; ------- Page 15
	org	0x8000, 0xBFFF
ImageData_15:
    ; INCBIN "Images/aerofighters_14.sra.new"
    INCBIN "Images/aerofighters-bg2_14.sra.new"
.size:      equ $ - ImageData_15
	ds PageSize - ($ - 0x8000), 255

; ------- Page 16
	org	0x8000, 0xBFFF
ImageData_16:
    ; INCBIN "Images/aerofighters_15.sra.new"
    INCBIN "Images/aerofighters-bg2_15.sra.new"
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
