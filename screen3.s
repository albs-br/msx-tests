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
NAMTBL:     equ 0x0800  ; to 0x0aff (768 bytes)
PATTBL:     equ 0x0000  ; to 0x07ff (2048 bytes)
SPRPAT:     equ 0x3800  ; to 0x3fff (2048 bytes)
SPRATR:     equ 0x1b00  ; to 0x1b7f (128 bytes)

Execute:
    ; define screen colors
    ld 		a, 1      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 1  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 1      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color

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
    db      0x00, 0x00      ; char # 0, lines 0,  4,  8, 12, 16, 20
    db      0x00, 0x00      ; char # 0, lines 1,  5,  9, 13, 17, 21
    db      0x00, 0x00      ; char # 0, lines 2,  6, 10, 14, 18, 22
    db      0x00, 0x00      ; char # 0, lines 3,  7, 11, 15, 19, 23
    
    db      0x22, 0x22      ; char # 1, lines 0,  4,  8, 12, 16, 20
    db      0x34, 0x45      ; char # 1, lines 1,  5,  9, 13, 17, 21
    db      0xcd, 0xdc      ; char # 1, lines 2,  6, 10, 14, 18, 22
    db      0x78, 0x78      ; char # 1, lines 3,  7, 11, 15, 19, 23
    
    db      0xef, 0xfe      ; char # 2, lines 0,  4,  8, 12, 16, 20
    db      0x23, 0x32      ; char # 2, lines 1,  5,  9, 13, 17, 21
    db      0xab, 0xba      ; char # 2, lines 2,  6, 10, 14, 18, 22
    db      0x45, 0x54      ; char # 2, lines 3,  7, 11, 15, 19, 23
.size:  equ $ - PatternsData

NamesTableData:
    db      2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 0
    db      2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 1
    db      2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 2
    db      2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 3
    db      2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 4
    db      2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 5
    db      2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 6
    db      2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 7
    db      2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 8
    db      2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 9
    db      2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 10
    db      2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 11
.size:  equ $ - NamesTableData

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF



; RAM
;	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)


; VerticalScroll:     rb 1

; debug_0:    rb 1
; debug_1:    rb 1
