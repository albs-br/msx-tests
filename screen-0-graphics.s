FNAME "screen-0-graphics.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 0
NAMTBL:     equ 0x0000  ; to 0x03ff (960 bytes)
PATTBL:     equ 0x0800  ; to 0x0bff (2048 bytes)

Execute:
    ; define screen colors
    ld 		a, 15      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 1  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 4      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color

    ; change to screen 0
    ld      a, 0
    call    BIOS_CHGMOD

    ; ---- clear VRAM
	; fill NAMTBL with pattern 255 (empty pattern)
    ld	    hl, NAMTBL		                    ; VRAM start address
    ld      bc, 40*24                           ; number of bytes
    ld      a, 255                              ; value
    call    BIOS_FILVRM                         ; Fill VRAM

    ld	    hl, PATTBL		                    ; VRAM start address
    ld      bc, 256*8                           ; number of bytes
    ld      a, 0                                ; value
    call    BIOS_FILVRM                         ; Fill VRAM


    ; ; load PATTBL
    ; ld		hl, PatternsData            ; RAM address (source)
    ; ld		de, PATTBL + (255 * 8)      ; VRAM address (destiny)
    ; ld		bc, 8 ;PatternsData.size	    ; Block length
    ; call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory




    ld      a, 0
    call    SetupSprite_8x8





    ld      a, 0
    ld      h, 0
    ld      l, 0
    call    PutSprite_8x8

    jp      $ ; eternal loop


; Inputs:
;   A: pattern number of sprite
SetupSprite_8x8:

    ; get addr of sprite pattern in ROM
    ld      de, SpritePatterns_ROM
    ld      h, 0
    ld      l, a        ; HL = pattern number
    add     hl, hl      ; multiply by 8
    add     hl, hl
    add     hl, hl
    add     hl, de      ; HL = address of the sprite pattern in ROM




    
    ld b, 2 ; TEST shift 2 pixels

    ld      de, SpritePatterns_RAM

    ld      ixl, 8 ; loop counter for lines

        .loop_lines:

            push    bc
                ld      c, (hl)

                ld      a, b
                or      a
                jp      z, .ignore_loop_shift

                .loop_shift:
                        srl     c               ; shift right register 1 pixel
                        djnz    .loop_shift
                .ignore_loop_shift:

                ld      a, c
                ld      (de), a
                inc     hl
                inc     de
            pop     bc

    dec     ixl
    jp      nz, .loop_lines





    ret




; Inputs:
;   A: pattern number of sprite
;   H: coordinate X of the sprite (0-239)
;   L: coordinate Y of the sprite (0-191)
PutSprite_8x8:
    push  	af, hl
        ; ---- convert X to column number (0-39)
        ld      bc, LookUpTable_DivideBy6
        ld      l, h
        ld      h, 0            ; HL = x
        add     hl, hl          ; multiply by 2 to get the offset in the table
        add     hl, bc          ; add the base address of the table
        ld      c, (hl)         ; get the column number (0-39)
        inc     hl
        ld      b, (hl)         ; get the remainder (0-5)
    pop     hl, af

    ; Get RAM address of the pre-shifted sprite pattern
    ; ld      de, SpritePatterns_RAM
    ; ld      h, 0
    ; ld      l, a        ; HL = pattern number
    ; add     hl, hl      ; multiply by 8
    ; add     hl, hl
    ; add     hl, hl
    ; add     hl, de      ; HL = address of the sprite pattern in ROM
    ld      hl, SpritePatterns_RAM ; test






    ; update PATTBL
    push    hl
        ld      hl, PATTBL
        call    BIOS_SETWRT ; SetVdp_Write
    pop     hl
    ;ld      hl, SPRATR_Buffer
    ld      c, PORT_0
    outi outi outi outi outi outi outi outi 



    ; update NAMTBL
    ; ld      a, 0
    ld      hl, NAMTBL
    call    BIOS_SETWRT ; SetVdp_Write
    ;ld      hl, SPRATR_Buffer
    ld      c, PORT_0
    ld      a, 0
    out     (c), a
    ld      a, 1
    out     (c), a



    ret



End:


