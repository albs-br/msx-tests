
1 '---- Simplest possible assembler in MSX-Basic


10 S$ = "daa" ' input line 
11 S$ = "nop"
15 S$ = "ld a,c"
17 S$ = "ld a,9"
20 S$ = "ld a,64"
21 S$ = "ld hl,8900"

100 L = 0 ' line counter



1000 S = len(s$)

1100 if S = 3 then gosub 3000
1110 if S = 4 then gosub 4000
1120 if S = 6 then gosub 6000
1130 if S = 7 then gosub 7000
1140 if S = 10 then gosub 10000

2000 print S$
2003 print "size: " + str$(O)
2007 print O1$ + " " + O2$
2010 end

3000 ' ---- instructions with length = 3
3010 if S$ = "nop" then A = 1 : O1$ = "00" : return
3020 'TODO
3990 goto 20000

6000 ' ---- instructions with length = 6
6005 if S$ = "ld a,b" then O = 1 : O1$ = "11" : return
6010 if S$ = "ld a,c" then O = 1 : O1$ = "12" : return
6020 if S$ = "ld a,d" then O = 1 : O1$ = "13" : return
6030 'TODO
6100 L5$ = left$(S$, 5)
6105 V = val(right$(S$, 1))
6110 if L5$ = "ld a," then O = 2 : O1$ = "20" : O2$ = hex$(V) : return
6990 goto 20000

7000 ' ---- instructions with length = 7
7010 L5$ = left$(S$, 5)
7020 V = val(right$(S$, 2))
7030 if L5$ = "ld a," then O = 2 : O1$ = "20" : O2$ = hex$(V) : return
7990 goto 20000

10000 ' ---- instructions with length = 10
10010 L6$ = left$(S$, 6)
10020 V = val(right$(S$, 4))
10030 if L6$ = "ld hl," then O = 3 : O1$ = "30" : O2$ = hex$(V) : O3$ = hex$(V) : return 'should reverse byte order of value (little endian)


20000 print "Error line " + str$(L) + ": " + s$