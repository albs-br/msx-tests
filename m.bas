10 defint a-z
15 screen 2, 2, 0 : color 15, 1, 7
20 's$=""
30 'FOR I=0 TO 7: READ A: s$=s$+CHR$(A): NEXT I
40 'SPRITE$(0)=s$ 
80 'DATA 24,60,126,255,36,36,66,129 

81 ' P: player current sprite pattern
82 ' Z: flag to skip frame animation 
83 ' D: direction (0: right, 8: left)
84 ' C: walk cycle counter
85 ' V, W: (X, Y) of player center (aux var to make collision check faster)
86 ' J: jump control var (-1: not jumping)
87 ' B(J): array of delta Ys to jump

98  p=0 : z=0 : D = 0
100 x=128-8 : y=192-32 : V = X+8 : W = Y+8
101 's$ = "b..b.....b..bb.b"
102 'for i=1 to 16
106 '  if MID$(s$, i, 1) = "b" then line ((i-1)*16, 192-32)-((i-1)*16+15, 192-32+15), 15, BF
108 'next i
110 ON STRIG GOSUB 800 : STRIG(0) ON 
115 J = -1
116 DIM B(29) : FOR I=0 TO 28 : READ A : B(I)=A : NEXT I
117 DATA -6, -5, -5, -5, -4, -4, -3, -3, -2, -2, -2, -1, -1, -1, 0, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 5, 6

150 GOSUB 30000

180 'ON SPRITE GOSUB 1200
190 GOSUB 1200

500 IF J<>-1 THEN gosub 1000
505 A = STICK(0)
507 IF A=0 GOTO 900
510 ON A GOSUB 690, 600, 600, 600, 690, 700, 700, 700

530 PUT SPRITE 0, (x, y), 6, P
540 PUT SPRITE 1, (x, y), 11, P+1
542 if V >= R and V < G and W >= k and W < H then gosub 1200
550 goto 500

599 ' move right
600 d=0 : if x<=236 then x=x+3 : V = X+8
611 IF J <> -1 THEN P = 0 : RETURN
622 IF Z = 0 THEN Z = 1 : RETURN
645 Z = 0 : c=c+2 : if c=8 then c=2
667 P = c
690 RETURN

699 ' move left
700 d=8 : if x>=3 then x=x-3 : V = X+8
722 IF J <> -1 THEN P = 8 : RETURN
745 IF Z = 0 THEN Z = 1 : RETURN
767 Z = 0 : c=c+2 : if c=8 then c=2
778 P = c + 8
790 RETURN

799 ' spacebar pressed
800 IF J=-1 THEN J=0
810 RETURN

899 ' no arrow pressed
900 P=D
910 GOTO 530

999 ' jump logic
1000 Y = Y + B(J) : W = Y+8
1010 IF J=28 THEN 1100
1020 J=J+1
1030 RETURN

1099 ' end jump
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

9001 ' --- Slot 0
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
9110 ' 
9120 ' --- Slot 1
9130 ' color 6
9140 DATA &H07,&H0F,&H0E,&H14,&H16,&H18,&H00,&H3F
9150 DATA &H3F,&H0E,&H0F,&H1F,&H3F,&H7C,&H70,&H38
9160 DATA &HC0,&HF8,&H40,&H40,&H20,&H78,&H00,&HC0
9170 DATA &HF0,&HF8,&HE4,&HFC,&HFC,&H7C,&H00,&H00
9180 ' color 11
9190 DATA &H00,&H00,&H01,&H0B,&H09,&H07,&H07,&H00
9200 DATA &HC0,&HE1,&HC0,&H00,&H00,&H00,&H00,&H00
9210 DATA &H00,&H00,&HA0,&HB8,&HDC,&H80,&HF0,&H00
9220 DATA &H0E,&H06,&H00,&H00,&H00,&H00,&H00,&H00
9230 ' 
9240 ' --- Slot 2
9250 ' color 6
9260 DATA &H07,&H0F,&H0E,&H14,&H16,&H18,&H00,&H0F
9270 DATA &H1F,&H1F,&H1F,&H1C,&H0C,&H07,&H07,&H07
9280 DATA &HC0,&HF8,&H40,&H40,&H20,&H78,&H00,&HC0
9290 DATA &HE0,&H60,&HF0,&H70,&HE0,&HE0,&HF0,&H80
9300 ' color 11
9310 DATA &H00,&H00,&H01,&H0B,&H09,&H07,&H07,&H00
9320 DATA &H00,&H00,&H00,&H03,&H03,&H00,&H00,&H00
9330 DATA &H00,&H00,&HA0,&HB8,&HDC,&H80,&HF0,&H00
9340 DATA &H00,&H90,&H00,&H80,&H00,&H00,&H00,&H00
9350 ' 
9360 ' --- Slot 3
9370 ' color 6
9380 DATA &H00,&H03,&H07,&H07,&H0A,&H0B,&H0C,&H00
9390 DATA &H07,&H07,&H07,&H1F,&H1F,&H3E,&H21,&H01
9400 DATA &H00,&HE0,&HFC,&H20,&H20,&H10,&H3C,&H00
9410 DATA &HE0,&HE0,&HE0,&HF0,&HF0,&HE0,&HC0,&HE0
9420 ' color 11
9430 DATA &H00,&H00,&H00,&H00,&H05,&H04,&H03,&H03
9440 DATA &H00,&H08,&H18,&H00,&H00,&H00,&H00,&H00
9450 DATA &H00,&H00,&H00,&HD0,&HDC,&HEE,&HC0,&HF8
9460 DATA &H08,&H1C,&H18,&H00,&H00,&H00,&H00,&H00

