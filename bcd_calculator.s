FNAME "bcd_calculator.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:
    ; define screen colors
    ld 		a, 15      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 1  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 1      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color

    ; change to screen 0
    call    BIOS_INITXT

    ; clear VRAM
    ; TODO



    ; ld      hl, Operand_1
    ; ld      de, Operand_2
    ; ld      ix, Result
    ; call    Test_Addition



    ld      hl, Operand_1
    call    Print
    
    ld      hl, Operand_2
    call    Print

    ld      hl, Operand_1
    ld      de, Operand_2
    ld      ix, Result
    call    Addition

    ld      hl, Result
    call    Print

    jp      $ ; eternal loop


; HL: operand a
; DE: operand b
; IX: result
Addition:
    ld      bc, OPERAND_SIZE - 1
    add     hl, bc
    
    ex      de, hl
        add     hl, bc
    ex      de, hl

    add     ix, bc

    xor     a ; clear carry flag
    ld      b, OPERAND_SIZE		; number of bytes of operand
    .loop:
        ld      c, (hl)

        ld      a, (de)
        ; jp      nc, .not_carry
        ; inc     a
        ; daa

    ;.not_carry:
        adc     c
        daa
        ld      (ix), a
        dec     hl
        dec     de
        dec     ix
    djnz	.loop
    ret


; Input: HL
Print:

    ld      b, OPERAND_SIZE
    .loop:
        ld a, (hl)
        ;4x shift right
        srl     a   ; shift right register
        srl     a
        srl     a
        srl     a
        add     ZERO_CHR
        call	BIOS_CHPUT

        ld      a, (hl)
        and     0000 1111 b
        add     ZERO_CHR
        call	BIOS_CHPUT

        inc     hl
    djnz    .loop

    call    PrintCrLf

    ret

PrintCrLf:
    ld      a, 13
    call	BIOS_CHPUT
    ld      a, 10
    call	BIOS_CHPUT    

    ret

End:

OPERAND_SIZE:   equ 2
ZERO_CHR:       equ 0x30

; Operand_1:    db      0x71, 0x34      ; 7134
; Operand_2:    db      0x05, 0x90      ;  590
Operand_1:    db      0x08, 0x43      ; 843
Operand_2:    db      0x04, 0x09      ; 409

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)


Result:     rb OPERAND_SIZE
