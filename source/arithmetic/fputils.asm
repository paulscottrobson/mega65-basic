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

iszero32 .macro
		lda 	\1 							; check if B Mantissa zero
		ora 	\1+1
		ora 	\1+2
		ora 	\1+3
		.endm

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
;								Convert B Integer to Float
;
; *******************************************************************************************

FPUBToFloat:
		pha
		lda 	B_Type 						; exit if already float.
		bmi 	_FPUBExit
		lda 	#Type_Float 				; set float type
		sta 	B_Type
		lda 	#32 						; and the exponent to 32, makes it * 2^32
		sta 	B_Exponent
		;
		lda 	#0 							; clear sign/zero bytes
		sta 	B_Sign 					
		sta		B_Zero
		;
		lda 	B_Mantissa+3 				; signed integer ?
		bpl		_FPUBPositive
		jsr 	FPUIntegerNegateB 			; do B = -B in integer, so +ve mantissa
		dec 	B_Sign 						; set the sign byte to $FF
_FPUBPositive:		
		;
		#iszero32 B_Mantissa 				; mantissa is zero ?
		bne 	_FPUBNonZero
		dec 	B_Zero 						; set the zero byte to $FF
_FPUBNonZero:
		;
		ldx 	#B_Mantissa-A_Mantissa 		; normalise it.
		jsr 	FPUNormalise
_FPUBExit:
		pla
		rts

; *******************************************************************************************
;
;									Convert B to Integer
;
; *******************************************************************************************

FPUBToInteger:
		rts

; *******************************************************************************************
;
;						Normalise float at offset X from A_Mantissa
;
; *******************************************************************************************

FPUNormalise:		
		pha
		lda 	A_Zero,x 					; if float-zero, don't need to normalise it.
		bne 	_FPUNExit
_FPULoop:
		lda 	A_Mantissa+3,x 				; bit 31 of mantissa set.
		bmi 	_FPUNExit 					; if so, we are normalised.
		;
		asl 	A_Mantissa+0,x 				; shift mantissa left
		rol 	A_Mantissa+1,x
		rol 	A_Mantissa+2,x
		rol 	A_Mantissa+3,x
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
;								Negate B as a 32 bit integer
;
; *******************************************************************************************

FPUIntegerNegateB:
		pha
		sec
		lda 	#0
		sbc 	B_Mantissa+0
		sta 	B_Mantissa+0
		lda 	#0
		sbc 	B_Mantissa+1
		sta 	B_Mantissa+1
		lda 	#0
		sbc 	B_Mantissa+2
		sta 	B_Mantissa+2
		lda 	#0
		sbc 	B_Mantissa+3
		sta 	B_Mantissa+3
		pla
		rts
