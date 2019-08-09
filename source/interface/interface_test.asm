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

		.include 	"interface_emu.asm"
;		.include 	"interface_mega65.asm"

TestCode:
		ldx 		#$FF 					; empty stack
		txs
		jsr 		IF_Reset 				; reset external interface

		jsr 		IF_Home 				; home r/w cursor to (0,0)

WaitKey:jsr 		IF_Home
		jsr 		IF_CheckBreak
		jsr 		IF_Write
		jsr 		IF_NewLine
		jsr 		IF_GetKey				; get a single key.
		beq 		WaitKey
		pha 								; write out what it is.
		lsr 		a
		lsr 		a
		lsr 		a
		lsr 		a
		jsr 		Nibble
		pla
		jsr 		Nibble
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


