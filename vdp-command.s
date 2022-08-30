FNAME "vdp-command.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:

    ; change to screen 5
    ld      a, 5
    call    BIOS_CHGMOD

    ;call    ClearVram_MSX2


; ----------------- Write on first 16 lines of the second page (not visible)

    xor     a           	; set vram write base address
    ld      hl, 0x8000     	;  to 1st byte of page 1...
    call    SetVDP_Write

    ld      a, 0x88        	; set color for 2 pixels

	ld      c, 32          	; fill 1st N lines of page 1
.fillL1:
    ld      b, 128        	; one line in SC5 = 128 bytes
.fillL2:
    out     (PORT_0), a     ; could also have been done with
    djnz    .fillL2     	; a vdp command (probably faster)
    dec     c           	; (and could also use a fast loop)
    jp      nz, .fillL1




; ----------- Load test bg image on second page (not visible)

    ld      ix, 0x8000 + (128 * 64)         ; vram base address
    ld      iy, Image_Test_16x8             ; ram base address

    ld      d, 8        ; number of lines
.loop_1:    
    xor     a
    
    ; HL = IX
    push    ix
    pop     hl

    push    hl
        call    SetVDP_Write
    pop     hl

    ld      bc, 128     ; next line
    add     hl, bc

    ; IX = HL
    push    hl
    pop     ix

    ld      c, PORT_0

    ; HL = IY
    push    iy
    pop     hl

    ; 8x OUTI
    outi outi outi outi outi outi outi outi 

    ; IY = HL
    push    hl
    pop     iy

    dec     d
    jp      nz, .loop_1


; ----------------- Execute test VDP commands on the first page (visible)

    ; test HMMM
    ld      hl, HMMM_Parameters
    call    Execute_VDP_HMMM	    ; High speed move VRAM to VRAM


    ; test HMMV
    ld      hl, HMMV_Parameters
    call    Execute_VDP_HMMV        ; High speed move VDP to VRAM (fills an area with one single color)


    ; test YMMM
    ld      hl, YMMM_Parameters
    call    Execute_VDP_YMMM        ; High speed move VRAM to VRAM, Y coordinate only


    ; test LMMM (will put an image on screen like a sprite)
    ld      hl, LMMM_Parameters
    call    Execute_VDP_LMMM        ; Logical move CPU to VRAM (copies data from your ram to the vram)


    ; test PSET
    ld      hl, PSET_Parameters
    call    Execute_VDP_PSET




    ; wait until the start of a frame
    call    Wait_Vblank

    ; save current JIFFY
    ld      a, (BIOS_JIFFY)
    ld      ixl, a

    ; MAX: 15 lines in one frame
    ld      b, 15      ; number of repetitions
.loop:
    ; test LINE
    ld      hl, LINE_Parameters
    push    bc
        call    Execute_VDP_LINE
    pop     bc
    djnz    .loop

    ; check if it took more than one frame
    ld      a, (BIOS_JIFFY)
    cp      ixl
    jp      z, .doBeeps

    jp      $

; beeps means it took less than one frame
.doBeeps:
    call    BIOS_BEEP
    jp      .doBeeps


.endProgram:
	jr      .endProgram

    ret



Image_Test_16x8:
    db  0x00, 0x00, 0x00, 0x88, 0x88, 0x00, 0x00, 0x00
    db  0x00, 0x00, 0x88, 0x88, 0x88, 0x88, 0x00, 0x00
    db  0x00, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00
    db  0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88
    db  0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88
    db  0x00, 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x00
    db  0x00, 0x00, 0x88, 0x88, 0x88, 0x88, 0x00, 0x00
    db  0x00, 0x00, 0x00, 0x88, 0x88, 0x00, 0x00, 0x00



HMMM_Parameters:
;    db 0,0,0,1       ; R#32, R#33, R#34, R#35
;    db 0,0,0,0       ; R#36, R#37, R#38, R#39
;    db 8,0,8,0       ; R#40, R#41, R#42, R#43
;    db 0,0, 0xD0     ; R#44, R#45, R#46 = HMMM

;    dw    0x0000, 0x0100 ; Source X (9 bits), Source Y (10 bits)
;    dw    0x0080, 0x0010 ; Destiny X (9 bits), Destiny Y (10 bits)
;    dw    0x0008, 0x0008	; number of cols/lines
;    db    0, 0, 0xD0

;    dw    0, 256 	; Source X (9 bits), Source Y (10 bits)
;    dw    128, 96 	; Destiny X (9 bits), Destiny Y (10 bits)
;    dw    20, 20		; number of cols (9 bits), number of lines (10 bits)
;    db    0, 0, VDP_COMMAND_HMMM
.Source_X:   dw    0 	    ; Source X (9 bits)
.Source_Y:   dw    256 	    ; Source Y (10 bits)
.Destiny_X:  dw    128 	    ; Destiny X (9 bits)
.Destiny_Y:  dw    96 	    ; Destiny Y (10 bits)
.Cols:       dw    20       ; number of cols (9 bits)
.Lines:      dw    20       ; number of lines (10 bits)
.NotUsed:    db    0
.Options:    db    0        ; select destination memory and direction from base coordinate
.Command:    db    VDP_COMMAND_HMMM
HMMM_Parameters_size: equ $ - HMMM_Parameters

