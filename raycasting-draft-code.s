; JUST SNIPPETS OF CODE.
; THIS CODE DOES NOT COMPILE DIRECTLY

; ------ cast long rays Y (DDA), looking for horizontal intersections

; BHL contains ray current X
; CDE contains ray DX

; X += DX
add     hl, de          ; add BHL to CDE, result in BHL
ld      a, b
adc     a, c
ld      b, a

push hl
    push bc

        ; same as Y--
        ; current_map_address -= map_width
        ld      hl, (current_map_address)
        ld      bc, -64  ; map width
        add     hl, bc
        ; --- TODO: if map_width = 256 it can be a simple dec h

        ; current_map_address += B
        ld      c, b
        ld      b, 0
        add     hl, bc
       
        ld      (current_map_address), hl

    pop bc
pop hl



; ; Y--
; ld      a, (ray_current_y_high_byte)
; dec     a
; ld      (ray_current_y_high_byte), a
; ; TODO: this can be changed to MAP_CURRENT_ADDR -= 64




; --- TODO: this can be improved calculating before the loop
; --- eg. MAX_ITERATIONS = 20; player_y = 14; loop will be 14
; ; if (Y != 0) Y--;
; ld      a, (ray_current_y_high_byte)
; or      a
; jr      z, .end_casting_ray_verticaly
; dec     a
; ld      (ray_current_y_high_byte), a






; TODO: possible optimization: EXX to switch to alternate registers (must disable interrupts first)
; main registers: ray X and DX
; alternate registers: ray_current_distance and ray_delta_long_distance

; distance += ray_delta_long_distance
push    hl
    push    bc
        ; load current distance
        ld      hl, (ray_current_distance)          ; least significant 16 bits (little endian)
        ld      a, (ray_current_distance + 2)       ; most significant 8 bits

        ; load ray delta long distance
        ld      de, (ray_delta_long_distance)          ; least significant 16 bits (little endian)
        ld      c, (ray_delta_long_distance + 2)       ; most significant 8 bits ; THIS INSTRUCTION DOES NOT EXIST!

        add     hl, de          ; add AHL to CDE, result in AHL
        adc     a, c

        ; save current distance
        ld      (ray_current_distance), hl          ; least significant 16 bits (little endian)
        ld      (ray_current_distance + 2), a       ; most significant 8 bits

    pop     bc
pop     hl


; check if tile is wall
push    hl
    ; convert tile x and y to map address
    ld      hl, base_map_address
    ; L += tile_x
    ; H += tile_y * map_width

    ld      a, (hl)
    or      a

pop     hl
jr      z, .is_not_wall

; is wall

.is_not_wall:

; --------------------------------------------------------------

; OTHER APPROACH

; -----data structure example (long ray):


; ---- 0 degrees

    ; ----- horizontal intersections

    ;   value                                     description                                                                   format                  decimal value
    db  00000000 b, 00000000 b, 00000001 b      ; horiz. intersections map relative address delta for each step                 8.16 fixed point        1.0

    ; step 1
    db  00000000 b, 00000000 b, 00000001 b      ; distance cumulative                       8.16 fixed point        1.0
    db  00000000 b, 00000000 b, 00000001 b      ; dx cumulative                             8.16 fixed point        1.0
   
    ;db  00000000 b, 00000000 b, 00000001 b      ; dy cumulative                             8.16 fixed point        1.0

    ; ...more steps...



; ----- code

; ------ cast long rays Y (DDA), looking for horizontal intersections


; iyL = the smallest of max_iterations and number of cells to map bound
.loop:

    ; HLIX contains map current address 16.16 fixed point
    ; BCDE contains map relative address delta for each step 16.16 fixed point

    add     ix, de
    adc     hl, bc

    ; check map cell
    ld      a, (hl)
    or      a
    jr      nz, .is_wall

    dec     iyl
    jp      nz, .loop




; ---------------------------------
; ONE MORE APPROACH (PRECALC TOUCHED SQUARES FOR EACH ANGLE / PLAYER POSITION INSIDE CELL, PLUS DISTANCE)

; data format:

; --- player position: (0, 0)

; ------ angle 0 degrees
db      +1, +1, +1, +1, +1, +1, +1, +1, +1, +1, +1, +1, -32, +1, +1, +1, +1, +1, +1, +1 ; delta to next square

db      00000000 b, 00000000 b ; distance from player to square 1; fixed point 8.8?
; (...)
db      00000000 b, 00000000 b ; distance from player to square 20;

; size = 256 positions x 180 double-degrees x (20+40) bytes = 2.7 MB


; --- code

