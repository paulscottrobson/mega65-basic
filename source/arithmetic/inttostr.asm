; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		inttostr.asm
;		Purpose :	Convert integer to string.
;		Date :		13th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;				Convert integer in A_Mantissa to ASCII String at Num_Buffer[NumBufX]
;
; *******************************************************************************************

INTToString:
		pha
		phx
		phy
		lda 		A_Mantissa+3 			; check -ve
		bpl 		_ITSNotMinus
		lda 		#"-"					; output a minus
		jsr 		ITSOutputCharacter
		ldx 		#0
		jsr 		FPUIntegerNegateX
_ITSNotMinus:		
		ldx 		#0 						; X is offset in table.
		stx 		NumSuppress 			; clear the suppression flag.
_ITSNextSubtractor:		
		ldy 		#0 						; Y is count.
_ITSSubtract:
		sec
		lda 		A_Mantissa 				; subtract number and push on stack
		sbc 		_ITSSubtractors+0,x
		pha
		lda 		A_Mantissa+1
		sbc 		_ITSSubtractors+1,x
		pha
		lda 		A_Mantissa+2
		sbc 		_ITSSubtractors+2,x
		pha
		lda 		A_Mantissa+3
		sbc 		_ITSSubtractors+3,x
		bcc 		_ITSCantSubtract 		; if CC, then gone too far.
		;
		sta 		A_Mantissa+3 			; save subtract off stack
		pla 		
		sta 		A_Mantissa+2
		pla 		
		sta 		A_Mantissa+1
		pla 		
		sta 		A_Mantissa+0
		;
		iny 								; bump count.
		bra 		_ITSSubtract 			; go round again.
		;
_ITSCantSubtract:
		pla 								; throw away interim answers
		pla
		pla
		cpy 		#0 						; if not zero then no suppression check
		bne 		_ITSOutputDigit
		bit 		NumSuppress 			; if suppression check +ve (e.g. zero)
		bpl 		_ITSGoNextSubtractor
_ITSOutputDigit:
		dec 		NumSuppress 			; suppression check will be -ve.
		tya 								; count of subtractions
		ora 		#"0"					; make ASCII
		jsr 		ITSOutputCharacter 		; output it.
		;
_ITSGoNextSubtractor:
		inx 								; next dword
		inx
		inx
		inx
		cpx 		#_ITSSubtractorsEnd-_ITSSubtractors
		bne 		_ITSNextSubtractor 		; do all the subtractors.
		lda 		A_Mantissa 				; and the last digit is left.
		ora 		#"0"
		jsr 		ITSOutputCharacter
		ply 								; and exit
		plx
		pla
		rts		
;
;		Powers of 10 table.
;
_ITSSubtractors:
		.dword 		1000000000
		.dword 		100000000
		.dword 		10000000
		.dword 		1000000
		.dword 		100000
		.dword 		10000
		.dword 		1000
		.dword 		100
		.dword 		10
_ITSSubtractorsEnd:

; *******************************************************************************************
;
;							Output A to Number output buffer
;
; *******************************************************************************************

ITSOutputCharacter:
		pha
		phx
		ldx 	NumBufX 					; save digit
		sta 	Num_Buffer,x
		lda		#0 							; follow by trailing NULL
		sta 	Num_Buffer+1,x
		inc 	NumBufX						; bump pointer.
		plx
		pla
		rts
