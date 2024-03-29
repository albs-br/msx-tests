FNAME "doom-fire-msx.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0x7fff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

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

;SPRCOL_2:   equ 0xfc00  ; to 0xfdff (512 bytes);
;SPRATR_2:   equ 0xfe00  ; to 0xfe7f (128 bytes)



Execute:


    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    SetSpritesMagnified

    call    Set192Lines

    call    SetColor0ToNonTransparent


    ; -------------------------------------------------------

    ; Load sprite pattern #0
    ; ld      a, 0000 0000 b
    ; ld      hl, SPRPAT
    ; call    SetVdp_Write
    ; ld      b, SpritePattern_1.size
    ; ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ; ld      hl, SpritePattern_1
    ; otir


    ; -------------------------------------------------------
    ; Load sprite colors table

    ld      a, 0000 0000 b
    ld      hl, SPRCOL
    call    SetVdp_Write
    ld      b, 0; 256 bytes SpriteColors_1.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteColors_a
    otir

    ; -------------------------------------------------------
    ; Load sprite atributes table

    ld      a, 0000 0000 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      b, SpriteAttributes_top.size
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      hl, SpriteAttributes_top
    otir

    ; -------------------------------------------------------

    call    BIOS_ENASCR

    call    BIOS_BEEP


    ; Wait space bar to be pressed
.readKeyBoard:
    ; read keyboard
    ld      a, 8                    ; 8th line
    call    BIOS_SNSMAT             ; Read Data Of Specified Line From Keyboard Matrix
    ;call  	SNSMAT_NO_DI_EI
    bit     0, a                ; 0th bit (space bar)
    jp    	z, .exit

    jp  	.readKeyBoard
.exit:

    ; ------ Init vars

    ; Init random number generator
    ld      hl, (BIOS_JIFFY)                  ; MSX BIOS time variable
    ld      a, l
    or      0x80                             ; A value different of zero is granted
    ld      l, a
    ld      (Seed), hl

    ; Fill up LUT of pre calc rnd values
    ld      hl, RndNumbers
    ld      b, 0
.loop_rnd:
    call    RandomNumber
    ld      (hl), a
    inc     hl
    djnz    .loop_rnd

    ; Main loop
MainLoop:
    call    Wait_Vblank

;     ld      hl, SPRPAT + (12 * 8)

;     ld      b, 16
; .loop:
;     push    hl
;         xor     a
;         call    SetVdp_Write
;         ld      c, PORT_0

;         ld      a, 0xff ; data

;         out     (c), a
;     pop     hl

;     inc     hl
;     djnz    .loop


    xor     a
    ld      hl, SPRPAT + (13 * 8) + 7 ; last line
    call    SetVdp_Write
    ld      c, PORT_0

    ;ld      a, 0xff ; data
    call    RandomNumber
    out     (c), a

    jp      MainLoop

    ; -------------------------------------------------------
    ; Data
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
    db 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
.size:  equ $ - SpriteColors_a


SpriteAttributes_top:
    db  -1 + (191 - (32 * 4)), (32 * 0), 0 * 4, 0 ; -1 to compensate the Y+1 bug/feature of VDP
    db  -1 + (191 - (32 * 3)), (32 * 0), 1 * 4, 0
    db  -1 + (191 - (32 * 2)), (32 * 0), 2 * 4, 0
    db  -1 + (191 - (32 * 1)), (32 * 0), 3 * 4, 0

    db  -1 + (191 - (32 * 4)), (32 * 1), 4 * 4, 0
    db  -1 + (191 - (32 * 3)), (32 * 1), 5 * 4, 0
    db  -1 + (191 - (32 * 2)), (32 * 1), 6 * 4, 0
    db  -1 + (191 - (32 * 1)), (32 * 1), 7 * 4, 0

    db  -1 + (191 - (32 * 4)), (32 * 1), 8 * 4, 0
    db  -1 + (191 - (32 * 3)), (32 * 1), 9 * 4, 0
    db  -1 + (191 - (32 * 2)), (32 * 1), 10 * 4, 0
    db  -1 + (191 - (32 * 1)), (32 * 1), 11 * 4, 0

    db  -1 + (191 - (32 * 4)), (32 * 1), 12 * 4, 0
    db  -1 + (191 - (32 * 3)), (32 * 1), 13 * 4, 0
    db  -1 + (191 - (32 * 2)), (32 * 1), 14 * 4, 0
    db  -1 + (191 - (32 * 1)), (32 * 1), 15 * 4, 0

    db  216, 0, 0, 0 ; hide all sprites from this onwards
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0
    db  0, 0, 0, 0

.size:  equ $ - SpriteAttributes_top

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF




; ----------------- Variables
    org 0xc000

Seed:                       rw 1            ; Seed for random number generator

; ---------------------------
    org 0xdf00
RND_NUMBERS_HIGH_BYTE_BASE_ADDR:    equ 0xdf
RndNumbers:                 rb 256


;       doom fire fx msx
;       
;       0	0 0000	2 	0 0010	16 1 0000
;       1	0 0001	3 	0 0011	17 1 0001
;       
;       4	0 0100	6 	0 0110
;       5	0 0101	7 	0 0111
;       
;       8	0 1000	10	0 1010
;       9	0 1001	11	0 1011
;       
;       12	0 1100	14	  1110
;       13	0 1101	15	  1111