; HL points to current player cell on map
; DE points to precalc squares touched data for current angle and player position inside cell

    ld      b, 0


; unroll loop 20x: 53 * 20 cycles max to find wall
    ld      a, (de)
   
    ld      c, a

    add     hl, bc

    ld      a, (hl)
    or      a
    jr      nz, .is_wall        ; JR wont work here if destiny is over 127 bytes
    ;call    nz, .is_not_empty ; map cell contains enemy/object <--- IMPROVE THIS PART

    inc     de


; 53 cycles per tile
; 20 tiles per ray
; 30 rays per frame
; 53 * 20 * 30 columns = >32000 cycles (OMG 60 fps !!!!)

; ---------------------------------

; ------------------ Render column to NAMTBL_buffer

    ; HL: ROM start addr of column strip (16 bytes)
    ; DE: NAMTBL_buffer addr for this column

    ld      (saved_SP), sp

    ld      sp, 32 - 1  ; must disable interrupts before using SP as general purpose register


    ; (...) unrolled 16x = 16 * 40 = 640 cycles for each column!
    ldi     ; copy byte from (HL) to (DE), increment both HL and DE, decrement BC
    ex      de, hl              ; DE += 31, go to next line
        add     hl, sp
    ex      de, hl



    ld      sp, (saved_SP)

; --- other approach (table aligned)

    ; before
    ld      a, e
    ld      b, 32
    ld      c, 255 ; safe value to LDI not touch B

    ; (...) unrolled 16x = 16 * 28 = 448 cycles for each column! 13440 cycles for 30 columns
    ldi     ; copy byte from (HL) to (DE), increment both HL and DE, decrement BC
    add     b
    ld      e, a

    ; after 8 repetitions
    inc     d       ; is it really necessary? A: yes, the last LDI increments E from 224 to 225...


; --- one more approach: using SP as ponter to column data and POP to get 2 bytes at once (need to disable interrupts first)

    ; SP: ROM start addr of column strip (16 bytes)
    ; HL: NAMTBL_buffer addr for this column

    ; before
    ld      a, l
    ld      d, 32

    ; 47 cycles to read 2 bytes and write them to addresses 32 bytes apart
    ; (...) unrolled 8x = 8 * 47 = 376 cycles for each column! 11280 cycles for 30 columns
    pop     bc
    ld      (hl), c
    ;add     hl, de
    add     d           ; L += 32
    ld      l, a
    ld      (hl), b
    add     d
    ld      l, a

    ; after 4 repetitions
    inc     h



; ----- another (crazy) approach

    pop    hl
    ld     a, l
    ld     (addr), a
    ld     a, h
    ld     (addr + 32), a

; ---------------------------------

; 18 * 512 = 9216 cycles
outi    ; 18 cycles


; ---------------------------------


; some command timings
push   hl           ; 12 cycles
pop    hl           ; 11 cycles

ex      de, hl      ; 5 cycles

ld      (addr), hl  ; 17 cycles
ld      (addr), a   ; 14 cycles


; save 8.16 to memory
ld      (addr), hl          ; least significant 16 bits (little endian)
ld      (addr + 2), a       ; most significant 8 bits

; load 8.16 from memory
ld      hl, (addr)          ; least significant 16 bits (little endian)
ld      a, (addr + 2)       ; most significant 8 bits




; IX/IY vs memory
ld      (addr), hl      ; 17 cycles

ld      ixl, l        ; 13 cycles
ld      ixh, h        ; 13 cycles

push    hl          ; 12
pop     ix          ; 11

outi    ; 18 cycles




; ld HL x A to memory
ld      (addr), hl      ; 17 cycles
ld      (addr), a       ; 14 cycles



; LDI x option
ldi     ; 18 cycles

ld      a, (hl)
ld      (de), a
inc     hl





; outi x pop
outi    ; 18 cycles


; 39 cycles for 2 bytes... not very good
pop     de
out (c), e
; some nop
out (c), d


    ; ; invert number (twos complement)
    ; ld      a, 255
    ; sub     c
    ; ld      c, a

    ; ; invert number (twos complement)
    ; xor     255
    ; inc     a
    ; ld      c, a



    ; (current_map_address_low) and (current_map_address_high) contains map current address
    ; BCDE contains map relative address delta for each step 16.16 fixed point

    ; Add two 16.16 FP numbers: memory to BCDE
    ; ld      hl, (current_map_address_low)
    ; add     hl, de
    ; ld      (current_map_address_low), hl
    ; ld      hl, (current_map_address_high)
    ; adc     hl, bc
    ; ld      (current_map_address_high), hl