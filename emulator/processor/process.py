# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		process.py
#		Purpose :	CPU Description Document Processor.
#		Date :		4th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re
#
#			EAC Mappers.
#
eacMap = { 	"$nn":"zero","$nnnn":"abs","$nn,x":"zerox","$nn,y":"zeroy",
			"$nnnn,x":"absx","$nnnn,y":"absy","#$nn":"imm8","":"implied",
			"($nn,x)":"indx","($nn),y":"indy","($nn),z":"indz","a":"acc",	
			"$zp,$nn":"bittest","$nn,$nn":"bittest","($nnnn)":"absind",
			"($nnnn,x)":"absindx","($nn,sp),y":"stkindy","#$nnnn":"imm16",
			"$rr":"rel8","$rrrr":"rel16"
}
#
#			List of non-implemented instructions
#
remove = [ "asw", "dew", "inw", "row", "map", "aug", "brk", "phw","smb","rmb","bbs","bbr","trb","tsb" ]
#
#			Categories of instruction.
#
loadType = 		[ "adc","and","cmp","eor","sbc","ora","bit","lda","ldx","ldy","ldz","cpx","cpy","cpz"]
saveType = 		[ "sta","stx","sty","stz" ]
rmwType =  		[ "asl","asr","lsr","ror","rol","inc","dec" ]
rmwWordType = 	[ "asw", "dew", "inw","row", "phw" ]
flagType = 		[ "clc","cld","clv","cle","cli","sec", "sei", "sed","see" ]
stackType = 	[ "pha","phx","phy","phz","pla","plx","ply","plz" ]
transferType =  [ "tax","txa","tay","tya","taz","tza" ]
branchType = 	[ "beq","bne","bmi","bpl","bvc","bvs","bcc","bcs","bra" ]
incDecType = 	[ "inx","iny","inz","dex","dey","dez" ]
#
#			Read source and strip out lines.
#
src = [x.replace("\t"," ").rstrip() for x in open("65ce02.txt").readlines()]
src = [x for x in src if x.startswith(" ")]
src = [x for x in src if re.match("^\\s+[A-Z][A-Z][A-Z].*65.*02$",x) is not None]
#
#			Analyse it.
#
opcodes = [ None ] * 256
for s in src:
	m = re.match("^\\s*([A-Z]+[0-7]?)\\s+(.*?)\\s+([0-9A-F][0-9A-F]).*65.*02$",s)
	assert m is not None,s
	opcode = int(m.group(3),16)
	assert opcodes[opcode] is None,"Duplicate "+s
	mode = m.group(2).lower()
	if (opcode & 0x1F) == 0x10  or (opcode & 0x1F) == 0x13 or opcode == 0x80 or opcode == 0x83 or opcode == 0x63:
		mode = "$rr" if (opcode & 0x0F) == 0 else "$rrrr"
	assert mode in eacMap,"Mode "+mode
	mnemonic = m.group(1).lower()
	if mnemonic[:3] not in remove:
		opcodes[opcode] = [ opcode, mnemonic ,eacMap[mode] ]

definitions = {}

print("//\n// This file is generated from 65CE02.txt\n//\n")
for opc in range(0,256):
	if opcodes[opc] is not None:
		mnemonic = opcodes[opc][1]
		aMode = opcodes[opc][2]
		decode = "" if aMode == "acc" or aMode == "implied" else " @1"
		if aMode.find("abs") >= 0 or aMode == "rel16":
			decode = " @2"
		decode = mnemonic+decode
		eac = "EAC_"+aMode.upper()+"()"
		definitions[eac] = True

		print("case 0x{0:02x}: // *** ${0:02x} {1} {2} ***".format(opc,mnemonic,aMode))

		if mnemonic in loadType:
			print("\t{0};READ8();OPC_{1}();".format(eac,mnemonic.upper()))
			definitions["OPC_"+mnemonic.upper()+"()"] = True

		elif mnemonic in saveType:
			print("\t{0};MBR = {1};WRITE8();".format(eac,mnemonic[-1].upper()))

		elif mnemonic in rmwType:
			isAcc = aMode = "acc"
			print("\t{0};{1};OPC_{2}();{3};".format(eac,"MBR = A" if isAcc else "READ8()",
											mnemonic.upper(),"A = MBR" if isAcc else "WRITE8()"))
			definitions["OPC_"+mnemonic.upper()+"()"] = True

		elif mnemonic in rmwWordType:
			assert False,"Not implemented"

		elif mnemonic in flagType:
			print("\t{0}_FLAG = {1};".format(mnemonic[-1].upper(),0 if mnemonic[0] == 'c' else 1))

		elif mnemonic in stackType:
			if mnemonic[1] == 'h':
				print("\tPUSH8({0});".format(mnemonic[-1].upper()))
			else:
				print("\t{0} = PULL8();SETNZ({0});".format(mnemonic[-1].upper()))

		elif mnemonic in transferType:
			print("\t{0} = {1};SETNZ({0});".format(mnemonic[-1].upper(),mnemonic[1].upper()))

		elif mnemonic in branchType:
			print("\t{0};if (TEST_{1}()) PC = MAR;".format(eac,mnemonic.upper()))
			definitions["TEST_"+mnemonic.upper()+"()"] = True

		elif mnemonic in incDecType:
			cmd = "INC" if mnemonic[0] == "i" else "DEC"
			print("\tMBR = {0};OPC_{1}();{0} = MBR;".format(mnemonic[-1].upper(),cmd))

		else:
			s = ""
			if aMode != "implied" and aMode != "acc":
				s = eac+";"
			print("\t{0}OPC_{1}();".format(s,mnemonic.upper()))
			definitions["OPC_"+mnemonic.upper()+"()"] = True

		print("\tbreak;\n")


macros = [x for x in definitions.keys()]
macros.sort()

open("temp","w").write("\n".join(["#define {0}".format(k) for k in macros]))

