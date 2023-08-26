FNAME "v9990-openmsx-issue-1466-A.rom"      ; output file

; Test file provided for help with openmsx issue:
; https://github.com/openMSX/openMSX/issues/1466

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/V9990.s"


Execute:

    call    V9.Mode_P1

    call    V9.ClearVRAM





    ; ----------- Enable both layers and sprites
    
    ;          +---- SDA: Set to "1" to disable layer "A" and sprites.
    ;          |+--- SDB: Set to "1" to disable layer "B" and sprites.
    ;          ||
    ld      b, 0000 0000 b  ; value
    ld      a, 22           ; register number
    call    V9.SetRegister


    INCLUDE "v9990-openmsx-issue-1466-common.s"


; -------------------------
	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF
