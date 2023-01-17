FNAME "zx0_compressor.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"
    INCLUDE "Include/dzx0_standard.asm"

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
    ld      hl, ZX0_ImageData
    ld      de, UncompressedData
    call    dzx0_standard

; --------- Load uncompressed data to screen     
    ld		hl, UncompressedData   			        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, NAMTBL + (8192)                     ; VRAM address (destiny, bits 15-0)
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


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff



; RAM
	org     0xc000, 0xe5ff


UncompressedData:     rb 8192
.size:      equ $ - UncompressedData
