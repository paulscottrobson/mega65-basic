; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpfromstr.asm
;		Purpose :	Convert String to floating point
;		Date :		12th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Convert string at GenPtr into B_Register. Return CC if okay, CS on error
;		On successful exit A is the characters consumed from the string.
;
; *******************************************************************************************

FPAsciiToFloat:
		phx
		phy
		ldx 	#0 							; set the initial value to integer to zero.
		ldy 	#0
		jsr 	FPUSetBFromXY
		;
		ldy 	#0  						; get first character.
		lda 	(zGenPtr),y 
		eor 	#"-"
		bne 	_FPANotMinus
		iny									; skip over the minus
_FPANotMinus:
		pha 								; A is zero for minus, non-zero for plus.		
		;
		ldx 	#$FF 						; X counts the decimal places.
_FPAGetNextBody:
		lda 	(zGenPtr),y 				; get next character
		cmp 	#"."						; decimal place
		bne 	_FPANotDecimal
		;
		iny 								; skip decimal place.
		cpx 	#0 							; already in decimals ?
		bpl 	_FPAError
		ldx 	#0 							; start counting decimals.
		bra 	_FPAGetNextBody
		;
_FPANotDecimal:
		cmp 	#"0"						; if out of range 0-9 exit this bit.
		bcc 	_FPAEndConstantPart
		cmp 	#"9"+1
		bcs 	_FPAEndConstantPart
		;
		;
		lda 	B_Mantissa+3 				; check for overflow.
		cmp 	#$0C 						; roughly $7F/10
		bcs 	_FPASkipDigit 				; can't do any more
		;
		cpx 	#00 						; if X +ve, then bump decimals.
		bmi 	_FPANotIndecimal
		inx				
_FPANotInDecimal:
		;
		lda 	(zGenPtr),y 				; get the digit.
		pha 								; save digit.
		iny 								; skip over it
		jsr 	FPABTimes10Int 				; multiply B_Mantissa by 10.
		pla
		and 	#15 						; make 0-9
		clc
		adc 	B_Mantissa
		sta 	B_Mantissa
		bcc 	_FPAGetNextBody
		inc 	B_Mantissa+1
		bne 	_FPAGetNextBody
		inc 	B_Mantissa+2
		bne 	_FPAGetNextBody
		inc 	B_Mantissa+3
		bra 	_FPAGetNextBody
;
_FPASkipDigit:
		iny
		cpx 	#$00						; in decimals, can skip
		bpl 	_FPAGetNextBody		
		pla 								; throw minus
;
_FPAError: 									; overflow error
		ply
		plx
		sec
		rts		
		;
_FPAEndConstantPart:
		pla 								; minus flag.
		bne 	_FPANotNegative				; skip if +ve
		phx
		ldx 	#B_Mantissa-A_Mantissa
		jsr 	FPUIntegerNegateX
		plx
_FPANotNegative:		
		txa 								; negate X as we want to divide by 10^x
		eor 	#$FF
		inc 	a
		tax
;
;		Have constant part in the value, decimal places to reduce by in X.
;		
		lda 	(zGenPtr),y 				; check for exponents
		cmp 	#"E"
		beq 	_FPAExponent
		cmp 	#"e"
		bne 	_FPANoExponent
		iny
_FPAExponent:		
		phx
		jsr 	FPAGetExponent 				; get exponent.
		txa
		plx
		stx 	TIM_PC 						; use this as a temporary as not running TIM.
		clc
		adc 	TIM_PC 						; add to the exponent.
		bvs 	_FPAError 					; overflow ?
		tax
;	
;		Got the final exponent adjustment in A.
;		
_FPANoExponent:
		txa 								; if adjustment is zero, do nothing
		beq 	_FPANoScaling
		jsr 	FPScaleBByATimes10
_FPANoScaling:		
		tya 								; Y is the offset.
		ply
		plx		
		clc
		rts

