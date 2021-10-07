; Load palette data pointed by HL
LoadPalette:
			; set palette register number in register R#16 (Color palette address pointer)
			ld      b, 0    ; data
            ld      c, 16   ; register #
            call    BIOS_WRTVDP
            ld      c, 0x9a ; V9938 port #2

			ld      b, 16
.loop:
			di
                ld    a, (hl)
                out   (c), a
                inc   hl
                ld    a, (hl)
                out   (c), a
            ei
            inc     hl
            djnz    .loop
            
			ret



; Typical routine to select the ROM on page 8000h-BFFFh from page 4000h-7FFFh
EnableRomPage2:
; source: https://www.msx.org/wiki/Develop_a_program_in_cartridge_ROM#Typical_examples_to_make_a_32kB_ROM

	call	BIOS_RSLREG
	rrca
	rrca
	and	    3	;Keep bits corresponding to the page 4000h-7FFFh
	ld	    c,a
	ld	    b,0
	ld	    hl, BIOS_EXPTBL
	add	    hl,bc
	ld	    a,(hl)
	and	    80h
	or	    c
	ld	    c,a
	inc	    hl
	inc	    hl
	inc	    hl
	inc	    hl
	ld	    a,(hl)
	and	    0Ch
	or	    c
	ld	    h,080h
	call	BIOS_ENASLT		; Select the ROM on page 8000h-BFFFh

    ret


Wait:
	ld		c, 15

	.loop:
		ld      a, (BIOS_JIFFY)
		ld      b, a
	.waitVBlank:
		ld      a, (BIOS_JIFFY)
		cp      b
		jp      z, .waitVBlank

	dec		c
	jp		nz, .loop

	ret



;
; Set VDP address counter to write from address AHL (17-bit)
; Enables the interrupts
;
SetVdp_Write:
    rlc h
    rla
    rlc h
    rla
    srl h
    srl h
    di
    out (PORT_1),a
    ld a,14 + 128
    out (PORT_1),a
    ld a,l
    nop
    out (PORT_1),a
    ld a,h
    or 64
    ei
    out (PORT_1),a
    ret

;
; Set VDP address counter to read from address AHL (17-bit)
; Enables the interrupts
;
SetVdp_Read:
    rlc h
    rla
    rlc h
    rla
    srl h
    srl h
    di
    out (PORT_1),a
    ld a,14 + 128
    out (PORT_1),a
    ld a,l
    nop
    out (PORT_1),a
    ld a,h
    ei
    out (PORT_1),a
    ret


; TODO:
; ClearVram_MSX2:
;     ; clear VRAM
;     ; set address counter (bits 16 to 14)
;     ld      b, 0000 0000 b  ; data
;     ld      c, 6            ; register #
;     call    BIOS_WRTVDP

;     ; set address counter (bits 7 to 0)
;     ld      c, PORT_1
;     ld      a, 0000 0000 b
;     di
;     out     (c), a
;     ; set address counter (bits 13 to 8) and operation mode
;     ;           0: read, 1: write
;     ;           |
;     ld      a, 0100 0000 b
;     ei
;     out     (c), a
;     ; write to VRAM
;     xor     a
;     ld      b, 0 ;256 iterations
;     ld      c, PORT_0
; .loop:
;     di
;         out (c), a
;     ei
;     dec     b
;     jp      nz, .loop
	
; 	ret

; ClearVram_MSX2:

; 	ld		d, 7

; .loop:

;     ; set 3 upper bits of VRAM addr (bits 16 to 14)
;     ld      b, 1; d  			; data
;     ld      c, 14           ; register #
;     call    BIOS_WRTVDP

; 	; Set register #14
; 	; DI
; 	; LD    A, 1;d   ; Base adress #4000
; 	; OUT   (PORT_1), A
; 	; LD    A, 14 + 128 ; Write regster #14 (BIT 7 is set for writing)
; 	; OUT   (PORT_1), A
; 	; EI

; 	xor		a
; 	ld		hl, 0
; 	ld		bc, 16384 * 2
; 	call	BIOS_BIGFIL
; 	; dec		d
; 	; jp		nz, .loop


; 	ret


ClearVram_MSX2:
    xor a           ; set vram write base address
    ld hl, 0     	; to 1st byte of page 0
    call SetVDP_Write

;     xor a
; FillL1:
;     ld c, 64          ; fill 1st 8 lines of page 1
; FillL2:
;     ld b, 0        ;
;     out (PORT_0),a     ; could also have been done with
;     djnz FillL2     ; a vdp command (probably faster)
;     dec c           ; (and could also use a fast loop)
;     jp nz,FillL1

	xor		a

	ld		d, 2		; 2 repetitions
.loop_2:
	ld		c, 0		; 256 repetitions
.loop_1:
	ld		b, 0		; 256 repetitions
.loop:
	out		(PORT_0), a
	djnz	.loop
	dec		c
	jp		nz, .loop_1
	dec		d
	jp		nz, .loop_2

	ret


Screen11:
    ; change to screen 11
    ; it's needed to set screen 8 and change the YJK and YAE bits of R#25 manually
    ld      a, 8
    call    BIOS_CHGMOD
    ld      b, 0001 1000 b  ; data
    ld      c, 25            ; register #
    call    BIOS_WRTVDP
	ret

SetSprites16x16:
    ld      a, (REG1SAV)
    or      0000 0010 b
    ld      b, a
    ld      c, 1            ; register #
    call    BIOS_WRTVDP
	ret

Set192Lines:
    ; set 192 lines
    ; ld      b, 0000 0000 b  ; data
    ; ld      c, 9            ; register #
    ; call    BIOS_WRTVDP
    ld      a, (REG9SAV)
    and     0111 1111 b
    ld      b, a
    ld      c, 9            ; register #
    call    BIOS_WRTVDP
	ret

SetColor0ToTransparent:
    ; set color 0 to transparent
    ; ld      b, 0000 1000 b  ; data
    ; ld      c, 8            ; register #
    ; call    BIOS_WRTVDP
    ld      a, (REG8SAV)
    and     1101 1111 b
    ld      b, a
    ld      c, 8            ; register #
    call    BIOS_WRTVDP
	ret

; Inputs:
; 	HL: source addr in RAM
; 	ADE: 17 bits destiny addr in VRAM
; 	C: number of bytes x 256 (e.g. C=64, total = 64 * 256 = 16384)
LDIRVM_MSX2:
    ;ld      a, 0000 0000 b
    ex		de, hl
	;ld      hl, NAMTBL + (0 * (256 * 64))
    call    SetVdp_Write
    ex		de, hl
    ld      d, c
    ;ld      hl, ImageData_1
    ld      c, PORT_0        ; you can also write ld bc,#nn9B, which is faster
    ld      b, 0
.loop_1:
    otir
    dec     d
    jp      nz, .loop_1
	ret