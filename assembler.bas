1    SCREEN 0 : WIDTH 40 : KEYOFF : DEFINT A-Z : DIM B$(5)
2    B$(0) = "  LD a, 5" ' test lines
3    B$(1) = "ldir"
4    B$(2) = "loop:"
5    B$(3) = "  loop1:  "
6    B$(4) = "ld (ix - 1),a"
7    B$(5) = "LD HL,0xAbcd" 
8    PRINT   "              CMD  LBL    PAR"
10   FOR J = 0 TO 5
12     A$ = B$(J)
13     D$ = A$ ' debug string
15     S = 0 'state machine; 0 = space; 1=text (label/command); 2=number; 3=parameters
17     TE$ = "" ' current text
18     CM$ = "" ' command
19     LB$ = "" ' label
21     PA$ = "" ' parameters
25     FOR I = 1 TO LEN(A$)
30 	     C$ = MID$(A$, I, 1) ' Current char
35       D = ASC(C$) ' ASCII code of current char
36       T = (D >= 65 AND D <= 90) OR (D >= 97 AND D <= 122) ' IsChar
37       N = (D >= 48 AND D <= 57) ' IsNumber
40       IF S = 0 THEN GOSUB 1000     ELSE IF S = 1 THEN GOSUB 2000     ELSE IF S = 2 THEN GOSUB 3000     ELSE IF S = 3 THEN GOSUB 4000
95       'PRINT C$, S
100    NEXT I
102    GOSUB 10000
103    LOCATE 0, J+1 : PRINT D$ : LOCATE 14, J+1 : PRINT CM$ : LOCATE 19, J+1 : PRINT LB$
104    LOCATE 26, J+1 : PRINT PA$
105    'PRINT "CMD: " + CM$
107    'PRINT "LBL: " + LB$
108    'PRINT "TXT: " + TE$
109  NEXT J
110  END

1000 ' state machine = 0 (space)
1010 IF C$ = " " THEN RETURN
1020 IF T THEN S = 1 : TE$ = C$ : RETURN
1030 IF N THEN S = 2 : RETURN
1900 RETURN

2000 ' state machine = 1 (text)
2010 IF C$ = " " THEN S = 0 : GOSUB 10000 : RETURN ' check if text is a command
2015 IF C$ = ":" THEN S = 0 : LB$ = TE$ : TE$ = "" : RETURN ' text is label
2020 IF T THEN TE$ = TE$ + C$ : RETURN
2030 IF N THEN TE$ = TE$ + C$ : RETURN
2900 RETURN

3000 ' state machine = 2 (number)
3010 IF C$ = " " THEN S = 0 : RETURN
3020 IF T THEN S = 1 : RETURN
3030 IF N THEN RETURN
3900 RETURN

4000 ' state machine = 3 (parameters)
4010 IF C$ <> " " THEN PA$ = PA$ + C$ : RETURN
4900 RETURN

10000 ' check if text is a command
10005 IF CM$ <> "" THEN TE$ = "" : RETURN
10007 ' TODO: check if is a valid command
10010 CM$ = TE$ : TE$ = ""
10050 S = 3
10900 RETURN
