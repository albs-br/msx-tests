FNAME "64kb_RAM.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x8000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

; ADDRESS_TO_BE_TESTED: equ 0x8000 ; start of page 2
; ADDRESS_TO_BE_TESTED: equ 0x0000 ; start of page 0
ADDRESS_TO_BE_TESTED: equ 0x4000 ; start of page 1

Execute:

    ; Code only working on MSX 1 Gradiente Expert/Sharp Hotbit
    ; on MSX 2 and above probably crashing due to sub-slots


    ; set screen 0
    call    BIOS_INITXT ; warning: if page 0 is disabled, cannot use BIOS routines

    ; save current page 1 value from PPI
    in      a, (PPI.A)
    ; and     00110000 b      ; keep only page 2 position
    ; and     00000011 b      ; keep only page 0 position
    and     00001100 b      ; keep only page 1 position
    ld      (PPI_A_saved), a



    ; code for MSX1
    ; call    Set_RAM_Page_2
    ; call    Set_RAM_Page_0
    ; call    Set_RAM_Page_1
  	


    ; code for MSX2 and over

    ; https://www.msx.org/forum/msx-talk/development/i-dont-understand-enaslt-sample-in-the-wiki
    ; Select the slot 2-1 for page 1 (4000h-07FFFh) using BIOS routine
    ; ENASLT	equ	0024h
    ; 	ld	h,040h
    ; 	ld	a,086h	;Slot ID
    ; 	call	ENASLT
    ; Slot ID is coded this way: F000EEPP
    ; if F is set, then EE (subslot) is used.
    ; 0x86 = 1000 0110, primary = 2, extended = 1

    ; set page 1 (0x4000-0x7fff) to slot ?-?
    ld	    hL, ADDRESS_TO_BE_TESTED
    ;          F000EEPP
   	; ld	    a, 10001111 b ; slot ID 3-3
   	ld	    a, 10001111 b ; slot ID 3-0
   	call	BIOS_ENASLT

    ; select segment (0-255) of memory mapper
    ; Physical page 0 → FCH port
    ; Physical page 1 → FDH port
    ; Physical page 2 → FEH port
    ; Physical page 3 → FFH port
     in      a, (0xff)
    ;ld      a, 0
    out     (0xfd), a


    ; TODO:
    
    ;https://www.msx.org/forum/development/msx-development/universal-ram-allocator

    ; Q: I don't know, can't you just use whatever slot is being used on page 3?
    ; A: No. It would be too easy! That was my first approach, but there are some strange 
    ; machines around. For example, the Toshiba HX-20 (RAM divided between slots 0 and 3-0)
    ;  or the SONY HB-900 (not confirmed be me), with RAM divided
    ; in different slots. Any clues?

    ; You need to parse each slot for a page (or each page) to look for RAM.
    ; You can use $000C (RDSLT) and $0014 (WRSLT) to hunt for memory without having 
    ; to set the slot yourself first. SCC-I RAM is detected in a different way. The
    ;  cartridge is set in ReadOnly mode and you need to set it to RAM mode yourself. SCC is 
    ;  usually ROM anyway and if you write to a switch address in a slot where a 
    ;  MegaROM is detected the ROM area will change in a whole, not change just one byte.

    ; Detecting RAM in general is like this:
    ; Read current value, write test value, read test value, restore old value... 
    ; if writing and reading the test value succeeds it's most likely RAM, and if the
    ; current value is read after writing the test value, it's most likely ROM.

    ; oh yeah, you need to use $FCC1 (EXPTBL) to determine if the slot is expanded 
    ; and you need to parse secundary slots as well.

    ; EXPTBL
    ; #FCC1	1	Slot 0: #80 = expanded, 0 = not expanded. Also main BIOS-ROM slot address.
    ; #FCC2	1	Slot 1: #80 = expanded, 0 = not expanded.
    ; #FCC3	1	Slot 2: #80 = expanded, 0 = not expanded.
    ; #FCC4	1	Slot 3: #80 = expanded, 0 = not expanded.


    ; more info:
    ;
    ; RSLREG
    ; Address  : #0138
    ; Function : Reads the primary slot register
    ; Output   : A  - For the value which was read
    ;            33221100
    ;            ││││││└┴─ Page 0 (#0000-#3FFF)
    ;            ││││└┴─── Page 1 (#4000-#7FFF)
    ;            ││└┴───── Page 2 (#8000-#BFFF)
    ;            └┴─────── Page 3 (#C000-#FFFF)
    ; Registers: A
    ; WSLREG
    ; Address  : #013B
    ; Function : Writes value to the primary slot register
    ; Input    : A  - Value to write, see RSLREG    


    ld      a, 66
    call    BIOS_CHPUT ; debug

    ld      a, 32
    ld      (ADDRESS_TO_BE_TESTED), a

.loop:
    call    Wait_15_Vblanks


    ; -----------------------------------
    ; call    Set_RAM_Page_2
    ; call    Set_RAM_Page_0
    ; call    Set_RAM_Page_1

    ld      hl, ADDRESS_TO_BE_TESTED

    inc     (hl)

    ld      a, (hl)


    ld      hl, 0 + (0 * 40) + 20 ; NAMTBL addr for middle of first line
    call    PutCharOnScreen


    ; -----------------------------------
    ; call    Restore_Page_2
    ; call    Restore_Page_0
    ; call    Restore_Page_1

    ld      hl, ADDRESS_TO_BE_TESTED
    ld      a, (hl)

    ld      hl, 0 + (2 * 40) + 20 ; NAMTBL addr for middle of third line
    call    PutCharOnScreen



    jp      .loop

; --------------------------

; Inputs
;   HL: NAMTBL address
;   A: char code
PutCharOnScreen:
    push    af
        ; ld      hl, 0 + (2 * 40) + 20 ; NAMTBL addr for middle of third line
        ld      a, 0000 0000 b
        call    SetVdp_Write
    pop     af
    out     (PORT_0), a

    ret

; --------------------------

;             +----------- page 3 (0xc000 to 0xffff)
;             | +--------- page 2 (0x8000 to 0xbfff)
;             | | +------- page 1 (0x4000 to 0x7fff)
;             | | | +----- page 0 (0x0000 to 0x3fff)
;             | | | |
;            33221100
; ld      a, 00000000 b
; out     (PPI.A), a


; WARNING: using page 0 as RAM is not working (probably because of ISR)
Set_RAM_Page_0:

    ; read page 3 current slot (to know which is the RAM slot)
    in      a, (PPI.A)
    and     11000000 b      ; keep only page 3 position
    srl     a               ; shift right register
    srl     a
    srl     a
    srl     a
    srl     a
    srl     a
    ld      b, a            ; register B: RAM slot number to page 0 position

    ; set page 0 to slot number on register B
    in      a, (PPI.A)
    and     11111100 b      ; clear page 0 value, keeping other pages
    or      b               ; put RAM slot number into page 0 position
    out     (PPI.A), a

    ret

Restore_Page_0:
    ld      a, (PPI_A_saved)
    and     00000011 b      ; keep only page 0 position
    ld      b, a
    in      a, (PPI.A)
    and     11111100 b      ; clear page 0 value, keeping other pages
    or      b               ; put saved slot number into page 0 position
    ld      (PPI_A_saved), a
    out     (PPI.A), a

    ret

; -----

Set_RAM_Page_1:

    ; read page 3 current slot (to know which is the RAM slot)
    in      a, (PPI.A)
    and     11000000 b      ; keep only page 3 position
    srl     a               ; shift right register
    srl     a
    srl     a
    srl     a
    ld      b, a            ; register B: RAM slot number to page 1 position

    ; set page 1 to slot number on register D
    in      a, (PPI.A)
    and     11110011 b      ; clear page 1 value, keeping other pages
    or      b               ; put RAM slot number into page 1 position
    out     (PPI.A), a

    ret

Restore_Page_1:
    ld      a, (PPI_A_saved)
    and     00001100 b      ; keep only page 1 position
    ld      b, a
    in      a, (PPI.A)
    and     11110011 b      ; clear page 1 value, keeping other pages
    or      b               ; put saved slot number into page 1 position
    ld      (PPI_A_saved), a
    out     (PPI.A), a

    ret

; ------

Set_RAM_Page_2:

    ; read page 3 current slot (to know which is the RAM slot)
    in      a, (PPI.A)
    and     11000000 b      ; keep only page 3 position
    srl     a               ; shift right register
    srl     a
    ld      b, a            ; register B: RAM slot number to page 2 position

    ; set page 2 to slot number on register E
    in      a, (PPI.A)
    and     11001111 b      ; clear page 2 value, keeping other pages
    or      b               ; put RAM slot number into page 2 position
    out     (PPI.A), a

    ; ; set page 0 to slot 2 (RAM on Gradiente Expert)
    ; ld      a, 00000010 b
    ; out     (PPI.A), a
    ret

Restore_Page_2:
    ld      a, (PPI_A_saved)
    and     00110000 b      ; keep only page 2 position
    ld      b, a
    in      a, (PPI.A)
    and     11001111 b      ; clear page 2 value, keeping other pages
    or      b               ; put saved slot number into page 2 position
    ld      (PPI_A_saved), a
    out     (PPI.A), a

    ret



; --------------------------


    db      "End ROM started at 0x4000"

    ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff

; ----------------- Variables
    org 0xc000

PPI_A_saved:        rb 1


