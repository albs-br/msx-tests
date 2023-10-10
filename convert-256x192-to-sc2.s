; some untested code for ploting pixels on screen 2/4 converting from 
; x, y pixels (256x192) to cols, lines (32x192)


; Inputs: H = x (0-255), L = y (0-191)
; Outputs: 
;   DE = PATTBL address offset
;   A = bit pattern
Convert_XY_to_Addr:

    ; TODO: 3 low bits of Y should be converted to pattern:
    ; 000 = 1000 0000
    ; 001 = 0100 0000
    ; 010 = 0010 0000
    ; ...
    ; 111 = 0000 0001
    ld      h, LOOKUP_TABLE_BITS >> 8
    ld      l, nnn ; n = value (0-7)
    ld      a, (hl)

    ; convert y (L register) in pixels (0-191) to PATTBL addr
    ld      a, h

    sla     l   ; shift left register, 0 --> bit 0, bit 7 --> carry
    rla         ; rotate left A, carry --> bit 0, bit 7 --> carry
    sla     l
    rla
    sla     l
    rla
    sla     l
    rla
    sla     l
    rla

    ld      a, d

    
    
    ; convert x
    srl     h   ; shift right, 0 --> bit 7, bit 0 --> carry
    srl     h
    srl     h


    ; E = H or L
    ld      a, l
    or      h
    ld      e, a



    ret







    ; ld      hl, LOOKUP_TABLE_NAMTBL_BUFFER_LINES
    ; ld      b, 0
    ; add     hl, bc
    ld      h, LOOKUP_TABLE_NAMTBL_BUFFER_LINES >> 8


    ; ex      de, hl ; DE = HL
    
    ; HL = (HL)
    ld      a, (hl)
    ld      b, a
    ; inc     hl ; it may be INC L if LUT is table aligned
    inc     l
    ld      a, (hl)
    ld      h, a
    ld      l, b




    ; convert x in pixels (0-255) to cols (0-31)
    srl     a   ; shift right register
    srl     a
    srl     a




LOOKUP_TABLE_NAMTBL_BUFFER_LINES: ; must be table aligned
    dw      NAMTBL_BUFFER + (32 * 0)
    dw      NAMTBL_BUFFER + (32 * 1)
    dw      NAMTBL_BUFFER + (32 * 2)
    dw      NAMTBL_BUFFER + (32 * 3)
    ; TODO ...


LOOKUP_TABLE_BITS:
    db      1000 0000 b ; 0
    db      0100 0000 b ; 1
    db      0010 0000 b ; 2
    ; ...
    db      0000 0001 b ; 7
