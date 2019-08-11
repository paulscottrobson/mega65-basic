; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		fpmacros.asm
;		Purpose :	Floating Point Macros
;		Date :		11th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

iszero32 .macro
		lda 	\1 							; check if \1 zero
		ora 	\1+1
		ora 	\1+2
		ora 	\1+3
		.endm

add32 	.macro 								; add \2 to \1
		clc
		lda 	\1+0
		adc 	\2+0
		sta 	\1+0
		lda 	\1+1
		adc 	\2+1
		sta 	\1+1
		lda 	\1+2
		adc 	\2+2
		sta 	\1+2
		lda 	\1+3
		adc 	\2+3
		sta 	\1+3
		.endm

sub32 	.macro 								; subtract \2 from \1
		sec
		lda 	\1+0
		sbc 	\2+0
		sta 	\1+0
		lda 	\1+1
		sbc 	\2+1
		sta 	\1+1
		lda 	\1+2
		sbc 	\2+2
		sta 	\1+2
		lda 	\1+3
		sbc 	\2+3
		sta 	\1+3
		.endm


asl32 	.macro 								; asl32 \1
		asl 	0+\1
		rol 	1+\1
		rol 	2+\1
		rol 	3+\1
		.endm		

asl32x 	.macro 								; asl32 \1,x
		asl 	0+\1,x
		rol 	1+\1,x
		rol 	2+\1,x
		rol 	3+\1,x
		.endm		

lsr32 	.macro 								; lsr32 \1
		lsr 	3+\1
		ror 	2+\1
		ror 	1+\1
		ror 	0+\1
		.endm		

lsr32x 	.macro 								; lsr32 \1,x
		lsr 	3+\1,x
		ror 	2+\1,x
		ror 	1+\1,x
		ror 	0+\1,x
		.endm		

ror32 	.macro 								; ror32 \1
		ror 	3+\1
		ror 	2+\1
		ror 	1+\1
		ror 	0+\1
		.endm		

ror32x 	.macro 								; ror32 \1,x
		ror 	3+\1,x
		ror 	2+\1,x
		ror 	1+\1,x
		ror 	0+\1,x
		.endm		
