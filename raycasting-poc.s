FNAME "raycasting-poc.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0x7fff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    ; Common
    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"


; Default VRAM tables for Screen 4
NAMTBL:     equ 0x3800  ; to 0x???? (768 bytes)
SPRPAT:     equ 0x1800  ; to 0x???? (2048 bytes)
SPRCOL:     equ 0x1c00  ; to 0x???? (512 bytes)
SPRATR:     equ 0x1e00  ; to 0x???? (128 bytes)

//SPRCOL_2:   equ 0xfc00  ; to 0xfdff (512 bytes)
//SPRATR_2:   equ 0xfe00  ; to 0xfe80 (128 bytes)



Execute:


    ; change to screen 4
    ld      a, 4
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    Set192Lines

    call    SetColor0ToNonTransparent

    call    BIOS_ENASCR

    call    BIOS_BEEP


; ray casting code starts here

; -------- raycasting-msx


; There are 262 lines on NTSC and 313 lines on PAL. Each line takes exactly 228 CPU cycles if the VDP and CPU are 
; clocked by the same clock crystal. Consequently, a frame takes 262 × 228 = 59736 CPU cycles on NTSC and 
; 313 × 228 = 71364 CPU cycles on PAL. The precise display frequency is therefore 59.92 Hz on NTSC and 50.16 Hz on PAL.


; ----------------------------------  32 columns:

; read a seq of 16 bytes for column tile numbers and copy it to a column on NAMTBL buffer
;   bc: ROM start addr of column (origin)
;   hl: ROM start addr of NAMTBL buffer (destiny)

    ld  de, 32              ; screen width in tiles

    .loop: ; use macro to repeat 16 times (height of column)
        ld	    a, (bc)		; 8
        ld	    (hl), a		; 8
        ;inc	bc		; 7
        inc	    c		    ; 5	; data should be table aligned
        add	    hl, de		; 12

; total 33 cycles / char

; + 18 of outi = 51 cycles/char

; 512 chars (2/3 of screen): 51 x 512 = 26112 cycles (44% of 1 frame)

; ----------------------------------  32 columns optimized:

; read a seq of 16 bytes for column tile numbers and copy it to a column on NAMTBL buffer
;   sp: ROM start addr of column (origin)
;   hl: ROM start addr of NAMTBL buffer (destiny)

    di
    ld  (OldSP), sp
    ld  de, 32              ; screen width in tiles

    .loop: ; use macro to repeat 8 times (height of column / 2)
        pop     bc		    ; 11    BC = (SP); SP += 2
        ld	    (hl), c		; 8
        add	    hl, de		; 12
        ld	    (hl), b		; 8
        add	    hl, de		; 12

    ld  sp, (OldSP)
    ei

; total 51 cycles / 2 chars

; + 36 of 2x outi = 87 cycles / 2 chars

; 512 chars (2/3 of screen): 87 x (512/2) = 22272 cycles (37% of 1 frame)

; ----------------------------------  32 columns (optimized? in speed, size much worse):

; read a seq of 16 bytes for column tile numbers and copy it to a column on NAMTBL buffer
;   sp: ROM start addr of column (origin)
;   nnnn: start addr of NAMTBL buffer (destiny)

    di
    ld  (OldSP), sp

.loop_cols: ; use macro to repeat 32 times (number of columns)          -->     col++
    .loop_lines: ; use macro to repeat 8 times (height of column / 2)      -->     line+=2
        pop     hl		                            ; 11    HL = (SP); SP += 2
        ld      a, l                                ; 5
        ld	    (nnnn + (line * 32) + col), a       ; 14
        ld      a, h                                ; 5
        ld	    (nnnn + ((line+1) * 32) + col), a   ; 14

    ld  sp, (OldSP)
    ei

; total 49 cycles / 2 chars

; + 36 of 2x outi = 85 cycles / 2 chars

; 512 chars (2/3 of screen): 85 x (512/2) = 21760 cycles (36% of 1 frame)

; ----------------------------------  64 columns:

; read two seq of 16 bytes for columns tile numbers and copy it to a column on NAMTBL buffer
;   bc: ROM start addr of even column (origin)
;   de: ROM start addr of odd column (origin)
;   hl: ROM start addr of NAMTBL buffer (destiny)

    di
    ld  (OldSP), sp
    ld	sp, 32              ; screen width in tiles

    .loop: ; use macro to repeat 16 times (height of column)
        ld	    a, (bc)		; 8
        ld	    ixl, a		; 10
        ld	    a, (de)		; 8
        or	    ixl		    ; 10
        ld	    (hl), a		; 8
        ;inc	bc		; 7
        inc	    c		    ; 5	; data should be table aligned
        inc	    e		    ; 5	; data should be table aligned
        add	    hl, sp		; 12


    ld  sp, (OldSP)
    ei

; total 66 cycles

; + 18 of outi = 84 cycles/char

; 512 chars (2/3 of screen): 84 x 512 = 43008 cycles (72% of 1 frame)

; ----------------------------------  64 columns (improved speed/much bigger size):

