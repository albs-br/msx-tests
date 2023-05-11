; Mouse POC for MSX Pen
; Setup:
; On WebMSX: Help & Settings / Ports / Toggle Mouse Mode: ENABLED
; ALT+CAPS: Lock/Unlock pointer


; the address of our program
	ORG #C000
 
;--------------------------
 
BEGIN:
 
GTPAD:  EQU #DB
SETWRT: EQU #53
LDIRVM: EQU #5C
CHGMOD: EQU #5F
 
SPRATT: EQU #F928
SPRGEN: EQU #F926
FORCLR: EQU #F3E9
HINT:   EQU #FD9F
 
XPOS:   DB 128
YPOS:   DB 96
PORT:   DB 12
BUSY:   DB 0
 
SPRITE_OLD:
        DB %0001000
        DB %0001000
        DB %0001000
        DB %1110111
        DB %0001000
        DB %0001000
        DB %0001000
        DB %0000000
SPRITE:
        DB %1000000
        DB %1000000
        DB %1100000
        DB %1100000
        DB %1110000
        DB %1110000
        DB %1000000
        DB %0000000
INIT:
        DI
        ;Select mouse port
        CALL SELECTPORT
 
        ; Set colors
        LD HL,FORCLR
        LD (HL),15
        INC HL
        LD (HL),0
        INC HL
        LD (HL),0
 
        ; Change screenmode
        LD A,1
        CALL CHGMOD
 
        ; Copy sprite outlook
        LD HL,SPRITE
        LD DE,(SPRGEN)
        LD BC,8
        CALL LDIRVM
 
        ; Setup interrupt hook
        LD HL,HINT
        LD DE,STORE
        LD BC,5
        LDIR
        LD HL,INTERRUPT
        LD DE,HINT
        LD BC,3
        LDIR
        RET
 
SELECTPORT:
        ; Autodetect mouse port
        ; (check if mouse is connected to joystick port 1 or 2)
        CALL 	READMOUSE
        DEC 	D
        RET 	NZ
        DEC 	E
        RET 	NZ
        LD 		A,16
        LD 		(PORT),A
        RET
 
 
 
READMOUSE:
        ; Read mouse position (relative to previous position)
        ; OUT E = X
        ; OUT D = Y
 
        LD A,(PORT)
        PUSH AF
        CALL GTPAD

; GTPAD
; Address  : #00DB
; Function : Returns current touch pad status
; Input    : A  - Function call number. Fetch device data first, then read.

;            [ 0]   Fetch touch pad data from port 1 (#FF if available)
;            [ 1]   Read X-position
;            [ 2]   Read Y-position
;            [ 3]   Read touchpad status from port 1 (#FF if pressed)

;            [ 4]   Fetch touch pad data from port 2 (#FF if available)
;            [ 5]   Read X-position
;            [ 6]   Read Y-position
;            [ 7]   Read touchpad status from port 2 (#FF if pressed)

; Output   : A  - Value
; Registers: All
; Remark   : On MSX2, function call numbers 8-23 are forwarded to
;            NEWPAD in the SubROM.


; NEWPAD
; Address  : #01AD
; Function : Read light pen, mouse and trackball
; Input    : A  - Function call number. Fetch device data first, then read.

;            [ 8]   Fetch light pen (#FF if available; touching screen)
;            [ 9]   Read X-position
;            [10]   Read Y-position
;            [11]   Read lightpen-status (#FF if pressed)

;            [12]   Fetch mouse/trackball in port 1
;            [13]   Read X-offset
;            [14]   Read Y-offset
;            [15]   No function (always #00)

;            [16]   Fetch mouse/trackball in port 2
;            [17]   Read X-offset
;            [18]   Read Y-offset
;            [19]   No function (always #00)

;            [20]   Fetch 2nd light pen (#FF if available; touching screen)
;            [21]   Read X-position
;            [22]   Read Y-position
;            [23]   Read light-pen status (#FF if pressed)

; Output   : A  - Read value
; Registers: All
; Remark   : Access via GTPAD in the main BIOS, function call numbers 8 and up
;            will be forwarded to this call.

        POP AF
        ADD A, 2
        PUSH AF
        CALL GTPAD
        POP DE
        PUSH AF
        LD A, D
        DEC A
        CALL GTPAD
        POP DE
        LD E,A
        RET
 
INTERRUPT:
        ; This will be copied to interrupt hook
        JP HANDLER
 
HANDLER:
        ; This is actual interrupt handler routine
        LD A,(BUSY)
        AND A
        RET NZ
        LD A,255
        LD (BUSY),A
 
        CALL READMOUSE
        LD HL,(XPOS) ; put x and y on H and L registers (they are together on RAM)
        CALL CLIPADD
        LD (XPOS),HL
 
        DI
        LD DE,(SPRATT)
        EX DE,HL
        CALL SETWRT
 
        LD A,D
        SUB 4
        OUT (#98),A   ; Sprite Y
        LD A,E
        SUB 4
        LD C,8        ; Color
        JR NC,.NOEC
        ADD A,32
        LD C,8+128    ; Color + EC
.NOEC:
        OUT (#98),A   ; Sprite X
        LD A,0
        OUT (#98),A   ; Sprite number
        LD A,C
        OUT (#98),A   ; Color + [EC]
 
        XOR A
        LD (BUSY),A
 
STORE:
        ; Here is space for old interrupt handler from the interrupt hook
        DB 0,0,0,0,0
        RET
 
 
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
 
 
 
;END:
            ; use the label "BEGIN" as the entry point
            end BEGIN