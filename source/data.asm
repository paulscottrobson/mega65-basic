; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		data.asm
;		Purpose :	Memory Allocation Program
;		Date :		10th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										Zero Page
;
; *******************************************************************************************

		* = $10

zTemp1:		.word ?							; temporary pointers
zTemp2:		.word ?
zTemp3:		.word ?

A_Mantissa	.dword ?						; floating point registers
A_Exponent	.byte ?
A_Sign 		.byte ?
A_Type 		.byte ?

B_Mantissa	.dword ?
B_Exponent	.byte ?
B_Sign 		.byte ?
B_Type 		.byte ?


; *******************************************************************************************
;
;									   Buffers etc.
;
; *******************************************************************************************

		* = $300

Tim_PC:		.word ?							; program counter on BRK (Hi/Lo order)
Tim_IRQ:	.word ?							; IRQ Vector (Hi/Lo order)
Tim_SR:		.byte ? 						; Processor Status
Tim_A:		.byte ? 						; Processor Registers
Tim_X:		.byte ?
Tim_Y:		.byte ?
Tim_Z:		.byte ?
Tim_SP:		.byte ?							; Stack Pointer

