
#ram_watch   add     0xc000      -type byte      -desc debug_0     -format hex
#ram_watch   add     0xc001      -type byte      -desc debug_1     -format hex

#ram_watch   add     0xc001      -type byte      -desc CurrentMegaROMPage        -format dec
#ram_watch   add     0xc002      -type word      -desc CurrentAddrLineScroll     -format hex


#ram_watch   add     0xF3E1      -type byte      -desc REG2SAV        -format hex

#ram_watch   add     0xdf00      -type word      -desc RndNumbers      -format hex
#ram_watch   add     0xdf02      -type word      -desc RndNumbers      -format hex
#ram_watch   add     0xdf04      -type word      -desc RndNumbers      -format hex
#ram_watch   add     0xdf06      -type word      -desc RndNumbers      -format hex
#ram_watch   add     0xdf08      -type word      -desc RndNumbers      -format hex
#ram_watch   add     0xdf0a      -type word      -desc RndNumbers      -format hex
#ram_watch   add     0xdffe      -type word      -desc RndNumbers      -format hex

#RndNumbers: equ 0DF00h ; last def. pass 3


ram_watch   add     0xc000      -type byte      -desc ActivePage      -format dec

#ram_watch   add     0xc021      -type word      -desc Total_Frames      -format dec
#ram_watch   add     0xc015      -type word      -desc Animation_CurrentFrame_List      -format hex
#ram_watch   add     0xc023      -type byte      -desc Frame_Counter      -format dec
#ram_watch   add     0xc002      -type byte      -desc Step      -format dec

#ram_watch   add     0xc006      -type word      -desc HMMM.S_X      -format dec
#ram_watch   add     0xc008      -type word      -desc HMMM.S_Y      -format dec
#ram_watch   add     0xc00a      -type word      -desc HMMM.D_X      -format dec
#ram_watch   add     0xc00c      -type word      -desc HMMM.D_Y      -format dec
#ram_watch   add     0xc00e      -type word      -desc HMMM.Cols      -format dec
#ram_watch   add     0xc010      -type word      -desc HMMM.Lines     -format dec

#RestoreBG_HMMM_Command.Cols: equ 0C00Eh ; last def. pass 3
#RestoreBG_HMMM_Command.Source_X: equ 0C006h ; last def. pass 3


#Player_1_Vars.Animation_CurrentFrame_List: equ 0C015h ; last def. pass 3
