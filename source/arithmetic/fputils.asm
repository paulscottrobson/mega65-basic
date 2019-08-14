; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fputils.asm
;		Purpose :	Floating Point Utilities
;		Date :		11th August 2019
;		Reviewed : 	14th August 2019 		(Review#1)
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;							Sign Extend XY and put in A (as integer)
;
; *******************************************************************************************

FPUSetAFromXY:
		pha
		stx 	A_Mantissa 					; set the lower 2 bytes
		sty 	A_Mantissa+1
		tya
		asl 	a 							; CS if MSB set.
		lda 	#0 							; 0 if CC,$FF if CS
		bcc 	_FPUSA1
		dec 	a
_FPUSA1:sta 	A_Mantissa+2 				; these are the two ms bytes
		sta 	A_Mantissa+3		
		lda 	#Type_Integer 				; type is integer (as integer)
		sta 	A_Type 
		pla
		rts

; *******************************************************************************************
;
;							Sign Extend XY and put in B
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
;										Copy A to B
;
; *******************************************************************************************

FPUCopyAToB:
		pha 								; copy the 8 byte format across.
		phx
		ldx 	#7
_FPUCopy2:
		lda 	A_Mantissa,x
		sta 	B_Mantissa,x
		dex
		bpl 	_FPUCopy2
		plx
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
		;
		lda 	#Type_Float 				; set float type
		sta 	A_Type,x
		;
		lda 	#32 						; and the exponent to 32, makes it * 2^32
		sta 	A_Exponent,x 				; x mantissa.
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
		lda 	A_Mantissa,x 				; mantissa is zero ?
		ora 	A_Mantissa+1,x
		ora 	A_Mantissa+2,x
		ora 	A_Mantissa+3,x
		bne 	_FPUBNonZero
		dec 	A_Zero,x 					; set the zero byte to $FF
_FPUBNonZero:
		;
		jsr 	FPUNormaliseX 				; normalise the floating point.
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
		;
		lda 	#Type_Integer 				; make type zero (integer)
		sta 	A_Type
		lda 	A_Zero						; if zero, return zero.
		bne 	_FPUATOI_Zero		
		;
		lda 	A_Exponent 					; check -ve exponent or < 32
		bmi 	_FPUAToIOk
		cmp 	#32 						; sign exponent >= 32, overflow.
		bcs 	FP_Overflow
_FPUAToIOk:		
		;									; inverse of the toFloat() operation.
_FPUAToIToInteger:
		lda 	A_Exponent 					; keep right shifting until reached ^32
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
		sta 	ZLTemp1+1
		lda 	A_Mantissa+2,x
		sta 	ZLTemp1+2
		lda 	A_Mantissa+3,x
		sta 	ZLTemp1+3
		#lsr32 	ZLTemp1 					; divide by 4. What we're doing here is
		#lsr32 	ZLTemp1						; 8 x n + 8 x n/4
		;
		clc
		lda 	A_Mantissa+0,x 				; add n/4 to n
		adc 	ZLTemp1+0
		sta 	A_Mantissa+0,x
		lda 	A_Mantissa+1,x
		adc 	ZLTemp1+1
		sta 	A_Mantissa+1,x
		lda 	A_Mantissa+2,x
		adc 	ZLTemp1+2
		sta 	A_Mantissa+2,x
		lda 	A_Mantissa+3,x
		adc 	ZLTemp1+3
		sta 	A_Mantissa+3,x

		bcc 	_FPUTimes10
		ror32x	A_Mantissa 					; rotate carry back into mantissa
		inc 	A_Exponent,x				; fix exponent
_FPUTimes10:
		lda 	A_Exponent,x 				; fix up x 2^3 e.g. multiply by 8.
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
		;
_FPULoop:
		lda 	A_Mantissa+3,x 				; bit 31 of mantissa set.
		bmi 	_FPUNExit 					; if so, we are normalised.
		;
		#asl32x A_Mantissa+0 				; shift mantissa left
		;
		dec 	A_Exponent,x 				; decrement exponent
		lda 	A_Exponent,x 				; if exponent not $7F (e.g. gone < -$80)
		cmp 	#$7F
		bne 	_FPULoop 		 			; go round again until bit 31 set.
		;
		lda 	#$FF
		sta 	A_Zero,x 					; the result is now zero.
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
		lda 	#0 							; simple 32 bit subtraction.
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

; *******************************************************************************************
;
;					Compare A-B - returns -1,0,1 depending on difference.
;
;	This is an approximate comparison, so values where |a-b| < c will still return zero
;	because of rounding errors. c is related to the scale of a and b, not a fixed
; 	constant.
;
; *******************************************************************************************

FPCompare:
		lda 	A_Exponent 					; save the exponents on the stack
		pha
		lda 	B_Exponent 					
		pha
		;
		jsr 	FPSubtract 					; calculate A-B
		lda 	A_Zero 						; is the result zero ?
		bne 	_FPCPullZero 				; if so, then return zero throwing saved exp
		;
		pla
		sta 	B_Mantissa 					; BM+0 is BX
		pla 	
		sta 	B_Mantissa+1 				; BM+1 is AX
		sec
		sbc 	B_Mantissa 					; AX-BX
		bvs 	_FPCNotEqual				; overflow, can't be equal.
		;
		inc 	a 							; map -1,0,1 to 0,1,2
		cmp 	#3 							; if >= 3 e.g. abs difference > 1
		bcs 	_FPCNotEqual  				; exponents can't be more than 2 out.
		;
		clc
		lda 	B_Mantissa 					; mean of exponents (note above, we are using
		adc 	B_Mantissa+1				; the mantissa as a temporary store here()
		ror 	a 							; shift carry out back in.
		;
		sec
		sbc 	#12 						; allow for 2^12 error, relatively, about 4 DP ish.
		bvc 	_FPCNotRange 				; keep in range.
		lda 	#$80
_FPCNotRange:		
		sec
		sbc 	A_Exponent  				; if exponent of difference more than this.
		bvc 	_FPCNotOverflow 			; signed comparison
		eor 	#$80
_FPCNotOverflow:		
		bmi 	_FPCNotEqual 				; then error is too large, so return -1 or 1
		lda 	#0 							; "approximately equal" allowing for rounding
		bra 	_FPCExit 					; errors. 
		;
		;
_FPCNotEqual:
		lda 	A_Sign 						; if sign is -ve , will be $FF, so return $FF
		bne 	_FPCExit
		lda 	#1 							; otherwise return $01 as not zero.
		bra 	_FPCExit
_FPCPullZero:
		pla 								; throw saved exponents
		pla
		lda 	#0 							; and return zero
_FPCExit:		
		rts
