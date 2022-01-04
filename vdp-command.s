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


    xor     a           	; set vram write base address
    ld      hl, 0x8000     	;  to 1st byte of page 1...
    call    SetVDP_Write

    ld      a, 0x88        	; use color 8 (red)

	ld      c, 16          	; fill 1st N lines of page 1
.fillL1:
    ld      b, 128        	; one line in SC5 = 128 bytes
.fillL2:
    out     (PORT_0), a     	; could also have been done with
    djnz    .fillL2     	; a vdp command (probably faster)
    dec     c           	; (and could also use a fast loop)
    jp      nz, .fillL1

    ld      hl, COPYBLOCK 	; execute the copy
    call    DoCopy

.endProgram:
	jr      .endProgram

    ret



COPYBLOCK:
;    db 0,0,0,1       ; R#32, R#33, R#34, R#35
;    db 0,0,0,0       ; R#36, R#37, R#38, R#39
;    db 8,0,8,0       ; R#40, R#41, R#42, R#43
;    db 0,0, 0xD0     ; R#44, R#45, R#46 = HMMM

;    dw    0x0000, 0x0100 ; Source X (9 bits), Source Y (10 bits)
;    dw    0x0080, 0x0010 ; Destiny X (9 bits), Destiny Y (10 bits)
;    dw    0x0008, 0x0008	; number of cols/lines
;    db    0, 0, 0xD0

   dw    0, 256 ; Source X (9 bits), Source Y (10 bits)
   dw    128, 96 ; Destiny X (9 bits), Destiny Y (10 bits)
   dw    20, 20	; number of cols/lines
   db    0, 0, VDP_COMMAND_HMMM

VDP_COMMAND_HMMM:       equ 1101 0000b