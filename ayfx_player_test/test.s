;-Sound effects player test------------------------------------;
;                                                              ;
; Тестовая программа, использующая Minimal ayFX player.        ;
; Проигрывает эффекты на штатном AY; при наличии второго AY по ;
; схеме NedoPC можно включить музыку для проигрывания на нём.  ;
; Клавиши 1-0,Q-P,A-L,Z-M,SS,CS проигрывают эффекты 0..38      ;
; (можно загрузить банк с меньшим количеством эффектов),       ;
; клавиша 'пробел' включает/выключает музыку на втором AY.     ;
;                                                              ;
;--------------------------------------------------------------;

sfxBankAd:	EQU 0xa000	;адрес банка эффектов
musInitAd:	EQU 0xc000	;адрес скомпилированной музыки (PT3)
musPlayAd:	EQU musInitAd+5
musShutAd:	EQU musInitAd+8


	ORG 0x6200

	;ENT $
	
	di
	ld sp,0x61ff
	
	ld hl,sfxBankAd	;инициализация плеера эффектов
	call AFXINIT
	
	call musInitAd	;инициализация музыки
	
	xor a			;музыка по умолчанию выключена
	ld (tsMusEnable+1),a

	ld hl,intProc	;перемещаем обработчик прерывания в 0xbdbd
	ld de,0xbdbd
	ld bc,intProcEnd-intProc
	ldir
	
	ld hl,0xbe00		;таблица прерывания для адреса 0xbdbd
	ld de,0xbe01
	ld bc,0x0100
	ld a,h
	ld i,a
	ld (hl),0xbd
	ldir
	im 2
	ei
	
mainLoop:			;основной цикл

	halt
	
	ld b,4			;цикл опроса клавиш
	ld hl,tblRowNum
keyLoop:
	push bc
	
	ld b,(hl)		;проверка текущего левого полуряда
	ld c,0xfe
	inc hl
	in a,(c)
	ld b,5
	ld c,(hl)
	inc hl
keyRowL:
	rra
	call nc,playSfx
	inc c
	djnz keyRowL
	
	ld b,(hl)		;проверка текущего правого полуряда
	ld c,0xfe
	inc hl
	in a,(c)
	ld b,5
	ld c,(hl)
	inc hl
keyRowR:
	rra
	call nc,playSfx
	dec c
	djnz keyRowR

	pop bc
	djnz keyLoop
	
	jr mainLoop
	
	
	
playSfx:				;запуск эффекта
	push af
	push bc
	push hl

	ld a,39			;эффект номер 39 = клавиша 'пробел'
	cp c
	jr nz,playSfx0	;переход, если пробел не нажат
	
	ld hl,tsMusEnable+1
	ld a,(hl)		;инвертируем флаг включения музыки
	inc a
	ld (hl),a
	and 1
	jr nz,playSfx1	;переход, если музыка была включена
	
	halt			;музыка выключена, выключаем каналы AY
	di
	ld a,1
	call aySelChip
	call musShutAd
	ei
	jr playSfx1
	
playSfx0:
	ld a,(sfxBankAd);проверка на наличие эффекта в банке
	dec a
	cp c
	jr c,playSfx2	;переход, если в банке нет столько эффектов
	ld a,c			;собственно запуск эффекта
	call AFXPLAY

playSfx1:
	halt			;задержка после нажатия клавиши
	halt
	halt
	halt
	
playSfx2:
	pop hl
	pop bc
	pop af
	ret
	
	
aySelChip:			;процедура выбора нужного AY
	ld bc,0xfffd
	xor b
	out (c),a
	ret
	
INCLUDE "ayfx_player_test/ayfxplay.S"	;включаем исходник плеера эффектов

;табличка для опроса полурядов клавиатуры
;первый байт - старший байт адреса порта
;второй байт - стартовый номер эффекта для полуряда

tblRowNum:
	DB 0xf7,0x00,0xef,0x09,0xfb,0x0a,0xdf,0x13
	DB 0xfd,0x14,0xbf,0x1d,0xfe,0x1e,0x7f,0x27



	
intProc:				;обработчик прерывания
	push af
	push bc
	push de
	push hl

tsMusEnable:	EQU $-intProc+0xbdbd	;адрес метки после перемещения
	ld a,0			;музыка включена?
	and 1
	jr z,noMusic
	
	ld a,1			;выбираем второй AY
	call aySelChip
	call musPlayAd	;проигрываем музыку
	
noMusic:
	xor a			;выбираем первый AY
	call aySelChip
	call AFXFRAME	;проигрываем эффекты

	pop hl
	pop de
	pop bc
	pop af
	ei
	ret
intProcEnd: