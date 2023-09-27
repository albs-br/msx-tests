1    COLOR 15, 1, 7 : SCREEN 0 : WIDTH 80 : KEYOFF : DEFINT A-Z

10   ' allowed instructions
11 	 DIM I$(10) : FOR I = 0 TO 10 : READ I$(I) : NEXT I
12   DATA "nop", "ld", "add", "adc", "sub", "sbc", "and", "or", "xor", "cp"
13   DATA "ldir"

80   ' test lines / expected results
81   DATA "  LD a, 5",     "3E 05"
82   DATA "ldir",          "ED B0"
83   DATA "loop:",         "TODO: test labels"
84   DATA "  Loop1:  ",    "TODO: test labels"
85   DATA "ld (ix - 1),a", "DD 77 FF"
86   DATA "LD HL,0xAbcd",  "21 CD AB"
87   DATA "MULT A,B",      "Invalid instruction"
88   DATA " 10:",          "Line cant start by number"
89   DATA "8: add h",      "Line cant start by number"
90   DATA "l1: add 10",    "Not allowed after label"
91   DATA "L7: EITA",      "Not allowed after label"
92   DATA ":",             "Invalid instruction"
93   DATA "ADD 120",       "C6 78"
94   DATA "ADD 0xa",       "C6 A"
95   DATA " add 0x1",      "C6 1"
96   DATA "add 0x1f",      "C6 1F"
97   DATA "add 0x0Z",      "Parameter invalid"
98   DATA " adD A",        "87"
99   DATA "add    d",      "82"
100  DATA "add (hl)",      "86"
101  DATA "NOP",           "00"
102  DATA "XOR 7",         "EE 7"
103  DATA "XOR H",         "AC"
104  DATA " xor 0x10",     "EE 10"
105  DATA "XOR  (HL)",     "AE"
106  DATA "add 0x1234",    ""

110  GOSUB 50000 : ' print header

115  FOR K = 0 TO 25 'number of test lines
117    IF K=21 THEN LOCATE 0, 23 : INPUT "Press enter to continue";A : CLS : GOSUB 50000 ' J = variable for LOCATE of PRINTS
118    IF K>20 THEN J = K-21 ELSE J = K 

120    READ A$ : READ RE$ ' read test line / expected result

150    S = 0 ' state machine: 0=space; 1=text (label/command); 2=number; 3=parameter 1; 4=parameter 2
170    TE$ = "" ' current text
180    CM$ = "" ' command
190    LB$ = "" ' label
210    P1$ = "" ' parameter 1

211    T1 = 0 ' parameter 1 IsText 
212    N1 = 0 ' parameter 1 IsNumber
213    H1 = 0 ' parameter 1 IsHexadecimalNumber
 
215    P2$ = "" ' parameter 2
217    OU$ = "" ' output
220    ER$ = "" ' error description
250    FOR I = 1 TO LEN(A$)
275      IF ER$ <> "" GOTO 550 ' if error end loop



300	     C$ = MID$(A$, I, 1) ' Current char
350      D = ASC(C$) ' ASCII code of current char
360      T = (D >= 65 AND D <= 90) OR (D >= 97 AND D <= 122) ' IsChar
370      N = (D >= 48 AND D <= 57) ' IsDecimalChar
380      H = N OR ((D >= 97 AND D <= 102) OR (D >= 65 AND D <= 70)) ' IsHexadecimalChar
400      IF S = 0 THEN GOSUB 1000     ELSE IF S = 1 THEN GOSUB 2000     ELSE IF S = 2 THEN GOSUB 3000     ELSE IF S = 3 THEN GOSUB 4000     ELSE IF S = 4 THEN GOSUB 5000
450      'PRINT C$, S 'debug
490    NEXT I

500    GOSUB 10000
502    'GOSUB 20000
504    ZZ$ = P1$ : GOSUB 60000 : P1$ = ZZ$ ' ToLowerCase(P1$)
505    ZZ$ = P2$ : GOSUB 60000 : P2$ = ZZ$ ' ToLowerCase(P2$)

508	   IF ER$ <> "" THEN 550

520    GOSUB 30000 ' decode instructions

530    IF ER$ <> "" THEN 550

539    ' print valid line
540    LOCATE 0, J+2 : PRINT A$ : LOCATE 14, J+2 : PRINT CM$ : LOCATE 19, J+2 : PRINT LB$
544    LOCATE 26, J+2 : PRINT P1$ : LOCATE 34, J+2 : PRINT P2$ : LOCATE 41, J+2 : PRINT OU$
545    LOCATE 53, J+2 : IF OU$ = RE$ THEN PRINT "OK" ELSE PRINT "-" ' print test passed/failed
546    GOTO 800 ' next loop iteration

550	   ' print error description
560    LOCATE 0, J+2 : PRINT A$ : LOCATE 14, J+2 : PRINT ER$
570    LOCATE 53, J+2 : IF ER$ = RE$ THEN PRINT "OK" ELSE PRINT "-" ' print test passed/failed

