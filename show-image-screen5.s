FNAME "show-image-screen5.rom"      ; output file

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

    call    Set192Lines

    call    SetColor0ToNonTransparent


    
	; enable page 2
    ld	    a, 2
	ld	    (Seg_P8000_SW), a
    ; load 32-byte palette data
    ;ld      hl, ImageData_2.palette ; PaletteData
                    ; ; debug
                    ; ld      a, (hl)
                    ; ld      (debug_0), a
                    ; inc     hl
                    ; ld      a, (hl)
                    ; ld      (debug_1), a
                    ; ld      hl, ImageData_2.palette ; PaletteData
    ld      hl, Palette
    call    LoadPalette

	; ; enable page 1
    ; ld	    a, 1
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData        				    ; RAM address (source)
    ; ld		de, 0					                ; VRAM address (destiny)
    ; ld		bc, ImageData.size					    ; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            
	; ; enable page 2
    ; ld	    a, 2
	; ld	    (Seg_P8000_SW), a
    ; ; write to VRAM bitmap area
    ; ld		hl, ImageData_2      				    ; RAM address (source)
    ; ld		de, 16384			                    ; VRAM address (destiny)
    ; ld		bc, ImageData_2.size					; Block length
    ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory

    ; ---- load sc5 image with width = 103 pixels (52 bytes), and height = 71 lines
	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a
    ld		hl, ImageData        				    ; RAM address (source)
    ld		de, 0					                ; VRAM address (destiny)
    ld      b, 71 ; height
.loop:
    push    bc
        push    de
            ; write to VRAM bitmap area
            ; ld		bc, 52 ; width			                ; Block length
            ; call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            ld      a, 0000 0000 b
            ; ld      hl, PATTBL
            ex      de, hl
                call    SetVdp_Write
            ex      de, hl
            ld      b, 52
            ld      c, PORT_0
            otir
        pop     de
        
        ; DE += 128
        push    hl
            ex      de, hl
                ld      bc, 128         ; next sc5 line
                add     hl, bc
            ex      de, hl
        pop     hl

    pop     bc

    djnz    .loop

    call    BIOS_ENASCR

; --------- 

.endlessLoop:
    jp      .endlessLoop

End:

Palette:
    ; INCBIN "Images/title-screen.pal"
    INCBIN "Images/plane_rotating.pal"

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
ImageData:
    ;INCBIN "Images/aerofighters-xaa"
    ;INCBIN "Images/metalslug-xaa"
    ; INCBIN "Images/msxmas title scr.SC5"
    INCBIN "Images/plane_rotating_0_size_103x71_position_5_3.sc5_small"
.size:      equ $ - ImageData
	ds PageSize - ($ - 0x8000), 255

; ; ------- Page 2
; 	org	0x8000, 0xBFFF
; ImageData_2:
;     INCBIN "Images/aerofighters-xab"
;     ;INCBIN "Images/metalslug-xab"
; .size:      equ $ - ImageData_2
; .palette:   equ $ - 32
; 	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

debug_0:    rb 1
debug_1:    rb 1
