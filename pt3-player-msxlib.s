FNAME "pt3-player-msxlib.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"


; INCLUDES from msxlib:
	include	"include/msxlib/asm.asm"



; -----------------------------------------------------------------------------

SONG_TABLE:
	dw	.PT3_Music_sample
	; dw	.empty
.PT3_Music_sample:
    INCBIN "Sound/StayorGo.pt3", 100
; .empty:
; 	incbin	"games/minigames/run23/music/empty.pt3.hl.zx0"

SOUND_BANK:
	; incbin	"games/minigames/run23/music/run23.afb"

	; CFG_SOUND_JOIN:			equ 1 -1
	; CFG_SOUND_PUSH:			equ 2 -1
	; CFG_SOUND_TIMEOUT:		equ 3 -1
	; CFG_SOUND_WEIGHT_MOVE:		equ 5 -1
	; CFG_SOUND_WEIGHT_FALL:		equ 4 -1


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
; ; No music
; 	ld	a, 2
; 	call	REPLAYER.PLAY


; ; Starts the music
; 	xor	a
; 	call	REPLAYER.PLAY


; Starts the music
	; ld	a, $80 + 1
	ld	a, $80 + 0
	call	REPLAYER.PLAY


; ; Stops the music
; 	jp	REPLAYER.STOP




Execute:

    ; ld      hl, Debug_Message
    ; call    PrintString

    call    BIOS_INITXT


.loop:

	;wait vblank
    ld      a, (BIOS_JIFFY)
    ld      b, a
.waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, .waitVBlank

; Invokes the replayer
IFEXIST REPLAYER.FRAME
; Invokes the replayer (with frameskip in 60Hz machines)
	ld	a, 5 ;6 ; [frames_per_tenth]
	cp	5
	jr	z, .NO_FRAMESKIP ; No frameskip (50Hz machine)
; Checks frameskip (60Hz machine)
	; ld	a, 6 ; (unnecessary)
	ld	hl, replayer.frameskip
	inc	[hl]
	sub	[hl]
	jr	nz, .NO_FRAMESKIP ; No framewksip
; Resets frameskip counter
	; xor	a ; (unnecessary)
	ld	[hl], a
	jr	.FRAMESKIP

.NO_FRAMESKIP:
; Executes a frame of the replayer
	call	REPLAYER.FRAME
.FRAMESKIP:
ENDIF ; REPLAYER.FRAME

    ; call    BIOS_BEEP

    jp      .loop


PrintString:
    ld      a, (hl)
    cp      0
    ret     z
    call    BIOS_CHPUT
    inc     hl
    jr      PrintString

Debug_Message:
    db      "Test message", 0

    db      "End ROM started at 0x4000"

    ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff



; RAM
	org     0xc000, 0xe5ff

; ; -----------------------------------------------------------------------------
; ; Unpacker routine buffer
; unpack_buffer:
; 	rb	CFG_RAM_RESERVE_BUFFER

	include	"include/PT3-RAM.tniasm.asm"

	include	"include/ayFX-RAM.tniasm.asm"

; 60Hz replayer synchronization
replayer.frameskip:
	rb	1