FNAME "sprite-split.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    ; Common
    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; NAMTBL:     equ 0x0000
; SPRPAT:     equ 0xf000 ; actually 0x1f000, but 17 bits address are not accepted
; SPRCOL:     equ 0xf800
; SPRATR:     equ 0xfa00

; Default VRAM tables for Screen 11
NAMTBL:     equ 0x0000  ;
SPRPAT:     equ 0xf000  ; to 0xf7ff (2048 bytes)
SPRCOL:     equ 0xf800  ; to 0xf9ff (512 bytes)
SPRATR:     equ 0xfa00  ; to 0xfa80 (128 bytes)

SPRCOL_2:   equ 0xfc00  ; to 0xfdff (512 bytes)
SPRATR_2:   equ 0xfe00  ; to 0xfe80 (128 bytes)


LINE_INTERRUPT_NUMBER: equ 64


Execute:

    ; define screen colors
    ld 		a, 1      	            ; Foregoung color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 5  		            ; Backgroung color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 3      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color



    call    Screen11

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    Set192Lines

    call    SetColor0ToTransparent




    call    Load_SPRATR_1
    call    Load_SPRATR_2

    call    Set_SPRATR_1


; ---- set SPRPAT to 0x1f000
    ; bits:    16     11
    ;           |      |
    ; 0x1f000 = 1 1111 0000 0000 0000
    ; high bits (00aaaaaa: bits 16 to 11)
    ld      b, 0011 1110 b  ; data
    ld      c, 6            ; register #
    call    BIOS_WRTVDP


    ; Load sprite pattern #0
    ld      a, 0000 0001 b
    ;ld      a, 0000 0000 b
    ld      hl, SPRPAT
    call    SetVdp_Write
    ld      b, SpritePattern_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpritePattern_1
    otir


    ; -------------------------------------------------------
    ; Load sprite colors table 1

    ld      a, 0000 0001 b
    ld      hl, SPRCOL
    call    SetVdp_Write
    ld      b, 0; 256 bytes SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_a
    otir

    ld      a, 0000 0001 b
    ld      hl, SPRCOL + 256
    call    SetVdp_Write
    ld      b, 0; 256 bytes SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_b
    otir


    ; -------------------------------------------------------
    ; Load sprite colors table 2

    ld      a, 0000 0001 b
    ld      hl, SPRCOL_2
    call    SetVdp_Write
    ld      b, 0; 256 bytes SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_a
    otir

    ld      a, 0000 0001 b
    ld      hl, SPRCOL_2 + 256
    call    SetVdp_Write
    ld      b, 0; 256 bytes SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_b
    otir


    ;call    .lineInterruptCode ; Set_SPRATR_top


    ; ------------------------ Draw screen -----------------------------

    ; FOR Y=0 TO 255 : FOR X=0 TO 255 : VPOKE X + Y * 256, X X OR Y : NEXT X, Y
    ld   	hl, 0
    call  	BIOS_NSTWRT
    ld  	c, PORT_0

    ld 		iyl, 0
.loop_Y:            
        ld  	ixl, 0
.loop_X:
            ld  	a, iyl
            xor  	ixl

            out  	(c), a

            ;inc   	hl

        inc		ixl
        jp  	nz, .loop_X
    
    inc   	iyl
    jp  	nz, .loop_Y




    ; Init variables
    xor  	a
    ld  	(Flag_LineInterrupt), a
    ld  	(Counter_LineInterrupt), a

    ld      a, LINE_INTERRUPT_NUMBER - 8
    ld      (Sprite_Y), a

    ld      a, 1
    ld      (Sprite_Direction), a

; ----------------- set sprite split

    ; ------------------------ set up interrupt -----------------------------

    di

    
    ; override HKEYI hook
    ld 		a, 0xc3    ; 0xc3 is the opcode for "jp", so this sets "jp LineInterruptHook" as the interrupt code
    ld 		(HKEYI), a
    ld 		hl, LineInterruptHook
    ld 		(HKEYI + 1), hl

    
    ; enable line interrupts
    ld  	a, (REG0SAV)
    or  	16
    ld  	b, a		; data to write
    ld  	c, 0		; register number
    call  	WRTVDP_without_DI_EI		; Write B value to C register



    ; set the interrupt to happen on line n
    ld  	b, LINE_INTERRUPT_NUMBER - 1 - 3		; data to write
    ld  	c, 19		; register number
    call  	WRTVDP_without_DI_EI		; Write B value to C register


    ei


    call    BIOS_ENASCR

    call    BIOS_BEEP


.loop:
    call    Wait_Vblank

    ld      a, (Sprite_Direction)
    ld      b, a
    ld      a, (Sprite_Y)
    add     b
    ld      (Sprite_Y), a


    ld      c, PORT_0

    ld      a, 0000 0001 b
    ld      hl, SPRATR + (31 * 4)  ; Y coord of sprite # 31
    call    SetVdp_Write
    ld      a, (Sprite_Y)
    out     (c), a

    ld      a, 0000 0001 b
    ld      hl, SPRATR_2 + (31 * 4)  ; Y coord of sprite # 31
    call    SetVdp_Write
    ld      a, (Sprite_Y)
    out     (c), a


    cp      LINE_INTERRUPT_NUMBER
    call    z, .setDirectionUp

    cp      LINE_INTERRUPT_NUMBER - 16
    call    z, .setDirectionDown




    jp      .loop

