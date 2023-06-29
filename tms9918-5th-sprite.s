FNAME "tms9918-5th-sprite.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 2
SPRPAT:     equ 0x3800  ; to 0x3fff (2048 bytes)
SPRATR:     equ 0x1b00  ; to 0x1b7f (128 bytes)
; xx01 1011 0000 0000 b

; -----
SPRATR_1:     equ 0x1b80  ; to 0x1b7f (128 bytes)
; xx01 1011 1000 0000 b

Execute:

    ; -------- trying to show more than 4 sprites per line
    ; spoiler: don't work, shows 1st line of the 4 first sprites, then the 2nd line of the 4 other sprites...
    ; as if the VDP read the sprite attr table on start of each line

    ; define screen colors
    ld 		a, 1      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 1  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 1      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color

    ; change to screen 3
    ld      a, 2
    call    BIOS_CHGMOD

    ; clear VRAM
    ; TODO

    ; load SPRPAT
    ld		hl, SpritePatternsData      ; RAM address (source)
    ld		de, SPRPAT					; VRAM address (destiny)
    ld		bc, SpritePatternsData.size	; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load SPRATR 0
    ld		hl, SPRATRData              ; RAM address (source)
    ld		de, SPRATR					; VRAM address (destiny)
    ld		bc, SPRATRData.size	        ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load SPRATR 1
    ld		hl, SPRATR_1_Data              ; RAM address (source)
    ld		de, SPRATR_1					; VRAM address (destiny)
    ld		bc, SPRATR_1_Data.size	        ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory




    ld      h, 0 ; 

    ; ld	    a, (0x0006)	; Main-ROM must be selected on page 0000h-3FFFh
	; inc	    a
	; ld	    c, a	; C = CPU port #99h (VDP reading port#1)

.loop:

    ; read vdp status register #0
	in	    a, (PORT_1)	; read the value to the port#1

    bit     6, a
    jp      z, .loop

    ; if (H == 0) { H = 1; show SPRATR; }
    ld      a, h
    or      a
    jp      z, .SPRATR

    ; else  { H = 0; show SPRATR_1; }
    jp      .SPRATR_1

.SPRATR:
    ld      h, 1
    ; set SPRATR 0
    ld      a, 0011 0110 b     ; value
    ld      b, 5 OR 0x80     ; register number
    call    WR2VDPREG
    jp      .loop

.SPRATR_1:
    ld      h, 0
    ; set SPRATR 1
    ld      a, 0011 0111 b     ; value
    ld      b, 5 OR 0x80    ; register number
    call    WR2VDPREG
    jp      .loop

End:

SpritePatternsData:
    db      1111 1111 b
    db      1111 1111 b
    db      1111 1111 b
    db      1111 1111 b
    db      1111 1111 b
    db      1111 1111 b
    db      1111 1111 b
    db      1111 1111 b
    ; db      1010 1111 b
    ; db      0101 1111 b
    ; db      1010 1111 b
    ; db      0101 1111 b
    ; db      1010 1111 b
    ; db      0101 1111 b
    ; db      1010 1111 b
    ; db      0101 1111 b
.size: equ $ - SpritePatternsData

SPRATRData:
    db 96, 0,  0, 4
    db 96, 16, 0, 8
    db 96, 32, 0, 10
    db 96, 48, 0, 2
    
    db 96, 64, 0, 15   ; 5th sprite
.size: equ $ - SPRATRData

SPRATR_1_Data:
    db 96, 100 + 64,  0, 7
    db 96, 100 + 80,  0, 15
    db 96, 100 + 96,  0, 3
    db 96, 100 + 112, 0, 13

    db 96, 128, 0, 15   ; 5th sprite
.size: equ $ - SPRATR_1_Data

VDP_DW:	equ	0007h	; VDP data write port
 
; Routine to write a byte to a VDP register.
 
; Entry: A = data, B = register number + 80h (to set the bit 7)
;
; Modify: BC 
 
WR2VDPREG:
	; push	af
	; ld	a,(VDP_DW)	; A = First writing port used to access the internal VDP
	; ld	c,a
	; inc	c		; C = CPU port connected to the VDP writing port #1
    ld      c, PORT_1
 
	di			; Interrupts must be disabled here
	; pop	af
	out	    (c), a		; Write the data
	out	    (c), b		; Write the register number (with the bit 7 always set)
	ei			; Interrupts can be enabled here
	ret