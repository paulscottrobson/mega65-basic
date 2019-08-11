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

StartROM:
		ldx 		#$FF 					; empty stack
		txs
		jsr 		IF_Reset 				; reset external interface

		jsr 		IFT_ClearScreen

		ldx 		#31
		ldy 		#0
		jsr 		FPUSetBFromXY
		ldx 		#B_Mantissa-A_Mantissa
		jsr 		FPUToFloatX
		jsr 		FPUCopyBToA		
		ldx 		#31
		ldy 		#0
		jsr 		FPUSetBFromXY
		ldx 		#B_Mantissa-A_Mantissa
		jsr 		FPUToFloatX
		jsr 		FPSubtract
		;jsr 		FPUATOInteger
		.byte 		$5C

ERR_Handler:
		bra 		ERR_Handler

NMIHandler:
		rti
		* = $FFFA
		.word		NMIHandler
		.word 		StartROM
		.word 		TIM_BreakVector

