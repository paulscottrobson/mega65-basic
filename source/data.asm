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

A_Mantissa	.dword ?						; floating point registers
A_Exponent	.byte ?							; showab.py is dependent on these being at $10,$18
A_Sign 		.byte ?
A_Zero 		.byte ?
A_Type 		.byte ?

B_Mantissa	.dword ?
B_Exponent	.byte ?
B_Sign 		.byte ?
B_Zero 		.byte ?
B_Type 		.byte ?

Type_Integer = $00 							; type IDs, not tested directly.
Type_Float = $80
Type_String = $40

zTemp1:		.word ?							; temporary pointers
zTemp2:		.word ?
zTemp3:		.word ?

zLTemp1:	.dword ?						; long word (used in multiply)
zGenPtr:	.word ? 						; general pointer.

; *******************************************************************************************
;
;									   Buffers etc.
;
; *******************************************************************************************

		* = $300

Num_Buffer:	.fill 	32						; Buffer for number -> ASCII conversion
NumBufX:	.byte 	?						; Index into buffer for number -> ASCII conversion.
NumSuppress:.byte 	? 						; Buffer zero suppression flag.

ExpTemp:	.byte ? 						; Byte used in ASCII->number conversion.

Tim_PC:		.word ?							; program counter on BRK (Hi/Lo order)
Tim_IRQ:	.word ?							; IRQ Vector (Hi/Lo order)
Tim_SR:		.byte ? 						; Processor Status
Tim_A:		.byte ? 						; Processor Registers
Tim_X:		.byte ?
Tim_Y:		.byte ?
Tim_Z:		.byte ?
Tim_SP:		.byte ?							; Stack Pointer

