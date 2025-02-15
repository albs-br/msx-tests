FNAME "triple-buffer.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB
Seg_P8000_SW:	equ	0x7000	        ; Segment switch for page 0x8000-BFFFh (ASCII 16k Mapper)

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:
    call    EnableRomPage2

	; enable page 1
    ld	    a, 1
	ld	    (Seg_P8000_SW), a

    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    call    BIOS_DISSCR

    call    ClearVram_MSX2

    call    Set212Lines

    call    SetColor0ToNonTransparent

    call    DisableSprites


    
    ; load 32-byte palette data
    ld      hl, Palette
    call    LoadPalette

   
    ; --- Write to VRAM bitmap area

    ; SC 5 - page 0
    ld      a, 0000 0000 b
    ld      hl, 0x0000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 1
    ld      a, 0000 0000 b
    ld      hl, 0x8000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 2
    ld      a, 0000 0001 b
    ld      hl, 0x0000
    call    LoadImageTo_SC5_Page

    ; SC 5 - page 3
    ld      a, 0000 0001 b
    ld      hl, 0x8000
    call    LoadImageTo_SC5_Page



    call    BIOS_ENASCR


    ; ------------- Copy player 1 sprite to page 0

    ; init vars
    ld      hl, 0x0000
    ld      (Last_NAMTBL_Addr), hl

    ld      hl, List
    
.loop:


    ld      a, (hl)     ; C = increment
    or      a
    jp      z, .endFrame ; if (increment == 0) endFrame
    ld      c, a

    inc     hl
    ld      a, (hl)     ; A = length

    inc     hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)     ; DE = slice data address

    inc     hl
    push    hl
        ; --- set VRAM addr

        ; HL = (Last_NAMTBL_Addr) + increment
        ld      hl, (Last_NAMTBL_Addr)
        ld      b, 0
        add     hl, bc
        ld      (Last_NAMTBL_Addr), hl

        ld      b, a

        ; set R#14 to 0
        ; set remaining bits of VRAM addr to HL
        xor     a ; page 0
        ; ld a, 0000 0010 b ; page 1
        ; ld a, 0000 0100 b ; page 2
        ; ld a, 0000 0110 b ; page 3
        di
            ; write bits a14-16 of address to R#14
            out     (PORT_1), a ; data
            ld      a, 14 + 128
            out     (PORT_1), a ; register #

            ; write the other address bits to VDP PORT_1
            ld      a, l
            nop
            out     (PORT_1), a ; addr low
            ld      a, h
            or      64
        ei
        out     (PORT_1),a ; addr high


        ; HL = Data + slice addr
        ld      hl, Data
        add     hl, de

        ld      c, PORT_0
        otir
    pop     hl
    jp      .loop

    ; ---

.endFrame:


    ; ld      hl, Restore_BG_HMMM_Parameters
    ; call    Execute_VDP_HMMM	    ; High speed move VRAM to VRAM


    jp      $ ;.loop ; endless loop

; ----------

; Input:
;   AHL: 17-bit VRAM address
LoadImageTo_SC5_Page:
	; enable page 1
    push    af
        ld	    a, 1
        ld	    (Seg_P8000_SW), a
    pop     af

    ; first 16kb (top 128 lines)
    push    af, hl
        call    SetVdp_Write
        ld      hl, Bg_Top
        ld      c, PORT_0
        ld      d, 0 + (Bg_Top.size / 256)
        ld      b, 0 ; 256 bytes
    .loop_10:    
        otir
        dec     d
        jp      nz, .loop_10
    pop     hl, af

	; enable page 2
    push    af
        ld	    a, 2
        ld	    (Seg_P8000_SW), a
    pop     af

    ; lines below 128
    ld      bc, 16 * 1024
    add     hl, bc

    call    SetVdp_Write
    ld      hl, Bg_Bottom
    ld      c, PORT_0
    ld      d, 0 + (Bg_Bottom.size / 256)
    ld      b, 0 ; 256 bytes
.loop_20:    
    otir
    dec     d
    jp      nz, .loop_20


    ret



Palette:
    INCBIN "Images/mk.pal"

; --- Slice index list
; increment in bytes, length in bytes, address of the slice on the Data
List:
    INCLUDE "Images/scorpion_frame_1_list.s"

    
    

; --- Slice data
Data:
    INCLUDE "Images/scorpion_frame_1_data.s"

Restore_BG_HMMM_Parameters:
.Source_X:   dw    0 	            ; Source X (9 bits)
.Source_Y:   dw    0 + (256*3) 	    ; Source Y (10 bits)
.Destiny_X:  dw    0 	    ; Destiny X (9 bits)
.Destiny_Y:  dw    0 	    ; Destiny Y (10 bits)
.Cols:       dw    32       ; number of cols (9 bits)
.Lines:      dw    64       ; number of lines (10 bits)
.NotUsed:    db    0
.Options:    db    0        ; select destination memory and direction from base coordinate
.Command:    db    VDP_COMMAND_HMMM
Restore_BG_HMMM_Parameters_size: equ $ - Restore_BG_HMMM_Parameters



    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF








; MegaROM pages at 0x8000
; ------- Page 1
	org	0x8000, 0xBFFF
Bg_Top:
    INCBIN "Images/mk-bg-top.sc5"
.size:      equ $ - Bg_Top
	ds PageSize - ($ - 0x8000), 255

; ------- Page 2
	org	0x8000, 0xBFFF
Bg_Bottom:
    INCBIN "Images/mk-bg-bottom.sc5"
.size:      equ $ - Bg_Bottom
	ds PageSize - ($ - 0x8000), 255



; RAM
	org     0xc000, 0xe5ff                   ; for machines with 16kb of RAM (use it if you need 16kb RAM, will crash on 8kb machines, such as the Casio PV-7)

Last_NAMTBL_Addr:   rw 1


; ----------------------------
; Player_1:
; .Restore_BG_X:              rb 1
; .Restore_BG_Y:              rb 1
; .Restore_BG_WidthInPixels:  rb 1
; .Restore_BG_HeightInPixels:  rb 1

; ;frame data
; ;.frame_data_slices:     rb (Frame_Data_Slice.size) * 256



; ; ----------------------------

; ; for each slice:
; Frame_Data_Slice:
; .offset:    rb 1 ; offset in bytes from top left of frame/last slice start
; .length:    rb 1 ; length in bytes (can be changed to pointer to unrolled OUTI's)
; .address:   rw 1 ; address of bytes to be plotted to screen

; .size: $ - Frame_Data_Slice