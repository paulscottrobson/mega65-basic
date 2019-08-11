; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpmultiply.asm
;		Purpose :	Floating Point Multiply
;		Date :		11th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Multiply A by B (floating point)
;	
; *******************************************************************************************

FPMultiply:	
		pha
		phx
		lda		B_Zero 						; if B = 0, return B unchanged
		bne 	_FPM_ReturnB
		lda 	A_Zero 						; if A = 0, return A
		bne 	_FPM_Exit
		;
		lda 	A_Exponent					; add their exponents
		clc
		adc 	B_Exponent
		sta 	A_Exponent 					; exponent of result.
		bpl 	_FPM_NoOverflow 			; error if -ve result and overflow. 
		bvc 	_FPM_NoOverflow
		jmp 	FP_Overflow
_FPM_NoOverflow:
		;
		lda 	#0
		sta 	zLTemp1+0 					; clear the long temp which is upper word of
		sta 	zLTemp1+1 					; long product. lower word is mantissa-A
		sta 	zLTemp1+2 					; multiplicand is mantissa-B
		sta 	zLTemp1+3
		;
		ldx 	#32							; X is loop counter
_FPM_Loop:
		lda 	A_Mantissa					; check LSB of long product
		and 	#1
		clc 								; clear carry for the long rotate.
		beq 	_FPM_NoAddition

		#add32 	zLTemp1,B_Mantissa 			; add the multiplicand to the upper word, preserves C.
_FPM_NoAddition:
		#ror32 	zLTemp1 					; rotate the long product right.
		#ror32 	A_Mantissa		

		dex
		bne 	_FPM_Loop 					; do this 32 times.

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
		bra		_FPM_Exit

_FPM_ReturnB:
		jsr 	FPUCopyBToA
_FPM_Exit:
		plx
		pla
		rts		
