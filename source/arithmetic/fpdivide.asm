; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpdivide.asm
;		Purpose :	Divide B into A (floating point)
;		Date :		11th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

FPD_IsDivZero:
		jsr 		ERR_Handler
		.text 		"Division by zero",0

; *******************************************************************************************
;
;							Divide B into A (floating point)
;	
; *******************************************************************************************

FPDivide:
		pha
		phx
		lda 	B_Zero 						; check if division by zero
		bne 	FPD_IsDivZero
		lda 	A_Zero 						; if 0/X (X is not zero) return 0
		bne 	_FPD_Exit
		;
		lda 	A_Exponent 					; calculate new exponent
		sec		
		sbc 	B_Exponent
		bpl 	_FPD_NoOverflow 			; check for overflow.
		bvc 	_FPD_NoOverflow
_FPD_Overflow:		
		jmp 	FP_Overflow
_FPD_NoOverflow:
		clc 	 							; x 2, overflow if -ve
		adc 	#1
		bvs 	_FPD_Overflow
		sta 	A_Exponent
		;
		lda 	#0 							; clear result (kept in zLTemp1)
		sta 	zLTemp1+0
		sta 	zLTemp1+1
		sta 	zLTemp1+2
		sta 	zLTemp1+3
		;
		ldx 	#32 						; times round.
_FPD_Loop:
		sec 								; calculate A-B stacking result.
		lda 	A_Mantissa+0
		sbc 	B_Mantissa+0		
		pha
		lda 	A_Mantissa+1
		sbc 	B_Mantissa+1		
		pha
		lda 	A_Mantissa+2
		sbc 	B_Mantissa+2		
		pha
		lda 	A_Mantissa+3
		sbc 	B_Mantissa+3		
		bcc		_FPD_NoSubtract 			; if CC couldn't subtract
		;
		sta 	A_Mantissa+3 				; save results out to A
		pla
		sta 	A_Mantissa+2
		pla
		sta 	A_Mantissa+1
		pla
		sta 	A_Mantissa+0
		;
		lda 	zLTemp1+3 					; set high bit of result
		ora 	#$80
		sta 	zLTemp1+3
		bra 	_FPD_Rotates
		;
_FPD_NoSubtract:
		pla 								; throw away unwanted results
		pla
		pla
		;
_FPD_Rotates:
		#lsr32 	B_Mantissa 					; shift B Mantissa right.

		#asl32 	zLTemp1 					; rotate result left.
		bcc 	_FPD_NoCarry
		inc 	zLTemp1 					; if rotated out, set LSB.
_FPD_NoCarry:						
		;
		dex 								; do 32 times
		bne 	_FPD_Loop
		;
		lda 	zLTemp1+0 					; copy the left product into Mantissa A.
		sta 	A_Mantissa+0
		lda 	zLTemp1+1
		sta 	A_Mantissa+1
		lda 	zLTemp1+2
		sta 	A_Mantissa+2
		lda 	zLTemp1+3
		sta 	A_Mantissa+3

		lda 	A_Sign 						; sign is xor of signs
		eor 	B_Sign
		sta 	A_Sign

		ldx 	#0 							; normalise the result
		jsr 	FPUNormaliseX
		;
_FPD_Exit:
		plx
		pla		
		rts
