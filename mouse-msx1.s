; Mouse POC for MSX Pen (works also on MSX 1)
; Setup:
; On WebMSX: Help & Settings / Ports / Toggle Mouse Mode: ENABLED
; ALT+CAPS: Lock/Unlock pointer

; Direct usage of mouse
; Mouse related BIOS-calls are not available on MSX1, so in this case you need to handle mouse directly.
; Here is example of how to do that. Note that the trackball uses a different protocol and need a specific routine.

; bios call to print a character on screen
CHPUT:      equ 0x00a2
BIOS_JIFFY:   equ 0xfc9e
BIOS_INIGRP:  equ 0x0072
BIOS_LDIRVM:  equ 0x005c
BIOS_BEEP:    equ 0x00c0
BIOS_FORCLR: EQU 0xF3E9


SPRPAT:     equ 0x3800
SPRATR:     equ 0x1b00

WAIT1:  equ   10              ; Short delay value
WAIT2:  equ   30              ; Long delay value

; the address of our program
            org 0xc000

spritePattern:
	db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    
spriteAttributes:
	db 96, 128, 0, 7
    db 208 ; hide all other sprites

start:

	ld a, 128
    ld (cursorX), a
	ld a, 96
    ld (cursorY), a
    
    ld hl, BIOS_FORCLR
    ld a, 15 ; foreground color
    ld (hl), a
    inc hl
    ld a, 1 ; background color
    ld (hl), a
    inc hl
    ld a, 4 ; border color
    ld (hl), a

	call    BIOS_INIGRP                 ; screen 2
    
    ; load sprpat
    ld		hl, spritePattern       ; RAM address (source)
    ld		de, SPRPAT		        ; VRAM address (destiny)
    ld		bc, 8					; Block length
    call 	BIOS_LDIRVM        	    ; Block transfer to VRAM from memory
    
    ; init spratt
    ld		hl, spriteAttributes    ; RAM address (source)
    ld		de, SPRATR		        ; VRAM address (destiny)
    ld		bc, 5					; Block length
    call 	BIOS_LDIRVM        	    ; Block transfer to VRAM from memory


loop:

	;wait vblank
    ld      a, (BIOS_JIFFY)
    ld      b, a
waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, waitVBlank
    

	ld de, 01310h
    call GTMOUS
    ; if(H==255 & H==L) noMouse
    ld a, h
    cp 255
    jp nz, skip
    cp l
    call z, noMouse

skip:

	; update cursor position
    ;ld a, (cursorX)
    ;sub h
    ;ld (cursorX), a
    
    ;ld a, (cursorY)
    ;sub l
    ;ld (cursorY), a
    
    ; invert delta x
    ld a, h
    neg
    ld h, a

    ; invert delta y
	ld a, l
    neg
    ld l, a
    
    ld e, h ; delta X
    ld d, l ; delta Y
    ld a, (cursorX)
    ld l, a ; current X
    ld a, (cursorY)
    ld h, a ; current Y
    call CLIPADD
    ld a, l
    ld (cursorX), a
    ld a, h
    ld (cursorY), a

	;update SPRATR
    ld hl, spriteAttributes
    ld a, (cursorY)
    ld (hl), a
    
    inc hl
    ld a, (cursorX)
    ld (hl), a

	ld		hl, spriteAttributes    ; RAM address (source)
    ld		de, SPRATR		        ; VRAM address (destiny)
    ld		bc, 2					; Block length
    call 	BIOS_LDIRVM        	    ; Block transfer to VRAM from memory

	jp loop

noMouse:
	;ld a, 65
    ;call CHPUT
    call BIOS_BEEP
    ret

; Routine to read the mouse by direct accesses (works on MSX1/2/2+/turbo R)
;
; Input: DE = 01310h for mouse in port 1 (D = 00010011b, E = 00010000b)
;        DE = 06C20h for mouse in port 2 (D = 01101100b, E = 00100000b)
; Output: H = X-offset, L = Y-offset (H = L = 255 if no mouse)
GTMOUS:
	ld	b,WAIT2	; Long delay for first read
	call	GTOFS2	; Read bits 7-4 of the x-offset
	and	0Fh
	rlca
	rlca
	rlca
	rlca
	ld	c,a
	call	GTOFST	; Read bits 3-0 of the x-offset
	and	0Fh
	or	c
	ld	h,a	; Store combined x-offset
	call	GTOFST	; Read bits 7-4 of the y-offset
	and	0Fh
	rlca
	rlca
	rlca
	rlca
	ld	c,a
	call	GTOFST	; Read bits 3-0 of the y-offset
	and 0Fh
	or c
	ld l,a		; Store combined y-offset
	ret
 
GTOFST:	
	ld b,WAIT1
GTOFS2:	
	ld a,15		; Read PSG register 15 for mouse
	di		; DI useless if the routine is used during an interrupt
	out (0A0h),a
	in  a,(0xA1) 
	and 0x80   ; preserve LED code/Kana state
	or  d            ; mouse1 x0010011b / mouse2 x1101100b
	out (0A1h),a
	xor e
	ld d,a
 
	call WAITMS	; Extra delay because the mouse is slow
 
	ld a,14
	out (0A0h),a
	ei		; EI useless if the routine is used during an interrupt
	in a,(0A2h)
	ret
WAITMS:
	ld	a,b
WTTR:
	djnz	WTTR
	db	0EDh,055h	; Back if Z80 (RETN on Z80, NOP on R800)
	rlca
	rlca
	ld	b,a
WTTR2:
	djnz	WTTR2
	ld	b,a	
WTTR3:
	djnz	WTTR3

	ret            

; Input:
;  E = delta X
;  D = delta Y
;  L = current X
;  H = current Y
; Output:
;  L = updated X
;  H = updated Y
CLIPADD:
        ; Make sure that mouse pointer stays inside visible screen area
        LD A,L
        LD B,E
        CALL LIMITADD
        LD L,A
        
        LD A,H
        LD B,D
        CALL LIMITADD
        LD H,A
        CP 191
        RET C
        LD H,191
        RET
 
LIMITADD:
 
; Clip mouse pointer to 0..255
; In:  A = mouse position 0..255
;      B = mouse move -128..+127
; Out: A = new mouse position 0..255
 
 
	SUB	128		; move from range 0..255 to -128..+127
	ADD	A,B		; add mouse offset, both numbers are signed
	JP	PE, .CLIP	; pe -> previous instruction caused a signed overflow
	ADD	A,128		; move back to range 0..255
	RET			;
.CLIP:	LD	A,B		; get mouse offset
	CPL			; flip all bits (only bit 7 matters)
	ADD	A,A		; move bit 7 to carry flag
	SBC	A,A		; carry set -> a=255   carry not set -> a=0
	RET			;

;    org 0xc000
   
cursorX: db 1
cursorY: db 1

   
    
    end start