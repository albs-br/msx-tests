FNAME "sc8-double-buffer.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:
    call    EnableRomPage2

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a

    ; change to screen 8
    ld      a, 8
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    Set192Lines

    call    SetColor0ToNonTransparent

    call    DisableSprites


    
 
    ; --- Load background on first page

    ; SC 8 - line 0 of page 0
    ld      a, 0000 0000 b
    ld      hl, 0x0000
    call    LoadImageTo_SC8_Page

    ; ; SC 8 - line 64 of page 1 (line 320 overall)
    ; ld      a, 0000 0000 b
    ; ld      hl, 0x0000
    ; call    LoadImageTo_SC8_Page





    call    BIOS_ENASCR



    ; --- Set R#23 (Vertical scroll register)
    ld      b, 128  ; data
    ld      c, 23   ; register #
    call    BIOS_WRTVDP

    jp $ ; [debug]

;--------------------------------------------------------------------

; Input:
;   A: value of R#2 to set active page (constants: R2_PAGE_n)
SetActivePage:
    ; set VDP R#2 (NAMTBL base address; bits a10-16)
    ; bits:    16 15        7
    ;           | |         |
    ; 0x08000 = 0 1000 0000 0000 0000
    ; R#2 : 0 a16 a15 1 1 1 1 1

    ; ld      a, 0001 1111 b  ; page 0 (0x00000)
    ; ld      a, 0011 1111 b  ; page 1 (0x08000)
    ; ld      a, 0101 1111 b  ; page 2 (0x10000)
    ; ld      a, 0111 1111 b  ; page 3 (0x18000)
    di
        ; write bits a10-16 of address to R#2
        out     (PORT_1), a ; data
        ld      a, 2 + 128
        out     (PORT_1), a ; register #
    ei

    ret

;--------------------------------------------------------------------




; Input:
;   AHL: 17-bit VRAM address
LoadImageTo_SC8_Page:
	; enable page 1
    push    af
        ld	    a, 1
        ld	    (Seg_P8000_SW), a
    pop     af

    ; first 16kb (top 64 lines)
    push    af, hl
        call    SetVdp_Write
        ld      hl, Bg_Top
        ld      c, PORT_0
        ld      d, 0 + (Bg_Top.size / 256)
        ld      b, 0 ; 256 bytes
    .loop_10:    
        otir
        dec     d
        jp      nz, .loop_10
    pop     hl, af

; 	; enable page 2
;     push    af
;         ld	    a, 2
;         ld	    (Seg_P8000_SW), a
;     pop     af

;     ; lines below 128
;     ld      bc, 16 * 1024
;     add     hl, bc

;     call    SetVdp_Write
;     ld      hl, Bg_Bottom
;     ld      c, PORT_0
;     ld      d, 0 + (Bg_Bottom.size / 256)
;     ld      b, 0 ; 256 bytes
; .loop_20:    
;     otir
;     dec     d
;     jp      nz, .loop_20


    ret





    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF








; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
Bg_Top:
    INCBIN "Images/streets of fight 3MUGZC - top.SR8"
.size:      equ $ - Bg_Top
	ds PageSize - ($ - 0x8000), 255

; ------- Page 2
	org	0x8000, 0xBFFF
	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

