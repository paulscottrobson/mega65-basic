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

zLTemp1:	.dword ?						; long word (used in multiply)
zGenPtr:	.word ? 						; general pointer.

; *******************************************************************************************
;
;									   Buffers etc.
;
; *******************************************************************************************

		* = $300 							; expression stack area.

XS_Mantissa .dword ? 						; 4 byte mantissa, bit 31 set.
XS_Exponent .byte ?							; 1 byte exponent, 128 == 2^0 (float only)
XS_Type 	.byte ? 						; bit 7 sign (float only)
											; bit 6 zero (float only)
											; bit 2-3 type flags (zero)
											; bit 1 string flag
											; bit 0 integer flag.
											; float type when all type bits 0-3 are zero.


		* = $400

Tim_PC:		.word ?							; program counter on BRK (Hi/Lo order)
Tim_IRQ:	.word ?							; IRQ Vector (Hi/Lo order)
Tim_SR:		.byte ? 						; Processor Status
Tim_A:		.byte ? 						; Processor Registers
Tim_X:		.byte ?
Tim_Y:		.byte ?
Tim_Z:		.byte ?
Tim_SP:		.byte ?							; Stack Pointer

