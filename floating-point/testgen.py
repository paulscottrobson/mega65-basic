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
	if op == "~":
		result = n1-n2				# very infrequently wrong answer as slightly different !
		if abs(result) <= abs(n1+n2) / 2.0 / pow(2,13):
			result = 0
		else:
			result = -1 if result < 0 else 1
		return result
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
seed = random.randint(0,999999)
#seed = 653639
random.seed(seed)
print("Generating test using seed {0}".format(seed))
src = ""
count = 0
for i in range(0,4000):
	op = "+-*/~"[random.randint(0,4)]					# select operation
	n1 = create()										# first number
	n2 = create()										# second number.
	if random.randint(0,20) == 0:						# occasionally equal.
		n2 = n1
	if isOkay(op,n1,n2):
		src += "L["+strf(n1)+"] C"						# first number -> B then -> A
		src += " L["+strf(n2)+"]" 						# put into B
		src = src + " " + op 							# calculate result A = A op B or op(A)
		src += " L["+strf(calc(op,n1,n2))+"]"			# into B
		src += " = "									# check result.
		src = src + "\n"
		count += 1
print("Created {0} tests.\n".format(count))
open("maths.test","w").write(src)

