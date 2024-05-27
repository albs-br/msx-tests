FNAME "palette-split.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    ; Common
    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"


; Default VRAM tables for Screen 5
NAMTBL:     equ 0x0000  ; to 0x???? (??? bytes)
SPRPAT:     equ 0x7800  ; to 0x7fff (2048 bytes)
SPRCOL:     equ 0x7400  ; to 0x75ff (512 bytes)
SPRATR:     equ 0x7600  ; to 0x767f (128 bytes)

LINE_INTERRUPT_NUMBER: equ 96 ; TODO: it is triggering some 10 lines above... Why?


Execute:

    ; define screen colors
    ld 		a, 1      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 5  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 3      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color



    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    Set192Lines

    call    SetColor0ToTransparent

    
    
    
    
    
    
    
    call    DisableSprites



    ; ------------------------ Draw screen -----------------------------

    ld   	hl, 0
    call  	BIOS_NSTWRT
    ld  	c, PORT_0

    ld      d, 0x00 ; color

    ld 		iyl, 0 ; line counter
.loop_Y:            
        ld  	ixl, 0 ; column counter
.loop_X:

            ; convert x coord to color of two pixels
            ld      a, ixl
            and     0111 1000 b
            sla     a   ; shift left register, 0 --> bit 0, bit 7 --> carry
            ld      b, a
            srl     a               ; shift right register
            srl     a
            srl     a
            srl     a
            or      b

            out  	(c), a

        inc		ixl
        ld      a, ixl
        cp      128 ; 1 line on SC5 = 128 bytes
        jp  	nz, .loop_X

    inc   	iyl
    ld      a, iyl
    cp      192
    jp  	nz, .loop_Y



    ; Init variables
    xor  	a
    ld  	(Flag_LineInterrupt), a
    ld  	(Counter_LineInterrupt), a



; ----------------- set palette split

    ; ------------------------ setup line interrupt -----------------------------

    di
        ; override HKEYI hook
        ld 		a, 0xc3    ; 0xc3 is the opcode for "jp", so this sets "jp LineInterruptHook" as the interrupt code
        ld 		(HKEYI), a
        ld 		hl, LineInterruptHook
        ld 		(HKEYI + 1), hl

        
        ; enable line interrupts
        ld  	a, (REG0SAV)
        or  	16
        ld  	(REG0SAV), a ; it's a good practice to update the REGnSAV values
        ld  	b, a		; data to write
        ld  	c, 0		; register number
        call  	WRTVDP_without_DI_EI		; Write B value to C register



        ; set the interrupt to happen on line n
        ld  	b, LINE_INTERRUPT_NUMBER 		; data to write
        ld  	c, 19		; register number
        call  	WRTVDP_without_DI_EI		; Write B value to C register
    ei


    call    BIOS_ENASCR

    call    BIOS_BEEP


.loop:
    call    Wait_Vblank



    jp      .loop

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

    ; TODO: vblank interrupt is being called twice per frame. Why?

    ; Code to run on Vblank:
    jp      z, Set_Palette_1

    ; Code to run on line interrupt:
    jp   	Set_Palette_2

Set_Palette_1:
    ; call    SetColor0ToNonTransparent
    ld hl, PaletteData_1
    call LoadPalette
    ret

Set_Palette_2:
    ; call    SetColor0ToTransparent
    ld hl, PaletteData_2
    call LoadPalette
    ret
; ------------

PaletteData_1:
			;  data 1 (red 0-7; blue 0-7); data 2 (0000; green 0-7)
			db 0x00, 0x00 ; Color index 0
			db 0x77, 0x00 ; Color index 1
			db 0x10, 0x00 ; Color index 2
			db 0x20, 0x00 ; Color index 3
			db 0x30, 0x00 ; Color index 4
			db 0x40, 0x00 ; Color index 5
			db 0x50, 0x00 ; Color index 6
			db 0x60, 0x00 ; Color index 7
			db 0x70, 0x00 ; Color index 8
			db 0x11, 0x01 ; Color index 9
			db 0x22, 0x02 ; Color index 10
			db 0x33, 0x03 ; Color index 11
			db 0x77, 0x07 ; Color index 12
			db 0x66, 0x06 ; Color index 13
			db 0x55, 0x05 ; Color index 14
			db 0x44, 0x04 ; Color index 15

PaletteData_2:
			;  data 1 (red 0-7; blue 0-7); data 2 (0000; green 0-7)
			db 0x00, 0x00 ; Color index 0
			db 0x00, 0x01 ; Color index 1
			db 0x00, 0x02 ; Color index 2
			db 0x00, 0x03 ; Color index 3
			db 0x00, 0x04 ; Color index 4
			db 0x00, 0x05 ; Color index 5
			db 0x00, 0x06 ; Color index 6
			db 0x00, 0x07 ; Color index 7
			db 0x03, 0x00 ; Color index 8
			db 0x03, 0x01 ; Color index 9
			db 0x03, 0x02 ; Color index 10
			db 0x03, 0x03 ; Color index 11
			db 0x03, 0x04 ; Color index 12
			db 0x03, 0x05 ; Color index 13
			db 0x03, 0x06 ; Color index 14
			db 0x03, 0x07 ; Color index 15



	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF




; ----------------- Variables
    org 0xc000

; vars for line interrupt routine:
Flag_LineInterrupt:	    rb 1        ; these two vars MUST be on sequential addresses 
Counter_LineInterrupt:	rb 1        ; this var MUST be imediately after Flag_LineInterrupt

