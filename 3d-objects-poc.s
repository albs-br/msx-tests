FNAME "3d-objects-poc.rom"      ; output file

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

    ; change to screen 4
    ld      a, 4
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    Set192Lines

    call    SetColor0ToNonTransparent


    
    call    BIOS_ENASCR

; --------- 

.start:

    ld      a, (BIOS_JIFFY)
    ld      b, a
.waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, .waitVBlank

    ld      (SavedJiffy), a     ; save low byte of Jiffy


    ; ----- Routine here




    
    ; check if routine take more then one frame
    ld      a, (BIOS_JIFFY)
    ld      b, a
    ld      a, (SavedJiffy)
    cp      b
    jp      z, .lessThanOneFrame

; --- more than one frame
.moreThanOneFrame:
    ; make screen color red
    ld 		a, 8      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 8  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 8      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color

.moreThanOneFrame_loop:    
    call    BIOS_BEEP
    jp      .moreThanOneFrame_loop

.lessThanOneFrame:
    ; make screen color green
    ld 		a, 12      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 12  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 12      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color

    call    BIOS_BEEP
    jp      $

End:

; Palette:
;     ; INCBIN "Images/title-screen.pal"
;     INCBIN "Images/plane_rotating.pal"

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; ; MegaROM pages at 0x8000
; ; ------- Page 1
; 	org	0x8000, 0xBFFF
; ImageData:
;     ;INCBIN "Images/aerofighters-xaa"
; .size:      equ $ - ImageData
; 	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff

SavedJiffy:     rb 1

