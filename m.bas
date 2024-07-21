10 defint a-z
15 screen 2,1,0 : color 15, 1, 7
20 s$=""
30 FOR I=0 TO 7: READ A: s$=s$+CHR$(A): NEXT I
40 SPRITE$(0)=s$
80 DATA 24,60,126,255,36,36,66,129 ' sprite pattern
100 x=128-8 : y=191-32
101 's$ = "b..b.....b..bb.b"
102 'for i=1 to 16
106 '  if MID$(s$, i, 1) = "b" then line ((i-1)*16, 192-32)-((i-1)*16+15, 192-32+15), 15, BF
108 'next i
110 ON STRIG GOSUB 800 : STRIG(0) ON 
115 J = -1
116 DIM B(37) : FOR I=0 TO 36 : READ A : B(I)=A : NEXT I
117 DATA -5, -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5 ' jump Y offsets

500 IF J<>-1 THEN gosub 1000
510 a=STICK(0)
520 if a=3 then gosub 600 else if a=7 then gosub 700

530 PUT SPRITE 0, (x, y), 15, 0
540 PUT SPRITE 1, (x+1, y+1), 10, 0
550 goto 500

599' if MID$(s$, (x+17)/16+1, 1) = "." then x=x+2
600 if x<=236 then x=x+2
620 RETURN

699' if MID$(s$, (x-2)/16+1, 1) = "." then x=x-2
700 if x>=2 then x=x-2
720 RETURN

800 IF J=-1 THEN J=0
810 RETURN

1000 Y = Y + B(J)
1010 IF J=36 THEN 1100
1020 J=J+1
1030 RETURN

1100 J=-1
1110 RETURN