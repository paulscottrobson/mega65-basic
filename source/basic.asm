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

StartROM:
		ldx 		#$FF 					; empty stack
		txs
		jsr 		IF_Reset 				; reset external interface

		jsr 		IFT_ClearScreen
		jmp 		TIM_Start

Next:	jsr 		IFT_NewLine
WaitKey:jsr 		IFT_ReadLine
		jsr 		IFT_NewLine
		ldx 		#0
_OutLine:
		lda 		$280,x
		beq 		Next
		jsr 		IFT_PrintCharacter
		lda 		#"."
		jsr 		IFT_PrintCharacter
		inx
		bra 		_OutLine		

IRQHandler:
		bra 		IRQHandler

NMIHandler:
		rti
		* = $FFFA
		.word		NMIHandler
		.word 		StartROM
		.word 		IRQHandler

