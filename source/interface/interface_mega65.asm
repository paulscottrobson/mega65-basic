; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		interface_mega65.asm
;		Purpose :	Assembler Interface (Mega65 Hardware)
;		Date :		9th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

IF_Width 	= 80 							; characters across
IF_Height 	= 25 							; characters down.

IF_Pos 		= 4 							; current position, start of line.
IF_XPos 	= 6 							; current position, horizontal.
IF_FarPtr 	= 8 							; far pointer (4 bytes)

IF_Screen = $1000							; 2k screen RAM here
IF_CharSet = $800							; 2k character set (0-7F) here

; *******************************************************************************************
;
;										  Home cursor
;
; *******************************************************************************************

IF_Home:
		rts

; *******************************************************************************************
;
;									 Start of next line
;
; *******************************************************************************************

IF_NewLine:
		rts

; *******************************************************************************************
;
;									  Read a character.
;
; *******************************************************************************************

IF_Read:
		rts

; *******************************************************************************************
;
;									  Write a character.
;
; *******************************************************************************************

IF_Write:
		rts

; *******************************************************************************************
;
;						Check if break pressed, return A != 0 if so, Z set.
;
; *******************************************************************************************

IF_CheckBreak:
		rts

; *******************************************************************************************
;
;									Get one key press in A, Z set
;
; *******************************************************************************************

IF_GetKey:
		rts

; *******************************************************************************************
;
;									  Reset the interface
;
; *******************************************************************************************

IFWriteHW 	.macro 							; write to register using
	ldz 	#\1 							; address already set up
	lda 	#\2
	nop
	sta 	(IF_FarPtr),z
.endm

IF_Reset:
	pha 									; save registers
	phx
	phy
	lda 	#$0F 							; set up to write to video system.
	sta 	IF_FarPtr+3
	lda 	#$FD
	sta 	IF_FarPtr+2
	lda 	#$30
	sta 	IF_FarPtr+1
	lda 	#$00
	sta 	IF_FarPtr+0

	#IFWriteHW 	$2F,$47 					; switch to VIC-IV mode ($A5/$96 VIC III)
	#IFWriteHW 	$2F,$53	

	#IFWriteHW 	$30,$40						; C65 Charset 					
	#IFWriteHW 	$31,$80+$40 				; 80 column mode, 40Mhz won't work without 3.5Mhz on.

	#IFWriteHW $20,0 						; black border
	#IFWriteHW $21,0 						; black background

	#IFWriteHW $54,$40 						; Highspeed on.

	; point VIC-IV to bottom 16KB of display memory

	#IFWriteHW $01,$FF
	#IFWriteHW $00,$FF

	#IFWriteHW $16,$CC 					; 40 column mode

	#IFWriteHW $18,$42	 				; screen address $0800 video address $1000
	#IFWriteHW $11,$1B 					; check up what this means

	lda 	#$00							; colour RAM at $1F800-1FFFF (2kb)
	sta 	IF_FarPtr+3 
	lda 	#$01
	sta 	IF_FarPtr+2
	lda 	#$F8
	sta 	IF_FarPtr+1
	lda 	#$00
	sta 	IF_FarPtr+0
	ldz 	#0 
_EXTClearColorRam:	
	lda 	#1									; fill that with this colour.
	nop
	sta 	(IF_FarPtr),z
	dez
	bne 	_EXTClearColorRam
	inc 	IF_FarPtr+1
	bne 	_EXTClearColorRam

	ldx 	#0 								; copy PET Font into memory.
_EXTCopyCBMFont:
	lda 	IF_CBMFont,x 					; +$800 uses the lower case c/set
	sta 	IF_CharSet,x
	lda 	IF_CBMFont+$100,x
	sta 	IF_CharSet+$100,x
	lda 	IF_CBMFont+$200,x
	sta 	IF_CharSet+$200,x
	lda 	IF_CBMFont+$300,x
	sta 	IF_CharSet+$300,x
	dex
	bne 	_EXTCopyCBMFont

	lda 	#$3F-4  					; puts ROM back in the map (the -4)
	sta 	$01

	lda 	#$00						; do not map bytes 0000-7FFF
	ldx 	#$00
	ldy 	#$00 						; 8000-FFFF offset by $2000
	ldz 	#$F2
	map
	eom

	ply 									; restore and exit.
	plx
	pla

	ldx 	#0
x1:	
	txa
	sta 	$1000,x
	sta 	$1100,x
	sta 	$1200,x
	sta 	$1300,x
	sta 	$1400,x
	sta 	$1500,x
	sta 	$1600,x
	sta 	$1700,x
	inx
	bne 	x1
	rts

IF_CBMFont:
	.binary "pet-font.bin"

