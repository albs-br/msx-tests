FNAME "mouse-msx1-openmsx.rom"      ; output file

; Direct usage of mouse
; Mouse related BIOS-calls are not available on MSX1, so in this case you need to handle mouse directly.
; Here is example of how to do that. Note that the trackball uses a different protocol and need a specific routine.

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 2
SPRPAT:     equ 0x3800  ; to 0x3fff (2048 bytes)
SPRATR:     equ 0x1b00  ; to 0x1b7f (128 bytes)


WAIT1:  equ   10              ; Short delay value
WAIT2:  equ   30              ; Long delay value


spritePattern:
	db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    
spriteAttributes_init:
	db 96, 128, 0, 7
    db 208 ; hide all other sprites

Execute:

	ld      a, 128
    ld      (cursorX), a
	ld      a, 96
    ld      (cursorY), a
    ld      a, 7
    ld      (cursorColor), a
    
    ld      hl, BIOS_FORCLR
    ld      a, 15 ; foreground color
    ld      (hl), a
    inc     hl
    ld      a, 1 ; background color
    ld      (hl), a
    inc     hl
    ld      a, 4 ; border color
    ld      (hl), a

	call    BIOS_INIGRP                 ; screen 2
    
    ; load sprpat
    ld		hl, spritePattern       ; RAM address (source)
    ld		de, SPRPAT		        ; VRAM address (destiny)
    ld		bc, 8					; Block length
    call 	BIOS_LDIRVM        	    ; Block transfer to VRAM from memory
    
    ; init spratt
    ld		hl, spriteAttributes_init    ; RAM address (source)
    ld		de, SPRATR		        ; VRAM address (destiny)
    ld		bc, 5					; Block length
    call 	BIOS_LDIRVM        	    ; Block transfer to VRAM from memory

.loop:

	; wait vblank
    ld      a, (BIOS_JIFFY)
    ld      b, a
.waitVBlank:
    ld      a, (BIOS_JIFFY)
    cp      b
    jp      z, .waitVBlank
    

	ld      de, 0x1310 ; mouse on joyport 1
    ;ld      de, 0x6C20  ; mouse on joyport 2
    call    GTMOUS
    ; if(H==255 && H==L) noMouse
    ld      a, h
    cp      255
    jp      nz, .skip
    cp      l
    call    z, .noMouse

.skip:

    ; ----- set cursor color baased on buttons pressed
    ld      b, 7 ; default cursor color
    
    ld      a, ixh
    and     ixl
    jp      z, .not_BothButtonsPressed

    ld      b, 13 ; color for both buttons pressed
    jp      .continue 

.not_BothButtonsPressed:
    ld      a, ixh
    or      a
    jp      z, .skipSetCursorRed
    ld      b, 8 ; color for mouse 1 button clicked
.skipSetCursorRed:
    
    ld      a, ixl
    or      a
    jp      z, .skipSetCursorGreen
    ld      b, 12 ; color for mouse 2 button clicked
.skipSetCursorGreen:

.continue:
    ld      a, b
    ld      (cursorColor), a



    ; invert delta x
    ld      a, h
    neg
    ld      h, a

    ; invert delta y
	ld      a, l
    neg
    ld      l, a
    
    ld      e, h ; delta X
    ld      d, l ; delta Y
    ld      a, (cursorX)
    ld      l, a ; current X
    ld      a, (cursorY)
    ld      h, a ; current Y
    call    CLIPADD
    ld      a, l
    ld      (cursorX), a
    ld      a, h
    ld      (cursorY), a

	;update SPRATR
    ld      hl, spriteAttributes
    ld      a, (cursorY)
    dec     a ; to compensate the Y+1 bug of 9918
    ld      (hl), a
    
    inc     hl
    ld      a, (cursorX)
    ld      (hl), a

    inc     hl
    xor     a ; sprite pattern
    ld      (hl), a

    inc     hl
    ld      a, (cursorColor)
    ld      (hl), a

	ld		hl, spriteAttributes    ; RAM address (source)
    ld		de, SPRATR		        ; VRAM address (destiny)
    ld		bc, 4					; Block length
    call 	BIOS_LDIRVM        	    ; Block transfer to VRAM from memory

	jp      .loop

.noMouse:
	;ld     a, 65
    ;call   CHPUT
    call    BIOS_BEEP
    ret

