FNAME "pt3-player-msxlib.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; -----------------------------------------------------------------------------

SONG_TABLE:
	dw	.PT3_Music_sample
	dw	.empty
.PT3_Music_sample:
    INCBIN "Sound/StayorGo.pt3"
.empty:
	incbin	"games/minigames/run23/music/empty.pt3.hl.zx0"

; SOUND_BANK:
; 	incbin	"games/minigames/run23/music/run23.afb"

; 	CFG_SOUND_JOIN:			equ 1 -1
; 	CFG_SOUND_PUSH:			equ 2 -1
; 	CFG_SOUND_TIMEOUT:		equ 3 -1
; 	CFG_SOUND_WEIGHT_MOVE:		equ 5 -1
; 	CFG_SOUND_WEIGHT_FALL:		equ 4 -1


; -----------------------------------------------------------------------------
; Replayer routines

; Define to enable packed songs when using the PT3-based implementation
	CFG_PT3_PACKED:

; Define to use headerless PT3 files (without first 100 bytes)
	CFG_PT3_HEADERLESS:

; PT3-based implementation
	include	"include/replayer_pt3.asm"

; ayFX REPLAYER v1.31
	include	"include/ayFX-ROM.tniasm.asm"
; -----------------------------------------------------------------------------



; ---- init new game
; No music
	ld	a, 2
	call	REPLAYER.PLAY


; Starts the music
	xor	a
	call	REPLAYER.PLAY


; Starts the music
	ld	a, $80 + 1
	call	REPLAYER.PLAY


; Stops the music
	jp	REPLAYER.STOP




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