LookUpTable_DivideBy6:
    db  0, 0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5 ; inputs 0-5
    db  1, 0, 1, 1, 1, 2, 1, 3, 1, 4, 1, 5 ; inputs 6-11
    db  2, 0, 2, 1, 2, 2, 2, 3, 2, 4, 2, 5 ; inputs 12-17
    db  3, 0, 3, 1, 3, 2, 3, 3, 3, 4, 3, 5 ; inputs 18-23
    db  4, 0, 4, 1, 4, 2, 4, 3, 4, 4, 4, 5 ; inputs 24-29
    db  5, 0, 5, 1, 5, 2, 5, 3, 5, 4, 5, 5 ; inputs 30-35
    db  6, 0, 6, 1, 6, 2, 6, 3, 6, 4, 6, 5 ; inputs 36-41
    db  7, 0, 7, 1, 7, 2, 7, 3, 7, 4, 7, 5 ; inputs 42-47
    db  8, 0, 8, 1, 8, 2, 8, 3, 8, 4, 8, 5 ; inputs 48-53
    db  9, 0, 9, 1, 9, 2, 9, 3, 9, 4, 9, 5 ; inputs 54-59
    db 10, 0, 10, 1, 10, 2, 10, 3, 10, 4, 10, 5 ; inputs 60-65
    db 11, 0, 11, 1, 11, 2, 11, 3, 11, 4, 11, 5 ; inputs 66-71
    db 12, 0, 12, 1, 12, 2, 12, 3, 12, 4, 12, 5 ; inputs 72-77
    db 13, 0, 13, 1, 13, 2, 13, 3, 13, 4, 13, 5 ; inputs 78-83
    db 14, 0, 14, 1, 14, 2, 14, 3, 14, 4, 14, 5 ; inputs 84-89
    db 15, 0, 15, 1, 15, 2, 15, 3, 15, 4, 15, 5 ; inputs 90-95
    db 16, 0, 16, 1, 16, 2, 16, 3, 16, 4, 16, 5 ; inputs 96-101
    db 17, 0, 17, 1, 17, 2, 17, 3, 17, 4, 17, 5 ; inputs 102-107
    db 18, 0, 18, 1, 18, 2, 18, 3, 18, 4, 18, 5 ; inputs 108-113
    db 19, 0, 19, 1, 19, 2, 19, 3, 19, 4, 19, 5 ; inputs 114-119
    db 20, 0, 20, 1, 20, 2, 20, 3, 20, 4, 20, 5 ; inputs 120-125
    db 21, 0, 21, 1, 21, 2, 21, 3, 21, 4, 21, 5 ; inputs 126-131
    db 22, 0, 22, 1, 22, 2, 22, 3, 22, 4, 22, 5 ; inputs 132-137
    db 23, 0, 23, 1, 23, 2, 23, 3, 23, 4, 23, 5 ; inputs 138-143
    db 24, 0, 24, 1, 24, 2, 24, 3, 24, 4, 24, 5 ; inputs 144-149
    db 25, 0, 25, 1, 25, 2, 25, 3, 25, 4, 25, 5 ; inputs 150-155
    db 26, 0, 26, 1, 26, 2, 26, 3, 26, 4, 26, 5 ; inputs 156-161
    db 27, 0, 27, 1, 27, 2, 27, 3, 27, 4, 27, 5 ; inputs 162-167
    db 28, 0, 28, 1, 28, 2, 28, 3, 28, 4, 28, 5 ; inputs 168-173
    db 29, 0, 29, 1, 29, 2, 29, 3, 29, 4, 29, 5 ; inputs 174-179
    db 30, 0, 30, 1, 30, 2, 30, 3, 30, 4, 30, 5 ; inputs 180-185
    db 31, 0, 31, 1, 31, 2, 31, 3, 31, 4, 31, 5 ; inputs 186-191
    db 32, 0, 32, 1, 32, 2, 32, 3, 32, 4, 32, 5 ; inputs 192-197
    db 33, 0, 33, 1, 33, 2, 33, 3, 33, 4, 33, 5 ; inputs 198-203
    db 34, 0, 34, 1, 34, 2, 34, 3, 34, 4, 34, 5 ; inputs 204-209
    db 35, 0, 35, 1, 35, 2, 35, 3, 35, 4, 35, 5 ; inputs 210-215
    db 36, 0, 36, 1, 36, 2, 36, 3, 36, 4, 36, 5 ; inputs 216-221
    db 37, 0, 37, 1, 37, 2, 37, 3, 37, 4, 37, 5 ; inputs 222-227
    db 38, 0, 38, 1, 38, 2, 38, 3, 38, 4, 38, 5 ; inputs 228-233
    db 39, 0, 39, 1, 39, 2, 39, 3, 39, 4, 39, 5 ; inputs 234-239