LMMM_Parameters:
.Source_X:   dw    0 	    ; Source X (9 bits)
.Source_Y:   dw    256 + 64 ; Source Y (10 bits)
.Destiny_X:  dw    10       ; Destiny X (9 bits)
.Destiny_Y:  dw    10       ; Destiny Y (10 bits)
.Cols:       dw    16       ; number of cols (9 bits)
.Lines:      dw    8        ; number of lines (10 bits)
.NotUsed:    db    0
.Options:    db    0        ; select destination memory and direction from base coordinate
.Command:    db    VDP_COMMAND_LMMM OR VDP_LOGIC_OPERATION_TIMP
LMMM_Parameters_size: equ $ - LMMM_Parameters

LINE_Parameters:
.Start_X:    dw    0      ; Starting point X (9 bits)
.Start_Y:    dw    0      ; Starting point Y (10 bits)
.Cols:       dw  128      ; number of cols (9 bits)
.Lines:      dw  128      ; number of lines (10 bits)
.Color:      db   15      ; 4 bits (G4, G5), 2 bits (G6), 8 bits (G7)
.Options:    db    0      ; select destination memory and direction from base coordinate
.Command:    db    VDP_COMMAND_LINE
LINE_Parameters_size: equ $ - LINE_Parameters


PSET_Parameters:
.X:          dw   10      ; X (9 bits)
.Y:          dw   80      ; Y (10 bits)
.NotUsed:    dw    0, 0   ;
.Color:      db   15      ; 4 bits (G4, G5), 2 bits (G6), 8 bits (G7)
.Options:    db    0      ; select destination memory
.Command:    db    VDP_COMMAND_PSET
PSET_Parameters_size: equ $ - PSET_Parameters

; Not working:
HMMC_Parameters:    ; R#36 to R#46
   dw    128, 96 	; Destiny X (9 bits), Destiny Y (10 bits)
   dw    20, 20		; number of cols (9 bits), number of lines (10 bits)
   db    0, 0, VDP_COMMAND_HMMC

HMMV_Parameters:    ; R#36 to R#46
   dw    0, 0 	    ; Destiny X (9 bits), Destiny Y (10 bits)
   dw    20, 20		; number of cols (9 bits), number of lines (10 bits)
   db    0xac       ; color of the fill
   db    0, VDP_COMMAND_HMMV

YMMM_Parameters:
   dw    256                ; R#34 and R#35: Source Y (10 bits)
   dw    10, 2 	            ; R#36 and R#37: Destiny X (9 bits), R#38 and R#39: Destiny Y (10 bits)
   db    0, 0               ; R#40 and R#41: not used
   dw    2		            ; R#42 and R#43: number of lines (10 bits)
   db    0                  ; R#44: not used
   db    0000 0000b         ; R#45: destination memory and direction from base coordinate
   db    VDP_COMMAND_YMMM   ; R#46: command number

VDP_COMMAND_HMMC:       equ 1111 0000 b	; High speed move CPU to VRAM (copies data from your ram to the vram)
VDP_COMMAND_YMMM:       equ 1110 0000 b	; High speed move VRAM to VRAM, Y coordinate only
VDP_COMMAND_HMMM:       equ 1101 0000 b	; High speed move VRAM to VRAM
VDP_COMMAND_HMMV:       equ 1100 0000 b	; High speed move VDP to VRAM (fills an area with one single color)

; Logical commands (four lower bits specifies logic operation)
VDP_COMMAND_LMMC:       equ 1011 0000 b	; Logical move CPU to VRAM (copies data from your ram to the vram)
VDP_COMMAND_LMCM:       equ 1010 0000 b	; Logical move VRAM to CPU
VDP_COMMAND_LMMM:       equ 1001 0000 b	; Logical move VRAM to VRAM
VDP_COMMAND_LMMV:       equ 1000 0000 b	; Logical move VDP to VRAM (fills an area with one single color)

VDP_COMMAND_LINE:       equ 0111 0000 b
VDP_COMMAND_SRCH:       equ 0110 0000 b
VDP_COMMAND_PSET:       equ 0101 0000 b
VDP_COMMAND_POINT:      equ 0100 0000 b

VDP_COMMAND_STOP:       equ 0000 0000 b


; Logical operations:
VDP_LOGIC_OPERATION_IMP:    equ 0000 b
VDP_LOGIC_OPERATION_AND:    equ 0001 b
VDP_LOGIC_OPERATION_OR:     equ 0010 b
VDP_LOGIC_OPERATION_XOR:    equ 0011 b
VDP_LOGIC_OPERATION_NOT:    equ 0100 b

VDP_LOGIC_OPERATION_TIMP:   equ 1000 b
VDP_LOGIC_OPERATION_TAND:   equ 1001 b
VDP_LOGIC_OPERATION_TOR:    equ 1010 b
VDP_LOGIC_OPERATION_TXOR:   equ 1011 b
VDP_LOGIC_OPERATION_TNOT:   equ 1100 b

; https://msx.org/forum/msx-talk/development/doubts-about-9938-commands

; HMMC copies data from your ram to the vram. The destination is a xy square in the vram however 
; your source is a starting adress in ram. You then out your data byte by byte until you have everything 
; you need. The first byte you out will be at the start of the adress where your gfx data is.

; The other command HMMV simply fills an area with one single color. So you basicly tell the VDP to fill 
; up that area for you. Very handy when you for example quickly want to fill a part of the VRAM area with 
; background color or want to clear the VRAM.



End:

    db      "End ROM started at 0x4000"

	ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF
