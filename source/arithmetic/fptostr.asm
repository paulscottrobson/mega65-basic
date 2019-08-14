; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fptostr.asm
;		Purpose :	Convert A_Mantissa to string.
;		Date :		13th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

FPToString:
		pha
		phx
		phy

		lda 		#0	 					; reset the index.
		sta 		NumBufX

		lda 		A_Type
		bne 		_FPTSIsFloat 			; if zero, go to floating point code.
		jsr 		INTToString 			; convert it as a simple int, it's an integer.

_FPTSExit:
		ply
		plx
		pla
		rts
		;
_FPTSZero:
		lda 		#"0"
		jsr 		ITSOutputCharacter
		bra 		_FPTSExit
		;
_FPTSIsFloat:
		lda 		A_Zero 					; is it zero ?
		bne 		_FPTSZero 				; output a zero ?
		;
		lda 		A_Sign 					; is it signed ?
		beq 		_FPTSNotSigned
		lda 		#0 						; clear sign flag
		sta 		A_Sign
		lda 		#"-"					; output a minus
		jsr 		ITSOutputCharacter
_FPTSNotSigned:
		jsr 		FPTOutputBody 			; output the body.
		bra 		_FPTSExit

FPTOutputBody:
		jsr 		FPUCopyAtoB 			; save in B
		ldx 		#0
		jsr 		FPUAToInteger 			; convert A to integer
		jsr 		INTToString  			; output integer part as string.
		jsr 		FPUCopyBToA 			; get back.
		jsr 		FPFractionalPart 		; get the fractional part.
		lda 		A_Zero 					; any fractional part ?
		bne 		_FPTOExit 				; exit if so.
		lda 		#"."					; output a decimal place
		jsr 		ITSOutputCharacter 		
_FPDecimalLoop:
		lda 		A_Zero 					; zeroed out A
		bne 		_FPTOExit2
		lda 		NumBufX 				; too many characters out.
		cmp			#11
		bcs 		_FPToExit2
		;
		ldx 		#0						; multiply A by 10
		jsr 		FPUTimes10X
		jsr 		FPUCopyAToB 			; copy to B
		jsr 		FPUAToInteger 			; make integer
		lda 		A_Mantissa 				; output digit
		ora 		#"0"
		jsr 		ITSOutputCharacter
		jsr 		FPUCopyBToA 			; get it back.
		jsr 		FPFractionalPart 		; get fractional part
		bra 		_FPDecimalLoop
_FPTOExit2:	
		ldx 		NumBufX 				; strip trailing DPs.
_FPStrip:
		dex 								; back one.
		bmi 		_FPToExit 				; too far
		lda 		Num_Buffer,x 			; 0 ?
		cmp 		#"0"
		beq 		_FPStrip
		inx 								; first zero.
		stx 		NumBufX 				; save position
		lda 		#0 						; trim
		sta 		Num_Buffer,X 
_FPTOExit:
		rts
