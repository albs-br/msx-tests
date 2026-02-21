FNAME "screen-split.rom"      ; output file

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

; Default VRAM tables for Screen 4
SC4_NAMTBL:     equ 0x1800  ; to 0x1aff (768 bytes)
SC4_PATTBL:     equ 0x0000  ; to 0x17ff (6144 bytes)
SC4_COLTBL:     equ 0x2000  ; to 0x37ff (6144 bytes)
SC4_SPRPAT:     equ 0x3800  ; to 0x3fff (2048 bytes)
SC4_SPRCOL:     equ 0x1c00  ; to 0x1dff (512 bytes)
SC4_SPRATR:     equ 0x1e00  ; to 0x1e7f (128 bytes)


; Default VRAM tables for Screen 8
SC8_NAMTBL:     equ 0x00000

LINE_INTERRUPT_NUMBER: equ 128


Execute:

    ; define screen colors
    ld 		a, 1      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 5  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 3      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color




    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    Set192Lines

    call    SetColor0ToTransparent




    ;call    .lineInterruptCode ; Set_SPRATR_top


    ; ------------------------ Draw screen 4 (first 128 lines) -----------------------------

    ld      a, 4
    call    BIOS_CHGMOD
    ; di
    ;     call    Set_SC4
    ; ei

    ld      a, 00001111 b               ; data
    ld		hl, SC4_PATTBL              ; VRAM address
    ld      bc, 512 * 8                 ; Length of the area to be written
    call    BIOS_BIGFIL                 ; Fill VRAM with value

    ld      a, 0x47                     ; data
    ld		hl, SC4_COLTBL              ; VRAM address
    ld      bc, 512 * 8                 ; Length of the area to be written
    call    BIOS_BIGFIL                 ; Fill VRAM with value

    ld      a, 0                        ; data
    ld		hl, SC4_NAMTBL              ; VRAM address
    ld      bc, 512                     ; Length of the area to be written
    call    BIOS_BIGFIL                 ; Fill VRAM with value


    ; ------------------------ Draw screen 8 (other lines) -----------------------------

    ld      a, 8
    call    BIOS_CHGMOD
    ; di
    ;     call    Set_SC8
    ; ei

    ; SC8 pixel format: ggg rrr bb
    ld      a, 0001 1100 b                       ; data
    ld		hl, SC8_NAMTBL + (128 * 256); VRAM address
    ld      bc, 256 * 64                ; Length of the area to be written
    call    BIOS_BIGFIL                 ; Fill VRAM with value

; call    BIOS_ENASCR ; DEBUG
; jp $ ; debug

    ; --------------------

    ; Init variables
    xor  	a
    ld  	(Flag_LineInterrupt), a
    ld  	(Counter_LineInterrupt), a



; ----------------- set screen split

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
        ld  	b, LINE_INTERRUPT_NUMBER - 1 - 3		; data to write
        ld  	c, 19		; register number
        call  	WRTVDP_without_DI_EI		; Write B value to C register
    ei


    call    BIOS_ENASCR

    call    BIOS_BEEP


.loop:
    call    Wait_Vblank

    ; ld      a, (Sprite_Direction)
    ; ld      b, a
    ; ld      a, (Sprite_Y)
    ; add     b
    ; ld      (Sprite_Y), a


    ; ld      c, PORT_0

    ; ld      a, 0000 0001 b
    ; ld      hl, SPRATR + (31 * 4)  ; Y coord of sprite # 31
    ; call    SetVdp_Write
    ; ld      a, (Sprite_Y)
    ; out     (c), a

    ; ld      a, 0000 0001 b
    ; ld      hl, SPRATR_2 + (31 * 4)  ; Y coord of sprite # 31
    ; call    SetVdp_Write
    ; ld      a, (Sprite_Y)
    ; out     (c), a


    ; cp      LINE_INTERRUPT_NUMBER
    ; call    z, .setDirectionUp

    ; cp      LINE_INTERRUPT_NUMBER - 16
    ; call    z, .setDirectionDown




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

    ; Code to run on Vblank:
    jp      z, Set_SC4

    ; Code to run on line interrupt:
    jp   	Set_SC8

; ------------

Set_SC4:
; ---- set screen mode to SC4
    ; R#0   0 DG 0 IE1 M5 M4 M3 0
    ld      b, 0001 0100 b  ; data
    ld      a, b
    ld  	(REG0SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 0            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register

    ; R#1   0 1 1 M1 M2 0 1 0
    ld      b, 0110 0010  b  ; data
    ld      a, b
    ld  	(REG1SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 1            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register

    ; ---- set all table base addresses
    
    ; set NAMTBL base addr
    ; R#2   0 A16 (...) A10
    ld      b, 0000 0110 b  ; data
    ld      a, b
    ld  	(REG2SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 2            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register
    
    ; set COLTBL base addr
    ; R#3   A13 (...) A6
    ld      b, 1111 1111 b  ; data
    ld      a, b
    ld  	(REG3SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 3            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register
    ; R#10  0 0 0 0 0 A16 A15 A14
    ld      b, 0000 0000 b  ; data
    ld      a, b
    ld  	(REG10SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 10           ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register

    ; set PATTBL base addr
    ; R#4   0 0 A16 (...) A11
    ld      b, 0000 0011 b  ; data
    ld      a, b
    ld  	(REG4SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 4            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register

    ret

Set_SC8:
; ---- set screen mode to SC8
    ; R#0   0 DG 0 IE1 M5 M4 M3 0
    ld      b, 0001 1110 b  ; data
    ld      a, b
    ld  	(REG0SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 0            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register

    ; R#1   0 1 1 M1 M2 0 1 0
    ld      b, 0110 0010 b  ; data
    ld      a, b
    ld  	(REG1SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 1            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register

    ; set NAMTBL base addr, set page 0
    ; R#2   0 0 A16 1 1 1 1 1
    ld      b, 0001 1111 b  ; data
    ld      a, b
    ld  	(REG2SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 2            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register
    ; R#3   
    ld      b, 1000 0000 b  ; data
    ld      a, b
    ld  	(REG3SAV), a ; it's a good practice to update the REGnSAV values
    ld      c, 3            ; register #
    call  	WRTVDP_without_DI_EI		; Write B value to C register

    ret



End:

; ------------- Data


; ----------------- Variables
    org 0xc000

; vars for line interrupt routine:
Flag_LineInterrupt:	    rb 1        ; these two vars MUST be on sequential addresses 
Counter_LineInterrupt:	rb 1        ; this var MUST be imediately after Flag_LineInterrupt


; Sprite_Y:               rb 1
; Sprite_Direction:       rb 1