FNAME "v9990.rom"      ; output file

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"


; --------------- V9990 constants

V9:

; ------ MSX V9990 ports:
; 60h~6Fh*	Graphics9000 / V9990.

; V9900 I/O PORT SPECIFICATIONS
; P#0	VRAM DATA	(R/W)
; P#1	PALETTE DATA	(R/W)
; P#2	COMMAND DATA	(R/W)
; P#3	REGISTER DATA	(R/W)
; P#4	REGISTER SELECT	(W)
; P#5	STATUS	(R)
; P#6	INTERRUPT FLAG	(R/W)
; P#7	SYSTEM CONTROL	(W)
; P#8-B	Kanji ROM
; P#C-F	Reserved

.PORT_0:    equ 0x60
.PORT_1:    equ 0x61
.PORT_2:    equ 0x62
.PORT_3:    equ 0x63
.PORT_4:    equ 0x64
.PORT_5:    equ 0x65
.PORT_6:    equ 0x66
.PORT_7:    equ 0x67
; ... TODO: include more ports



; P1 VRAM mapping
; 00000-3FDFF	(Sprite) Pattern Data (Layer A)
; 3FE00-3FFFF	Sprite Attribute Table
; 40000-7BFFF	Pattern Data (Layer B)
; 7C000-7DFFF	PNT(A) - Pattern Name Table (Layer A)
; 7E000-7FFFF	PNT(B) - Pattern Name Table (Layer B)

; P1 mode:
.P1_PATTBL_LAYER_A:     equ 0x00000     ; 00000-3FDFF	(Sprite) Pattern Data (Layer A)
.P1_PATTBL_LAYER_B:     equ 0X40000     ; 40000-7BFFF	Pattern Data (Layer B)
.P1_SPRATR:             equ 0X3fe00     ; 3FE00-3FFFF	Sprite Attribute Table
.P1_NAMTBL_LAYER_A:     equ 0X7c000     ; 7C000-7DFFF	PNT(A) - Pattern Name Table (Layer A)
.P1_NAMTBL_LAYER_B:     equ 0X7e000     ; 7E000-7FFFF	PNT(B) - Pattern Name Table (Layer B)

; -------------------------------------------------------------

; To set a value in the register, have the register No. output at REGISTER SELECT port (P#4) and then the data at REGISTER DATA port (P#3).

; Set register number A with value in B
.SetRegister:
    out     (V9.PORT_4), a  ; register number
    ld      a, b
    out     (V9.PORT_3), a  ; value
    ret


Execute:

    ; ------- set P1 mode

    ; set MCS = 0 on P#7
    ld      a, 0
    out     (V9.PORT_7), a

    ; set DSPM = 0 (bits 7-6) of R#6
    ; set DKCM = 0 (bits 5-4) of R#6
    ; set XIMM = 1 (bits 3-2) of R#6
    ; set CLRM = 1 (bits 1-0) of R#6
    ld      a, 6            ; register number
    ld      b, 0000 0101 b  ; value
    call    SetRegister

    ; bit 7 of R#7 is fixed at 0
    ; set C25M = 0 (bit 6) of R#7
    ; set SM1 = 0 (bit 5) of R#7
    ; set SM = 0 (bit 4) of R#7
    ; set PAL = 0 (bit 3) of R#7
    ; set EO = 0 (bit 2) of R#7
    ; set IL = 0 (bit 1) of R#7
    ; set HSCN = 0 (bit 0) of R#7
    ld      a, 7            ; register number
    ld      b, 0000 0000 b  ; value
    call    V9.SetRegister

    ; ------- set tile pattern
    ld		hl, ImageData        				    ; RAM address (source)
    ld		a, 0					                ; VRAM address bits 18-16 (destiny)
    ld		de, 0					                ; VRAM address bits 15-0 (destiny)
    ld		bc, ImageData.size					    ; Block length
    call 	V9.LDIRVM        						; Block transfer to VRAM from memory

    ; ------- set names table

    jp      $   ; eternal loop


; -------------------------------------------------------------

; To write a value in VRAM, set the target address to VRAM Write Base Address registers (R#0-R#2) 
; and have the data output at VRAM DATA port (P#0). As the bit 7 (MSB) of R#2 functions as
; AII (Address Increment Inhibit), if it is "1", automatic address increment by writing the data is inhibited.

; To read the data of VRAM, set the target address to VRAM Read Base Address registers (R#3-R#5) and read 
; in the data of VRAM DATA port (P#0). As the bit 7 (MSB) of R#5 functions as AII (Address Increment Inhibit), 
; if it is "1", automatic address increment by reading in the data is inhibited.

; The address can be specified up to 19 bits (512K bytes), with lower 8 bits set to R#0 (or R#3), center 8 
; bits to R#1 (or R#4) and upper 3 bits to R#2 (or R#5).

; Note: Always the full address must be written. Specifying partial addresses will not work correctly.

; ----- Write to VRAM:
; set P#4 to 0000 0000 b
; set P#3 to VRAM lower addr (bits 0-7)
; set P#3 to VRAM center addr (bits 8-15)
; set P#3 to VRAM upper addr (bits 16-18) --> warning: higher bit here is AII (explained above)
; set P#0 to value to be written
; if AII is 0, write next bytes to sequentially P#0


.LDIRVM:
    push    bc
        push    af
            ld      c, V9.PORT_4
            
            ; set P#4 to 0000 0000 b
            ld      a, 0000 0000 B
            out     (c), a

            ld      c, V9.PORT_3

            ; set P#3 to VRAM lower addr (bits 0-7)
            out     (c), e

            ; set P#3 to VRAM center addr (bits 8-15)
            out     (c), d
        pop     af

        ; set P#3 to VRAM upper addr (bits 16-18) --> warning: higher bit here is AII (explained above)
        and     0111 1111 b     ; force AII bit to 0
        out     (c), a
    pop     de


    ;out     (c), a

    ld      c, V9.PORT_0
.LDIRVM_loop:
    ; set P#0 to value to be written
    outi
    
    dec     e
    jp      nz, .LDIRVM_loop
    dec     d
    jp      nz, .LDIRVM_loop

    ret



; -----------------------------------------------------------------


; 8x8 x 4bpp tile
Tile_0:
    db  0xff, 0xff, 0xff, 0xff
    db  0xf0, 0x00, 0x00, 0x0f
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
    db  0xff, 0xff, 0xff, 0xff
