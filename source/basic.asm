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

;		.include 	"testing/fptest.asm"

		ldx 		#1
		ldy 		#0
_TLoop:
		phx
		phy
		lda 		#toConvert & $FF 		
		sta 		zGenPtr
		lda 		#toConvert >> 8
		sta 		zGenPtr+1
		jsr 		FPAsciiToNumber
		ply
		plx
		dey
		bne 		_TLoop
		dex
		bne 		_TLoop

;		jsr 		FPToString 				; convert to string.
		.byte 		$5C
h1:		bra 		h1

toConvert:
		.text 		"3842145.13",0

ERR_Handler:
		bra 		ERR_Handler

NMIHandler:
		rti
		* = $FFFA
		.word		NMIHandler
		.word 		StartROM
		.word 		TIM_BreakVector

