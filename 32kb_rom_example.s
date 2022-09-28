FNAME "32kb_rom_example.rom"      ; output file

; ATTENTION: it should be run without the "-romtype ASCII16" parameter on openMSX

PageSize:	    equ	0x4000	        ; 16kB

    org 0x4000

    INCLUDE "Include/RomHeader.s"
    INCLUDE "Include/MsxBios.s"
    INCLUDE "Include/MsxConstants.s"
    INCLUDE "Include/CommonRoutines.s"

Execute:

    ;call    SETPAGES32K

; Typical routine to select the ROM on page 8000h-BFFFh from page 4000h-7BFFFh
	call	BIOS_RSLREG
	rrca
	rrca
	and	3	;Keep bits corresponding to the page 4000h-7FFFh
	ld	c,a
	ld	b,0
	ld	hl,BIOS_EXPTBL
	add	hl,bc
	ld	a,(hl)
	and	80h
	or	c
	ld	c,a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	0Ch
	or	c
	ld	h,080h
	call	BIOS_ENASLT		; Select the ROM on page 8000h-BFFFh



    ; set screen 0
    call    BIOS_INITXT


    ld      hl, Message_0x4000
    call    PrintString

    ld      hl, Message_0x8000
    call    PrintString


    jp      $           ; endless loop

PrintString:
    ld      a, (hl)
    cp      0
    ret     z
    call    BIOS_CHPUT
    inc     hl
    jr      PrintString


RET_OPCODE:     equ 0xc9

;-----------------------------------------------
; From: http://www.z80st.es/downloads/code/
; SETPAGES32K:  BIOS-ROM-YY-ZZ   -> BIOS-ROM-ROM-ZZ (SITUA PAGINA 2)
SETPAGES32K:    ; --- Posiciona las paginas de un megarom o un 32K ---
    ld  a,RET_OPCODE        ; Codigo de RET
    ld  (SETPAGES32K_NOPRET),a            ; Modificamos la siguiente instruccion si estamos en RAM
SETPAGES32K_NOPRET:   
    nop                     ; No hacemos nada si no estamos en RAM
    ; --- Si llegamos aqui no estamos en RAM, hay que posicionar la pagina ---
    call BIOS_RSLREG             ; Leemos el contenido del registro de seleccion de slots
    rrca                    ; Rotamos a la derecha...
    rrca                    ; ...dos veces
    call GETSLOT            ; Obtenemos el slot de la pagina 1 ($4000-$BFFF)
    ;ld (ROM_slot),a         ; santi: I added this to the routine, so we can easily call methods later from page 1
    ld  h, 0x80               ; Seleccionamos pagina 2 ($8000-$BFFF)
    jp  BIOS_ENASLT              ; Posicionamos la pagina 2 y volvemos

;-----------------------------------------------
; From: http://www.z80st.es/downloads/code/ (author: Konamiman)
; GETSLOT:  constructs the SLOT value to then call ENSALT
; input:
; a: slot
; output:
; a: value for ENSALT
GETSLOT:    
    and 0x03             ; Proteccion, nos aseguramos de que el valor esta en 0-3
    ld  c,a             ; c = slot de la pagina
    ld  b,0             ; bc = slot de la pagina
    ld  hl,0xfcc1        ; Tabla de slots expandidos
    add hl,bc           ; hl -> variable que indica si este slot esta expandido
    ld  a,(hl)          ; Tomamos el valor
    and 0x80             ; Si el bit mas alto es cero...
    jr  z,GETSLOT_EXIT            ; ...nos vamos a @@EXIT
    ; --- El slot esta expandido ---
    or  c               ; Slot basico en el lugar adecuado
    ld  c,a             ; Guardamos el valor en c
    inc hl              ; Incrementamos hl una...
    inc hl              ; ...dos...
    inc hl              ; ...tres...
    inc hl              ; ...cuatro veces
    ld  a,(hl)              ; a = valor del registro de subslot del slot donde estamos
    and 0x0C             ; Nos quedamos con el valor donde esta nuestro cartucho
GETSLOT_EXIT:     
    or  c               ; Slot extendido/basico en su lugar
    ret                 ; Volvemos


Message_0x4000:
    db      "Hello world from page 0x4000", 0

	ds      PageSize - ($ - 0x4000), 255	; Fill the unused area with 0xFF


; ------------------------------------------------------------------

    org 0x8000
Message_0x8000:
    db      "Hello world from page 0x8000", 0
	ds      PageSize - ($ - 0x8000), 255	; Fill the unused area with 0xFF
