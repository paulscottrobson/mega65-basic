# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		testgen.py
#		Purpose :	Generate unit tests in mscript
#		Date :		4th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random

def create():
	n = random.randint(0,3)
	if n == 0:
		return random.randint(-3,3)
	if n == 1:
		return random.randint(-20000,20000)/100
	if n == 2:
		return random.randint(-20000000,20000000) / 1000
	n = random.randint(-1000,1000)/100
	pw = random.randint(-15,15)
	return n * pow(10,pw)

def calc(op,n1,n2):
	if op == "+":
		return n1+n2
	if op == "-":
		return n1-n2
	if op == "*":
		return n1 * n2
	if op == "/":
		return n1 / n2
	if op == "I":
		return int(n1)
	if op == "F":
		return n1-int(n1)
	assert False

def isOkay(op,n1,n2):
	if op == "/" and n2 == 0:
		return False
	if op == "*":
		s = str(n1*n2)
		if len(s) > 8 and s.find("E") < 0:
			return False
	return True 

def strf(n):
	if abs(n) < 800000:
		return str(n)
	return "{0:6e}".format(n)

random.seed()
src = ""
for i in range(0,4000):
	op = "+-*/FI"[random.randint(0,3)]					# select operation
	n1 = create()										# first number
	n2 = create()										# second number.
	if isOkay(op,n1,n2):
		src += "L["+strf(n1)+"] C"						# first number -> B then -> A
		if op != "F" and op != "I":						# second number, if needed.
			src += " L["+strf(n2)+"]" 					# put into B
		src = src + " " + op 							# calculate result A = A op B or op(A)
		src += " L["+strf(calc(op,n1,n2))+"]"			# into B
		src += " = "									# check result.
		src = src + "\n"

print(src)
