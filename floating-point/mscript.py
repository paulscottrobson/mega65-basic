# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		mscript.py
#		Purpose :	Floating point in Python
#		Date :		4th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re,sys
from float import *
#
#		Read and process script (% is line marker)
#
assert len(sys.argv) == 2,"No file name"
src = ["" if x.startswith("#") else x.strip() for x in open(sys.argv[1]).readlines()]
script = "%".join(src)
script = script.replace("\t","").replace("\r","").replace(" ","").upper()
#
#		Process the string
#
lineNumber = 1
floatA = Float().setInteger(0).toFloat()
floatB = Float().setInteger(0).toFloat()
while script != "":
	cmd = script[0]
	s
		cript = script[1:]
	#print(lineNumber,"<"+cmd+">",floatA.toString(),floatB.toString())
	if cmd == "L":
		m = re.match("^\\[(.*?)\\](.*)$",script)
		assert m is not None,"<"+script+">"
		floatB.convertFromString(m.group(1)).toFloat()
		script = m.group(2)
	elif cmd == "W":
		print("Output : "+floatA.convertToString())
	elif cmd == "C":
		floatA.copy(floatB)
	elif cmd == "+":
		floatA.addFloat(floatB)
	elif cmd == "-":
		floatA.subFloat(floatB)
	elif cmd == "*":
		floatA.mulFloat(floatB)
	elif cmd == "/":
		floatA.divFloat(floatB)
	elif cmd == "F":
		floatA.fractionalPart()
	elif cmd == "I":
		floatA.integerPart()
	elif cmd == "%":
		lineNumber += 1
	elif cmd == "Q":
		script = ""
	elif cmd == "=":
		assert floatA.equalFloat(floatB),"Different...."
	else:
		assert False,"Unknown "+cmd


