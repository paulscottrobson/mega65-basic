# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showab.py
#		Purpose :	Show A + B from dump.mem
#		Date :		11th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

mem = [x for x in open("memory.dump","rb").read(0x10000)]
for v in range(0,2):
	a = v * 8 + 0x10
	mantissa = mem[a] + (mem[a+1] << 8)+ (mem[a+2] << 16)+ (mem[a+3] << 24)
	exponent = mem[a+4]
	sign = mem[a+5]
	zero = mem[a+6]
	typeID = mem[a+7]
	print("Register {0} at ${1:04x} Mantissa:{2:08x} Exponent:{3:02x} Sign:{4:02x} Zero:{5:02x} Type:{6:02x}".format(chr(v+65),a,mantissa,exponent,sign,zero,typeID))
	if typeID == 0x00:
		mantissa = mantissa if (mantissa & 0x80000000) == 0 else mantissa - 0x100000000
		print("\tInteger {0}".format(mantissa))	
	if typeID == 0x40:
		assert False
	if typeID == 0x80:
		fpv = 0.0
		if (exponent & 0x80) != 0:
			exponent = exponent - 0x100
		if zero == 0:
			fpv = pow(2,exponent) * mantissa / 0x100000000 * (-1 if sign != 0 else 1)
		print("\tFloat {0}".format(fpv))
	print()