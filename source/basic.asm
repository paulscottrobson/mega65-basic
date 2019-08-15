; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		basic.asm
;		Purpose :	Basic Main Program
;		Date :		10th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		* = $0000
		nop
		.include 	"data.asm"
		* = $A000
		.if 		INTERFACE=1
		.include 	"interface/interface_emu.asm"
		.else
		.include 	"interface/interface_mega65.asm"
		.endif
		;
		.include 	"interface/interface_tools.asm"
		.include 	"utility/tim.asm"
		.include 	"testing/fptest.asm"	
		.include 	"float/fpmacros.asm"
		.include 	"float/fputils.asm"
		.include 	"float/fpadd.asm"
		.include 	"float/fpmultiply.asm"
		.include 	"float/fpdivide.asm"
		.include 	"float/fpcompare.asm"
		.include 	"float/fpparts.asm"
		.include 	"integer/inttostr.asm"
		.include 	"integer/intfromstr.asm"

StartROM:
		ldx 	#$FF 						; empty stack
		txs

		jsr 	IF_Reset 					; reset external interface
		jsr 	IFT_ClearScreen

		jsr 	FPTTest
		ldx 	#6
		lda 	#Source & $FF
		sta 	zGenPtr
		lda 	#Source >> 8
		sta 	zGenPtr+1
		jsr 	INTFromString

		.if 	CPU=6502 					; exit on emulator
		.byte 	$5C
		.endif
freeze:	bra 	freeze		

Source:	.text 	"1234576",0

ERR_Handler:
		bra 	ERR_Handler

NMIHandler:
		rti

		* = $FFFA
		.word	NMIHandler
		.word 	StartROM
		.word 	TIM_BreakVector


