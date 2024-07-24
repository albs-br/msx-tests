10 defint a-z
15 color 15, 1, 4 : screen 2, 2, 0

81 ' P: player current sprite pattern
82 ' Z: flag to skip frame animation 
83 ' D: direction (0: right, 8: left)
84 ' C: walking cycle counter
85 ' V, W: (X, Y) of player center (aux var to make collision check faster)
86 ' J: jump control var (-1: not jumping)
87 ' B(J): array of delta Ys to jump
88 ' E: flag for coin color control
90 ' F: border color

98  p=0 : z=0 : D = 0 : f = 1
100 x=128-8 : y=192-32-1 : V = X+8 : W = Y+8
110 ON STRIG GOSUB 800 : STRIG(0) ON 
115 J = -1
116 DIM B(27) : FOR I=0 TO 26 : READ A : B(I)=A : NEXT I
117 DATA -6, -6, -5, -5, -5, -4, -4, -3, -3, -2, -2, -1, -1, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 5, 6, 6

140 GOSUB 60000
150 GOSUB 30000
160 GOSUB 40000
170 GOSUB 50000


190 GOSUB 1200

200 ON INTERVAL=20 GOSUB 1500 : INTERVAL ON

499 ' --- main game loop
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
1010 IF J=26 THEN 1100
1020 J=J+1
1030 RETURN

1099 ' end jump
1100 J=-1
1110 RETURN

1199 ' place new coin in screen
1200 BEEP : R=RND(-TIME) : R=INT(RND(1)*14)+1 : K = INT((RND(1)*4)) + 7
1205 'PRINT R, K
1207 'print x, y
1208 R = R * 16 : K = (K * 16) - 1
1209 G = R + 16 : H = K + 16
1210 PUT SPRITE 2, (R, K), 1, 16
1220 PUT SPRITE 3, (R, K), 10, 17
1255 if F=1 THEN F=4 : color 2, 2, F : RETURN
1272 if F=4 THEN F=7 : color 2, 2, F : RETURN
1285 if F=7 THEN F=1 : color 2, 2, F : RETURN
1290 RETURN

1499 ' change coin color
1500 if e=0	then VPOKE 6927, 10 : e=1 : RETURN
1510 VPOKE 6927, 6 : e=0 : return

8000 ' -------------- NAMTBL





8002 data 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 5, 2, 2, 5, 5, 5, 5, 2, 5, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2 
8003 data 2, 2, 2, 2, 2, 2, 2, 5, 5, 2, 5, 5, 2, 5, 2, 2, 2, 2, 2, 5, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2 
8004 data 2, 2, 2, 2, 2, 2, 2, 4, 2, 4, 2, 4, 2, 4, 2, 2, 2, 2, 2, 2, 4, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2 
8005 data 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 4, 2, 2, 4, 4, 4, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
8006 data 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 3, 2, 2, 4, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2 
8007 data 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 3, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2 
8008 data 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 3, 3, 3, 3, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2 
8009 data 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 



8060 data 2, 5, 5, 5, 5, 2, 2, 2, 5, 5, 5, 2, 2, 2, 5, 5, 5, 5, 2, 2, 5, 5, 5, 2, 2, 2, 5, 5, 5, 5, 2, 2
8070 data 2, 2, 5, 2, 2, 5, 2, 5, 2, 2, 2, 5, 2, 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2 
8080 data 2, 2, 4, 2, 2, 4, 2, 4, 2, 2, 2, 4, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2 
8090 data 2, 2, 4, 4, 4, 2, 2, 4, 4, 4, 4, 4, 2, 2, 4, 4, 4, 2, 2, 2, 2, 4, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2 
8100 data 2, 2, 3, 2, 2, 3, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2 
8110 data 2, 2, 3, 2, 2, 3, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2 
8120 data 2, 3, 3, 3, 3, 2, 2, 3, 2, 2, 2, 3, 2, 3, 3, 3, 3, 2, 2, 2, 3, 3, 3, 2, 2, 2, 3, 3, 3, 3, 2, 2 
8125 data 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 



8150 data 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 5, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
8160 data 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 5, 4, 5, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
8170 data 5, 2, 2, 2, 2, 2, 2, 2, 2, 5, 4, 3, 4, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
8180 data 4, 5, 2, 2, 2, 2, 2, 2, 2, 2, 5, 3, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2
8190 data 3, 4, 5, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 4, 5, 2, 2, 2, 2
8200 data 3, 4, 5, 2, 5, 2, 5, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 5, 2, 5, 4, 3, 4, 5, 2, 5, 5
8210 data 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
8220 DATA 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

8990 DATA -1

9001 ' --- player standing facing right
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
9120 ' --- player walking cycle 1 right
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
9240 ' --- player walking cycle 2 right
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
9360 ' --- player walking cycle 3 right
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

9500 ' --- player standing facing left
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
9620 ' --- player walking cycle 1 left
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
9740 ' --- player walking cycle 2 left
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
9860 ' --- player walking cycle 3 left
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

