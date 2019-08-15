; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpfromstr.asm
;		Purpose :	Convert String to floating point
;		Date :		14th August 2019
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
		pha 								; push AX
		phx

		lda		(zGenPtr),y					; followed by a DP.
		cmp 	#"."
		beq	 	_FPFIsDecimal
		jmp 	_FPFNotDecimal
_FPFIsDecimal:
		iny 								; consume the decimal.
		#fpush 	B_Mantissa 					; push B fp.
		;
		phy
		lda		(zGenPtr),y					; followed by a DP.
		ldx 	#0 							; convert A to float.
		jsr 	FPUToFloatX
		jsr 	FPUCopyAToB 				; put the integer (as float) part in B.
		jsr 	INTFromStringY 				; get the part after the DP.
		ldx 	#0							; convert that to a Float
		jsr 	FPUToFloatX
		;
		pla 								; calculate - chars consumed.		
		sty 	ExpTemp
		sec		
		sbc 	ExpTemp 					; this is the shift amount
		jsr 	FPScaleABy10PowerAC 		; scale it by that.
		jsr 	FPAdd 						; Add B to A giving the fractional bit.
		;
		lda 	(zGenPtr),y 				; exponent ?
		cmp 	#"E"
		beq 	_FPFExponent
		cmp 	#"e"
		bne 	_FPFEndTranslate
		;
_FPFExponent:		
		lda 	#0 							; zero exponent 
		sta 	ExpTemp

		iny 								; skip E 
		lda 	(zGenPtr),y 				; get next char, + - or a constant should be.
		pha 								; save for later.
		cmp 	#"+" 						; if + or - then skip it.
		beq 	_FPFSkipFetch
		cmp 	#"-"
		bne 	_FPFExpLoop
_FPFSkipFetch:
		iny 							
_FPFExpLoop:		
		lda 	(zGenPtr),y 				; get character
		cmp 	#"0" 						; check 0-9
		bcc 	_FPFDoExponent
		cmp 	#"9"+1
		bcs 	_FPFDoExponent
		;
		lda 	ExpTemp 					; exponent too much ?
		cmp 	#3
		bcs 	_FPFExpOverflow
		asl 	a 							; x old exponent by 10
		asl 	a
		adc 	ExpTemp
		asl 	a
		;
		clc 
		adc 	(zGenPtr),y 				; add digit
		sec
		sbc 	#"0"						; fix up.
		sta 	ExpTemp
		iny 								; consume character
		bra 	_FPFExpLoop		

_FPFDoExponent:
		lda 	ExpTemp
		plx 								; get the next char
		cpx 	#"-" 						; if it was -
		bne 	_FPFNoNegExponent
		eor 	#$FF
		inc 	a
_FPFNoNegExponent:
		jsr 	FPScaleABy10PowerAC 		; scale by the exponent.

_FPFEndTranslate:
		#fpull	B_Mantissa	
_FPFNotDecimal:		 	
		plx
		pla
		rts

_FPFExpOverflow:
		jsr 	ERR_Handler
		.text 	"Exponent Range",0

; *******************************************************************************************
;
;					Multiply the FP A Register by 10 ^ AX. Preserves B
;
; *******************************************************************************************

FPScaleABy10PowerAC:
		pha
		phx
		phy
		tay 

		beq 	_FPSAExit 					; zero, do nothing.

		#fpush 	B_Mantissa 					; save B

		phy 								; save actual count.
		cpy 	#0 							; put |Y| in Y
		bpl 	_FPSAAbs
		tya
		eor 	#$FF
		inc 	a
		tay
_FPSAAbs:
		phy 								; rest
		ldx 	#1
		ldy 	#0
		jsr 	FPUSetBFromXY
		ldx 	#B_Mantissa-A_Mantissa
		jsr 	FPUToFloatX 				; B is now 1.0 float
		ply
_FPSATimes10: 								; convert to scalar.
		jsr 	FPUTimes10X
		dey
		bne 	_FPSATimes10
		;
		pla 								; restore actual count
		bpl 	_FPSAMultiply
		jsr 	FPDivide 					; use to decide whether x or / scalar
		bra 	_FPSAPopExit
_FPSAMultiply:
		jsr 	FPMultiply		
_FPSAPopExit:
		#fpull 	B_Mantissa 					; restore B
_FPSAExit:
		ply
		plx
		pla				
		rts
