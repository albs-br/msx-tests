
#ram_watch   add     0xc000      -type byte      -desc debug_0     -format hex
#ram_watch   add     0xc001      -type byte      -desc debug_1     -format hex

#ram_watch   add     0xc001      -type byte      -desc CurrentMegaROMPage        -format dec
#ram_watch   add     0xc002      -type word      -desc CurrentAddrLineScroll     -format hex


ram_watch   add     0xF3E1      -type byte      -desc REG2SAV        -format hex
