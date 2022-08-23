CHPUT:      equ 0x00a2	; bios call to print a character on screen
CHGMOD:		equ 0x005f
WRTVDP:		equ 0x0047
WRTVRM:		equ 0x004d	; MSX 1
NRDVRM:		equ 0x0174	; MSX 2
NWRVRM:		equ 0x0177	; MSX 2
NSTWRT:		equ 0x0171	; MSX 2
BEEP:		equ 0x00c0
SNSMAT:		equ 0x0141

PORT_0: equ 0x98
PORT_1: equ 0x99
PORT_2: equ 0x9a
PORT_3: equ 0x9b

REG0SAV: equ 0xF3DF

            ; the address of our program
            org 0xD000

start:

			; Init variables
            xor  	a
            ld  	(Flag_IN), a
            ld  	(Counter_T), a
            ld  	(Var_P), a
            ld  	hl, 0
            ld  	(Var_AD), hl


			; VDP(9)=10 ' In this example we don't need sprites, so we disable them.
			ld  	b, 10		; data to write
            ld  	c, 8		; register number (9 to 24	Control registers 8 to 23	Read / Write	MSX2 and higher)
            call  	WRTVDP		; Write B value to C register
            
            
			; screen 8
            ld 		a, 8
			call	CHGMOD


			; ------------------------ Draw screen -----------------------------

			; FOR Y=0 TO 255 : FOR X=0 TO 255 : VPOKE X + Y * 256, X X OR Y : NEXT X, Y
            ld   	hl, 0
            call  	NSTWRT
            ld  	c, PORT_0

			ld 		iyl, 0
.loop_Y:            
				ld  	ixl, 0
	.loop_X:
              	ld  	a, iyl
                xor  	ixl
                
                out  	(c), a
            
            	inc   	hl

                inc		ixl
                jp  	nz, .loop_X
            
            inc   	iyl
            jp  	nz, .loop_Y
            

			; ------------------------ set up interrupt -----------------------------

            ;130 ' Let's disable interrups until we are ready (DI)
            ;140 '#I 243
            di
            
            ;150 ' We will use general interrupt hook in address &hFD9A (-614)
            ;160 ' This address is called every time when interrupt occurs.
            ;170 ' To use it, we have to copy line 80 to the hook.
            ;180 ' First we need to know in what memory address line 80 is:
            ;190 ' AD = LINE 80 (NOTE: RENUM does not work in this case!!!)
            ;200 '#I 33,@80,34,AD

			;db	0x21 ; =decimal 33 : LD HL, nn nn
            ;dw	.line_80
            ;db	0x22 ; =decimal 34 : LD (nn nn), HL
            ;dw  Var_AD

            ;210 ' ... and then just copy...
			; FOR I=0 TO 4:POKE -614+I,PEEK(AD+I):NEXT I

			ld 		a, 0xc3    ; 0xc3 is the opcode for "jp", so this sets "jp .line_80" as the interrupt code
            ld 		(0xfd9a), a
            ld 		hl, .line_80
            ld 		(0xfd9a + 1), hl

            

            ; ' We want to have line interrupts, so let's enable them.
            ; VDP(0)=VDP(0) OR 16
			ld  	a, (REG0SAV)
            or  	16
			ld  	b, a		; data to write
            ld  	c, 0		; register number (9 to 24	Control registers 8 to 23	Read / Write	MSX2 and higher)
            call  	WRTVDP		; Write B value to C register
            di

            ; ' Let's set the interrupt to happen on line 100
            ; VDP(20)=100
			ld  	b, 100		; data to write
            ld  	c, 19		; register number (9 to 24	Control registers 8 to 23	Read / Write	MSX2 and higher)
            call  	WRTVDP		; Write B value to C register
            ;di

            ; ' Now we are ready and we can enable interrupts (EI)
            ; '#I 251
            ei

            ; ' Do what ever you want to do here in main program
            ; ' In this example we make some noise...
            ; SOUND 8,15
            ; SOUND 1,RND(1)*8:SOUND 0,RND(1)*255
            ; IF INKEY$="" THEN 320

			; TODO
.readKeyBoard:
            ; read keyboard
            ld      a, 8                    ; 8th line
            call    SNSMAT             ; Read Data Of Specified Line From Keyboard Matrix
            bit     0, a                ; 0th bit (space bar)
            jp    	z, .exit            

			jp  	.readKeyBoard

