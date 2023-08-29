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
    ld		hl, ImageData        			        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, NAMTBL                              ; VRAM address (destiny, bits 15-0)
    ld		c, 0 + (ImageData.size / 256)           ; Block length * 256
    call    LDIRVM_MSX2



; --------- Decompress data

    ; init partial decompressor
    ld      hl, UncompressedData + 4096
    ld      (NextDestiny), hl

    ; using custom partial decompressor
    ld      hl, ZX0_ImageData
    ld      de, UncompressedData
    call    dzx0_standard_partial_depacking
    
; --------- Load uncompressed data to screen     
    ld		hl, UncompressedData   			        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, NAMTBL + 8192 + 1024                ; VRAM address (destiny, bits 15-0)
    ld		c, 0 + (UncompressedData.size / 256)    ; Block length * 256
    call    LDIRVM_MSX2


    jp      $ ; eternal loop


; Original data
ImageData:
    INCBIN "Images/level1_0.sra.new.first8kb"
.size:      equ $ - ImageData

; Compressed data
ZX0_ImageData:
    INCBIN "Images/level1_0.sra.new.first8kb.zx0"
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
        jp      nc, .exit_1
        jp      .cont_1
.exit_1:
        pop     bc                      ; discard last offset
        ret
.cont_1:
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
        jp      nc, .exit_1
        jp      .cont_1
.exit_1:
        pop     bc                      ; discard last offset
        ret
.cont_1:
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



    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff



; RAM
	org     0xc000, 0xe5ff


UncompressedData:     rb 8192
.size:      equ $ - UncompressedData



; vars of zx0 partial depacker
NextDestiny:            rw 1