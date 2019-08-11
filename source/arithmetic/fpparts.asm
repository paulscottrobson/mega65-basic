; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fppars.asm
;		Purpose :	Get Fractional/Integer part of a float.
;		Date :		11th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Get Fractional Part
;
; *******************************************************************************************

FPFractionalPart:
		lda 	A_Exponent 					; if exponent -ve then then unchanged
		sec 								; this flag tells us to keep the fractional part
		bpl 	FPGetPart
		rts

; *******************************************************************************************
;
;								Get Integer Part
;
; *******************************************************************************************

FPIntegerPart:
		lda 	A_Exponent 					; if exponent -ve then the result is zero.
		clc 								; this flag says keep the integer part.
		bpl 	FPGetPart
		pha
		lda 	#$FF 						; set the Zero Flag
		sta 	A_Zero
		pla
		rts

; *******************************************************************************************
;
;									Get one part or the other
;
; *******************************************************************************************

FPGetPart:
		pha
		phx 								; save X
		lda 	A_Zero 						; if zero, return zero
		bne 	_FPGP_Exit 					; then do nothing.
		php 								; save the action flag on the stack.

		lda 	#$FF 						; set the mask long to -1
		sta 	zLTemp1+0
		sta 	zLTemp1+1
		sta 	zLTemp1+2
		sta 	zLTemp1+3
		;
		ldx 	A_Exponent 					; the number of shifts.
		beq 	_FPGP_NoShift 				; ... if any
		cpx 	#32
		bcc 	_FPGP_NotMax
		ldx 	#32 						; max of 32.
_FPGP_NotMax:		 	
		#lsr32	zLTemp1 					; shift mask right that many times.
		dex
		bne 	_FPGP_NotMax
_FPGP_NoShift:

		ldx 	#3 							; now mask each part in turn.
_FPGP_MaskLoop:
		lda 	zlTemp1,x 					; get mask.
		plp 								; if CC we keep the top part, so we 
		php		 							; flip the mask.
		bcs		_FPGP_NoFlip
		eor 	#$FF
_FPGP_NoFlip:
		and 	A_Mantissa,x
		sta 	A_Mantissa,x
		dex
		bpl 	_FPGP_MaskLoop		
		;
		plp 								; get action flag on the stack
		bcc 	_FPGP_NotFractional 		; if fractional part always return +ve.
		lda 	#0
		sta 	A_Sign
_FPGP_NotFractional:		
		;
		#iszero32 A_Mantissa 				; is the result zero
		beq 	_FPGP_Zero 					; if zero, return zero
		;
		ldx 	#0							; otherwise normalise
		jsr 	FPUNormaliseX
		bra 	_FPGP_Exit 					; and exit
		;
_FPGP_Zero:
		lda 	#$FF 						; set zero flag
		sta 	A_Zero		
		;
_FPGP_Exit:
		plx
		pla
		rts