.exit:
            ; ' Before we can exit the program we have to disable line interrupts
            ; VDP(0)=VDP(0) AND 239
			ld  	a, (REG0SAV)
            and  	239
			ld  	b, a		; data to write
            ld  	c, 0		; register number (9 to 24	Control registers 8 to 23	Read / Write	MSX2 and higher)
            call  	WRTVDP		; Write B value to C register

            ; ' ... and release the interrupt hook (put RETurn to it)
            ; POKE -614,201
            ld  	a, 201
            ld  	(-614), a

            ; ' Now it is safe to exit
            ; BEEP:END
            call  	BEEP

            ret  	; exit program

.line_80:

			;call  	BEEP
            ;ret


            ; ' This is interrupt routine
            ; ' Here we make sure, that the example interrupt handler does not end up
            ; ' to infinite loop in case of nested interrupts
            ; IF IN=0 THEN IN=1:GOSUB 470:IN=0:T=0 ELSE T=T+1:IF T=100 THEN T=0:IN=0
            ; RETURN
            ld  	a, (Flag_IN)
            or  	a
            jp  	nz, .else
; .then:
			ld 		a, 1
            ld  	(Flag_IN), a
            call  	.sub_470
            xor  	a
            ld  	(Flag_IN), a
            ld  	(Counter_T), a
            ret
.else:
            ; T=T+1
            ld  	hl, Counter_T
            inc		(hl)
            
			; IF T=100 THEN T=0:IN=0
            ld  	a, (hl)
            cp  	100
            ret  	nz

			xor  	a
            ld  	(Counter_T), a
            ld  	(Flag_IN), a
			ret



.sub_470:
            ; ' Example interrupt handler:
            ; IF (VDP(-1)AND1)=1 THEN 530 ' Is this line interrupt?
			ld  	b, 1
            call 	RDSTATUSREG
           
            ld  	a, 1
            and  	b
            
            cp  	1
            
            jp   	z, .sub_470_line_530
            
            ; ' This was not line interrupt, so it's propably VBLANK
            ; ' VBLANK happens when screen has been drawn.
            ; VDP(24)=0 ' Upper part of screen shows still picture
			ld  	b, 0		; data to write
            ld  	c, 23		; register number (9 to 24	Control registers 8 to 23	Read / Write	MSX2 and higher)
            call  	WRTVDP		; Write B value to C register
            di
            
			ret

.sub_470_line_530:
            ; ' Here we handle line interrupt
            ; ' Lower part of screen jumps
            ; VDP(24)=P:P=ABS(SIN(R/20)*100):R=R+1
            ; RETURN
            ld  	a, (Var_P)
			ld  	b, a		; data to write
            ld  	c, 23		; register number (9 to 24	Control registers 8 to 23	Read / Write	MSX2 and higher)
            call  	WRTVDP		; Write B value to C register
            di
            
            ; P++ (provisory)
            ld  	hl, Var_P
            inc  	(hl)
            
            ret

;.eternalLoop:
;			jp  	.eternalLoop

; ---------------- includes


;----------------------------------
; Routine to read a status register
;
; Input: B = Status register number to read (MSX2~)
; Output: B = Read value from the status register
; Modify: AF, BC
;----------------------------------
RDSTATUSREG:
; -> Write the registre number in the r#15 (these 7 lines are specific MSX2 or newer)
	ld	a,(0007h)	; Main-ROM must be selected on page 0000h-3FFFh
	inc	a
	ld	c,a		; C = CPU port #99h (VDP writing port#1)
	;di		; Interrupts must be disabled here
	out	(c),b
	ld	a,080h+15
	out	(c),a
; <-
 
	ld	a,(0006h)	; Main-ROM must be selected on page 0000h-3FFFh
	inc	a
	ld	c,a		; C = CPU port #99h (VDP reading port#1)
	in	b,(c)	; read the value to the port#1
 
; -> Rewrite the registre number 0 in the r#15 (these 8 lines are specific MSX2 or newer)
	ld	a,(0007h)	; Main-ROM must be selected on page 0000h-3FFFh
	inc	a
	ld	c,a		; C = CPU port #99h (VDP writing port#1)
	xor	a
	out	(c),a
	ld	a,080h+15
	out	(c),a
	;ei		; Interrupts can be enabled here
; <-
	ret



; ----------------- Variables
Flag_IN:	db 0
Counter_T:	db 0
Var_P:		db 0
Var_AD:		dw 0

            ; use the label "start" as the entry point
            end start
            
