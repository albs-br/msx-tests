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

;DoExampleCopy:

    xor a           	; set vram write base address
    ld hl, 0x8000     	;  to 1st byte of page 1...
    call SetVDP_Write

    ld a, 0x88        	; use color 8 (red)

	ld c, 90          	; fill 1st 8 lines of page 1
.FillL1:
    ld b, 128        	;
.FillL2:
    out (0x98), a     	; could also have been done with
    djnz .FillL2     	; a vdp command (probably faster)
    dec c           	; (and could also use a fast loop)
    jp nz, .FillL1

    ld hl, COPYBLOCK 	; execute the copy
    call DoCopy

.endProgram:
	jr .endProgram

    ret


;
; Set VDP address counter to write from address AHL (17-bit)
; Enables the interrupts
;
; SetVDP_Write:
;     rlc h
;     rla
;     rlc h
;     rla
;     srl h
;     srl h
;     di
;     out (0x99),a
;     ld a,14 + 128
;     out (0x99),a
;     ld a,l
;     nop
;     out (0x99),a
;     ld a,h
;     or 64
;     ei
;     out (0x99),a
;     ret



;
; Fast DoCopy, by Grauw
; In:  HL = pointer to 15-byte VDP command data
; Out: HL = updated
;
DoCopy:
    ld      a,32
    di
    out     (0x99),a
    ld      a,17 + 128
    out     (0x99),a
    ld      c,0x9B
.VDPready:
    ld      a,2
    di
    out     (0x99),a     ; select s#2
    ld      a,15 + 128
    out     (0x99),a
    in      a,(0x99)
    rra
    ld      a,0          ; back to s#0, enable ints
    out     (0x99),a
    ld      a,15 + 128
    ei
    out     (0x99),a     ; loop if vdp not ready (CE)
    jp      c, .VDPready
    outi            ; 15x OUTI
    outi            ; (faster than OTIR)
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    outi
    ret



COPYBLOCK:
   db 0,0,0,1
   db 0,0,0,0
   db 8,0,8,0
   db 0,0, 0xD0        ; HMMM

; As an alternate notation, you might actually prefer the following:
;
;    dw    #0000,#0100
;    dw    #0000,#0000
;    dw    #0010,#0090	; number of cols/lines
;    db    0, 0, #D0

            ; use the label "start" as the entry point
            ;end start