FNAME "readkeyboard-using-newkey.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

keys: EQU 0xFBE5

Execute:

    ; it only works with this block on start:
    ld 		a, 15      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 1  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld      a, 1
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color

.loop:
    call    Wait_Vblank

    ; Check whether space is pressed
    ld      a, (keys + 8)   ; space
    bit     0, a
    call    z, .spacepressed

    jp      .loop

.spacepressed:
    call    BIOS_BEEP

    ld 		a, 15      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 1  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    
    ld 		a, (BIOS_BDRCLR)        ; Border color
    inc     a
    and     0000 1111 b             ; keep 0-15 range
    ;ld      a, 13
    ld 		(BIOS_BDRCLR), a    
    
    call 	BIOS_CHGCLR        		; Change Screen Color


    ret



    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff
