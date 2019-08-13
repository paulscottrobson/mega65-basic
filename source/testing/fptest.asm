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

; *******************************************************************************************
;
;								Do the arithmetic tests
;
; *******************************************************************************************

FPTTest:
		lda 	#FPTTestData & $FF 			; set zGenPtr to data.
		sta 	zGenPtr
		lda 	#FPTTestData >> 8
		sta 	zGenPtr+1
		lda 	#0
		sta	 	TIM_Irq
		sta 	TIM_Irq+1
		;
FPTNextLine:
		lda 	TIM_Irq+1
		jsr 	TIM_WriteHex
		lda 	TIM_Irq
		jsr 	TIM_WriteHex
		jsr 	IFT_NewLine

		inc 	TIM_Irq
		bne 	FPTLoop
		inc 	TIM_Irq+1		
		;		
FPTLoop:
		jsr 	FPTGet 						; get next
		cmp 	#"L"						; Load [xxxx]
		beq 	FPT_Load
		cmp 	#"Q" 						; Quit
		beq 	FPT_Exit
		cmp 	#0 							; Null Quit too.
		beq 	FPT_Exit
		cmp 	#"C"						; Copy
		beq 	FPT_Copy
		cmp 	#"%"						; Ignore new line (%)
		beq 	FPTNextLine	
		cmp 	#" "+1 						; Ignore control
		bcc 	FPTLoop
		cmp 	#"="						; = Checks A = B as floats (e.g. almost ....)
		beq		FPT_Equals
		cmp 	#"+"						; Maths operations
		beq 	FPT_Add
		cmp 	#"-"		
		beq 	FPT_Subtract
		cmp 	#"*"		
		beq 	FPT_Multiply
		cmp 	#"/"		
		beq 	FPT_Divide
		cmp 	#"~"		
		beq 	FPT_Compare
		;
FPT_Error:
		bra 	FPT_Error		
		;
		;		+ - * / 		Operators
		;
FPT_Add:
		jsr 	FPAdd
		bra 	FPTLoop		
FPT_Subtract:		
		jsr 	FPSubtract
		bra 	FPTLoop		
FPT_Multiply:		
		jsr 	FPMultiply
		bra 	FPTLoop		
FPT_Divide:
		jsr 	FPDivide
		bra 	FPTLoop		
		;
FPT_Compare:
		jsr 	FPCompare
		ldy 	#0
		tax
		bpl 	_FPTNotNeg
		dey
_FPTNotNeg:
		jsr 	FPUSetBFromXY
		ldx 	#B_Mantissa-A_Mantissa
		jsr 	FPUToFloatX		
		jsr 	FPUCopyBToA
		bra 	FPTLoop		
		;
		;		= 				Equal as Floats ?
		;
FPT_Equals:
		jsr 	FPCompare
		cmp 	#0
		bne 	FPT_Error
		bra 	FPTLoop		
		;
		;		Q 				Quit
		;
FPT_Exit:
		;.byte 	$5C
h1:		bra 	h1
		;
		;		C 				Copy B to A
		;
FPT_Copy:		
		jsr 	FPUCopyBToA
		bra 	FPTLoop
		;
		;		L[xxxxx]		Load FP Constant.
		;
FPT_Load:
		jsr 	FPTGet 						; get the [ character
		jsr 	FPAsciiToNumber
		bcs 	FPT_Error
		ldx 	#B_Mantissa-A_Mantissa		; make it float
		jsr 	FPUToFloatX
_FPTLoad1:
		jsr 	FPTGet 						; find the ] character
		cmp 	#"]"
		bne 	_FPTLoad1
		jmp 	FPTLoop		

; *******************************************************************************************
;
;			Get a single character
;
; *******************************************************************************************

FPTGet:	phy
		ldy 	#0
		lda 	(zGenPtr),y
		pha
		inc 	zGenPtr
		bne 	_FPTGet1
		inc 	zGenPtr+1
_FPTGet1:
		pla
		ply
		rts		

; *******************************************************************************************
;
;				Included test data created in floating-point directory.
;
; *******************************************************************************************

FPTTestData:
		.binary	"maths.test"
		.byte 	0		
