FNAME "vdp-command.rom"      ; output file


; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:

    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

; ----------------- Write on first 16 lines of the second page (not visible)

    xor     a           	; set vram write base address
    ld      hl, 0x8000     	;  to 1st byte of page 1...
    call    SetVDP_Write

    ld      a, 0x77        	; use color 8 (red)

	ld      c, 16          	; fill 1st N lines of page 1
.fillL1:
    ld      b, 128        	; one line in SC5 = 128 bytes
.fillL2:
    out     (PORT_0), a     	; could also have been done with
    djnz    .fillL2     	; a vdp command (probably faster)
    dec     c           	; (and could also use a fast loop)
    jp      nz, .fillL1




; ----------------- Execute VDP command copying a region of the second page to the first page (visible) 

    ld      hl, HMMM_Parameters 	; execute the copy
    call    DoCopy




.endProgram:
	jr      .endProgram

    ret



HMMM_Parameters:
;    db 0,0,0,1       ; R#32, R#33, R#34, R#35
;    db 0,0,0,0       ; R#36, R#37, R#38, R#39
;    db 8,0,8,0       ; R#40, R#41, R#42, R#43
;    db 0,0, 0xD0     ; R#44, R#45, R#46 = HMMM

;    dw    0x0000, 0x0100 ; Source X (9 bits), Source Y (10 bits)
;    dw    0x0080, 0x0010 ; Destiny X (9 bits), Destiny Y (10 bits)
;    dw    0x0008, 0x0008	; number of cols/lines
;    db    0, 0, 0xD0

   dw    0, 256 	; Source X (9 bits), Source Y (10 bits)
   dw    128, 96 	; Destiny X (9 bits), Destiny Y (10 bits)
   dw    20, 20		; number of cols (9 bits), number of lines (10 bits)
   db    0, 0, VDP_COMMAND_HMMM

VDP_COMMAND_HMMC:       equ 1111 0000b	; High speed move CPU to VRAM
VDP_COMMAND_YMMM:       equ 1110 0000b	; High speed move VRAM to VRAM, Y coordinate only
VDP_COMMAND_HMMM:       equ 1101 0000b	; High speed move VRAM to VRAM
VDP_COMMAND_HMMV:       equ 1100 0000b	; High speed move VDP to VRAM

; Logical commands (four lower bits specifies logic operation)
VDP_COMMAND_LMMC:       equ 1011 0000b	; Logical move CPU to VRAM
VDP_COMMAND_LMCM:       equ 1010 0000b	; Logical move VRAM to CPU
VDP_COMMAND_LMMM:       equ 1001 0000b	; Logical move VRAM to VRAM
VDP_COMMAND_LMMV:       equ 1000 0000b	; Logical move VDP to VRAM



; https://msx.org/forum/msx-talk/development/doubts-about-9938-commands

; HMMC copies data from your ram to the vram. The destination is a xy square in the vram however 
; your source is a starting adress in ram. You then out your data byte by byte until you have everything 
; you need. The first byte you out will be at the start of the adress where your gfx data is.

; The other command HMMV simply fills an area with one single color. So you basicly tell the VDP to fill 
; up that area for you. Very handy when you for example quickly want to fill a part of the VRAM area with 
; background color or want to clear the VRAM.