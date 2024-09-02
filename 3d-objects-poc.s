FNAME "3d-objects-poc.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; Default VRAM tables for Screen 4
NAMTBL:     equ 0x1800  ; to 0x1aff (768 bytes)
PATTBL:     equ 0x0000  ; to 0x17ff (6144 bytes)
COLTBL:     equ 0x2000  ; to 0x37ff (6144 bytes)
SPRPAT:     equ 0x3800  ; to 0x3fff (2048 bytes)
SPRCOL:     equ 0x1c00  ; to 0x1dff (512 bytes)
SPRATR:     equ 0x1e00  ; to 0x1e7f (128 bytes)

Execute:
    ; init interrupt mode and stack pointer (in case the ROM isn't the first thing to be loaded)
	di                          ; disable interrupts
	im      1                   ; interrupt mode 1
    ld      sp, (BIOS_HIMEM)    ; init SP

    call    BIOS_DISSCR

    ld      hl, RamStart        ; RAM start address
    ld      de, RamEnd + 1      ; RAM end address
    call    ClearRam_WithParameters


    call    EnableRomPage2

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a

    ; change to screen 4
    ld      a, 4
    call    BIOS_CHGMOD

    call    ClearVram_MSX2

    call    Set192Lines

    call    SetColor0ToNonTransparent

    ; load NAMTBL (third part)
    ld		hl, NAMTBL_Data             ; RAM address (source)
    ld		de, NAMTBL + (32*16)	    ; VRAM address (destiny)
    ld		bc, NAMTBL_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load PATTBL (third part)
    ld		hl, PATTBL_Data             ; RAM address (source)
    ld		de, PATTBL + (32*16*8)		; VRAM address (destiny)
    ld		bc, PATTBL_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load COLTBL (third part)
    ld		hl, COLTBL_Data             ; RAM address (source)
    ld		de, COLTBL + (32*16*8)		; VRAM address (destiny)
    ld		bc, COLTBL_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load SPRPAT
    ld		hl, SPRPAT_Data             ; RAM address (source)
    ld		de, SPRPAT   		        ; VRAM address (destiny)
    ld		bc, SPRPAT_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load SPRCOL
    ld		hl, SPRCOL_Data             ; RAM address (source)
    ld		de, SPRCOL   		        ; VRAM address (destiny)
    ld		bc, SPRCOL_Data.size	    ; Block length
    call 	BIOS_LDIRVM        		    ; Block transfer to VRAM from memory

    ; load SPRATR_Buffer
    ld		hl, SPRATR_Data             ; RAM address (source)
    ld		de, SPRATR_Buffer   		; VRAM address (destiny)
    ld		bc, SPRATR_Data.size	    ; Block length
    ldir        		                ; Block transfer to VRAM from memory


    call    BIOS_ENASCR

; ------------------------------------

    ; Init vars
    ld      hl, 32768 ; center of map
    ld      (Player.X), hl
    ld      (Player.Y), hl
    ld      hl, 0
    ld      (Player.angle), hl

    call    Update_walkDXandDY

; ------------------------------------

.loop:

    call    Wait_Vblank

    ; --- Update SPRATR from buffer
    ld      a, 0000 0000 b
    ld      hl, SPRATR
    call    SetVdp_Write
    ld      hl, SPRATR_Buffer
    ld      c, PORT_0
    outi outi outi outi ; update 1 sprite

    ; --- Read input
    ld      a, 8                    ; 8th line
    call    BIOS_SNSMAT             ; Read Data Of Specified Line From Keyboard Matrix
    
    push    af
        bit     4, a                    ; 4th bit (left)
        call   	z, .rotateLeft
    pop     af

    push    af
        bit     7, a                    ; 7th bit (right)
        call   	z, .rotateRight
    pop     af

    push    af
        bit     5, a                    ; 5th bit (up)
        call   	z, .walkForward
    pop     af

    ; push    af
    ;     bit     6, a                    ; 6th bit (down)
    ;     call   	z, .walkBackwards
    ; pop     af

    ; --- Update SPRATR buffer
    ld      hl, SPRATR_Buffer

    ld      a, (Player.Y + 1) ; high byte
    ; convert from 16 bits to 6 bits (0-63)
    srl     a               ; shift right register
    srl     a
    add     128
    ld      (hl), a

    inc     hl
    ld      a, (Player.X + 1) ; high byte
    ; convert from 16 bits to 6 bits (0-63)
    srl     a               ; shift right register
    srl     a
    ld      (hl), a




    jp      .loop

.rotateLeft:
    ; if (Player.angle == 0) Player.angle = 359; else Player.angle--;
    ld      hl, (Player.angle)
    ld      de, 0
    call    BIOS_DCOMPR         ; Compare Contents Of HL & DE, Set Z-Flag IF (HL == DE), Set CY-Flag IF (HL < DE)
    jr      z, .rotateLeft_set359

    dec     hl
    jp      .rotate_return

.rotateLeft_set359:
    ld      hl, 359
    jp      .rotate_return



.rotateRight:
    ; if (Player.angle == 360) Player.angle = 0; else Player.angle++;
    ld      hl, (Player.angle)
    ld      de, 360
    call    BIOS_DCOMPR         ; Compare Contents Of HL & DE, Set Z-Flag IF (HL == DE), Set CY-Flag IF (HL < DE)
    jr      z, .rotateRight_set0

    inc     hl
    jp      .rotate_return

.rotateRight_set0:
    ld      hl, 0

.rotate_return:
    ld      (Player.angle), hl

    call    Update_walkDXandDY

    ret

.walkForward:

    ; ---- Y += DY
    ld      hl, (Player.Y)
    ld      de, (Player.walk_DY)

    add     hl, de
    ld      (Player.Y), hl

    ; TODO: check map limit

    ret

; .left:
;     ; if (Player.X == 0) ret; else Player.X--;
;     ld      hl, (Player.X)
;     ld      de, 0
;     call    BIOS_DCOMPR
;     ret     z

;     ld      bc, -256
;     add     hl, bc
;     ; dec     hl
;     ld      (Player.X), hl

;     ret

Update_walkDXandDY:
    ; --- Update .walk_DY based on angle
    ld      hl, (Player.angle)
    
    add     hl, hl          ; HL = HL * 2

    ld      d, h            ; DE = HL
    ld      e, l

    ld      hl, LUT_cos     ; HL = LUT_cos + DE
    add     hl, de

    ld      e, (hl)         ; DE = (HL)
    inc     hl
    ld      d, (hl)

    ; for angles 0-89 invert signal (invert all bits, then add 1, ignoring overflow)
    ld      a, e
    xor     1111 1111 b
    ld      e, a
    
    ld      a, d
    xor     1111 1111 b
    ld      d, a

    inc     de

    ld      (Player.walk_DY), de
    
    ret


End:

; Palette:
;     ; INCBIN "Images/title-screen.pal"
;     INCBIN "Images/plane_rotating.pal"

NAMTBL_Data:
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.size:  equ $ - NAMTBL_Data

PATTBL_Data:
    db      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    db      0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.size:  equ $ - PATTBL_Data

COLTBL_Data:
    db      0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11
    db      0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.size:  equ $ - COLTBL_Data

SPRPAT_Data:
    db      11000000 b
    db      11000000 b
    db      00000000 b
    db      00000000 b
    db      00000000 b
    db      00000000 b
    db      00000000 b
    db      00000000 b
.size:  equ $ - SPRPAT_Data

SPRCOL_Data:
    db      0x08, 0x08, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db      0x04, 0x04, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.size:  equ $ - SPRCOL_Data

SPRATR_Data:
    ;       y, x, pattern, unused
    db      0, 0, 0, 0
    db      0, 0, 0, 0
.size:  equ $ - SPRATR_Data

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; ; MegaROM pages at 0x8000
; ; ------- Page 1
; 	org	0x8000, 0xBFFF
; ImageData:
;     ;INCBIN "Images/aerofighters-xaa"
; .size:      equ $ - ImageData
; 	ds PageSize - ($ - 0x8000), 255


; ----------------------------------------
LUT_cos:
dw 100000000 b ; cos of 0 degrees = 1
dw 100000000 b ; cos of 1 degrees = 0,9998476951563913
dw 100000000 b ; cos of 2 degrees = 0,9993908270190958
dw 100000000 b ; cos of 3 degrees = 0,9986295347545738
dw 11111111 b ; cos of 4 degrees = 0,9975640502598242
dw 11111111 b ; cos of 5 degrees = 0,9961946980917455
dw 11111111 b ; cos of 6 degrees = 0,9945218953682733
dw 11111110 b ; cos of 7 degrees = 0,992546151641322
dw 11111110 b ; cos of 8 degrees = 0,9902680687415704
dw 11111101 b ; cos of 9 degrees = 0,9876883405951378
dw 11111100 b ; cos of 10 degrees = 0,984807753012208
dw 11111011 b ; cos of 11 degrees = 0,981627183447664
dw 11111010 b ; cos of 12 degrees = 0,9781476007338057
dw 11111001 b ; cos of 13 degrees = 0,9743700647852352
dw 11111000 b ; cos of 14 degrees = 0,9702957262759965
dw 11110111 b ; cos of 15 degrees = 0,9659258262890683
dw 11110110 b ; cos of 16 degrees = 0,9612616959383189
dw 11110101 b ; cos of 17 degrees = 0,9563047559630354
dw 11110011 b ; cos of 18 degrees = 0,9510565162951535
dw 11110010 b ; cos of 19 degrees = 0,9455185755993168
dw 11110001 b ; cos of 20 degrees = 0,9396926207859084
dw 11101111 b ; cos of 21 degrees = 0,9335804264972017
dw 11101101 b ; cos of 22 degrees = 0,9271838545667874
dw 11101100 b ; cos of 23 degrees = 0,9205048534524404
dw 11101010 b ; cos of 24 degrees = 0,9135454576426009
dw 11101000 b ; cos of 25 degrees = 0,9063077870366499
dw 11100110 b ; cos of 26 degrees = 0,898794046299167
dw 11100100 b ; cos of 27 degrees = 0,8910065241883679
dw 11100010 b ; cos of 28 degrees = 0,882947592858927
dw 11100000 b ; cos of 29 degrees = 0,8746197071393957
dw 11011110 b ; cos of 30 degrees = 0,8660254037844387
dw 11011011 b ; cos of 31 degrees = 0,8571673007021123
dw 11011001 b ; cos of 32 degrees = 0,848048096156426
dw 11010111 b ; cos of 33 degrees = 0,838670567945424
dw 11010100 b ; cos of 34 degrees = 0,8290375725550417
dw 11010010 b ; cos of 35 degrees = 0,8191520442889918
dw 11001111 b ; cos of 36 degrees = 0,8090169943749475
dw 11001100 b ; cos of 37 degrees = 0,7986355100472928
dw 11001010 b ; cos of 38 degrees = 0,788010753606722
dw 11000111 b ; cos of 39 degrees = 0,7771459614569709
dw 11000100 b ; cos of 40 degrees = 0,766044443118978
dw 11000001 b ; cos of 41 degrees = 0,754709580222772
dw 10111110 b ; cos of 42 degrees = 0,7431448254773942
dw 10111011 b ; cos of 43 degrees = 0,7313537016191706
dw 10111000 b ; cos of 44 degrees = 0,7193398003386512
dw 10110101 b ; cos of 45 degrees = 0,7071067811865476
dw 10110010 b ; cos of 46 degrees = 0,6946583704589974
dw 10101111 b ; cos of 47 degrees = 0,6819983600624985
dw 10101011 b ; cos of 48 degrees = 0,6691306063588582
dw 10101000 b ; cos of 49 degrees = 0,6560590289905073
dw 10100101 b ; cos of 50 degrees = 0,6427876096865394
dw 10100001 b ; cos of 51 degrees = 0,6293203910498375
dw 10011110 b ; cos of 52 degrees = 0,6156614753256583
dw 10011010 b ; cos of 53 degrees = 0,6018150231520484
dw 10010110 b ; cos of 54 degrees = 0,5877852522924731
dw 10010011 b ; cos of 55 degrees = 0,573576436351046
dw 10001111 b ; cos of 56 degrees = 0,5591929034707468
dw 10001011 b ; cos of 57 degrees = 0,5446390350150272
dw 10001000 b ; cos of 58 degrees = 0,5299192642332049
dw 10000100 b ; cos of 59 degrees = 0,5150380749100543
dw 10000000 b ; cos of 60 degrees = 0,5000000000000001
dw 1111100 b ; cos of 61 degrees = 0,4848096202463371
dw 1111000 b ; cos of 62 degrees = 0,46947156278589086
dw 1110100 b ; cos of 63 degrees = 0,4539904997395468
dw 1110000 b ; cos of 64 degrees = 0,43837114678907746
dw 1101100 b ; cos of 65 degrees = 0,42261826174069944
dw 1101000 b ; cos of 66 degrees = 0,4067366430758002
dw 1100100 b ; cos of 67 degrees = 0,39073112848927394
dw 1100000 b ; cos of 68 degrees = 0,37460659341591196
dw 1011100 b ; cos of 69 degrees = 0,3583679495453004
dw 1011000 b ; cos of 70 degrees = 0,3420201433256688
dw 1010011 b ; cos of 71 degrees = 0,32556815445715676
dw 1001111 b ; cos of 72 degrees = 0,30901699437494745
dw 1001011 b ; cos of 73 degrees = 0,29237170472273677
dw 1000111 b ; cos of 74 degrees = 0,27563735581699916
dw 1000010 b ; cos of 75 degrees = 0,25881904510252074
dw 111110 b ; cos of 76 degrees = 0,2419218955996679
dw 111010 b ; cos of 77 degrees = 0,22495105434386492
dw 110101 b ; cos of 78 degrees = 0,20791169081775945
dw 110001 b ; cos of 79 degrees = 0,19080899537654492
dw 101100 b ; cos of 80 degrees = 0,17364817766693041
dw 101000 b ; cos of 81 degrees = 0,15643446504023092
dw 100100 b ; cos of 82 degrees = 0,1391731009600657
dw 11111 b ; cos of 83 degrees = 0,12186934340514749
dw 11011 b ; cos of 84 degrees = 0,10452846326765346
dw 10110 b ; cos of 85 degrees = 0,08715574274765814
dw 10010 b ; cos of 86 degrees = 0,06975647374412546
dw 1101 b ; cos of 87 degrees = 0,052335956242943966
dw 1001 b ; cos of 88 degrees = 0,03489949670250108
dw 100 b ; cos of 89 degrees = 0,017452406437283376
dw 0 b ; cos of 90 degrees = 6,123233995736766E-17

; RAM
	org     0xc000, 0xe5ff

RamStart:

SavedJiffy:     rb 1

SPRATR_Buffer:  rb 128

Player:
.X:             rw 1 ; 0-65535
.Y:             rw 1 ; 0-65535
.angle:         rw 1 ; 0-359 degrees, 0 is left (east), increments counter-clockwise
.walk_DX:       rw 1 ; 8.8 fixed point
.walk_DY:       rw 1 ; 8.8 fixed point

Object_0:
.X:             rw 1 ; 0-65535
.Y:             rw 1 ; 0-65535

RamEnd: