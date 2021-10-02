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