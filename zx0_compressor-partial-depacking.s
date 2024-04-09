FNAME "zx0_compressor-partial-depacking.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:
    call    Screen11

    call    ClearVram_MSX2

    call    Set192Lines

    call    SetColor0ToTransparent

NAMTBL:     equ 0x00000

; --------- Load original data to screen     
    ld	    hl, ImageData                       ; RAM address (source)
    ld      a, 0                                ; VRAM address (destiny, bit 16)
    ld	    de, NAMTBL                          ; VRAM address (destiny, bits 15-0)
    ld	    c, 0 + (ImageData.size / 256)       ; Block length * 256
    call    LDIRVM_MSX2



; ---------------- Decompress data (init & first 2048 bytes)

    ; init partial decompressor
    ld      hl, UncompressedData + 2048 ; address to stop depacking
    ld      (NextDestiny), hl
    ld      a, 0
    ld      (ReturnPoint), a

    ; using custom partial decompressor
    ld      hl, ZX0_ImageData
    ld      de, UncompressedData
    call    dzx0_standard_partial_depacking
    
; --------- Load uncompressed data to screen     
    ld	    hl, UncompressedData   	            ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld	    de, NAMTBL + 8192 + 1024                ; VRAM address (destiny, bits 15-0)
    ld	    c, 2048/256 ; 0 + (UncompressedData.size / 256)    ; Block length * 256
    call    LDIRVM_MSX2




    call    TrashAllRegisters

; ---------------- Decompress data (next part, next 2048 bytes)

    ; set partial decompressor for next block
    ld      hl, UncompressedData + 4096 ; address to stop depacking
    ld      (NextDestiny), hl

    ; using custom partial decompressor
;     ld      hl, ZX0_ImageData
;     ld      de, UncompressedData
    call    dzx0_standard_partial_depacking
    
; --------- Load uncompressed data to screen     
    ld	    hl, UncompressedData + 2048             ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld	    de, NAMTBL + 8192 + 1024 + 2048         ; VRAM address (destiny, bits 15-0)
    ld	    c, 2048/256 ; 0 + (UncompressedData.size / 256)    ; Block length * 256
    call    LDIRVM_MSX2



    call    TrashAllRegisters

; ---------------- Decompress data (next part, next 2048 bytes)

    ; set partial decompressor for next block
    ld      hl, UncompressedData + 4096 + 2048 ; address to stop depacking
    ld      (NextDestiny), hl

    ; using custom partial decompressor
;     ld      hl, ZX0_ImageData
;     ld      de, UncompressedData
    call    dzx0_standard_partial_depacking
    
; --------- Load uncompressed data to screen     
    ld	    hl, UncompressedData + 2048 + 2048      ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld	    de, NAMTBL + 8192 + 1024 + 2048 + 2048  ; VRAM address (destiny, bits 15-0)
    ld	    c, 2048/256 ; 0 + (UncompressedData.size / 256)    ; Block length * 256
    call    LDIRVM_MSX2




    jp      $ ; eternal loop


; Original data
ImageData:
    INCBIN "Images/level1_0.sra.new.first8kb" ; 8 kb
.size:      equ $ - ImageData

; Compressed data
ZX0_ImageData:
    INCBIN "Images/level1_0.sra.new.first8kb.zx0" ; 2.25 kb
.size:      equ $ - ZX0_ImageData



; ------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; ZX0 decoder by Einar Saukas & Urusergi
; "Standard" version (68 bytes only)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

dzx0_standard_partial_depacking:

        ld      a, (ReturnPoint)
        or      a
        jp      z, .normalStart

        cp      1; TODO: 'dec a'to save cycles
        jp      z, .RestoreRegistersAndGoTo_ReturnPoint_1
        ; jp      ReturnPoint_2

; RestoreRegistersAndGoTo_ReturnPoint_2:
        call    RestoreRegisters
        push    bc
        jp      ReturnPoint_2

.RestoreRegistersAndGoTo_ReturnPoint_1:
        call    RestoreRegisters
        push    bc
        jp      ReturnPoint_1

.normalStart:
        ld      bc, $ffff               ; preserve default offset 1
        push    bc
        inc     bc
        ld      a, $80
