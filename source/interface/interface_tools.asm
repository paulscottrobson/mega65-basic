; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		interface_tools.asm
;		Purpose :	Interface routines
;		Date :		10th August 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;
; *******************************************************************************************
; *******************************************************************************************

IFT_XCursor = $200								; current logical position on screen
IFT_YCursor = $201
IFT_Buffer = $202 								; scroll copy buffer.

; *******************************************************************************************
;
;										Clear Screen
;
; *******************************************************************************************

IFT_ClearScreen:
		pha
		phx
		phy
		jsr 	IF_Home 					; home cursor
		ldx 	#IF_Height 					; this many lines.
_IFT_CS0:
		ldy 	#IF_Width 					; this many chars/line
_IFT_CS1:
		lda 	#' '						; clear line.
		jsr 	IF_Write
		dey
		bne 	_IFT_CS1
		jsr 	IF_NewLine 					; next line down
		dex
		bne 	_IFT_CS0
		ply
		plx
		pla

; *******************************************************************************************
;
;										Home Cursor
;
; *******************************************************************************************

IFT_HomeCursor:
		pha
		jsr 	IF_Home
		lda 	#0
		sta 	IFT_XCursor
		sta 	IFT_YCursor
		pla
		rts

; *******************************************************************************************
;
;							Print Character on screen (ASCII in A)
;
; *******************************************************************************************

IFT_PrintCharacter:
		cmp 	#13 						; handle newline.
		beq 	IFT_NewLine
		pha
		jsr 	IFT_UpperCase 				; make upper case
		and 	#63 						; make 6 bit PETSCII
		jsr 	IF_Write 					; write out.
		inc 	IFT_XCursor 				; bump x cursor
		lda 	IFT_XCursor 				; reached RHS ?
		cmp 	#IF_Width
		bne 	_IFT_PCNotEOL
		jsr 	IFT_NewLine 				; if so do new line.
_IFT_PCNotEOL:		
		pla
		rts

; *******************************************************************************************
;
;									 	Go to next line
;
; *******************************************************************************************

IFT_NewLine:
		pha
		jsr 	IF_NewLine 					; new line on actual screen.
		lda 	#0 							; reset x position
		sta 	IFT_XCursor
		inc 	IFT_YCursor 				; move down.
		lda 	IFT_YCursor
		cmp 	#IF_Height 					; reached bottom.
		bne 	_IFT_NL_NotEOS
		jsr 	IFT_Scroll 					; scroll screen up.
_IFT_NL_NotEOS:		
		pla
		rts

; *******************************************************************************************
;
;								Capitalise ASCII character
;
; *******************************************************************************************

IFT_UpperCase:
		cmp 	#"a"
		bcc 	_IFT_UCExit
		cmp 	#"z"+1
		bcs 	_IFT_UCExit
		eor 	#$20
_IFT_UCExit:
		rts

IFT_Scroll:
		pha 								; save AXY
		phx
		phy
		ldx 	#0 							; start scrolling.
_IFT_SLoop:
		jsr 	_IFT_ScrollLine 			; scroll line X+1 => X
		inx
		cpx 	#IF_Height-1				; do whole screen
		bne 	_IFT_SLoop
		lda 	#IF_Height-1 				; move to X = 0,Y = A
		jsr 	_IFT_Move0A
		ldx 	#IF_Width 					; blank line
_IFT_SBlank:
		lda 	#32
		jsr 	IF_Write
		dex
		bne 	_IFT_SBlank
		;
		lda 	#IF_Height-1 				; move to X = 0,Y = A
		jsr 	_IFT_Move0A
		pla
		plx
		ply
		rts
		;
		;		Move to (0,A)
		;
_IFT_Move0A:
		tax
		jsr 	IFT_HomeCursor
		cpx 	#0
		beq 	_IFT_MOAExit
_IFT_MOALoop:
		jsr 	IF_NewLine
		inc 	IFT_YCursor
		dex 	
		bne		_IFT_MOALoop
_IFT_MOAExit:
		rts

_IFT_ScrollLine:
		phx
		phx
		txa 								; copy line into buffer.
		inc 	a 							; next line down.
		jsr 	_IFT_Move0A
		ldx 	#0
_IFTScrollCopy1:
		jsr 	IF_Read
		sta 	IFT_Buffer,x
		inx
		cpx 	#IF_Width
		bne 	_IFTScrollCopy1
		pla
		jsr 	_IFT_Move0A
		ldx 	#0
_IFTScrollCopy2:
		lda 	IFT_Buffer,x
		jsr 	IF_Write
		inx
		cpx 	#IF_Width
		bne 	_IFTScrollCopy2
		plx
		rts		