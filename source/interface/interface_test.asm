; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		interface_test.asm
;		Purpose :	Assembler Interface Test
;		Date :		9th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

		* = $0000
		nop

		* = $A000

		.if 		INTERFACE=1
		.include 	"interface_emu.asm"
		.else
		.include 	"interface_mega65.asm"
		.endif
		.include 	"interface_tools.asm"

TestCode:
		ldx 		#$FF 					; empty stack
		txs
		jsr 		IF_Reset 				; reset external interface

		jsr 		IFT_ClearScreen

WaitKey:jsr 		IF_GetKey				; get a single key.
		beq 		WaitKey
		jsr 		IFT_PrintCharacter
		bra 		WaitKey

Nibble:	and 		#15
		cmp 		#10
		bcc 		_NINoSub
		sec
		sbc 		#48+9
_NINoSub:
		clc
		adc 		#48
		jsr 		IF_Write
		rts		

DummyRoutine:
		rti
		* = $FFFA
		.word		DummyRoutine
		.word 		TestCode
		.word 		DummyRoutine