; read two seq of 16 bytes for columns tile numbers and copy it to a column on NAMTBL buffer
;   hl: ROM start addr of even column (origin)
;   de: ROM start addr of odd column (origin)
;   nnnn: start addr of NAMTBL buffer (destiny)

.loop_cols: ; use macro to repeat 32 times (number of columns)     -->     col++
    .loop_lines: ; use macro to repeat 16 times (height of column)      -->     line++
        ld	    a, (de)		                    ; 8
        or	    (hl)	                        ; 8
        ld	    (nnnn + (line * 32) + col), a   ; 14
        inc	    l		                        ; 5	; data should be table aligned
        inc	    e		                        ; 5	; data should be table aligned



; total 40 cycles / 7 bytes

; + 18 of outi = 58 cycles/char

; 512 chars (2/3 of screen): 58 x 512 = 29696 cycles (50% of 1 frame)

; 7 bytes x 32 x 16 = 3584 bytes

; -----------------------------------
    






; ; cast ray from player position, on an angle, until find a wall (block)
; ; Inputs:
; ;   HL: player X (0-255), L: 0
; ;   DE: offset X (8.8 fixed point)
; ;   H'L': player Y (0-255), L: 0
; ;   D'E': offset Y (8.8 fixed point)
;     ld      b, HIGH_BYTE_BASE_ADDR_DIV_BY_16_LUT
; .loop:
;     ; H: player X (0-255), L: 0
;     ; DE: offset X (8.8 fixed point)
;     add     hl, de      ; add current X to offset X
    
;     ; ; divide by 16 to convert to cells on map (32 cycles)
;     ; srl     h
;     ; srl     h
;     ; srl     h
;     ; srl     h

;     ; ; divide by 16 to convert to cells on map (27 cycles)
;     ; ld      a, h
;     ; and     1111 0000 b
;     ; rrca
;     ; rrca
;     ; rrca
;     ; rrca

;     ; divide by 16 to convert to cells on map (18 cycles)
;     ; ld      b, base_addr_div_by_16_LUT
;     ld      c, h
;     ld      a, (bc)

;     ; map cell X is on low nibble of A

;     di
;         exx
;             ; H: player Y (0-255), L: 0
;             ; DE: offset Y (8.8 fixed point)
;             add     hl, de      ; add current Y to offset Y

;             ; clear 4 low bits of H
;             ld      a, h
;             and     1111 0000 b
;             push    af ; save map cell Y

;             ; map cell Y is on high nibble of H
;         exx
;     ei

;     pop     hl ; restore map cell Y
;     or      h   ; merge cell X with cell Y

;     ; map cell X, Y is now on A

;     ld      h, HIGH_BYTE_BASE_ADDR_MAP
;     ld      l, a
;     cp      (hl)

;     jp      z, .loop    ; if block not found, next step on ray

;     ; block found code here



; -------------------------------------------------------


; raytrace from player until find a wall
; HL: addr of deltas for map cells reached by this ray
; ??: player map cell (256x256)

ld      bc, (PlayerPositionOnMap)
;ld      d, 0 + (RaytraceMapCells & 0xff00) >> 8     ; get high byte of addr <-- should be done dinamically

.loop: ; use macro to repeat 16x
    ; get delta value
    ld      e, (hl) ; DE = (HL)
    inc     l
    ld      d, (hl)

	push    hl
        ld	    h, b ; HL = (PlayerPositionOnMap)
        ld	    l, c
        ;ld      hl, (PlayerPositionOnMap)
        add	    hl, de  ; HL += delta cell map for ray cast

        ; A = 4 upper bits of H and L (transform a coordinate in the format (4.4, 4.4) fixed point in (4, 4) integer)
        ld      a, h
        and     1111 0000 b
        ld      h, a

        ld      d, base_addr_div_by_16_LUT
        ld      e, l
        ld      a, (de)

        or      h

        ; get cell on 16x16 map
        ld      h, 0 + (Map & 0xff00) >> 8     ; get high byte of addr
        ld      l, a
        
        xor     a
        cp	    (hl)
    pop     hl

	jp	    nz, .blockFound
	inc	    l       ; HL++
	
	;jp	.loop

; 149 cycles
; x 16 cells x 32 angles = 76288 cycles (128% of 1 frame)


; ray trace example:
RaytraceMapCells:       ; table aligned
	dw +1 * 16, +2 * 16, +3 * 16..., +15 * 16  ; ray aligned to right
	
    ;dw -1 * 16, -2 * 16, -3 * 16..., -15 * 16  ; ray aligned to left
    ;dw -16 * 16, -32 * 16, -48 * 16 ...  ; ray aligned to top



; -------------------------------------------------------



	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF




; ----------------- Variables
    org 0xc000

; CAUTION: this buffer needs to be table aligned
NAMTBL_Buffer:  rb 32 * 16 ; only upper 2/3 of the screen
Columns_Addr:   rw 32

OldSP:          rw 1


; ----------
    org 0xd000
Map:
	rb 16*16        ; table aligned
