FNAME "screen3.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 3
NAMTBL:     equ 0x0800  ; to 0x???? (768 bytes)
PATTBL:     equ 0x0000  ; to 0x???? (? bytes)
SPRPAT:     equ 0x3800  ; to 0x???? (2048 bytes)
SPRATR:     equ 0x1b00  ; to 0x???? (128 bytes)

Execute:
    ; change to screen 3
    ld      a, 3
    call    BIOS_CHGMOD

    ; clear VRAM
    ; TODO

    ; load PATTBL
    ld		hl, PatternsData            ; RAM address (source)
    ld		de, PATTBL					; VRAM address (destiny)
    ld		bc, PatternsData.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load NAMTBL
    ld		hl, NamesTableData          ; RAM address (source)
    ld		de, NAMTBL					; VRAM address (destiny)
    ld		bc, NamesTableData.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    jp      $ ; eternal loop


End:

PatternsData:
    ; colors for top left, top right, bottom left and bottom right (four bits each)
    db      0x78, 0x4a      ; char # 0
    db      0xcd, 0xdc      ; char # 1
    db      0xef, 0xfe      ; char # 2
.size:  equ $ - PatternsData

NamesTableData:
    db      0, 1, 2, 0, 0, 0, 0, 0
.size:  equ $ - NamesTableData

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF



; RAM
;	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)


; VerticalScroll:     rb 1

; debug_0:    rb 1
; debug_1:    rb 1
