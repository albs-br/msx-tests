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

; Automatically reads the keyboard
	; CFG_HOOK_ENABLE_AUTO_KEYBOARD:

; -----------------------------------------------------------------------------

SONG_TABLE:
	dw	.PT3_Music_sample
	dw	.ShuffleOne
	dw	.YouWin1
	dw	.empty
.PT3_Music_sample:
    INCBIN "Sound/StayorGo.pt3"
.ShuffleOne:
	incbin	"Sound/RUN23_ShuffleOne.pt3"
.YouWin1:
	incbin	"Sound/RUN23_YouWin1.pt3"
.empty:
	incbin	"Sound/empty.pt3"

SOUND_BANK:
    INCBIN "Sound/MsxWingsSfx_Bank.afb"
	; incbin	"games/minigames/run23/music/run23.afb"

SFX_EXPLOSION:          equ 0
SFX_SHOT:               equ 1
SFX_GET_ITEM:           equ 2
SFX_GET_DOLLAR_ITEM:    equ 3


; -----------------------------------------------------------------------------
; Replayer routines

; Define to enable packed songs when using the PT3-based implementation
	; CFG_PT3_PACKED:

; Define to use headerless PT3 files (without first 100 bytes)
	; CFG_PT3_HEADERLESS:

; PT3-based implementation
	include	"include/replayer_pt3.asm"

; ; ayFX REPLAYER v1.31
; 	include	"include/ayFX-ROM.tniasm.asm"
; -----------------------------------------------------------------------------



Execute:


; Install the interrupt routine
	di
		ld	a, 0xc3 ; opcode for "JP nn"
		ld	[HTIMI], a
		ld	hl, HOOK
		ld	[HTIMI+1], hl
	ei



; ---- init new game

; Starts the music
    ld      a, 0 			; index of music on SONG_TABLE
 	call	REPLAYER.PLAY 	; param a: liiiiiii, where l (MSB) is the loop flag (0 = loop), and iiiiiii is the 0-based song index (0, 1, 2...)




; ; Stops the music
; 	jp	REPLAYER.STOP
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



; 	; ----- play sfx when spacebar pressed
;     ld      a, 0                    ; read spacebar
;     call    BIOS_GTTRIG
;     jp    	nz, .playSFX
; 	jp		.continue


; .playSFX:
; 	ld      hl, Spacebar_Pressed_Message
;     call    PrintString

; 	ld	a, SFX_GET_DOLLAR_ITEM		; sfx index
; 	ld	c, 0						; sound priority
; 	call	ayFX_INIT
; .continue:
; 	; -------------------------------------


    
	ld      hl, Debug_Message
    call    PrintString

    jp      .loop


PrintString:
    ld      a, (hl)
    cp      0
    ret     z
    call    BIOS_CHPUT
    inc     hl
    jr      PrintString

Debug_Message:    				db      "Test message", 13, 10, 13, 10, 0
Spacebar_Pressed_Message:    	db      "Spacbar pressed", 13, 10, 0

; -----------------------------------------------------------------------------
; H.TIMI hook
; 1. Invokes the replayer
; 2. Reads the inputs
; 3. Tricks BIOS' KEYINT to skip keyboard scan, TRGFLG, OLDKEY/NEWKEY, ON STRIG...
; 5. Invokes the previously existing hook
HOOK:
	push	af ; Preserves VDP status register S#0 (a)

		; Invokes the replayer (with frameskip in 60Hz machines)
		ld	a, [frames_per_tenth]
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

		; ; Reads the inputs
		; 	IFDEF CFG_HOOK_ENABLE_AUTO_KEYBOARD
		; 		call	READ_KEYBOARD
		; 	ENDIF ; CFG_HOOK_ENABLE_AUTO_KEYBOARD

		; 	IFEXIST CFG_HOOK_DISABLE_AUTO_INPUT
		; 	ELSE
		; 		call	READ_INPUT
		; 	ENDIF ; CFG_HOOK_DISABLE_AUTO_INPUT

		; Tricks BIOS' KEYINT to skip keyboard scan, TRGFLG, OLDKEY/NEWKEY, ON STRIG...
		xor	a
		ld	[BIOS_SCNCNT], a
		ld	[BIOS_INTCNT], a

	pop	af ; Restores VDP status register S#0 (a)

	; Tricks BIOS' KEYINT to skip ON SPRITE...
	; IFDEF CFG_HOOK_PRESERVE_SPRITE_COLLISION_FLAG
	; ELSE
	and	$df ; Turns off sprite collision flag
	; ENDIF ; IFDEF CFG_HOOK_PRESERVE_SPRITE_COLLISION_FLAG

	; Invokes the previously existing hook
	; IFDEF CFG_INIT_USE_HIMEM_KEEP_HOOKS
	; 	jp	old_htimi_hook
	; ELSE
	ret
	; ENDIF ; IFDEF CFG_INIT_USE_HIMEM_KEEP_HOOKS

; -----------------------------------------------------------------------------


    db      "End ROM started at 0x4000"

    ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff



; RAM
	org     0xc000, 0xe5ff

; ; -----------------------------------------------------------------------------
; ; Unpacker routine buffer
; unpack_buffer:
; 	rb	CFG_RAM_RESERVE_BUFFER

	include	"include/PT3-RAM.tniasm.asm"

	;include	"include/ayFX-RAM.tniasm.asm"

; 60Hz replayer synchronization
replayer.frameskip:		rb	1

; Refresh rate in Hertzs (50Hz/60Hz) and related convenience vars
frame_rate:				rb	1

frames_per_tenth:		rb	1
