FNAME "horizontal-offset.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 5
NAMTBL:     equ 0x0000  ; to 0x69FF (27136 bytes) 128 bytes per line * 212 lines = 27136 bytes
SPRPAT:     equ 0x7800  ; to 0x7fff (2048 bytes)
SPRCOL:     equ 0x7400  ; to 0x75ff (512 bytes)
SPRATR:     equ 0x7600  ; to 0x767f (128 bytes)


Execute:
    call    EnableRomPage2

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a

    ; define screen colors
    ld 		a, 15      	            ; Foreground color
    ld 		(BIOS_FORCLR), a    
    ld 		a, 0  		            ; Background color
    ld 		(BIOS_BAKCLR), a     
    ld 		a, 0      	            ; Border color
    ld 		(BIOS_BDRCLR), a    
    call 	BIOS_CHGCLR        		; Change Screen Color

    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    Set192Lines

    call    SetColor0ToNonTransparent

    call    SetSprites16x16

    
	; enable page 2
    ld	    a, 2
	ld	    (Seg_P8000_SW), a
    ; load 32-byte palette data
    ld      hl, ImageData_2.palette
    call    LoadPalette

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData        				    ; RAM address (source)
    ld		de, 0					                ; VRAM address (destiny)
    ld		bc, ImageData.size					    ; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory
            
	; enable page 2
    ld	    a, 2
	ld	    (Seg_P8000_SW), a
    ; write to VRAM bitmap area
    ld		hl, ImageData_2      				    ; RAM address (source)
    ld		de, 16384			                    ; VRAM address (destiny)
    ld		bc, ImageData_2.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory


    ; load sprite pattern
	ld	    hl, SPRPAT		                    ; VRAM start address
    ld      bc, 32                              ; number of bytes
    ld      a, 0xff                             ; value
    call    BIOS_FILVRM                         ; Fill VRAM

    ; load sprite color
	ld	    hl, SPRCOL		                    ; VRAM start address
    ld      bc, 16 * 12                         ; number of bytes
    ld      a, 1000 0000 b OR 0x00              ; value ; bit 7 = Early Clock (-32 pixels to the left)
    call    BIOS_FILVRM                         ; Fill VRAM

	ld	    hl, SPRCOL + (16*12)                ; VRAM start address
    ld      bc, 16 * 12                         ; number of bytes
    ld      a, 0000 0000 b OR 0x00              ; value ; bit 7 = Early Clock (-32 pixels to the left)
    call    BIOS_FILVRM                         ; Fill VRAM


    ld		hl, SPRATR_Data   				        ; RAM address (source)
    ld		de, SPRATR  		                    ; VRAM address (destiny)
    ld		bc, SPRATR_Data.size					; Block length
    call 	BIOS_LDIRVM        						; Block transfer to VRAM from memory


    ; set horizontal offset register (R#18), four low bits
    ld      a, 8
    ld      (CurrentOffset), a

    call    UpdateScrollVariables
    call    UpdateScroll


    call    BIOS_ENASCR


; jp $

; --------- 

.loop:

    ld      b, 15
    call    Wait_B_Vblanks
    ; call    Wait_Vblank








    ; next horizontal offset value
    ld      a, (CurrentOffset)
    inc     a
    and     0000 1111 b
    ld      (CurrentOffset), a



    call    UpdateScrollVariables
    call    UpdateScroll    


    jp      .loop


UpdateScrollVariables:
    ; if(CurrentOffset == 8) SpriteX = 16; else SpriteX++;
    cp      8
    ld      a, (LeftBorder_SpriteX)
    jp      nz, .incrementX
    ld      a, 16
    jp      .saveSpriteX
.incrementX:
    inc     a
.saveSpriteX:
    ld      (LeftBorder_SpriteX), a
    add     256-32
    ld      (RightBorder_SpriteX), a

    ret



UpdateScroll:

    ; update horizontal scroll
    ld      a, (CurrentOffset)
    ld      b, a    ; data
    ld      c, 18   ; register #
    call    BIOS_WRTVDP

    ; update left border sprites X position
    ld      hl, SPRATR + 1 ; sprite X position
    ld      b, 12 ; 12 sprites
.updateLeftSprites:
    push    bc
        push    hl
            xor     a ;ld      a, 0000 0000 b
            call    SetVdp_Write
            ld      c, PORT_0
            ld      a, (LeftBorder_SpriteX)
            out     (c), a
        pop     hl
        ld      bc, 4
        add     hl, bc
    pop     bc
    djnz    .updateLeftSprites
    
    ; update right border sprites X position
    ld      hl, SPRATR + (12 * 4) + 1 ; sprite X position
    ld      b, 12 ; 12 sprites
.updateRightSprites:
    push    bc
        push    hl
            xor     a ;ld      a, 0000 0000 b
            call    SetVdp_Write
            ld      c, PORT_0
            ld      a, (RightBorder_SpriteX)
            out     (c), a
        pop     hl
        ld      bc, 4
        add     hl, bc
    pop     bc
    djnz    .updateRightSprites

    ret



End:


    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
ImageData:
    ;INCBIN "Images/aerofighters-xaa"
    INCBIN "Images/metalslug-xaa"
    ; INCBIN "Images/msxmas title scr.SC5"
    ;INCBIN "Images/plane_rotating_0_size_103x71_position_5_3.sc5_small"
.size:      equ $ - ImageData

	ds PageSize - ($ - 0x8000), 255



; ------- Page 2
	org	0x8000, 0xBFFF
ImageData_2:
    ;INCBIN "Images/aerofighters-xab"
    INCBIN "Images/metalslug-xab"
.size:      equ $ - ImageData_2
.palette:   equ $ - 32

SPRATR_Data:
    ;          y, x, pattern, unused
    db       (0*16)-1, 0, 0, 0
    db       (1*16)-1, 0, 0, 0
    db       (2*16)-1, 0, 0, 0
    db       (3*16)-1, 0, 0, 0
    db       (4*16)-1, 0, 0, 0
    db       (5*16)-1, 0, 0, 0
    db       (6*16)-1, 0, 0, 0
    db       (7*16)-1, 0, 0, 0
    db       (8*16)-1, 0, 0, 0
    db       (9*16)-1, 0, 0, 0
    db      (10*16)-1, 0, 0, 0
    db      (11*16)-1, 0, 0, 0

    db       (0*16)-1, 255-16, 0, 0
    db       (1*16)-1, 255-16, 0, 0
    db       (2*16)-1, 255-16, 0, 0
    db       (3*16)-1, 255-16, 0, 0
    db       (4*16)-1, 255-16, 0, 0
    db       (5*16)-1, 255-16, 0, 0
    db       (6*16)-1, 255-16, 0, 0
    db       (7*16)-1, 255-16, 0, 0
    db       (8*16)-1, 255-16, 0, 0
    db       (9*16)-1, 255-16, 0, 0
    db      (10*16)-1, 255-16, 0, 0
    db      (11*16)-1, 255-16, 0, 0

    db      216, 0, 0, 0 ; hide all sprites from this onwards

.size:  equ $ - SPRATR_Data

	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

CurrentOffset:    rb 1
LeftBorder_SpriteX:          rb 1
RightBorder_SpriteX:         rb 1
