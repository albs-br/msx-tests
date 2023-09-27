1    COLOR 15, 1, 7 : SCREEN 0 : WIDTH 40 : KEYOFF : DEFINT A-Z

10   ' instructions
11 	 DIM I$(10) : FOR I = 0 TO 10 : READ I$(I) : NEXT I
12   DATA "nop", "ld", "add", "adc", "sub", "sbc", "and", "or", "xor", "cp"
13   DATA "ldir"

80    ' test lines
81   DATA "  LD a, 5", "ldir", "loop:", "  Loop1:  ", "ld (ix - 1),a", "LD HL,0xAbcd"
82   DATA "MULT A,B", " 10:", "8: add h", "l1: add 10", "L7: EITA", ":"

90   LOCATE 0, 0 : PRINT   "INPUT         CMD  LBL    PAR 1   PAR 2 "
95   LOCATE 0, 1 : PRINT   "------------- ---- ------ ------- ------"
100  FOR J = 0 TO 11 'number of test lines
120    READ A$
150    S = 0 ' state machine: 0=space; 1=text (label/command); 2=number; 3=parameter 1; 4=parameter 2
170    TE$ = "" ' current text
180    CM$ = "" ' command
190    LB$ = "" ' label
210    P1$ = "" ' parameter 1
215    P2$ = "" ' parameter 2
220    ER$ = "" ' error description
250    FOR I = 1 TO LEN(A$)
275      IF ER$ <> "" GOTO 550 ' if error end loop
300	     C$ = MID$(A$, I, 1) ' Current char
350      D = ASC(C$) ' ASCII code of current char
360      T = (D >= 65 AND D <= 90) OR (D >= 97 AND D <= 122) ' IsChar
370      N = (D >= 48 AND D <= 57) ' IsNumber
400      IF S = 0 THEN GOSUB 1000     ELSE IF S = 1 THEN GOSUB 2000     ELSE IF S = 2 THEN GOSUB 3000     ELSE IF S = 3 THEN GOSUB 4000     ELSE IF S = 4 THEN GOSUB 5000
450      'PRINT C$, S 'debug
490    NEXT I

500    GOSUB 10000
502    'GOSUB 20000
504    ZZ$ = P1$ : GOSUB 60000 : P1$ = ZZ$ ' ToLowerCase(P1$)
505    ZZ$ = P2$ : GOSUB 60000 : P2$ = ZZ$ ' ToLowerCase(P2$)

508	   IF ER$ <> "" THEN 550

509    ' print valid line
510    LOCATE 0, J+2 : PRINT A$ : LOCATE 14, J+2 : PRINT CM$ : LOCATE 19, J+2 : PRINT LB$
514    LOCATE 26, J+2 : PRINT P1$ : LOCATE 34, J+2 : PRINT P2$
515    GOTO 890 ' end loop

550	   ' print error description
560    LOCATE 0, J+2 : PRINT A$ : LOCATE 14, J+2 : PRINT ER$

890  NEXT J
900  END

1000 ' state machine = 0 (space)
1005 IF LB$ <> "" AND C$ <> " " THEN ER$ = "Not allowed after label" : RETURN
1010 IF C$ = " " THEN RETURN
1015 IF N AND TE$ = "" THEN ER$ = "Line cant start by number" : RETURN
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

4000 ' state machine = 3 (parameter 1)
4005 IF C$ = "," THEN S = 4 : RETURN
4010 IF C$ <> " " THEN P1$ = P1$ + C$ : RETURN
4900 RETURN

5000 ' state machine = 4 (parameter 2)
5010 IF C$ <> " " THEN P2$ = P2$ + C$ : RETURN
5900 RETURN

10000 ' check if text is a command
10002 IF CM$ <> "" THEN TE$ = "" : RETURN ' only one command per line allowed
10003 IF ER$ <> "" THEN RETURN
10004 IF LB$ <> "" THEN RETURN

10005 ZZ$ = TE$ : GOSUB 60000 : TE$ = ZZ$ ' ToLowerCase(TE$)

10010 ' check if is a valid command
10015 ZF = 0 ' instruction not found
10020 FOR ZI = 0 TO 10
10025   IF TE$ = I$(ZI) THEN ZF = 1 ' instruction found
10030 NEXT ZI
10035 IF ZF = 0 THEN ER$ = "Invalid instruction" : RETURN
10040 CM$ = TE$ : TE$ = ""
10050 S = 3
10900 RETURN

20000 '' check if line is valid
20001 'IF CM$ <> "" AND LB$ <> "" THEN ER$ = "Command not allowed after label" : RETURN
20900 'RETURN 


60000 ' ToLowerCase()
60010 ' Input/Output: ZZ$
60015 IF ZZ$ = "" THEN RETURN
60020 FOR ZI = 1 TO LEN(ZZ$)
60022   ZC = ASC(MID$(ZZ$, ZI, 1))
60025   IF (ZC >= 65 AND ZC <= 90) THEN MID$(ZZ$, ZI) = CHR$(ZC + 32)
60030 NEXT ZI
60040 RETURN