.setDirectionUp:
    ld      a, -1
    ld      (Sprite_Direction), a
    ret

.setDirectionDown:
    ld      a, 1
    ld      (Sprite_Direction), a
    ret


;-------------------
LineInterruptHook:

            ; Interrupt routine (adapted from https://www.msx.org/forum/development/msx-development/how-line-interrupts-basic#comment-431760)
            ; Make sure that the example interrupt handler does not end up
            ; to infinite loop in case of nested interrupts
            ; if (Flag_LineInterrupt == 0) { 
            ;     Flag_LineInterrupt = 1; 
            ;     execute();
            ;     Flag_LineInterrupt = 0;
            ;     Counter_LineInterrupt = 0;
            ; }
            ; else {
            ;     Counter_LineInterrupt++;
            ;     if (Counter_LineInterrupt == 100) {
            ;         Flag_LineInterrupt = 0;
            ;         Counter_LineInterrupt = 0;
            ;     }
            ; }
            ld  	a, (Flag_LineInterrupt)
            or  	a
            jp  	nz, .else
; .then:
            inc     a ; ld a, 1 ; as A is always 0 here, inc a is the same as ld a, 1
            ld  	(Flag_LineInterrupt), a
            call  	.execute

            ; xor  	a
            ; ld  	(Flag_LineInterrupt), a
            ; ld  	(Counter_LineInterrupt), a
            ld      hl, 0
            ld      (Flag_LineInterrupt), hl ; as these two vars are on sequential addresses, this clear both

            ret     ;jp      .return
.else:
            ; Counter++
            ld  	hl, Counter_LineInterrupt
            inc		(hl)
            
			; if (Counter == 100) { Counter = 0; Flag = 0 }
            ld  	a, (hl)
            cp  	100
            ret  	nz
            ; jp      nz, .return

			; xor  	a
            ; ld  	(Counter_LineInterrupt), a
            ; ld  	(Flag_LineInterrupt), a
            ld      hl, 0
            ld      (Flag_LineInterrupt), hl ; as these two vars are on sequential addresses, this clear both

            ret     ;jp      .return

.execute:
    ; if (VDP(-1) and 1) == 1) ; check if is this a line interrupt
    ld  	b, 1
    call 	ReadStatusReg
    
    ld  	a, 0000 0001 b
    and  	b
    
    ;or      a ; this isn't necessary

    ; Code to run on Vblank:
    jp      z, Set_SPRATR_1

    ; Code to run on line interrupt:
    jp   	Set_SPRATR_2

; ------------

Set_SPRATR_1:
; ---- set SPRATR to 0x1fa00 (SPRCOL is automatically set 512 bytes before SPRATR, so 0x1f800)
    ; bits:    16 14        7
    ;           |  |        |
    ; 0x1fa00 = 1 1111 1010 0000 0000
    ; low bits (aaaaa111: bits 14 to 10)
    ld      b, 1111 0111 b  ; data          ; In sprite mode 2 the least significant three bits in register 5 should be 1 otherwise mirroring will occur. ; https://www.msx.org/forum/msx-talk/development/strange-behaviour-bug-on-spratr-base-addr-register-on-v993858
    ld      c, 5            ; register #
    ;call    BIOS_WRTVDP
    call  	WRTVDP_without_DI_EI		; Write B value to C register

    ; high bits (000000aa: bits 16 to 15)
    ld      b, 0000 0011 b  ; data
    ld      c, 11           ; register #
    ;call    BIOS_WRTVDP
    call  	WRTVDP_without_DI_EI		; Write B value to C register
    ret

Set_SPRATR_2:
; ---- set SPRATR to 0x1fe00 (SPRCOL is automatically set 512 bytes before SPRATR, so 0x1fc00)
    ; bits:    16 14        7
    ;           |  |        |
    ; 0x1fa00 = 1 1111 1110 0000 0000
    ; low bits (aaaaa111: bits 14 to 10)
    ld      b, 1111 1111 b  ; data          ; In sprite mode 2 the least significant three bits in register 5 should be 1 otherwise mirroring will occur. ; https://www.msx.org/forum/msx-talk/development/strange-behaviour-bug-on-spratr-base-addr-register-on-v993858
    ld      c, 5            ; register #
    ;call    BIOS_WRTVDP
    call  	WRTVDP_without_DI_EI		; Write B value to C register
    ; high bits (000000aa: bits 16 to 15)
    ld      b, 0000 0011 b  ; data
    ld      c, 11           ; register #
    ;call    BIOS_WRTVDP
    call  	WRTVDP_without_DI_EI		; Write B value to C register
    ret

Load_SPRATR_1:
    ld      a, 0000 0001 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      b, SpriteAttributes_top.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes_top
    otir
    ret

Load_SPRATR_2:
; wasting 7 scanlines to fill up 128 bytes of SPRATR

