FNAME "raycasting-poc.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0x7fff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    ; Common
    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"


; Default VRAM tables for Screen 4
NAMTBL:     equ 0x1800  ; to 0x???? (768 bytes)
PATTBL:     equ 0x0000  ; to 0x???? (? bytes)
COLTBL:     equ 0x2000  ; to 0x???? (? bytes)
SPRPAT:     equ 0x3800  ; to 0x???? (2048 bytes)
SPRCOL:     equ 0x1c00  ; to 0x???? (512 bytes)
SPRATR:     equ 0x1e00  ; to 0x???? (128 bytes)

;SPRCOL_2:   equ 0xfc00  ; to 0xfdff (512 bytes)
;SPRATR_2:   equ 0xfe00  ; to 0xfe80 (128 bytes)



Execute:


    ; change to screen 4
    ld      a, 4
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    SetSprites16x16

    call    Set192Lines

    call    SetColor0ToNonTransparent

    
    ; Load tile patterns
    ld      a, 0000 0000 b
    ld      hl, PATTBL
    call    SetVdp_Write
    ld      b, TilePatterns.size
    ld      c, PORT_0
    ld      hl, TilePatterns
    otir

    ld      a, 0000 0000 b
    ld      hl, PATTBL + (256 * 8)
    call    SetVdp_Write
    ld      b, TilePatterns.size
    ld      c, PORT_0
    ld      hl, TilePatterns
    otir

    ; Load sprite colors
    ld      a, 0000 0000 b
    ld      hl, COLTBL
    call    SetVdp_Write
    ld      b, TileColors.size
    ld      c, PORT_0
    ld      hl, TileColors
    otir

    ld      a, 0000 0000 b
    ld      hl, COLTBL + (256 * 8)
    call    SetVdp_Write
    ld      b, TileColors.size
    ld      c, PORT_0
    ld      hl, TileColors
    otir


    call    BIOS_ENASCR

    call    BIOS_BEEP



GameLoop:
    call    Wait_Vblank

    ; ---------- Update NAMTBL
    ld      a, 0000 0000 b
    ld      hl, NAMTBL
    call    SetVdp_Write
    ;ld      b, 32 * 16 ; only top 16 lines
    ld      c, PORT_0
    ld      hl, NAMTBL_Buffer
    ; 32 x 16 outi
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 
    outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi outi 



    ; ld	    hl, Columns
    ; ld	    de, NAMTBL_Buffer
    ; ld	    bc, 16
    ; ldir

    ld      bc, Columns
    ld      hl, NAMTBL_Buffer
    call    DrawColumn

    ld      bc, Columns + (1 * 16)
    ld      hl, NAMTBL_Buffer + 1
    call    DrawColumn

    ld      bc, Columns + (2 * 16)
    ld      hl, NAMTBL_Buffer + 2
    call    DrawColumn

    jp      GameLoop



; read a seq of 16 bytes for column tile numbers and copy it to a column on NAMTBL buffer
;   bc: ROM start addr of column (origin)
;   hl: ROM start addr of NAMTBL buffer (destiny)
DrawColumn:

    ld  de, 32              ; screen width in tiles

    ld  ixl, 16
.loop: ; use macro to repeat 16 times (height of column)
        ld	    a, (bc)		; 8
        ld	    (hl), a		; 8
        ;inc	bc		; 7
        inc	    c		    ; 5	; data should be table aligned
        add	    hl, de		; 12

    dec     ixl
    jp      nz, .loop

    ret

; ------------- Data:

Columns:
    db  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1
    db  0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
    db  0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0

TilePatterns:
    db  0000 0000 b
    db  0000 0000 b
    db  0000 0000 b
    db  0000 0000 b
    db  0000 0000 b
    db  0000 0000 b
    db  0000 0000 b
    db  0000 0000 b

    db  1111 1111 b
    db  1111 1111 b
    db  1111 1111 b
    db  1111 1111 b
    db  1111 1111 b
    db  1111 1111 b
    db  1111 1111 b
    db  1111 1111 b
.size:  equ $ - TilePatterns

TileColors:
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0

    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
    db  0xf0
.size:  equ $ - TileColors

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF




; ----------------- Variables
    org 0xc000

; CAUTION: this buffer needs to be table aligned
NAMTBL_Buffer:  rb 32 * 16 ; only upper 2/3 of the screen

Seed:                       rw 1            ; Seed for random number generator


;OldSP:          rw 1
