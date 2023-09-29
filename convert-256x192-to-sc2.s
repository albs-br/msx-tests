; some untested code for ploting pixels on screen 2/4 converting from 
; x, y pixels (256x192) to cols, lines (32x192)

    ; convert y (L register) in pixels (0-191) to cols (0-23)
    srl     l   ; shift right register
    srl     l
    srl     l

    sla     l   ; shift left register


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

