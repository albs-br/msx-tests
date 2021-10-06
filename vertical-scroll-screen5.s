FNAME "vertical-scroll-screen5.rom"      ; output file

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

    ; Das 16 cores da paleta, a cor 0 é transparente, ou seja, não pode
    ; ser definida uma cor para ela e qualquer objeto desenhado com ela não
    ; será visto. Entretanto, setando o bit 5 de R#8, a função de transparente
    ; será desativada e a cor 0 poderá ser definida por P#0.    
    ; set color 0 to non transparent
    ld      b, 0010 0000 b  ; data
    ld      c, 0x08         ; register #
    call    BIOS_WRTVDP
    
    ; set 192 lines
    ld      b, 0000 0000 b  ; data
    ld      c, 0x09         ; register #
    call    BIOS_WRTVDP

    
	; enable page 2
    ld	    a, 2
	ld	    (Seg_P8000_SW), a
    ; load 32-byte palette data
    ld      hl, ImageData_2.palette ; PaletteData
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
    INCBIN "Images/aerofighters-xaa"
    ;INCBIN "Images/metalslug-xaa"
.size:      equ $ - ImageData
	ds PageSize - ($ - 0x8000), 255

; ------- Page 2
	org	0x8000, 0xBFFF
ImageData_2:
    INCBIN "Images/aerofighters-xab"
    ;INCBIN "Images/metalslug-xab"
.size:      equ $ - ImageData_2
.palette:   equ $ - 32
	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)


VerticalScroll:     rb 1

debug_0:    rb 1
debug_1:    rb 1
