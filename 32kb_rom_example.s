FNAME "32kb_rom_example.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:

; Typical routine to select the ROM on page 8000h-BFFFh from page 4000h-7BFFFh
	call	BIOS_RSLREG
	rrca
	rrca
	and	3	;Keep bits corresponding to the page 4000h-7FFFh
	ld	c,a
	ld	b,0
	ld	hl,BIOS_EXPTBL
	add	hl,bc
	ld	a,(hl)
	and	80h
	or	c
	ld	c,a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	0Ch
	or	c
	ld	h,080h
	call	BIOS_ENASLT		; Select the ROM on page 8000h-BFFFh



    ; set screen 0
    call    BIOS_INITXT


    ld      hl, Message_0x4000
    call    PrintString

    ld      hl, Message_0x8000
    call    PrintString


    jp      $           ; endless loop

PrintString:
    ld      a, (hl)
    cp      0
    ret     z
    call    BIOS_CHPUT
    inc     hl
    jr      PrintString

Message_0x4000:
    db      "Hello world from page 0x4000", 0

	ds      PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; ------------------------------------------------------------------

    org 0x8000
Message_0x8000:
    db      "Hello world from page 0x8000", 0
	ds      PageSize - ($ - 0x8000), 255	; Fill the unused area with 0xFF
