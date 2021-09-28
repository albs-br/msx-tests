FNAME "load-image.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/CommonRoutines.s"


; bios call to print a character on screen
; CHPUT:      equ 0x00a2
; NVBXLN: EQU 0xC9
; EXTROM: EQU 0x15F
; CHGMOD: EQU 0x5F
; CHGET: EQU 0x9F
; GXPOS: EQU 0xFCB3
; GYPOS: EQU 0xFCB5
; ATRBYT: EQU 0xF3F3
; LOGOPR: EQU 0xFB02
; NWRVRM: equ 0x0177
; WRTVDP: equ 0x0047


Execute:
			; change to screen 5
            ld      a, 5
           	call    BIOS_CHGMOD
	
            ; set 192 lines
            ld      b, 0 ;&B00000000 ; data
            ld      c, 0x09 ; register #
            call    BIOS_WRTVDP
            
            ; load 32-byte palette data
            ld      hl, PaletteData
            call    LoadPalette

            ; write to VRAM bitmap area
            ld      de, ImageData       ; source in ROM
            ld      hl, 0               ; destiny in VRAM
            ld      bc, ImageData.size  ; number of bytes
.loop:
            ld      a, (de)
			call    BIOS_NWRVRM             
            inc     hl
            inc     de
            dec     bc
            ld      a, c
            or      b
            jp      nz, .loop

            
            
            
.endlessLoop:
            jp      .endlessLoop

PaletteData:
    INCBIN "Images/palette.bin"

ImageData:
    INCBIN "Images/test1-split-file.SC5"
.size:      equ $ - ImageData

End:

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0FFh
