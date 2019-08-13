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
		.include 	"arithmetic/fpmacros.asm"
		.include 	"arithmetic/fputils.asm"
		.include 	"arithmetic/fpadd.asm"
		.include 	"arithmetic/fpmultiply.asm"
		.include 	"arithmetic/fpdivide.asm"
		.include 	"arithmetic/fpparts.asm"
		.include 	"arithmetic/fpfromstr.asm"
		.include 	"arithmetic/fptostr.asm"
		.include 	"arithmetic/inttostr.asm"

StartROM:
		ldx 		#$FF 					; empty stack
		txs

		jsr 		IF_Reset 				; reset external interface
		jsr 		IFT_ClearScreen

		lda 		#toConvert & $FF 		
		sta 		zGenPtr
		lda 		#toConvert >> 8
		sta 		zGenPtr+1
		jsr 		FPAsciiToNumber
		jsr 		FPUCopyBToA
		lda 		#0	 					; reset the index.
		sta 		NumBufX
		jsr 		FPToString 				; convert to string.
		.byte 		$5C
h1:		bra 		h1

toConvert:
		.text 		"0.00003167",0

ERR_Handler:
		bra 		ERR_Handler

NMIHandler:
		rti
		* = $FFFA
		.word		NMIHandler
		.word 		StartROM
		.word 		TIM_BreakVector

