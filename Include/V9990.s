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



; Set V9990 to write at address pointed by ADE (19 bits)
.SetVdp_Write:
    ld      b, a    ; save A register

    ; set P#4 to 0000 0000 b
    ld      a, 0000 0000 b
    di
        out     (V9.PORT_4), a

        ld      c, V9.PORT_3

        ; set P#3 to VRAM lower addr (bits 0-7)
        out     (c), e

        ; set P#3 to VRAM center addr (bits 8-15)
        out     (c), d

        ; set P#3 to VRAM upper addr (bits 16-18) --> warning: higher bit here is AII (explained above)
        and     0111 1111 b     ; force AII bit to 0
    ei
    out     (c), b

    ret



; Write VRAM from RAM
; Inputs:
; 	HL: source addr in RAM
; 	ADE: 17 bits destiny addr in VRAM
; 	BC: number of bytes
.LDIRVM:
    push    bc
        push    af
            ; set P#4 to 0000 0000 b
            ld      a, 0000 0000 B
            out     (V9.PORT_4), a

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

    ld      c, V9.PORT_0
.LDIRVM_loop:
    ; set P#0 to value to be written
    outi
    
    dec     de
    ld      a, e
    or      d
    jp      nz, .LDIRVM_loop

    ret


; Set tile pattern at address pointed by ADE (19 bits)
.SetTilePattern:
    push    bc
        call    V9.SetVdp_Write

        ld      c, (V9.PORT_0)

        outi outi outi outi 

        ld      bc, 0x80 - 4    ; tile pattern lines are spaced by 128 bytes (0x80)
        add     hl, bc
    pop     bc
    djnz    .SetTilePattern

    ret