; Routine to read the mouse by direct accesses (works on MSX1/2/2+/turbo R)
;
; Input: DE = 01310h for mouse in port 1 (D = 00010011b, E = 00010000b)
;        DE = 06C20h for mouse in port 2 (D = 01101100b, E = 00100000b)
; Output: 
;   H = X-offset, L = Y-offset (H = L = 255 if no mouse)
;   IXH = button 1, IXL = button 2
GTMOUS:
	ld	    b, WAIT2	; Long delay for first read
	call	GTOFS2	; Read bits 7-4 of the x-offset

    ; get mouse buttons (IXH = button 1, IXL = button 2)
    ld      ix, 0
    bit     5, a
    jp      nz, .mouseButton_1_NotClicked
    ld      ixh, 1
.mouseButton_1_NotClicked:
    bit     4, a
    jp      nz, .mouseButton_2_NotClicked
    ld      ixl, 1
.mouseButton_2_NotClicked:


;     ;get mouse button 1
;     push    af
;         bit     5, a
;         jp      nz, .mouseButton_1_NotClicked
;         ld      a, 8
;         jp      .continue
; .mouseButton_1_NotClicked:
;         ld      a, 7
; .continue:
;         ld      (cursorColor), a
;     pop     af
;     ;get mouse button 2
;     push    af
;         bit     4, a
;         jp      nz, .mouseButton_2_NotClicked
;         ld      a, 12
;         jp      .continue_1
; .mouseButton_2_NotClicked:
;         ld      a, 7
; .continue_1:
;         ld      (cursorColor), a
;     pop     af

	and	    0x0F
	rlca
	rlca
	rlca
	rlca
	ld	    c, a
	call	GTOFST	; Read bits 3-0 of the x-offset
	and	    0x0F
	or	    c
	ld	    h, a	; Store combined x-offset
	call	GTOFST	; Read bits 7-4 of the y-offset
	and	    0x0F
	rlca
	rlca
	rlca
	rlca
	ld	    c, a
	call	GTOFST	; Read bits 3-0 of the y-offset
	and     0x0F
	or      c
	ld      l, a		; Store combined y-offset
	ret
 
GTOFST:	
	ld      b, WAIT1
GTOFS2:	
	ld      a, 15		; Read PSG register 15 for mouse
	di		; DI useless if the routine is used during an interrupt
	out     (0xA0), a
	in      a, (0xA1) 
	and     0x80   ; preserve LED code/Kana state
	or      d            ; mouse1 x0010011b / mouse2 x1101100b
	out     (0xA1), a
	xor     e
	ld      d, a
 
	call    WAITMS	; Extra delay because the mouse is slow
 
	ld      a, 14
	out     (0xA0), a
	ei		; EI useless if the routine is used during an interrupt
	in      a, (0xA2)
	ret
WAITMS:
	ld	    a, b
WTTR:
	djnz	WTTR
	db	0xED,0x55	; Back if Z80 (RETN on Z80, NOP on R800)
	rlca
	rlca
	ld	    b, a
WTTR2:
	djnz	WTTR2
	ld	    b, a	
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
    ld      a, l
    ld      b, e
    call    LIMITADD
    ld      l, a
    
    ld      a, h
    ld      b, d
    call    LIMITADD
    ld      h, a
    cp      191
    ret     c
    ld      h, 191
    ret
 
LIMITADD:
 
; Clip mouse pointer to 0..255
; In:  A = mouse position 0..255
;      B = mouse move -128..+127
; Out: A = new mouse position 0..255
 
 
	sub	    128		    ; move from range 0..255 to -128..+127
	add	    a, b		; add mouse offset, both numbers are signed
	jp	    pe, .CLIP	; pe -> previous instruction caused a signed overflow
	add	    a, 128		; move back to range 0..255
	ret			        ;
.CLIP:	
    ld	    a, b	; get mouse offset
	cpl	    		; flip all bits (only bit 7 matters)
	add	    a, a	; move bit 7 to carry flag
	sbc	    a, a	; carry set -> a=255   carry not set -> a=0
	ret	    		;

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF



; RAM
    org 0xc000
   
cursorX:            rb 1
cursorY:            rb 1
cursorColor:        rb 1

spriteAttributes:   rb 5
