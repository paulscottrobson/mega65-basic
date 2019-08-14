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
;		Called after IntFromString. Starting at (zGenPtr),y try to extract first a 
;		decimal part, which can be added to A, and then an exponent scalar, which 
;		can be used to scale A.
;
; *******************************************************************************************

FPFromString:
		;
		;		Push B
		;
		nop
		lda		(zGenPtr),y					; followed by a DP.
		cmp 	#"."
		bne	 	_FPFNotDecimal
		iny 								; consume the decimal.
		;
		jsr 	FPUCopyAToB 				; put the integer part in B.
		jsr 	INTFromStringY 				; get the part after the DP.
		;
		; 		Scale by -length
		; 		Add B to A
		;

		
_FPFNotDecimal:		 	
		;
		;		Pop B
		;
		clc
		rts

