10 defint a-z
15 screen 1, 2, 0 : color 15, 1, 7
20 's$=""
30 'FOR I=0 TO 7: READ A: s$=s$+CHR$(A): NEXT I
40 'SPRITE$(0)=s$ 
80 'DATA 24,60,126,255,36,36,66,129 

100 x=128-8 : y=192-32 : V = X+8 : W = Y+8
101 's$ = "b..b.....b..bb.b"
102 'for i=1 to 16
106 '  if MID$(s$, i, 1) = "b" then line ((i-1)*16, 192-32)-((i-1)*16+15, 192-32+15), 15, BF
108 'next i
110 ON STRIG GOSUB 800 : STRIG(0) ON 
115 J = -1
116 DIM B(37) : FOR I=0 TO 36 : READ A : B(I)=A : NEXT I
117 DATA -5, -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5

150 GOSUB 10000

180 'ON SPRITE GOSUB 1200
190 GOSUB 1200

500 IF J<>-1 THEN gosub 1000
510 ON STICK(0) GOSUB 690, 600, 600, 600, 690, 700, 700, 700

530 PUT SPRITE 0, (x, y), 6, 0
540 PUT SPRITE 1, (x, y), 11, 1
542 if V >= R and V < G and W >= k and W < H then gosub 1200
550 goto 500

599' if MID$(s$, (x+17)/16+1, 1) = "." then x=x+2
600 if x<=236 then x=x+2 : V = X+8
690 RETURN

699' if MID$(s$, (x-2)/16+1, 1) = "." then x=x-2
700 if x>=2 then x=x-2 : V = X+8
790 RETURN

800 IF J=-1 THEN J=0
810 RETURN

1000 Y = Y + B(J) : W = Y+8
1010 IF J=36 THEN 1100
1020 J=J+1
1030 RETURN

1100 J=-1
1110 RETURN

1200 BEEP : R=RND(-TIME) : R=INT(RND(1)*14)+1 : K = INT((RND(1)*4)) + 7
1205 'PRINT R, K
1207 'print x, y
1208 R = R * 16 : K = K * 16
1209 G = R + 16 : H = K + 16
1210 PUT SPRITE 2, (R, K), 10, 0
1215 'SPRITE ON
1217 'goto 1217
1220 RETURN

9000 ' --- Sprites data and load routine
9010 ' color 6
9020 DATA &H07,&H0F,&H0E,&H14,&H16,&H18,&H00,&H0F
9030 DATA &H1F,&H3F,&H0D,&H07,&H0F,&H0E,&H1C,&H3C
9040 DATA &HC0,&HF8,&H40,&H40,&H20,&H78,&H00,&HC0
9050 DATA &HF8,&HFC,&HB0,&HE0,&HF0,&H70,&H38,&H3C
9060 ' color 11
9070 DATA &H00,&H00,&H01,&H0B,&H09,&H07,&H07,&H00
9080 DATA &H00,&H00,&H32,&H38,&H30,&H00,&H00,&H00
9090 DATA &H00,&H00,&HA0,&HB8,&HDC,&H80,&HF0,&H00
9100 DATA &H00,&H00,&H4C,&H1C,&H0C,&H00,&H00,&H00
9110 DATA *
10000 REM -- LOAD SPRITES
10010 S=BASE(9)
10020 READ R$: IF R$="*" THEN RETURN ELSE VPOKE S,VAL(R$):S=S+1:GOTO 10020
