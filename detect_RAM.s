FNAME "detect_RAM.rom"      ; output file

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

    ; set screen 0
    call    BIOS_INITXT ; warning: if page 0 is disabled, cannot use BIOS routines

    ; save current pages value from PPI
    in      a, (PPI.A)
    ; and     00110000 b      ; keep only page 2 position
    ; and     00000011 b      ; keep only page 0 position
    ; and     00001100 b      ; keep only page 1 position
    ld      (PPI_A_saved), a


    ; ------------------------ detect RAM on page 1 (0x4000)

    xor     a
    ld      (SlotId), a

    ld      hl, 0x4000 ; Page 1
    ld      (Page), hl


    ld      hl, STRINGS.PAGE_1
    call    PrintString


.checkSlot_Start:

    call    PrintCrLf
    ld      hl, STRINGS.CHECKING_SLOT
    call    PrintString


    ; --- check if slot is expanded
    ld      a, (SlotId)
    and     0000 0011 b ; get slot number
    ; srl     a               ; shift right register
    ; srl     a               ; shift right register
    ld      b, 0
    ld      c, a

    call    PrintNumber

    ld      hl, BIOS_EXPTBL
    add     hl, bc
    ld      a, (hl)
    ld      b, a
    ld      a, (SlotId)
    or      b           ; merge slot number with expanded flag
    ld      (SlotId), a 
    and     0x80    ; if bit 7 is set then slot is expanded
    jr      nz, .slotIsExpanded
    ; jr      .slotIsNotExpanded

.slotIsNotExpanded:

    call    CheckRAM_On_SlotId

    jr      .nextSlot

.slotIsExpanded:

    ld      hl, STRINGS.IS_EXPANDED
    call    PrintString

.loopSubslots:

    call    PrintCrLf
    ld      hl, STRINGS.CHECKING_SUBSLOT
    call    PrintString


    call    CheckRAM_On_SlotId
    ;jr      .nextSubslot

.nextSubslot:

    ld      a, (SlotId)
    and     0000 1100 b  ; get subslot number (secondary slot)
    cp      0000 1100 b
    jr      z, .nextSlot    ; if (subslot == 3) nextSlot

    ld      a, (SlotId)
    add     0000 0100 b ; next subslot
    ld      (SlotId), a

    jr      .loopSubslots
    ;add     0000 0100 b ; next slot



    
.nextSlot:
    ld      a, (SlotId)
    and     0000 0011 b ; get primary slot number, reset subslot
    cp      3
    jr      z, .end

    inc     a
    ld      (SlotId), a
    jr      .checkSlot_Start
    

.end:
    jr      $

; Inputs:
;   (SlotId): Slot ID on BIOS_RDSLT format (8 bits)
;   (Page): Page (0x0000, 0x4000, 0x8000 or 0xC000) (16 bits)
CheckRAM_On_SlotId:

    ; --- read and save current value at sample address

    ; Input    : A  - ExxxSSPP  Slot-ID
    ;                 │   ││└┴─ Primary slot number (00-11)
    ;                 │   └┴─── Secondary slot number (00-11)
    ;                 └──────── Expanded slot (0 = no, 1 = yes)    
    ld      a, (SlotId)
    ld      hl, (Page)
    call    BIOS_RDSLT ; This routine turns off the interrupt, but won't turn it on again
    ei

    ld      (SavedValue), a

    
    ; --- write new value to the address
    inc     a
    ld      e, a    ; value to be writen

    ld      a, (SlotId)
    ld      hl, (Page)
    call    BIOS_WRSLT ; This routine turns off the interrupt, but won't turn it on again
    ei


    ; --- read again value and check it
    ld      a, (SlotId)
    ld      hl, (Page)
    call    BIOS_RDSLT ; This routine turns off the interrupt, but won't turn it on again
    ei

    ld      hl, SavedValue
    cp      (hl) ; if (new value == old value) IsNotRAM();
    jr      z, .IsNotRAM

.isRAM:

    ld      hl, STRINGS.RAM_FOUND
    call    PrintString

    ; TODO
    ; print slot/subslot
    ld      a, (SlotId)
    and     0000 0011 b
    call    PrintNumber

    ;jp $
    ret

.IsNotRAM:
    ret

    ; ------------------------ 



    ; ; code for MSX2 and over

    ; ; https://www.msx.org/forum/msx-talk/development/i-dont-understand-enaslt-sample-in-the-wiki
    ; ; Select the slot 2-1 for page 1 (4000h-07FFFh) using BIOS routine
    ; ; ENASLT	equ	0024h
    ; ; 	ld	h,040h
    ; ; 	ld	a,086h	;Slot ID
    ; ; 	call	ENASLT
    ; ; Slot ID is coded this way: F000EEPP
    ; ; if F is set, then EE (subslot) is used.
    ; ; 0x86 = 1000 0110, primary = 2, extended = 1

    ; ; set page 1 (0x4000-0x7fff) to slot ?-?
    ; ld	    hL, ADDRESS_TO_BE_TESTED
    ; ;          F000EEPP
   	; ; ld	    a, 10001111 b ; slot ID 3-3
   	; ld	    a, 10001111 b ; slot ID 3-0
   	; call	BIOS_ENASLT

    ; ; select segment (0-255) of memory mapper
    ; ; Physical page 0 → FCH port
    ; ; Physical page 1 → FDH port
    ; ; Physical page 2 → FEH port
    ; ; Physical page 3 → FFH port
    ;  in      a, (0xff)
    ; ;ld      a, 0
    ; out     (0xfd), a


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


; --------------------------

;             +----------- page 3 (0xc000 to 0xffff)
;             | +--------- page 2 (0x8000 to 0xbfff)
;             | | +------- page 1 (0x4000 to 0x7fff)
;             | | | +----- page 0 (0x0000 to 0x3fff)
;             | | | |
;            33221100
; ld      a, 00000000 b
; out     (PPI.A), a

; --------------------------

PrintString:
    ld      a, (hl)
    or      a ; cp 0
    ret     z
    call    BIOS_CHPUT
    inc     hl
    jr      PrintString

PrintNumber:
    add     '0'
    call    BIOS_CHPUT
    ret

PrintCrLf:
    ld      a, 13
    call    BIOS_CHPUT
    ld      a, 10
    call    BIOS_CHPUT
    ret
; --------------------------

STRINGS:
    .PAGE_0:            db 'Page 0 (0x0000)', 0
    .PAGE_1:            db 'Page 1 (0x4000)', 0
    .PAGE_2:            db 'Page 2 (0x8000)', 0
    .PAGE_3:            db 'Page 3 (0xC000)', 0
    .RAM_FOUND:         db ' RAM found at slot ', 0
    .CHECKING_SLOT:     db '  checking slot ', 0
    .CHECKING_SUBSLOT:  db '    checking subslot ', 0
    .IS_EXPANDED:       db ' (expanded)', 0

    db      "End ROM started at 0x4000"

    ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff

; ----------------- Variables
    org 0xc000

PPI_A_saved:        rb 1
SavedValue:         rb 1
CurrentSlot:        rb 1
CurrentSubslot:     rb 1
SlotId:             rb 1
Page:               rw 1