LookUpTable_DivideBy8:
    db  0, 0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7 ; inputs 0-7
    db  1, 0, 1, 1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1, 7 ; inputs 8-15
    db  2, 0, 2, 1, 2, 2, 2, 3, 2, 4, 2, 5, 2, 6, 2, 7 ; inputs 16-23
    db  3, 0, 3, 1, 3, 2, 3, 3, 3, 4, 3, 5, 3, 6, 3, 7 ; inputs 24-31
    db  4, 0, 4, 1, 4, 2, 4, 3, 4, 4, 4, 5, 4, 6, 4, 7 ; inputs 32-39
    db  5, 0, 5, 1, 5, 2, 5, 3, 5, 4, 5, 5, 5, 6, 5, 7 ; inputs 40-47
    db  6, 0, 6, 1, 6, 2, 6, 3, 6, 4, 6, 5, 6, 6, 6, 7 ; inputs 48-55
    db  7, 0, 7, 1, 7, 2, 7, 3, 7, 4, 7, 5, 7, 6, 7, 7 ; inputs 56-63
    db  8, 0, 8, 1, 8, 2, 8, 3, 8, 4, 8, 5, 8, 6, 8, 7 ; inputs 64-71
    db  9, 0, 9, 1, 9, 2, 9, 3, 9, 4, 9, 5, 9, 6, 9, 7 ; inputs 72-79
    db 10, 0, 10, 1, 10, 2, 10, 3, 10, 4, 10, 5, 10, 6, 10, 7 ; inputs 80-87
    db 11, 0, 11, 1, 11, 2, 11, 3, 11, 4, 11, 5, 11, 6, 11, 7 ; inputs 88-95
    db 12, 0, 12, 1, 12, 2, 12, 3, 12, 4, 12, 5, 12, 6, 12, 7 ; inputs 96-103
    db 13, 0, 13, 1, 13, 2, 13, 3, 13, 4, 13, 5, 13, 6, 13, 7 ; inputs 104-111
    db 14, 0, 14, 1, 14, 2, 14, 3, 14, 4, 14, 5, 14, 6, 14, 7 ; inputs 112-119
    db 15, 0, 15, 1, 15, 2, 15, 3, 15, 4, 15, 5, 15, 6, 15, 7 ; inputs 120-127
    db 16, 0, 16, 1, 16, 2, 16, 3, 16, 4, 16, 5, 16, 6, 16, 7 ; inputs 128-135
    db 17, 0, 17, 1, 17, 2, 17, 3, 17, 4, 17, 5, 17, 6, 17, 7 ; inputs 136-143
    db 18, 0, 18, 1, 18, 2, 18, 3, 18, 4, 18, 5, 18, 6, 18, 7 ; inputs 144-151
    db 19, 0, 19, 1, 19, 2, 19, 3, 19, 4, 19, 5, 19, 6, 19, 7 ; inputs 152-159
    db 20, 0, 20, 1, 20, 2, 20, 3, 20, 4, 20, 5, 20, 6, 20, 7 ; inputs 160-167
    db 21, 0, 21, 1, 21, 2, 21, 3, 21, 4, 21, 5, 21, 6, 21, 7 ; inputs 168-175
    db 22, 0, 22, 1, 22, 2, 22, 3, 22, 4, 22, 5, 22, 6, 22, 7 ; inputs 176-183
    db 23, 0, 23, 1, 23, 2, 23, 3, 23, 4, 23, 5, 23, 6, 23, 7 ; inputs 184-191


; PatternsData:
;     db      00000000 b
;     db      00000000 b
;     db      00000000 b
;     db      00000000 b
;     db      00000000 b
;     db      00000000 b
;     db      00000000 b
;     db      00000000 b
; .size:  equ $ - PatternsData

SpritePatterns_ROM:
    db      00111100 b
    db      01101110 b
    db      11100111 b
    db      11111100 b
    db      11110000 b
    db      11111100 b
    db      01111110 b
    db      00111100 b

NamesTableData:
    db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; line # 0
.size:  equ $ - NamesTableData

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF



RAM:
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)


SpritePatterns_RAM:     rb 8 * 8 * 3

; debug_0:    rb 1
; debug_1:    rb 1