800    ' next loop iteration
890  NEXT K
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
4007 IF H1 AND H THEN P1$ = P1$ + C$ : RETURN ' deal with parameter as hexadecimal number
4008 IF H1 AND NOT H THEN ER$ = "Parameter invalid" : RETURN ' error with parameter as hexadecimal number 
4010 IF N AND N1 = 0 AND T1 = 0 THEN N1 = -1 : P1$ = P1$ + C$ : RETURN ' parameter started by number
4020 IF T AND N1 = 0 AND T1 = 0 THEN T1 = -1 : P1$ = P1$ + C$ : RETURN ' parameter started by text
4030 IF N1 AND P1$ = "0" AND C$ = "x" THEN H1 = -1 : N1 = 0 : P1$ = P1$ + "x" : RETURN ' set parameter as hexadecimal number
4040 IF N1 AND N THEN P1$ = P1$ + C$ : RETURN ' decimal number
4100 IF C$ <> " " THEN P1$ = P1$ + C$ : RETURN
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
10025   IF TE$ = I$(ZI) THEN ZF = -1 ' instruction found
10030 NEXT ZI
10035 IF ZF = 0 THEN ER$ = "Invalid instruction" : RETURN
10040 CM$ = TE$ : TE$ = ""
10050 S = 3
10900 RETURN

20000 '' check if line is valid
20001 'IF CM$ <> "" AND LB$ <> "" THEN ER$ = "Command not allowed after label" : RETURN
20900 'RETURN 



30000 ' decode instructions
30110 IF CM$ <> "" AND P1$ = "" AND P2$ = "" THEN 31000 ' decode instructions without parameters
30120 IF CM$ <> "" AND P1$ <> "" AND P2$ = "" THEN 32000 ' decode instructions with 1 parameter
30900 RETURN

31000 ' decode instructions without parameters
31010 IF CM$ = "nop"  THEN OU$ = "00" : RETURN
31020 IF CM$ = "ldir" THEN OU$ = "ED B0" : RETURN
31900 RETURN

32000 ' decode instructions with 1 parameter
32005 IF T1 THEN ZZ$ = P1$ : GOSUB 40000 : R1 = ZO ' convert 8-bit register to value
32007 IF H1 THEN O1$ = HEX$(VAL("&H" + RIGHT$(P1$, LEN(P1$)-2))) ' hexadecimal value
32008 IF N1 THEN O1$ = HEX$(VAL(P1$))                   ' decimal value

32100 IF CM$ = "add" THEN 32110 ELSE 32200
32110 IF P1$ = "(hl)" THEN OU$ = "86" : RETURN            ' add (hl)
32120 IF N1 OR H1     THEN OU$ = "C6 " + O1$ : RETURN     ' add n
32130 IF T1           THEN OU$ = HEX$(&h80 + R1) : RETURN ' add r
32190 RETURN

32200 IF CM$ = "xor" THEN 32210 ELSE 32300
32210 IF P1$ = "(hl)" THEN OU$ = "AE" : RETURN            ' xor (hl)
32220 IF N1 OR H1     THEN OU$ = "EE " + O1$ : RETURN     ' xor n
32230 IF T1           THEN OU$ = HEX$(&hA8 + R1) : RETURN ' xor r
32290 RETURN

32300 'TODO: next instruction

32900 RETURN


39000 ' ---------- FUNCTIONS ---------
39001 ' function variables always started by Z (DO NOT use such variables outside of functions)



40000 ' convert 8-bit register to value
40010 ' Input: ZZ$, Output: ZO
40020 IF ZZ$ = "a" THEN ZO = 7 : RETURN
40030 IF ZZ$ = "b" THEN ZO = 0 : RETURN
40040 IF ZZ$ = "c" THEN ZO = 1 : RETURN
40050 IF ZZ$ = "d" THEN ZO = 2 : RETURN
40060 IF ZZ$ = "e" THEN ZO = 3 : RETURN
40070 IF ZZ$ = "h" THEN ZO = 4 : RETURN
40080 IF ZZ$ = "l" THEN ZO = 5 : RETURN
40900 RETURN


50000 ' print header
50010 LOCATE 0, 0 : PRINT   "INPUT         CMD  LBL    PAR 1   PAR 2  OUTPUT      PASSED"
50020 LOCATE 0, 1 : PRINT   "------------- ---- ------ ------- ------ ----------- ------"
50900 RETURN


60000 ' ToLowerCase()
60010 ' Input/Output: ZZ$
60015 IF ZZ$ = "" THEN RETURN
60020 FOR ZI = 1 TO LEN(ZZ$)
60022   ZC = ASC(MID$(ZZ$, ZI, 1))
60025   IF (ZC >= 65 AND ZC <= 90) THEN MID$(ZZ$, ZI) = CHR$(ZC + 32)
60030 NEXT ZI
60040 RETURN