9500 ' --- Slot 0
9510 ' color 6
9520 DATA &H03,&H1F,&H02,&H02,&H04,&H1E,&H00,&H03
9530 DATA &H1F,&H3F,&H0D,&H07,&H0F,&H0E,&H1C,&H3C
9540 DATA &HE0,&HF0,&H70,&H28,&H68,&H18,&H00,&HF0
9550 DATA &HF8,&HFC,&HB0,&HE0,&HF0,&H70,&H38,&H3C
9560 ' color 11
9570 DATA &H00,&H00,&H05,&H1D,&H3B,&H01,&H0F,&H00
9580 DATA &H00,&H00,&H32,&H38,&H30,&H00,&H00,&H00
9590 DATA &H00,&H00,&H80,&HD0,&H90,&HE0,&HE0,&H00
9600 DATA &H00,&H00,&H4C,&H1C,&H0C,&H00,&H00,&H00
9610 ' 
9620 ' --- Slot 1
9630 ' color 6
9640 DATA &H03,&H1F,&H02,&H02,&H04,&H1E,&H00,&H03
9650 DATA &H0F,&H1F,&H27,&H3F,&H3F,&H3E,&H00,&H00
9660 DATA &HE0,&HF0,&H70,&H28,&H68,&H18,&H00,&HFC
9670 DATA &HFC,&H70,&HF0,&HF8,&HFC,&H3E,&H0E,&H1C
9680 ' color 11
9690 DATA &H00,&H00,&H05,&H1D,&H3B,&H01,&H0F,&H00
9700 DATA &H70,&H60,&H00,&H00,&H00,&H00,&H00,&H00
9710 DATA &H00,&H00,&H80,&HD0,&H90,&HE0,&HE0,&H00
9720 DATA &H03,&H87,&H03,&H00,&H00,&H00,&H00,&H00
9730 ' 
9740 ' --- Slot 2
9750 ' color 6
9760 DATA &H03,&H1F,&H02,&H02,&H04,&H1E,&H00,&H03
9770 DATA &H07,&H06,&H0F,&H0E,&H07,&H07,&H0F,&H01
9780 DATA &HE0,&HF0,&H70,&H28,&H68,&H18,&H00,&HF0
9790 DATA &HF8,&HF8,&HF8,&H38,&H30,&HE0,&HE0,&HE0
9800 ' color 11
9810 DATA &H00,&H00,&H05,&H1D,&H3B,&H01,&H0F,&H00
9820 DATA &H00,&H09,&H00,&H01,&H00,&H00,&H00,&H00
9830 DATA &H00,&H00,&H80,&HD0,&H90,&HE0,&HE0,&H00
9840 DATA &H00,&H00,&H00,&HC0,&HC0,&H00,&H00,&H00
9850 ' 
9860 ' --- Slot 3
9870 ' color 6
9880 DATA &H00,&H07,&H3F,&H04,&H04,&H08,&H3C,&H00
9890 DATA &H07,&H07,&H07,&H0F,&H0F,&H07,&H03,&H07
9900 DATA &H00,&HC0,&HE0,&HE0,&H50,&HD0,&H30,&H00
9910 DATA &HE0,&HE0,&HE0,&HF8,&HF8,&H7C,&H84,&H80
9920 ' color 11
9930 DATA &H00,&H00,&H00,&H0B,&H3B,&H77,&H03,&H1F
9940 DATA &H10,&H38,&H18,&H00,&H00,&H00,&H00,&H00
9950 DATA &H00,&H00,&H00,&H00,&HA0,&H20,&HC0,&HC0
9960 DATA &H00,&H10,&H18,&H00,&H00,&H00,&H00,&H00
9970 DATA *

30000 ' -- LOAD SPRITES
30010 S=BASE(9)
30020 READ R$: IF R$="*" THEN RETURN ELSE VPOKE S,VAL(R$):S=S+1:GOTO 30020
