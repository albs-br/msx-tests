	
; Original by Bitvision Software
; Converted to TNI Asm by Andre Baptista

FNAME "opl4.rom"      ; output file


ENASLT: equ         0x0024
GTTRIG: equ 	    0x00D8

; Compilation address
    org 0x4000

; Cartridge Header
    db "AB"
    dw BEGIN
    dw 0, 0, 0, 0, 0, 0



BEGIN:                                 

			di
			im        1
			ld        sp, 0xF380

			ld        a, 0xc9
			ld        (0xfd9f), a                                              ;Disk BIOS hook is not gonna distrub us                 

			xor       a
			ld        (0x6000), a
			inc       a
			ld        (0x7000), a
		   
		   
			call      figure_where_rom_is

			ld        a, (0xf001)
			ld        h, 0x80                     ;pag 2
			call      ENASLT                 	;set rom


;keyboard klick disable
			xor       a
			ld        (0xF3DB), a                           
		   
		   
			;is OPL4 available?
		    in		  a, (0xc4)
		    cp		  0xff
		    jr		  z, $						;stay here forever if not found!
		   

			;setup OPL4 (parte FM)
			;enable new2:wave registers						(Manual pag 42)
			ld       a, 5
			out      (0xc6), a                                ; 0xc4 + 2
			ld       a, 2
			out      (0xc7), a                                ; 0xc4 + 2 + 1

			
			
			ld 		bc, 0x0210				;device ID 0, Wave table header 100b = 5 => from wave 384 to 511 starts at 0x200000 (Check manual pages 14,15)
			call    write_opl4_port
		   
			ld      bc, 0x2001				;first channel, wave most significant bit (MSB) always 1 ... so 1xxxxxxxxb 
			call    write_opl4_port

			ld      bc, 0x38F0				;first channel, octave 15 (max). Play this with FNumber (Check manual page 17). Our samples are 11Kz
			call    write_opl4_port
		   
		   
		   
			;uploading samples (headers & data)		   
			;activate reading/writting
			ld      b, 2
			call    read_opl4_port
			or      1                                        ;bit 0 to 1 => reading/writting wave memory
		   
;           ld      b, 2                                      ;b keeps value
			ld      c, a
			call    write_opl4_port
		   
			;uploading headers
			;set up wave ram writting address		0x200000
			ld      bc, 0x0320
			call    write_opl4_port
			ld      bc, 0x0400
			call    write_opl4_port
			ld      bc, 0x0500
			call    write_opl4_port                              
		   
			ld      a, 1
			ld      (0x7000), a								;megarom block 1 from 0x8000

			ld      hl, 0x8000 ;headers_begin
			ld      de, headers_end - headers_begin
			ld      b, 0x06                                   ;read/write OPL4 wave register
loop_header:
			ld      c, (hl)
		   
			call    write_opl4_port
			inc     hl
			dec     de
			ld      a, d
			or      e
			jr      nz, loop_header
		   

		   
			;uploading samples data
		   
			;set up wave ram writting address
			;from 0x201200  
			ld      bc, 0x0320
			call    write_opl4_port
			ld      bc, 0x0412
			call    write_opl4_port
			ld      bc, 0x0500
			call    write_opl4_port                              

			ld      a, 2
			ld      (0x7000), a
			call	load_16kb_chunk
			ld      a, 3
			ld      (0x7000), a
			call	load_16kb_chunk			
			ld      a, 4
			ld      (0x7000), a
			call	load_16kb_chunk
		   
		   

			;restore regular operation (play sound!)
			ld      b, 2
			call    read_opl4_port
			and     11111110b                                    ;bit 0 to 0 => reading/writting wave memory disabled
		   
;           ld      b, 2                    ;b keeps value
			ld      c, a
			call    write_opl4_port


			ei
		   
			xor    a
			ld     (0xefff), a			;key pressed?		0=> no , !=0 yes
			
			ld	   a, 0x80				;first sample to play . We will do it from 0x80 to 0x82  ... it's 9 bits ... bit8 it's already set to 1(look above)
										;bits 7-0 will be taken from here ... bit 7 should be always 1 ... so we will have 9 bits like this:
										; 11xxxxxxxb  (from 384 - 511)
			ld     (0xeffe), a			;sample to play at 0xeffe



			;;;;;;;;;;wait for space keypress
wait_space_loop:
			xor    a
			call   GTTRIG                
			or     a
			jr     z, clean_keypress
		   
			ld     a, (0xefff)
			or     a
			jr     nz,wait_space_loop
		   
			ld     a, 1
			ld     (0xefff), a                                               ;keypress
		   
			ld	   a, (0xeffe)					;play sample
		    ld	   d, a
			call   speak
			
		    ld	   a, d							;set up next sample
		    cp	   0x80 + 2
		    jr 	   z, .reset
		    inc	   a
		    jr 	   .cont
.reset:
			ld		a, 0x80						;start over!
.cont:
			ld		(0xeffe), a
		   
			jr     wait_space_loop
		   
		   
clean_keypress:
			xor    a
			ld     (0xefff), a                                               ;no keypress
			jr    wait_space_loop
		   








		   
		   
		   
		   
		   
		   