; *******************************************************************************************
;
;									Get exponent => X
;
; *******************************************************************************************

FPAGetExponent:
		lda 	(zGenPtr),y 				; get maybe +- sign.
		cmp 	#"+"
		beq 	_FPAGetExponentPreIY 		; if + skip and get
		cmp 	#"-"						
		bne 	_FPAGetExponent 			; if not -, get as is
		jsr 	_FPAGetExponentPreIY 		; get value
		txa
		eor 	#$FF 						; negate it
		inc 	a
		tax
		rts
;
_FPAGetExponentPreIY:
		iny
_FPAGetExponent:		
		ldx 	#0 							; start at 0.
_FPAGELoop:
		lda 	(zGenPtr),y 				; check char in range.
		cmp 	#"0"
		bcc 	_FPAGEExit
		cmp 	#"9"+1
		bcs 	_FPAGEExit 			
		;
		stx 	TIM_PC 						
		txa 
		asl 	a 							; x2
		asl 	a 							; x4
		adc 	TIM_PC 						; x5
		asl 	a 							; x10
		adc 	(zGenPtr),y 				; add digit and fix up.
		sec
		sbc 	#"0"
		tax 								; back in X.
		iny 								; next character
		bne 	_FPAGELoop
		;
_FPAGEExit:		
		rts

; *******************************************************************************************
;
;						Multiply integer value in B Mantissa by 10
;
; *******************************************************************************************


FPABTimes10Int:
		jsr 	_FPABTimes2 				; x 2
		lda 	B_Mantissa+3 				; save on stack.
		pha
		lda 	B_Mantissa+2
		pha
		lda 	B_Mantissa+1
		pha
		lda 	B_Mantissa+0
		pha
		jsr 	_FPABTimes2 				; x 4
		jsr 	_FPABTimes2 				; x 8
		clc
		pla 								; add x 2 on => x 10
		adc 	B_Mantissa+0
		sta 	B_Mantissa+0
		pla
		adc 	B_Mantissa+1
		sta 	B_Mantissa+1
		pla
		adc 	B_Mantissa+2
		sta 	B_Mantissa+2
		pla
		adc 	B_Mantissa+3
		sta 	B_Mantissa+3
		rts
;
_FPABTimes2:
		#asl32	B_Mantissa 					; x 2
		rts

; *******************************************************************************************
;
;					  if A < 0 B = B / 10^|A| else B = B * 10^|A|
;
; *******************************************************************************************

FPScaleBByATimes10:
		phx
		phy
		tay

		ldx 	#7
_FPSPush:
		lda 	A_Mantissa,x
		pha
		dex
		bpl 	_FPSPush 

		tya
		pha 								; save scalar.
		jsr 	FPUCopyBtoA					; put B in A

		ldx		#1
		ldy 	#0
		jsr 	FPUSetBFromXY 				; set B to 1
		ldx 	#B_Mantissa-A_Mantissa 		
		jsr 	FPUToFloatX 				; set B to 1.0
		ldx 	#0 						
		jsr 	FPUToFloatX 				; set A to float.
		;
		pla 								; count in A
		pha
		bpl 	_FPCountPos 				; |count| in Y
		eor 	#$FF
		inc 	a
_FPCountPos:
		tay		
		;
_FPCreateScalar:
		ldx 	#B_Mantissa-A_Mantissa 		; multiply B by 10.
		jsr 	FPUTimes10X
		jsr 	FPUNormaliseX
		dey 	
		bne 	_FPCreateScalar 			
		;
		pla 								; get direction back
		bmi 	_FPSDivide
		jsr 	FPMultiply 			
		bra 	_FPSExit
_FPSDivide:
		jsr 	FPDivide
_FPSExit:
		jsr 	FPUCopyAToB 				; result back in B		

		ldx 	#0
_FPSPull:
		pla
		sta 	A_Mantissa,x
		inx
		cpx 	#8
		bne 	_FPSPull

		ply
		plx
		rts
