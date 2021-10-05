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
ClearVram_MSX2:
    ; clear VRAM
    ; set address counter (bits 16 to 14)
    ld      b, 0000 0000 b  ; data
    ld      c, 6            ; register #
    call    BIOS_WRTVDP

    ; set address counter (bits 7 to 0)
    ld      c, PORT_1
    ld      a, 0000 0000 b
    di
    out     (c), a
    ; set address counter (bits 13 to 8) and operation mode
    ;           0: read, 1: write
    ;           |
    ld      a, 0100 0000 b
    ei
    out     (c), a
    ; write to VRAM
    xor     a
    ld      b, 0 ;256 iterations
    ld      c, PORT_0
.loop:
    di
        out (c), a
    ei
    dec     b
    jp      nz, .loop
	
	ret