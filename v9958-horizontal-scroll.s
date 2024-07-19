FNAME "v9958-horizontal-scroll.rom"      ; output file

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
    ld      hl, ImageData_2.palette ; PaletteData
    ; ld      hl, Palette
    call    LoadPalette

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData        				    ; RAM address (source)
    ld		de, 0					                ; VRAM address (destiny)
    ld		bc, ImageData.size					    ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            
	; enable page 2
    ld	    a, 2
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_2      				    ; RAM address (source)
    ld		de, 16384			                    ; VRAM address (destiny)
    ld		bc, ImageData_2.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory


    ; TODO: not working:
    ; ; setup horizontal scroll parameters on R#25
    ; ld      a, 25
    ; call    BIOS_RDVDP
    ; and     0111 1100 b     ; keep bits 2-6
    ; or      0000 0000 b     ; set bit 0 (SP2) and bit 1 (MSK)
    ; ld      b, a    ; data
    ; ld      c, 25   ; register #
    ; call    BIOS_WRTVDP

    xor     a
    ld      (Scroll_R26), a
    ld      (Scroll_R27), a

    call    BIOS_ENASCR

; --------- 

.loop:

    ; call    Wait_15_Vblanks
    call    Wait_Vblank

    ; call    .do_Scroll_R26

    ; --- do left scroll at pixel level on R#27 (count going down)
    ld      a, (Scroll_R27)
    or      a
    push    af
        call    z, .do_Scroll_R26
    pop     af

    dec     a
    and     0000 0111 b ; count only 0-7

    ld      (Scroll_R27), a
    ld      b, a    ; data
    ld      c, 27   ; register #
    call    BIOS_WRTVDP


    jp      .loop

.do_Scroll_R26:
    ; --- do left scroll at character level on R#26 (count going up)
    ld      a, (Scroll_R26)
    inc     a
    and     0001 1111 b ; count only 0-31
    ld      (Scroll_R26), a
    ld      b, a    ; data
    ld      c, 26   ; register #
    call    BIOS_WRTVDP
    ret

End:

; Palette:
;     ; INCBIN "Images/title-screen.pal"
;     INCBIN "Images/plane_rotating.pal"

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
ImageData:
    ;INCBIN "Images/aerofighters-xaa"
    INCBIN "Images/metalslug-xaa"
    ; INCBIN "Images/msxmas title scr.SC5"
    ;INCBIN "Images/plane_rotating_0_size_103x71_position_5_3.sc5_small"
.size:      equ $ - ImageData
	ds PageSize - ($ - 0x8000), 255

; ------- Page 2
	org	0x8000, 0xBFFF
ImageData_2:
    ;INCBIN "Images/aerofighters-xab"
    INCBIN "Images/metalslug-xab"
.size:      equ $ - ImageData_2
.palette:   equ $ - 32
	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

Scroll_R26:     rb 1
Scroll_R27:     rb 1