dzx0s_literals:
        call    dzx0s_elias             ; obtain length
        ldir                            ; copy literals


        ; ---- exit partial
        ld      ixl, a
        push    hl, de
            ex      de, hl ; current DE (destiny) goes to HL
            ld      de, (NextDestiny)
            call    BIOS_DCOMPR         ; Compare Contents Of HL & DE, Set Z-Flag IF (HL == DE), Set CY-Flag IF (HL < DE)
        pop     de, hl
        ld      a, ixl
        ; jp      nc, .exit_1 ; TODO: replace thes 2 JP's by "jp c, .cont_1"
        ; jp      .cont_1
        jp      c, .cont_1
.exit_1:
        pop     bc                      ; discard last offset
        call    SaveRegisters
        ld      a, 1
        ld      (ReturnPoint), a
        ret
.cont_1:
ReturnPoint_1:
        ; ------------------

        add     a, a                    ; copy from last offset or new offset?

        jr      c, dzx0s_new_offset
        call    dzx0s_elias             ; obtain length
dzx0s_copy:
        ex      (sp), hl                ; preserve source, restore offset
                push    hl                      ; preserve offset
                add     hl, de                  ; calculate destination - offset
                ldir                            ; copy from offset
                pop     hl                      ; restore offset
        ex      (sp), hl                ; preserve offset, restore source


        ; ---- exit partial
        ld      ixl, a
        push    hl, de
            ex      de, hl ; current DE (destiny) goes to HL
            ld      de, (NextDestiny)
            call    BIOS_DCOMPR         ; Compare Contents Of HL & DE, Set Z-Flag IF (HL == DE), Set CY-Flag IF (HL < DE)
        pop     de, hl
        ld      a, ixl
        ; jp      nc, .exit_1 ; TODO: replace thes 2 JP's by "jp c, .cont_1"
        ; jp      .cont_1
        jp      c, .cont_1
.exit_1:
        pop     bc                      ; discard last offset
        call    SaveRegisters
        ld      a, 2
        ld      (ReturnPoint), a
        ret
.cont_1:
ReturnPoint_2:
        ; ------------------


        add     a, a                    ; copy from literals or new offset?

        jr      nc, dzx0s_literals
dzx0s_new_offset:
        pop     bc                      ; discard last offset
        ld      c, $fe                  ; prepare negative offset
        call    dzx0s_elias_loop        ; obtain offset MSB
        inc     c
        ret     z                       ; check end marker
        ld      b, c
        ld      c, (hl)                 ; obtain offset LSB
        inc     hl
        rr      b                       ; last offset bit becomes first length bit
        rr      c
        push    bc                      ; preserve new offset
        ld      bc, 1                   ; obtain length
        call    nc, dzx0s_elias_backtrack
        inc     bc
        jr      dzx0s_copy
dzx0s_elias:
        inc     c                       ; interlaced Elias gamma coding
dzx0s_elias_loop:
        add     a, a
        jr      nz, dzx0s_elias_skip
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
dzx0s_elias_skip:
        ret     c
dzx0s_elias_backtrack:
        add     a, a
        rl      c
        rl      b
        jr      dzx0s_elias_loop

; -----------------------------------------------------------------------------

SaveRegisters:
        ; save registers
        ld      (Registers.HL), hl
        ld      (Registers.DE), de
        ld      (Registers.BC), bc

        push    af
        pop     bc
        ld      (Registers.AF), bc

        ret

RestoreRegisters:
        ;restore registers
        ld      bc, (Registers.AF)
        push    bc
        pop     af

        ld      hl, (Registers.HL)
        ld      de, (Registers.DE)
        ld      bc, (Registers.BC)

        ret

; -----------------------------------------------------------------------------

; trash all registers for testing purposes
TrashAllRegisters:
        ld      bc, 0
        ld      de, 0
        ld      hl, 0
        ld      a, 0
        ret


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff



; RAM
	org     0xc000, 0xe5ff


UncompressedData:     rb 8192
.size:      equ $ - UncompressedData



; vars of zx0 partial depacker
NextDestiny:            rw 1

Registers:
.AF:            rw 1
.BC:            rw 1
.DE:            rw 1
.HL:            rw 1

ReturnPoint:    rb 1