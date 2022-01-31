FNAME "test1.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"

    INCLUDE "ayfx_player_test/ayfxreplayer.s"


Execute:

.loop:
    ld      a, (BIOS_JIFFY)
    ld      b, a
.waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, .waitVBlank

    ; ...... do stuff here

    ;In ISR:

    call PT3_ROUT ; copia AYREGS a los registros del PSG
    call ayFX_PLAY ; hace sonar los efectos de sonido

    call    PlayFX


    jp      .loop


PlayFX:
    ;Call FX:

    ; LD HL,"name.afb"
    LD HL, test1_afx
    LD A,200
    LD (ayFX_VOLUME),A
    CALL ayFX_SETUP
    XOR A
    LD C,1
    CALL ayFX_INIT
    XOR A
    LD (ayFX_VOLUME),A 
    RET


test1_afx:
    INCBIN "ayfx_player_test/test1.afx"

End:

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF



; RAM
	org     0xc000, 0xe5ff                   ; for m


	;MAP 0xC000
;Variables
AYREGS:		    rb 14
ayFX_MODE:      rb 1 ;				; ayFX mode
ayFX_BANK:      rb 2 ;				; Current ayFX Bank
ayFX_PRIORITY:  rb 1 ;				; Current ayFX stream priotity
ayFX_POINTER:   rb 2 ;				; Pointer to the current ayFX stream
ayFX_TONE:      rb 2 ;				; Current tone of the ayFX stream
ayFX_NOISE:	    rb 1 ;				; Current noise of the ayFX stream
ayFX_VOLUME: 	rb 1 ;				; Current volume of the ayFX stream
ayFX_CHANNEL: 	rb 1 ;				; PSG channel to play the ayFX stream
ayFX_VT: 	    rb 2 ;				; ayFX relative volume table pointer
VARayFXEND:     rb 1 ; 


