; to be used with msxpen

; bios call to print a character on screen
CHPUT:      equ 0x00a2

            ; the address of our program
            org 0xD000

start:
            ld hl, message
            call PRINT

            ld hl, message
            call UPPER

            ld hl, message
            call PRINT


			ret ; end program and return to Basic
            
PRINT:      ld a, (hl)
            cp 0
            ret z
            call CHPUT
            inc hl
            jp PRINT

UPPER:      ld a, (hl)
            cp 0
            ret z

			; if (A < 97) next char
            cp 97 ; 'a'
            jp c, nextChar
            
			; if (A > 122) next char
            cp 122 + 1 ; 'z'
            jp nc, nextChar

			sub 32
            ld (hl), a
nextChar:   inc hl
            jp UPPER


message:
            db "Hello world zzz _OI [] !",0

            ; use the label "start" as the entry point
            end start