10000 ' --- Coin (pattern # 16)
10010 ' color 1
10020 DATA &H00,&H00,&H00,&H00,&H03,&H04,&H04,&H04
10030 DATA &H04,&H04,&H04,&H04,&H04,&H03,&H00,&H00
10040 DATA &H00,&H00,&H60,&H30,&H30,&H98,&H98,&H98
10050 DATA &H98,&H98,&H98,&H98,&H98,&H30,&H30,&H60
10060 ' color 10
10070 DATA &H00,&H00,&H07,&H0F,&H0C,&H1B,&H1B,&H1B
10080 DATA &H1B,&H1B,&H1B,&H1B,&H1B,&H0C,&H0F,&H07
10090 DATA &H00,&H00,&H80,&HC0,&HC0,&H60,&H60,&H60
10100 DATA &H60,&H60,&H60,&H60,&H60,&HC0,&HC0,&H80

11900 DATA *

12000 ' -------------- Tile patterns
12010 '--- bricks
12020 DATA &B11111111
12030 DATA &B11111110
12040 DATA &B11111110
12050 DATA &B00000000
12060 DATA &B11101111
12070 DATA &B11101111
12080 DATA &B11101111
12090 DATA &B00000000

12120 DATA &B11111110
12130 DATA &B11111110
12140 DATA &B11111110
12150 DATA &B00000000
12160 DATA &B11101111
12170 DATA &B11101111
12180 DATA &B11101111
12190 DATA &B00000000

12200 ' --- tile empty
12205 DATA &B00000000
12210 DATA &B00000000
12220 DATA &B00000000
12230 DATA &B00000000
12240 DATA &B00000000
12250 DATA &B00000000
12260 DATA &B00000000
12270 DATA &B00000000

12300 ' --- tile full
12305 DATA &B11111111
12310 DATA &B11111111
12320 DATA &B11111111
12330 DATA &B11111111
12340 DATA &B11111111
12350 DATA &B11111111
12360 DATA &B11111111
12370 DATA &B11111111

12400 ' --- tile half full
12405 DATA &B10101010
12410 DATA &B01010101
12420 DATA &B10101010
12430 DATA &B01010101
12440 DATA &B10101010
12450 DATA &B01010101
12460 DATA &B10101010
12470 DATA &B01010101

12500 ' --- tile almost empty
12505 DATA &B10101010
12510 DATA &B00000000
12520 DATA &B10101010
12530 DATA &B00000000
12540 DATA &B10101010
12550 DATA &B00000000
12560 DATA &B10101010
12570 DATA &B00000000

12990 DATA *

16000 ' -------------- Tile colors
16010 '--- bricks
16020 DATA &HF1
16030 DATA &H61
16040 DATA &H61
16050 DATA &H61
16060 DATA &H61
16070 DATA &H61
16080 DATA &H61
16090 DATA &H61

16120 DATA &H61
16130 DATA &H61
16140 DATA &H61
16150 DATA &H61
16160 DATA &H61
16170 DATA &H61
16180 DATA &H61
16190 DATA &H61

16200 ' --- tile empty
16205 DATA &H00
16210 DATA &H00
16220 DATA &H00
16230 DATA &H00
16240 DATA &H00
16250 DATA &H00
16260 DATA &H00
16270 DATA &H00

16300 ' --- tile empty
16305 DATA &H50
16310 DATA &H50
16320 DATA &H50
16330 DATA &H50
16340 DATA &H50
16350 DATA &H50
16360 DATA &H50
16370 DATA &H50

16400 ' --- tile half full
16405 DATA &H50
16410 DATA &H50
16420 DATA &H50
16430 DATA &H50
16440 DATA &H50
16450 DATA &H50
16460 DATA &H50
16470 DATA &H50

16500 ' --- tile almost empty
16505 DATA &H50
16510 DATA &H50
16520 DATA &H50
16530 DATA &H50
16540 DATA &H50
16550 DATA &H50
16560 DATA &H50
16570 DATA &H50

16990 DATA *



30000 ' -- LOAD SPRPAT
30010 S=BASE(9)
30020 READ R$: IF R$="*" THEN RETURN ELSE VPOKE S,VAL(R$):S=S+1:GOTO 30020

40000 ' -- LOAD PATTBL
40010 S=BASE(12)
40020 READ R$: IF R$="*" THEN RETURN
40025 V = VAL(R$)
40030 VPOKE S, V
40035 VPOKE S + 2048, V
40037 VPOKE S + 4096, V
40040 S=S+1:GOTO 40020

50000 ' -- LOAD COLTBL
50010 S=BASE(11)
50020 READ R$: IF R$="*" THEN RETURN 
50025 V = VAL(R$)
50030 VPOKE S, V
50035 VPOKE S + 2048, V
50037 VPOKE S + 4096, V
50040 S=S+1:GOTO 50020

60000 ' --- reset NAMTBL
60025 S=BASE(10)
60050 for i = S to s + 768
60062   vpoke i, 2
60075 next i
60100 ' -- LOAD NAMTLB
60110 S=BASE(10)
60120 READ R: IF R=-1 THEN RETURN ELSE VPOKE S, R : S=S+1 : GOTO 60120