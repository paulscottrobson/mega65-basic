	.byte 	1     ; *** Load Float 99.94 ***
	.dword 	$c7e147ae
	.byte 	$87,$0
	.byte 	1     ; *** Load Float 1 ***
	.dword 	$80000000
	.byte 	$81,$0
	.byte 	1     ; *** Load Float 0.099999 ***
	.dword 	$cccc4695
	.byte 	$7d,$0
	.byte 	$2b   ; *** Command + ***
	.byte 	1     ; *** Load Float 0.1 ***
	.dword 	$cccccccc
	.byte 	$7d,$0
	.byte 	$2b   ; *** Command + ***
	.byte 	1     ; *** Load Float 1.2 ***
	.dword 	$99999999
	.byte 	$81,$0
	.byte 	$3d   ; *** Command = ***
	.byte 	0
