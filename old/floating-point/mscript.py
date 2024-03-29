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
from floatx import *
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
floatA = FloatX().setInteger(0).toFloat()
floatB = FloatX().setInteger(0).toFloat()
while script != "":
	cmd = script[0]
	script = script[1:]
	#print(lineNumber,"<"+cmd+">",floatA.toString(),floatB.toString())
	if cmd == "L":
		m = re.match("^\\[(.*?)\\](.*)$",script)
		assert m is not None,"<"+script+">"
		floatA.convertFromString(m.group(1)+"!").toFloat()
		script = m.group(2)
	elif cmd == "W":
		print("Output : "+floatA.convertToString())
	elif cmd == "C":
		floatB.copy(floatA)
	elif cmd == "+":
		floatA.addFloat(floatB)
	elif cmd == "-":
		floatA.subFloat(floatB)
	elif cmd == "*":
		floatA.mulFloat(floatB)
	elif cmd == "/":
		floatA.divFloat(floatB)
	elif cmd == "!":
		floatA.sign = 0 if floatA.sign != 0 else 0xFF
	elif cmd == "~":
		result = floatA.cmpFloat(floatB)
		floatA.setInteger(result).toFloat()
	elif cmd == "%":
		lineNumber += 1
	elif cmd == "Q":
		script = ""
	elif cmd == "=":
		assert floatA.cmpFloat(floatB) == 0,"Different @ {0}".format(lineNumber)
	else:
		assert False,"Unknown "+cmd
print("Script run successfully.")

