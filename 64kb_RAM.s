FNAME "64kb_RAM.rom"      ; output file

PageSize:	    equ	0x4000	        ; 16kB

; Compilation address
    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:

    ; set screen 0
    call    BIOS_INITXT ; warning: if page 0 is disabled, cannot use BIOS routines

    xor     a
    ld      (PPI_A_saved), a

    ;call    Set_RAM_Page_2

ADDRESS_TO_BE_TESTED: equ 0x8000

    ld      a, 32
    ld      (ADDRESS_TO_BE_TESTED), a

.loop:
    call    Wait_15_Vblanks


    ; -----------------------------------
    ;call    Set_RAM_Page_2

    ld      hl, ADDRESS_TO_BE_TESTED
    ld      a, (hl)

    inc     (hl)

    call    BIOS_CHPUT


    ; -----------------------------------
;    call    Restore_Page_2

    ld      hl, ADDRESS_TO_BE_TESTED
    ld      a, (hl)

    call    BIOS_CHPUT



    jp      .loop

; --------------------------

;             +----------- page 3 (0xc000 to 0xffff)
;             | +--------- page 2 (0x8000 to 0xbfff)
;             | | +------- page 1 (0x4000 to 0x7fff)
;             | | | +----- page 0 (0x0000 to 0x3fff)
;             | | | |
;            33221100
; ld      a, 00000000 b
; out     (PPI.A), a

Set_RAM_Page_2:

    ; save current page 2 value
    in      a, (PPI.A)
    and     00110000 b      ; keep only page 2 position
    ld      b, a
    ld      a, (PPI_A_saved)
    and     11001111 b      ; clear page 2 value
    or      b               ; put current slot number into page 2 position
    ld      (PPI_A_saved), a



    ; read page 3 current slot (to know which is the RAM slot)
    in      a, (PPI.A)
    and     11000000 b      ; keep only page 3 position
    srl     a               ; shift right register
    srl     a
    ld      e, a            ; save RAM slot number to page 2 position
    srl     a
    srl     a
    ld      d, a            ; save RAM slot number to page 1 position
    srl     a
    srl     a
    ld      c, a            ; save RAM slot number to page 0 position

    ; set page 0 to slot number on register C
    in      a, (PPI.A)
    and     11001111 b      ; clear page 2 value
    or      e               ; put RAM slot number into page 2 position
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
    and     11001111 b      ; clear page 2 value
    or      b               ; put saved slot number into page 2 position
    ld      (PPI_A_saved), a
    out     (PPI.A), a

    ret

    db      "End ROM started at 0x4000"

    ds PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xff

; ----------------- Variables
    org 0xc000

PPI_A_saved:        rb 1


