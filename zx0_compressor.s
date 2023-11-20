FNAME "zx0_compressor.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

    INCLUDE "Include/dzx0_standard.asm"

; ZX0_NonStandard_Decompressor:

; ; code that needs to be realocated later need to be PHASE'd and DEPHASE'd 
; ; in order to solve correctly the labels
; PHASE   0xe000

;     ;INCLUDE "Include/dzx0_turbo.asm"
;     ;INCLUDE "Include/dzx0_fast.asm"
;     INCLUDE "Include/dzx0_mega.asm"

; DEPHASE

; ZX0_NonStandard_Decompressor_size:  equ $ - ZX0_NonStandard_Decompressor

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
; Documentation: https://github.com/einar-saukas/ZX0
;
; "Standard" routine: 68 bytes only
; "Turbo" routine: 126 bytes, about 21% faster
; "Fast" routine: 187 bytes, about 25% faster
; "Mega" routine: 673 bytes, about 28% faster

    ; using standard decompressor
    ld      hl, ZX0_ImageData
    ld      de, UncompressedData
    call    dzx0_standard
    
    ; ; using non-standard decompressors (they need to be on RAM, as they use self-modifying code)
    ; ld	    hl, ZX0_NonStandard_Decompressor
    ; ld	    de, ZX0_DecompressCode
    ; ld	    bc, ZX0_NonStandard_Decompressor_size
    ; ldir
    ; ld      hl, ZX0_ImageData
    ; ld      de, UncompressedData
    ; call    ZX0_DecompressCode

; --------- Load uncompressed data to screen     
    ld		hl, UncompressedData   			        ; RAM address (source)
    ld      a, 0                                    ; VRAM address (destiny, bit 16)
    ld		de, NAMTBL + 8192                       ; VRAM address (destiny, bits 15-0)
    ld		c, 0 + (UncompressedData.size / 256)    ; Block length * 256
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


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff



; RAM
	org     0xc000, 0xe5ff


UncompressedData:     rb 8192
.size:      equ $ - UncompressedData

ZX0_DecompressCode:     rb 800 ; the largest code is 673 bytes, plus some space to be on the safe side