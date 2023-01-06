FNAME "bcd_calculator.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Constants
OPERAND_SIZE:   equ 2

ZERO_CHR:       equ 0x30
SPACE_CHR:      equ 0x20
PLUS_CHR:       equ 0x2b
MINUS_CHR:      equ 0x2d
EQUAL_CHR:      equ 0x3d

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



    ld      hl, Operand_1
    ld      de, Operand_2
    ld      ix, Result
    call    Test_Addition

    ld      hl, Operand_3
    ld      de, Operand_4
    ld      ix, Result
    call    Test_Addition

    ld      hl, Operand_5
    ld      de, Operand_6
    ld      ix, Result
    call    Test_Addition

    ld      hl, Operand_7
    ld      de, Operand_8
    ld      ix, Result
    call    Test_Addition

    ld      hl, Operand_9
    ld      de, Operand_10
    ld      ix, Result
    call    Test_Addition

    ld      hl, Operand_11
    ld      de, Operand_12
    ld      ix, Result
    call    Test_Addition



    ; ld      hl, Operand_1
    ; call    Print
    
    ; ld      hl, Operand_2
    ; call    Print

    ; ld      hl, Operand_1
    ; ld      de, Operand_2
    ; ld      ix, Result
    ; call    Addition

    ; ld      hl, Result
    ; call    Print



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



; Inputs:
;   HL: Operand 1
;   DE: Operand 2
;   IX: Result
Test_Addition:

    ; ---------- Print ' ' + Operand 1
    ld      a, SPACE_CHR
    call    BIOS_CHPUT

    push    ix, de, hl
        ;ld      hl, Operand_1
        call    Print
    pop     hl, de, ix



    ; ---------- Print '+' + Operand 2
    ld      a, PLUS_CHR
    call    BIOS_CHPUT

    push    ix, de, hl
        ex      de, hl
        ;ld      hl, Operand_2
        call    Print
    pop     hl, de, ix



    ; Execute operation
    ; ld      hl, Operand_1
    ; ld      de, Operand_2
    ; ld      ix, Result
    push    ix
        call    Addition
    pop     hl



    ; ---------- Print '=' + Result
    ld      a, EQUAL_CHR
    call    BIOS_CHPUT

    ;ld      hl, Result
    call    Print

    call    PrintCrLf

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


Operand_1:    db      0x71, 0x34      ; 7134
Operand_2:    db      0x05, 0x90      ;  590

Operand_3:    db      0x08, 0x43      ;  843
Operand_4:    db      0x04, 0x09      ;  409

Operand_5:    db      0x00, 0x00      ;    0
Operand_6:    db      0x00, 0x00      ;    0

Operand_7:    db      0x00, 0x01      ;    1
Operand_8:    db      0x00, 0x99      ;   99

; from Wikipedia:
; Subtraction is done by adding the ten's complement of the subtrahend to the minuend. 
; To represent the sign of a number in BCD, the number 0000 is used to represent a positive number, 
; and 1001 (decimal 9) is used to represent a negative number. The remaining 14 combinations are invalid signs.

; To illustrate signed BCD subtraction, consider the following problem: 357 − 432:
; In signed BCD, 357 is 0000 0011 0101 0111. The ten's complement of 432 can be obtained by taking the nine's 
; complement of 432, and then adding one. So, 999 − 432 = 567, and 567 + 1 = 568. By preceding 568 in BCD by 
; the negative sign code, the number −432 can be represented. So, −432 in signed BCD is 1001 0101 0110 1000.

Operand_9:    db      0x01, 0x01      ;  101
Operand_10:   db      0x09, 0x80      ;  -20 ==> 999 - 20 + 1 = 980

Operand_11:    db      0x00, 0x01      ;    1
Operand_12:   db      0x09, 0x80      ;  -20 ==> 999 - 20 + 1 = 980


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff



; RAM
	org     0xc000, 0xe5ff


Result:     rb OPERAND_SIZE
