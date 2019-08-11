; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpadd.asm
;		Purpose :	Floating Point Add/Subtract
;		Date :		11th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Subtract B from A (floating point)
;	
; *******************************************************************************************

FPSubtract:
		pha
		lda 	B_Sign 						; flip the sign of B and add
		eor 	#$FF
		sta 	B_Sign
		pla

; *******************************************************************************************
;
;								Add B to A (floating point)
;	
; *******************************************************************************************

FPAdd:	
		pha
		phx
		lda 	A_Sign 						; if A is -ve, specialised code
		bne 	_FPA_NegativeLHS 
		jsr 	FPAdd_Worker 				; if +ve use standard worker unchanged.
		plx
		pla
		rts
;
;		-A +- B
;
_FPA_NegativeLHS:
		lda 	A_Sign 						; flip A and B signs
		eor 	#$FF
		sta 	A_Sign
		lda 	B_Sign
		eor 	#$FF
		sta 	B_Sign 						; so now it's A +- B
		jsr 	FPAdd_Worker
		lda 	A_Sign 						; and flip the result sign
		eor 	#$FF
		sta 	A_Sign
		plx
		pla
		rts

; *******************************************************************************************
;
;								Add B to A where A is positive.
;
; *******************************************************************************************

FPAdd_Worker:
		lda 	B_Zero 						; if B is zero (e.g. adding zero)
		bne 	_FPAWExit 					; no change.
		lda 	A_Zero 						; if A is zero (e.g. 0 + B)
		bne 	_FPAWReturnB 				; then return B.
		;
		;		Shift exponent and mantissa until values are the same.
		;
_FPAWMakeSame:		
		ldx 	#0 							; shift offset, this is to shift A.
		lda 	A_Exponent 					; check if exponents are the same.
		sec
		sbc	 	B_Exponent 					
		beq 	_FPAW_DoArithmetic 			; if they are, 
		bvc 	_FPAWNoOverflow 			; make it a signed comparison.
		eor 	#$80
_FPAWNoOverflow:		
		bmi 	_FPAWShiftA 				; if eA < eB then shift A
		ldx 	#B_Mantissa-A_Mantissa 		; if eA > eB then shift B
_FPAWShiftA:
		inc 	A_Exponent,x 				; so shift exponent up.
		#lsr32x A_Mantissa 					; and shift mantissa right 1
		bra 	_FPAWMakeSame 				; keep going till exponents are the same.
		;		
_FPAW_DoArithmetic:		
		lda 	B_Sign 						; is it adding a negative to a positive
		bne 	_FPAW_BNegative
		;
		;		Adding B to A, both +ve
		;
		#add32 	A_Mantissa,B_Mantissa 
		bcc 	_FPAWExit 					; no carry.
		inc 	A_Exponent 					; so shift exponent up.
		sec
		#ror32 	A_Mantissa
		bra 	_FPAWExit
		;
		;		Adding B to A, B is -ve, A is +ve
		;
_FPAW_BNegative:
		#sub32	A_Mantissa,B_Mantissa
		bcs		_FPAWExit 					; no borrow. 	
		ldx 	#0  						; negate the mantissa
		jsr 	FPUIntegerNegateX
		lda 	A_Sign 						; flip result sign
		eor 	#$FF
		sta 	A_Sign
		bra 	_FPAWExit

_FPAWReturnB:
		jsr 	FPUCopyBToA 				; copy B into A
_FPAWExit:		
		ldx 	#0 							; normalise A
		jsr 	FPUNormaliseX
		rts		 	
