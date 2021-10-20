FNAME "set-palette.rom"      ; output file

; Compilation address
    org 0x4000, 0xbeff	                    ; 0x8000 can be also used here if Rom size is 16kB or less.

    INCLUDE "Include/RomHeader.s"


; bios call to print a character on screen
CHPUT:      equ 0x00a2
NVBXLN: EQU 0xC9
EXTROM: EQU 0x15F
CHGMOD: EQU 0x5F
CHGET: EQU 0x9F
GXPOS: EQU 0xFCB3
GYPOS: EQU 0xFCB5
ATRBYT: EQU 0xF3F3
LOGOPR: EQU 0xFB02
NWRVRM: equ 0x0177
WRTVDP: equ 0x0047


Execute:
			; change to screen 5
            ld a, 5
           	call CHGMOD

			
            ;xor a
            ;LD (LOGOPR),A
            ;LD A,15
            ;LD (ATRBYT),A
            ;LD HL,100
            ;LD (GXPOS),HL
            ;LD HL,100
            ;LD (GYPOS),HL
            ;LD BC,10
            ;LD DE,10
            ;LD IX,NVBXLN
			;CALL EXTROM
            
            ; direct access to register
            ;DI
            ;ld c, 0x99 ; V9938 port #1
            ;ld a, 0x00 ; value
            ;OUT (C), A
            ;ld a, 0x00 ; register #
            ;OUT (C), A
            ;EI
            
            ; set 192 lines
            LD b, 0 ;&B00000000 ; data
            ld c, 0x09 ; register #
            call WRTVDP
            


            ; ---------- set palette
			; set palette register number in register R#16 (Color palette address pointer)
			ld b, 0    ; data
            ld c, 16   ; register #
            call WRTVDP
            
            ; set color #0 (if transparency is enabled will not bee visible)
            ld c, 0x9a ; v9938 port #2
            ld a, 0x00 ; data 1 (red 0-7; blue 0-7)
            di
            out (c), a
            ld a, 0x00 ; data 2 (0000; green 0-7)
            ei
            out (c), a

            ; set color #1
            ld a, 0x77 ; data 1 (red 0-7; blue 0-7)
            di
            out (c), a
            ld a, 0x00 ; data 2 (0000; green 0-7)
            ei
            out (c), a
            


            ld hl, PaletteData
            call LoadPalette
            


            ; write to VRAM bitmap area
            ld hl, 128*191 ; start of line number 191
            ld a, 0x87     ; color 8 on first pixel, color 7 on second pixel
			call NWRVRM             
            INC HL
			call NWRVRM             
            
            ;ld hl, 0
            ;ld a, 0x22
            ;call Draw8x8block
            ;ld hl, 4
            ;ld a, 0x88
            ;call Draw8x8block
            
            call DrawPalette
            
            ; wait for key
            call CHGET
            
            xor a
            call CHGMOD
            ret

; Load palette data pointed by HL
LoadPalette:
			; set palette register number in register R#16 (Color palette address pointer)
			ld b, 0    ; data
            ld c, 16   ; register #
            call WRTVDP
            ld c, 0x9a ; V9938 port #2

			ld b, 16
LoadPalette.loop:
            ld a, (hl)
			di
            out (c), a
            inc hl
            ld a, (hl)
            ei
            out (c), a
            inc hl
            djnz LoadPalette.loop
            
			ret


DrawPalette:
			ld hl, 0
            ld b, 16
            xor a
DrawPalette.loop:
			push hl
            	push bc
                	push af
            			call Draw8x8block
                    pop af
                pop bc
            pop hl
            ld de, 4 ;0 + (128 * 8)
            add hl, de
            ld d, 0x11 ; increment both colors
            add a, d
			djnz DrawPalette.loop
			ret


; HL: start addr; A: value
Draw8x8block:
			ld c, 8
.loop1:
			ld b, 4
.loop:
			call NWRVRM
            inc hl
            djnz .loop
            
            dec c
            ret z
            ld de, 128 - 4
            add hl, de
            jp .loop1
            
			ret

PaletteData:
			;  data 1 (red 0-7; blue 0-7); data 2 (0000; green 0-7)
			db 0x00, 0x00 ; Color index 0
			db 0x77, 0x00 ; Color index 1
			db 0x10, 0x00 ; Color index 2
			db 0x20, 0x00 ; Color index 3
			db 0x30, 0x00 ; Color index 4
			db 0x40, 0x00 ; Color index 5
			db 0x50, 0x00 ; Color index 6
			db 0x60, 0x00 ; Color index 7
			db 0x70, 0x00 ; Color index 8
			db 0x11, 0x01 ; Color index 9
			db 0x22, 0x02 ; Color index 10
			db 0x33, 0x03 ; Color index 11
			db 0x77, 0x07 ; Color index 12
			db 0x66, 0x06 ; Color index 13
			db 0x55, 0x05 ; Color index 14
			db 0x44, 0x04 ; Color index 15
