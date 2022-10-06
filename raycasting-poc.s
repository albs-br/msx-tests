FNAME "raycasting-poc.rom"      ; output file

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



Execute:


    call    Screen11

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    Set192Lines

    call    SetColor0ToTransparent


; ---- set SPRPAT to 0x1f000
    ; bits:    16     11
    ;           |      |
    ; 0x1f000 = 1 1111 0000 0000 0000
    ; high bits (00aaaaaa: bits 16 to 11)
    ld      b, 0011 1110 b  ; data
    ld      c, 6            ; register #
    call    BIOS_WRTVDP


    call    BIOS_ENASCR

    call    BIOS_BEEP


; ray casting code starts here

; -------- raycasting-msx

; read a seq of 16 bytes for column and copy it to a column on NAMTBL buffer
;   bc: ROM start addr of column (origin)
;   hl: ROM start addr for NAMTBL buffer (destiny)


; ----------------- 32 columns:

ld	de, 32

.loop: ; use macro to repeat 16 times (height of column)
	ld	a, (bc)		; 8
	; or (hl) to low nibble on 64 columns	; 8
	ld	(hl), a		; 8
	;inc	bc		; 7
	inc	c		; 5	; data should be table aligned
	add	hl, de		; 12

; total 33 cycles / char

; + 18 of outi = 51 cycles/char

; 512 chars (2/3 of screen): 51 x 512 = 26112 cycles (44% of 1 frame)

; ----------------- 64 columns:

; read two seq of 16 bytes for columns and copy it to a column on NAMTBL buffer
;   bc: ROM start addr of even column (origin)
;   de: ROM start addr of odd column (origin)
;   hl: ROM start addr for NAMTBL buffer (destiny)

ld	sp, 32

.loop: ; use macro to repeat 16 times (height of column)
	ld	a, (bc)		; 8
	ld	ixl, a		; 10
	ld	a, (de)		; 8
	or	ixl		; 10
	ld	(hl), a		; 8
	;inc	bc		; 7
	inc	c		; 5	; data should be table aligned
	inc	e		; 5	; data should be table aligned
	add	hl, sp		; 12

; total 66
; -----------------------------------
    






; cast ray from player position, on an angle, until find a wall (block)
; Inputs:
;   HL: player X (0-255), L: 0
;   DE: offset X (8.8 fixed point)
;   H'L': player Y (0-255), L: 0
;   D'E': offset Y (8.8 fixed point)
    ld      b, HIGH_BYTE_BASE_ADDR_DIV_BY_16_LUT
.loop:
    ; H: player X (0-255), L: 0
    ; DE: offset X (8.8 fixed point)
    add     hl, de      ; add current X to offset X
    
    ; ; divide by 16 to convert to cells on map (32 cycles)
    ; srl     h
    ; srl     h
    ; srl     h
    ; srl     h

    ; ; divide by 16 to convert to cells on map (27 cycles)
    ; ld      a, h
    ; and     1111 0000 b
    ; rrca
    ; rrca
    ; rrca
    ; rrca

    ; divide by 16 to convert to cells on map (18 cycles)
    ; ld      b, base_addr_div_by_16_LUT
    ld      c, h
    ld      a, (bc)

    ; map cell X is on low nibble of A

    di
        exx
            ; H: player Y (0-255), L: 0
            ; DE: offset Y (8.8 fixed point)
            add     hl, de      ; add current Y to offset Y

            ; clear 4 low bits of H
            ld      a, h
            and     1111 0000 b
            push    af ; save map cell Y

            ; map cell Y is on high nibble of H
        exx
    ei

    pop     hl ; restore map cell Y
    or      h   ; merge cell X with cell Y

    ; map cell X, Y is now on A

    ld      h, HIGH_BYTE_BASE_ADDR_MAP
    ld      l, a
    cp      (hl)

    jp      z, .loop    ; if block not found, next step on ray

    ; block found code here

End:


	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF




; ----------------- Variables
    org 0xc000