;d - sample number		   
speak:
			ld     bc, 0x6800                                             
			call   write_opl4_port                                              ;silence please

			ld     b, 0x08                                                              
			ld	   c, d															;sample number
			call   write_opl4_port                              

			ld     bc, 0x6880                                                    ;play that                                            
			jp     write_opl4_port                                              


		   
		   
		   
		   
		   
		   

;b - port number
;c - data
write_opl4_port:
			;port
			ld      a, b
			out     (0x7e), a
			ld      a, c
			nop
			nop
			;data
			out     (0x7f), a
			ret
		   
		   

;b - port number
; returns
; a - value read
read_opl4_port:
			;port
			ld     a, b
			out    (0x7e), a
			nop
			nop
			nop
			;data
			in     a, (0x7f)
			ret



;set the right page on the megarom before calling this guy
load_16kb_chunk:
			ld      hl, 0x8000
			ld      de, 0x4000			;16kb
			ld      b, 0x06                                                     ;read/write OPL4 wave register
loop_data:
			ld      c, (hl)
		   
			call    write_opl4_port
			inc     hl
			dec     de
			ld      a, d
			or      e
			jr      nz, loop_data
			ret









 
 
; 0xf001 will contain the rom ExxxxSSPP
figure_where_rom_is:                                                 
            jp search_slot
            ;jp ENASLT
 
 
; -----------------------
; SEARCH_SLOT
; Busca slot de nuestro rom
; -----------------------
 
search_slot:
 
			call 0x0138 ;RSLREG
			rrca
			rrca
			and 3
			ld c, a
			ld b, 0
			ld hl, 0x0FCC1
			add hl, bc
			ld a, (hl)
			and 0x80
			or c
			ld c, a
			inc hl
			inc hl
			inc hl
			inc hl
			ld a, (hl)
			and 0x0C
			or c
			ld h, 0x80
			ld (0xf001), a
			ret                                         
														   
			ds                           0x8000 - $
;;end page 0




		   
		   
		;    macro sample_header aaa,bbb 
		; 	;header aaa
		; 	db     aaa	>> 16, (aaa >> 8) and 0xff, aaa and 0xff
		; 	db     (bbb) >> 8
		; 	db     (bbb) and 0xff
		; 	db     ((bbb) xor 0xffFF) >> 8
		; 	db     ((bbb) xor 0xffFF) and 0xff
		; 	db     0x00, 0xf0, 0x00, 0x0f, 0x00 
		;    endm
		   
		     
		   
			;page 1
			org                         0x00
headers_begin:               
			;up to 384 headers, 12 bytes per header = 4608 bytes
			;so 0x200000 + 0x1200 = 0x201200 ... where data should start
		   
			;header sample 0
sample_0_size:	equ	sample_0_end - sample_0
			db     0x20, 0x12, 0x00                                                                                   ;8 bits & start address at wave memory
			db    (sample_0_size) >> 8
			db    (sample_0_size) and 0xff
			db    ((sample_0_size) xor 0xffFF) >> 8
			db    ((sample_0_size) xor 0xffFF) and 0xff
			db    0x00, 0xf0, 0x00, 0x00, 0x00   ;also works 0x00, 0xf0, 0x00, 0x0f, 0x00
		   


			;header sample 1

			; sample_header	sample_1, (sample_1_end - sample_1)

sample_1_size:	equ	sample_1_end - sample_1
			db    sample_1 >> 16, (sample_1 >> 8) and 0xff, sample_1 and 0xff                                                                           ;8 bits & start address at wave memory
			db    (sample_1_size) >> 8
			db    (sample_1_size) and 0xff
			db    ((sample_1_size) xor 0xffFF) >> 8
			db    ((sample_1_size) xor 0xffFF) and 0xff
			db    0x00, 0xf0, 0x00, 0x00, 0x00   ;also works 0x00, 0xf0, 0x00, 0x0f, 0x00



			;header sample 2
			; sample_header	sample_2, (sample_2_end - sample_2)

sample_2_size:	equ	sample_2_end - sample_2
			db    sample_2 >> 16, (sample_2 >> 8) and 0xff, sample_2 and 0xff                                                                           ;8 bits & start address at wave memory
			db    (sample_2_size) >> 8
			db    (sample_2_size) and 0xff
			db    ((sample_2_size) xor 0xffFF) >> 8
			db    ((sample_2_size) xor 0xffFF) and 0xff
			db    0x00, 0xf0, 0x00, 0x00, 0x00   ;also works 0x00, 0xf0, 0x00, 0x0f, 0x00

headers_end:  
			ds     16 * 1024 - $
		   
		   
		   
		   
		   
		   
		   
			;page 2 & more               
			org    0x201200
sample_0:          
			incbin    "Sound/opl4/ApplauseModerate2_11Kh_signed8bits.raw"
sample_0_end:
		   
sample_1:          
			incbin    "Sound/opl4/bitvision_female_british.raw"
sample_1_end:
		   
sample_2:          
			incbin    "Sound/opl4/hello_signed_8bits_11000hz.raw"
sample_2_end:
			ds     0x201200 + (16384 * 4) - $
               
               
               
