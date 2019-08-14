; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		intfromstr.asm
;		Purpose :	Convert String to integer
;		Date :		14th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Convert string at GenPtr into A_Register. Return CC if okay, CS on error
;		On successful exit A is the characters consumed from the string. Does not
;		support - (done by unary operator)
;
; *******************************************************************************************

IntFromString:
		phy
		lda 	#0 							; clear the mantissa
		sta 	A_Mantissa
		sta 	A_Mantissa+1
		sta 	A_Mantissa+2
		sta 	A_Mantissa+3
		tay 								; character index.
;
_IFSLoop:		
		lda 	(zGenPtr),y 				; get next
		cmp 	#"0"						; validate it.
		bcc 	_IFSExit
		cmp 	#"9"+1
		bcs 	_IFSExit
		;
		lda 	A_Mantissa+3 				; push mantissa on stack backwards
		pha
		lda 	A_Mantissa+2
		pha
		lda 	A_Mantissa+1
		pha
		lda 	A_Mantissa+0
		pha
		jsr 	IFSAShiftLeft 				; double
		jsr 	IFSAShiftLeft 				; x 4
		;
		clc 								; add saved value x 5
		pla
		adc 	A_Mantissa+0
		sta 	A_Mantissa+0
		pla
		adc 	A_Mantissa+1
		sta 	A_Mantissa+1
		pla
		adc 	A_Mantissa+2
		sta 	A_Mantissa+2
		pla
		adc 	A_Mantissa+3
		sta 	A_Mantissa+3
		jsr 	IFSAShiftLeft 				; x 10
		;
		lda 	(zGenPtr),y 				; add digit
		and 	#15
		iny
		adc 	A_Mantissa
		sta 	A_Mantissa
		bcc 	_IFSLoop
		inc 	A_Mantissa+1 				; propogate carry round.
		bne 	_IFSLoop
		inc 	A_Mantissa+2 		
		bne 	_IFSLoop
		inc 	A_Mantissa+3 		
		bra 	_IFSLoop
_IFSExit:
		tya 								; get offset
		clc
		bne 	_IFSOkay 					; if was non zero, conversion was okay
		sec 								; else no integer found.
_IFSOkay:		
		ply 								; and exit.
		rts
;
IFSAShiftLeft:
		#asl32 	A_Mantissa
		rts
