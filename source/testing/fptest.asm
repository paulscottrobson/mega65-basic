; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fptest.asm
;		Purpose :	Runs floating point script code, used in testing.
;		Date :		15th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Do the arithmetic tests
;
; *******************************************************************************************

FPTTest:
		lda 	#FPTTestData & $FF 			; set zGenPtr to data.
		sta 	zGenPtr
		lda 	#FPTTestData >> 8
		sta 	zGenPtr+1
		ldx 	#0 							; start at stack bottom.
FPTLoop:jsr 	FPTGet 						; get next command
		cmp 	#0 							; zero, exit
		beq 	FPTExit
		cmp 	#1 							; 1,load
		beq 	FPTLoad
FPTError:
		bra 	FPTError
		;
		;		1 loads integer/float value in.
		;
FPTLoad:
		ldy 	#6 							; data to copy
_FPTLoadLoop:
		jsr 	FPTGet
		sta 	XS_Mantissa,x
		inx
		dey
		bne 	_FPTLoadLoop
		bra 	FPTLoop
		;	
		;		0 which is stop (XEmu, Hardware) exit (emulator)
		;
FPTExit:		
		rts

; *******************************************************************************************
;
;			Get a single character
;
; *******************************************************************************************

FPTGet:	phy
		ldy 	#0
		lda 	(zGenPtr),y
		pha
		inc 	zGenPtr
		bne 	_FPTGet1
		inc 	zGenPtr+1
_FPTGet1:
		pla
		ply
		rts		

; *******************************************************************************************
;
;				Included test data created in floating-point directory.
;
; *******************************************************************************************

FPTTestData:
		.include "script.inc"
		.byte 	0		
