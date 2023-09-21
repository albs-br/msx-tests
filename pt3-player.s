FNAME "pt3-player.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

PT3_Music_sample:
    INCBIN "Sound/StayorGo.pt3"


; code that needs to be realocated later need to be PHASE'd and DEPHASE'd 
; in order to solve correctly the labels
PHASE   0xc000

pt3_player:
    INCLUDE "Include/pt3.asm"
pt3_player.size: equ $ - pt3_player

DEPHASE

Execute:

    ; pt3 player need to be on RAM, as it uses self-modifying code
    ld	    hl, pt3_player
    ld	    de, pt3_player_ram_addr
    ld	    bc, pt3_player.size
    ldir

    ld      hl, PT3_Music_sample
    call    INIT

.loop:

	;wait vblank
    ld      a, (BIOS_JIFFY)
    ld      b, a
.waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, .waitVBlank

    call    PLAY

    ; call    BIOS_BEEP
    jp      .loop

    db      "End ROM started at 0x4000"

    ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff



; RAM
	org     0xc000, 0xe5ff


pt3_player_ram_addr:     rb pt3_player.size