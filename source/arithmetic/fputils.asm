; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fputils.asm
;		Purpose :	Floating Point Utilities
;		Date :		11th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;							Sign Extend XY and put in B (Testing)
;
; *******************************************************************************************

FPUSetBFromXY:
		pha
		stx 	B_Mantissa 					; set the lower 2 bytes
		sty 	B_Mantissa+1
		tya
		asl 	a 							; CS if MSB set.
		lda 	#0 							; 0 if CC,$FF if CS
		bcc 	_FPUSB1
		dec 	a
_FPUSB1:sta 	B_Mantissa+2 				; these are the two ms bytes
		sta 	B_Mantissa+3		
		lda 	#Type_Integer 				; type is integer.
		sta 	B_Type 
		pla
		rts

; *******************************************************************************************
;
;										Copy B to A
;
; *******************************************************************************************

FPUCopyBToA:
		pha 								; copy the 8 byte format across.
		phx
		ldx 	#7
_FPUCopy1:
		lda 	B_Mantissa,x
		sta 	A_Mantissa,x
		dex
		bpl 	_FPUCopy1
		plx
		pla
		rts

; *******************************************************************************************
;
;								Convert X Integer to Float
;
; *******************************************************************************************

FPUToFloatX:
		pha
		lda 	A_Type,x					; exit if already float.
		bmi 	_FPUBExit
		lda 	#Type_Float 				; set float type
		sta 	A_Type,x
		lda 	#32 						; and the exponent to 32, makes it * 2^32
		sta 	A_Exponent,x
		;
		lda 	#0 							; clear sign/zero bytes
		sta 	A_Sign,x 					
		sta		A_Zero,x
		;
		lda 	A_Mantissa+3,x 				; signed integer ?
		bpl		_FPUBPositive
		jsr 	FPUIntegerNegateX 			; do B = -B in integer, so +ve mantissa
		dec 	A_Sign,x 					; set the sign byte to $FF
_FPUBPositive:		
		;
		#iszero32 B_Mantissa 				; mantissa is zero ?
		bne 	_FPUBNonZero
		dec 	A_Zero,x 					; set the zero byte to $FF
_FPUBNonZero:
		;
		jsr 	FPUNormaliseX
_FPUBExit:
		pla
		rts

; *******************************************************************************************
;
;									Convert A to Integer
;
; *******************************************************************************************

FPUAToInteger:
		pha
		lda 	A_Type 						; if already integer, exit
		beq 	_FPUATOI_Exit
		lda 	#Type_Integer 				; make type zero (integer)
		sta 	A_Type
		lda 	A_Zero						; if zero, return zero.
		bne 	_FPUATOI_Zero		
		lda 	A_Exponent 					; check -ve exponent or < 32
		bmi 	_FPUAToIOk
		cmp 	#32 						; sign exponent >= 32, overflow.
		bcs 	FP_Overflow
_FPUAToIOk:		
		;
_FPUAToIToInteger:
		lda 	A_Exponent 					; reached ^32
		cmp 	#32
		beq 	_FPUAtoICheckSign 			; check sign needs fixing up.
		inc 	A_Exponent 					; increment Exponent
		#lsr32 	A_Mantissa	 				; shift mantissa right
		bra 	_FPUAToIToInteger 			; keep going.
		;
_FPUAtoICheckSign:
		lda 	A_Sign 						; check sign
		beq 	_FPUAToI_Exit 				; exit if unsigned.
		phx
		ldx 	#0
		jsr 	FPUIntegerNegateX 			; otherwise negate the shifted mantissa
		plx
		bra 	_FPUATOI_Exit
		;
_FPUATOI_Zero:
		lda 	#0 							; return zero integer.
		sta 	A_Mantissa+0		
		sta 	A_Mantissa+1
		sta 	A_Mantissa+2		
		sta 	A_Mantissa+3		
_FPUATOI_Exit:
		pla
		rts
FP_Overflow:
		jsr 	ERR_Handler
		.text 	"Floating Point overflow",0


; *******************************************************************************************
;
;									Multiply AM,X times 10
;
; *******************************************************************************************

FPUTimes10X:
		lda 	A_Mantissa+0,x 				; copy mantissa to ZLTemp1
		sta 	ZLTemp1+0
		lda 	A_Mantissa+1,x
		sta 	ZLTemp1+1,x
		lda 	A_Mantissa+2,x
		sta 	ZLTemp1+2,x
		lda 	A_Mantissa+3,x
		sta 	ZLTemp1+3,x
		#lsr32 	ZLTemp1 					; divide by 4
		#lsr32 	ZLTemp1
		;
		clc
		lda 	A_Mantissa+0,x
		adc 	ZLTemp1+0,x
		sta 	A_Mantissa+0,x
		lda 	A_Mantissa+1,x
		adc 	ZLTemp1+1,x
		sta 	A_Mantissa+1,x
		lda 	A_Mantissa+2,x
		adc 	ZLTemp1+2,x
		sta 	A_Mantissa+2,x
		lda 	A_Mantissa+3,x
		adc 	ZLTemp1+3,x
		sta 	A_Mantissa+3,x

		bcc 	_FPUTimes10
		ror32x	A_Mantissa 					; rotate carry back into mantissa
		inc 	A_Exponent,x				; fix exponent
_FPUTimes10:
		lda 	A_Exponent,x 				; fix up x 2^3
		clc
		adc 	#3
		sta 	A_Exponent,x
		bvs 	FP_Overflow 				; error
		rts

; *******************************************************************************************
;
;						Normalise float at offset X from A_Mantissa
;
; *******************************************************************************************

FPUNormaliseX:		
		pha
		lda 	A_Zero,x 					; if float-zero, don't need to normalise it.
		bne 	_FPUNExit
_FPULoop:
		lda 	A_Mantissa+3,x 				; bit 31 of mantissa set.
		bmi 	_FPUNExit 					; if so, we are normalised.
		;
		#asl32x A_Mantissa+0 				; shift mantissa left
		;
		dec 	A_Exponent,x 				; decrement exponent
		lda 	A_Exponent,x 				; if exponent not $7F (e.g. gone < -$80)
		cmp 	#$7F
		bne 	_FPULoop 		
		;
		dec 	A_Zero,x 					; the result is now zero.
_FPUNExit:
		pla
		rts

; *******************************************************************************************
;
;								Negate AM,X as a 32 bit integer
;
; *******************************************************************************************

FPUIntegerNegateX:
		pha
		sec
		lda 	#0
		sbc 	A_Mantissa+0,x
		sta 	A_Mantissa+0,x
		lda 	#0
		sbc 	A_Mantissa+1,x
		sta 	A_Mantissa+1,x
		lda 	#0
		sbc 	A_Mantissa+2,x
		sta 	A_Mantissa+2,x
		lda 	#0
		sbc 	A_Mantissa+3,x
		sta 	A_Mantissa+3,X
		pla
		rts
