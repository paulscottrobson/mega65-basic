; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpmacros.asm
;		Purpose :	Floating Point Macros
;		Date :		15th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************

asl32x 	.macro 								; asl32 \1,x
		asl 	0+\1,x
		rol 	1+\1,x
		rol 	2+\1,x
		rol 	3+\1,x
		.endm		

lsr32x 	.macro 								; lsr32 \1,x
		lsr 	3+\1,x
		ror 	2+\1,x
		ror 	1+\1,x
		ror 	0+\1,x
		.endm		

ror32x 	.macro 								; ror32 \1,x
		ror 	3+\1,x
		ror 	2+\1,x
		ror 	1+\1,x
		ror 	0+\1,x
		.endm		

inx6 	.macro 								; add 6 to x
		inx
		inx
		inx
		inx
		inx
		inx
		.endm

add32x 	.macro 								; add \2 to \1
		clc
		lda 	\1+0,x
		adc 	\2+0,x
		sta 	\1+0,x
		lda 	\1+1,x
		adc 	\2+1,x
		sta 	\1+1,x
		lda 	\1+2,x
		adc 	\2+2,x
		sta 	\1+2,x
		lda 	\1+3,x
		adc 	\2+3,x
		sta 	\1+3,x
		.endm

sub32x 	.macro 								; subtract \2 from \1
		sec
		lda 	\1+0,x
		sbc 	\2+0,x
		sta 	\1+0,x
		lda 	\1+1,x
		sbc 	\2+1,x
		sta 	\1+1,x
		lda 	\1+2,x
		sbc 	\2+2,x
		sta 	\1+2,x
		lda 	\1+3,x
		sbc 	\2+3,x
		sta 	\1+3,x
		.endm

; *******************************************************************************************

iszero32 .macro
		lda 	\1 							; check if \1 zero
		ora 	\1+1
		ora 	\1+2
		ora 	\1+3
		.endm




asl32 	.macro 								; asl32 \1
		asl 	0+\1
		rol 	1+\1
		rol 	2+\1
		rol 	3+\1
		.endm		

lsr32 	.macro 								; lsr32 \1
		lsr 	3+\1
		ror 	2+\1
		ror 	1+\1
		ror 	0+\1
		.endm		


ror32 	.macro 								; ror32 \1
		ror 	3+\1
		ror 	2+\1
		ror 	1+\1
		ror 	0+\1
		.endm		


fpush 	.macro 								; push 8 byte value on 6502 stack
		ldx 	#0
_F1:	lda 	\1,x
		pha
		inx
		cpx 	#8
		bne 	_F1
		.endm

fpull 	.macro 								; pull 8 byte value off 6502 stack.
		ldx 	#7
_F2:	pla
		sta 	\1,x
		dex
		bpl		_F2
		.endm

