FNAME "v9990.rom"      ; output file

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"


; --------------- V9990 constants
V9:
.PORT_0:    equ 0x60
.PORT_1:    equ 0x61
.PORT_2:    equ 0x62
.PORT_3:    equ 0x63
.PORT_4:    equ 0x64
.PORT_5:    equ 0x65
.PORT_6:    equ 0x66
.PORT_7:    equ 0x67
; ... TODO: include more ports

; P1 mode:
.P1_PATTBL_LA:     equ 0x0000
; ... TODO: include more VRAM addresses

Execute:

    ; set P1 mode

    ; set tile pattern

    ; set names table

    jp      $

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


; P1 VRAM mapping
; 00000-3FDFF	(Sprite) Pattern Data (Layer A)
; 3FE00-3FFFF	Sprite Attribute Table
; 40000-7BFFF	Pattern Data (Layer B)
; 7C000-7DFFF	PNT(A) - Pattern Name Table (Layer A)
; 7E000-7FFFF	PNT(B) - Pattern Name Table (Layer B)


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
