1 ' BASIC VDP command:
2 '0 to 7	Control registers 0 to 7	Read / Write	MSX1 and higher
3 '8		Status register 0			Read			MSX1 and higher
4 '9 to 24	Control registers 8 to 23	Read / Write	MSX2 and higher
5 '26 to 28	Control registers 25 to 27	Read / Write	MSX2+ and higher
6 '33 to 47	Control regs 32 to 46 (*)	Write			MSX2 and higher
7 '-1 to -9	Status registers 1 to 9		Read			MSX2 and higher
8 ' (*) for graphic commands
9 'Method for easier approach to HMMC (https://www.msx.org/forum/msx-talk/development/transferring-data-after-hmmc-lmmc-command)
10 SCREEN 0 : WIDTH 80 : PRINT : I = 65
20 'VDP(26) = VDP(26) OR 64 ' R#25, bit 6 (CMD) enables the VDP commands for screens 0 to 4 when 1
30 VDP(37) = 0 : VDP(38) = 0 : VDP(39) = 0 : VDP(40) = 0 ' R#36 to 39: Destination X (DX) (9 bits), DY (10 bits)
40 VDP(41) = 8 : VDP(42) = 0 : VDP(43) = 1 : VDP(44) = 0 ' R#40 to 43: Width (9 bits), Height (10 bits)
50 VDP(45) = 255  ' R#44 color register
61 VDP(47) = &HF0 ' R#46 select command (HMMC) and execute it
62 VDP(41) = 26   ' set width in pixels (in screen 0 means number of chars)
63 VDP(43) = 1    ' set height in pixels (screen 0 meaning unknown)
64 VDP(47) = &HF0 ' R#46 select command (HMMC) and execute it
70 IF VDP(-2) AND 1 THEN VDP(45) = I : I = I + 1 : GOTO 70