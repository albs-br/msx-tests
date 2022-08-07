FNAME "show-image-screen7.rom"      ; output file

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

	; ; enable page 1
    ; ld	    a, 1
	; ld	    (Seg_P8000_SW), a

    ; set screen 7 (VDP mode G6, 512x212 16 colors)
    ld      a, 7
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    Set212Lines

    ; set pattern layout base address to page 1
    ; ld      a, (REG2SAV)
    ; or      0010 0000 b
    ; ld      b, a
    ld      b, 0011 1111 b
    ld      c, 2            ; register #
    call    BIOS_WRTVDP


    call    SetInterlacedMode
    

    call    SetColor0ToNonTransparent

    
	; ; enable page 2
    ; ld	    a, 2
	; ld	    (Seg_P8000_SW), a
    ; ; load 32-byte palette data
    ; ld      hl, ImageData_2.palette ; PaletteData
    ;                 ; ; debug
    ;                 ; ld      a, (hl)
    ;                 ; ld      (debug_0), a
    ;                 ; inc     hl
    ;                 ; ld      a, (hl)
    ;                 ; ld      (debug_1), a
    ;                 ; ld      hl, ImageData_2.palette ; PaletteData
    ; call    LoadPalette
    
    ; ld      hl, PaletteData
    ld      hl, PaletteData_without_Header
    call    LoadPalette

    ; ---------------- draw even lines on page 0

    ld	    a, 1
	ld	    (Seg_P8000_SW), a
    ld		hl, ImageData_without_Header	        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, 0x0000                              ; VRAM address (destiny, bits 15-0)
    ld		c, 64; 0 + (ImageData.size / 256)           ; Block length * 256
    call    LDIRVM_MSX2

	; ; enable page 1
    ; ld	    a, 1
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData        				    ; RAM address (source)
    ; ld		de, 0x00000				                ; VRAM address (destiny)
    ; ld		bc, ImageData.size					    ; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            
    ; ----------------- draw odd lines on page 1

    ld	    a, 2
	ld	    (Seg_P8000_SW), a
    ld		hl, ImageData_2_without_Header	        ; RAM address (source)
    ld      a, 1                                    ; VRAM address (destiny, bit 16)
    ld		de, 0x0000                              ; VRAM address (destiny, bits 15-0)
    ld		c, 64 ; 0 + (ImageData_2.size / 256)         ; Block length * 256
    call    LDIRVM_MSX2

	; ; enable page 2
    ; ld	    a, 2
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData_2      				    ; RAM address (source)
    ; ld		de, 0x10000			                    ; VRAM address (destiny)
    ; ld		bc, ImageData_2.size					; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    call    BIOS_ENASCR

; --------- 

.endlessLoop:
    jp      .endlessLoop


End:

PaletteData:
    ;INCBIN "Images/simcity2000_bmp2msx.pal"
    ;INCBIN "Images/test.pi7"
    INCBIN "Images/simcity2000_MIFui.pi7"
PaletteData_without_Header: equ PaletteData + 7


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
ImageData:
    ;INCBIN "Images/simcity2000_bmp2msx.S70"
    ;INCBIN "Images/test.si7"
    INCBIN "Images/simcity2000_MIFui.si7"
.size:      equ $ - ImageData
	ds PageSize - ($ - 0x8000), 255
ImageData_without_Header: equ ImageData + 7

; ------- Page 2
	org	0x8000, 0xBFFF
ImageData_2:
    ;INCBIN "Images/simcity2000_bmp2msx.S71"
    ;INCBIN "Images/test.sj7"
    INCBIN "Images/simcity2000_MIFui.sj7"
.size:      equ $ - ImageData_2
.palette:   equ $ - 32
	ds PageSize - ($ - 0x8000), 255
ImageData_2_without_Header: equ ImageData_2 + 7



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

debug_0:    rb 1
debug_1:    rb 1