; switching between 2 SPRATR tables: 3 lines

    ld      a, 0000 0001 b
    ld      hl, SPRATR_2
    call    SetVdp_Write
    ld      b, SpriteAttributes_bottom.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes_bottom
    otir
    ret

End:


SpritePattern_1:
    DB 00000111b
    DB 00011111b
    DB 00111111b
    DB 01111111b
    DB 01110011b
    DB 11110011b
    DB 11111111b
    DB 11111111b

    DB 11111111b
    DB 11111111b
    DB 11110111b
    DB 01111011b
    DB 01111100b
    DB 00111111b
    DB 00011111b
    DB 00000111b

    DB 11100000b
    DB 11111000b
    DB 11111100b
    DB 11111110b
    DB 11001110b
    DB 11001111b
    DB 11111111b
    DB 11111111b
    
    DB 11111111b
    DB 11111111b
    DB 11101111b
    DB 11011110b
    DB 00111110b
    DB 11111100b
    DB 11111000b
    DB 11100000b
.size:  equ $ - SpritePattern_1

SpriteColors_a:
    ;db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08

    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
    
    ;db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
.size:  equ $ - SpriteColors_a

SpriteColors_b:
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
.size:  equ $ - SpriteColors_b


SpriteAttributes_top:
    db  -1 + 0, 0, 0, 0 ; -1 to compensate the Y+1 bug/feature of VDP
    db  -1 + 0, 16, 0, 0
    db  -1 + 0, 32, 0, 0
    db  -1 + 0, 48, 0, 0
    db  -1 + 0, 64, 0, 0
    db  -1 + 0, 80, 0, 0
    db  -1 + 0, 96, 0, 0
    db  -1 + 0, 112, 0, 0
    db  -1 + 16, 0, 0, 0
    db  -1 + 16, 16, 0, 0
    db  -1 + 16, 32, 0, 0
    db  -1 + 16, 48, 0, 0
    db  -1 + 16, 64, 0, 0
    db  -1 + 16, 80, 0, 0
    db  -1 + 16, 96, 0, 0
    db  -1 + 16, 112, 0, 0
    db  -1 + 32, 0, 0, 0
    db  -1 + 32, 16, 0, 0
    db  -1 + 32, 32, 0, 0
    db  -1 + 32, 48, 0, 0
    db  -1 + 32, 64, 0, 0
    db  -1 + 32, 80, 0, 0
    db  -1 + 32, 96, 0, 0
    db  -1 + 32, 112, 0, 0
    db  -1 + 48, 0, 0, 0
    db  -1 + 48, 16, 0, 0
    db  -1 + 48, 32, 0, 0
    db  -1 + 48, 48, 0, 0
    db  -1 + 48, 64, 0, 0
    db  -1 + 48, 80, 0, 0
    db  -1 + 48, 96, 0, 0
    ;db  -1 + 48, 112, 0, 0
    db  -1 + LINE_INTERRUPT_NUMBER - 8, 200, 0, 0
.size:  equ $ - SpriteAttributes_top

SpriteAttributes_bottom:
    db  -1 + 64, 0, 0, 0 ; -1 to compensate the Y+1 bug/feature of VDP
    db  -1 + 64, 16, 0, 0
    db  -1 + 64, 32, 0, 0
    db  -1 + 64, 48, 0, 0
    db  -1 + 64, 64, 0, 0
    db  -1 + 64, 80, 0, 0
    db  -1 + 64, 96, 0, 0
    db  -1 + 128, 112, 0, 0 ;avoiding 8 sprites on the same line
    db  -1 + 80, 0, 0, 0
    db  -1 + 80, 16, 0, 0
    db  -1 + 80, 32, 0, 0
    db  -1 + 80, 48, 0, 0
    db  -1 + 80, 64, 0, 0
    db  -1 + 80, 80, 0, 0
    db  -1 + 80, 96, 0, 0
    db  -1 + 80, 112, 0, 0
    db  -1 + 96, 0, 0, 0
    db  -1 + 96, 16, 0, 0
    db  -1 + 96, 32, 0, 0
    db  -1 + 96, 48, 0, 0
    db  -1 + 96, 64, 0, 0
    db  -1 + 96, 80, 0, 0
    db  -1 + 96, 96, 0, 0
    db  -1 + 96, 112, 0, 0
    db  -1 + 112, 0, 0, 0
    db  -1 + 112, 16, 0, 0
    db  -1 + 112, 32, 0, 0
    db  -1 + 112, 48, 0, 0
    db  -1 + 112, 64, 0, 0
    db  -1 + 112, 80, 0, 0
    db  -1 + 112, 96, 0, 0
;    db  -1 + 112, 112, 0, 0
    db  -1 + LINE_INTERRUPT_NUMBER - 8, 200, 0, 0
.size:  equ $ - SpriteAttributes_bottom

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF




; ----------------- Variables
    org 0xc000

; vars for line interrupt routine:
Flag_LineInterrupt:	    rb 1        ; these two vars MUST be on sequential addresses 
Counter_LineInterrupt:	rb 1        ; this var MUST be imediately after Flag_LineInterrupt


Sprite_Y:               rb 1
Sprite_Direction:       rb 1