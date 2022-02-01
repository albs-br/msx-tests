FNAME "test1.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"

    INCLUDE "ayfx_player_test/ayfxreplayer.s"


Execute:
; init interrupt mode and stack pointer (in case the ROM isn't the first thing to be loaded)
	di                          ; disable interrupts
	im      1                   ; interrupt mode 1
    ld      sp, (BIOS_HIMEM)    ; init SP

; Install the interrupt routine
	di
	ld	    a, 0xc3 ; opcode for "JP nn"
	ld	    (HTIMI), a
	ld	    hl, HOOK
	ld	    (HTIMI + 1), hl
	ei


    call    BIOS_INIGRP


    call    InitVariables


.loop:
    ld      a, (BIOS_JIFFY)
    ld      b, a
.waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, .waitVBlank

    ;call    BIOS_BEEP

    call    PlayFX



    jp      .loop

; H.TIMI hook
HOOK:

	push	af ; Preserves VDP status register S#0 (a)
		; push	bc
		; 	push	de
		; 		push	hl

                    ;In ISR:

                    call PT3_ROUT ; copia AYREGS a los registros del PSG
                    call ayFX_PLAY ; hace sonar los efectos de sonido

					; ; Tricks BIOS' KEYINT to skip keyboard scan, TRGFLG, OLDKEY/NEWKEY, ON STRIG...
					; xor		a
					; ld		(BIOS_SCNCNT), a
					; ld		(BIOS_INTCNT), a

		; 		pop		hl
		; 	pop		de
		; pop		bc
	pop		af ; Restores VDP status register S#0 (a)


	ret


PlayFX:
    ;Call FX:

    LD HL, noname_afb
    LD A,200
    LD (ayFX_VOLUME),A
    CALL ayFX_SETUP
    
    ld      a, 1    ; number of sfx in the bank
    ld      c, 1    ; sound priority
    call    ayFX_INIT
    
    XOR A
    LD (ayFX_VOLUME),A 
    RET


InitVariables:
    ; Init all vars with 255 to avoid noise
    ld      a, 255
    ld      hl, Variables
    ld      b, Variables.size
.loop:
    ld      (hl), a
    inc     hl
    djnz    .loop    
    ret


test1_afx:
    INCBIN "ayfx_player_test/test1.afx"
noname_afb:
    INCBIN "ayfx_player_test/noname.afb"

End:

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF



; RAM
	org     0xc000, 0xe5ff                   ; for m


	;MAP 0xC000
Variables:
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
Variables.size:     equ $ - Variables

