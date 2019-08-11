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
		.include 	"arithmetic/fputils.asm"

StartROM:
		ldx 		#$FF 					; empty stack
		txs
		jsr 		IF_Reset 				; reset external interface

		jsr 		IFT_ClearScreen

		ldx 		#$00
		ldy 		#$FF
		jsr 		FPUSetBFromXY
		jsr 		FPUBToFloat
		jsr 		FPUCopyBToA		
		jsr 		FPUBToInteger
		.byte 		$5C

NMIHandler:
		rti
		* = $FFFA
		.word		NMIHandler
		.word 		StartROM
		.word 		TIM_BreakVector

