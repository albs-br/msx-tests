
#ram_watch   add     0xc000      -type byte      -desc debug_0     -format hex
#ram_watch   add     0xc001      -type byte      -desc debug_1     -format hex

#ram_watch   add     0xc001      -type byte      -desc CurrentMegaROMPage        -format dec
#ram_watch   add     0xc002      -type word      -desc CurrentAddrLineScroll     -format hex


#ram_watch   add     0xF3E1      -type byte      -desc REG2SAV        -format hex

ram_watch   add     0xdf00      -type word      -desc RndNumbers      -format hex
ram_watch   add     0xdf02      -type word      -desc RndNumbers      -format hex
ram_watch   add     0xdf04      -type word      -desc RndNumbers      -format hex
ram_watch   add     0xdf06      -type word      -desc RndNumbers      -format hex
ram_watch   add     0xdf08      -type word      -desc RndNumbers      -format hex
ram_watch   add     0xdf0a      -type word      -desc RndNumbers      -format hex
ram_watch   add     0xdffe      -type word      -desc RndNumbers_fe      -format hex

#RndNumbers: equ 0DF00h ; last def. pass 3
