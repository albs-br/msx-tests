FNAME "pt3-player.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"
    
    INCLUDE "Include/pt3.asm"

Execute:

    jp      $ ; eternal loop

    db      "End ROM started at 0x4000"

    ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff
