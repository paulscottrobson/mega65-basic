# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		floatx.py
#		Purpose :	Extended Floating point in Python
#		Date :		1th August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random,re
from float import *

# *******************************************************************************************
#
#					32 bit floating point/integer class - extensions
#
# *******************************************************************************************

class FloatX(Float):
	#
	#		Integer part
	#
	def integerPart(self):
		assert self.type == Float.FLOAT 					# float in ?
		if self.exponent < 0:								# too large
			self.zero = 0xFF
			return self
		mask = 0xFFFFFFFF >> self.exponent 					# strip mask.
		self.value = self.value & (mask ^ 0xFFFFFFFF)		# mask out lower bits.
		if self.value == 0:									# if fractional part zero, return zero
			self.zero = 0xFF
		else:
			self.normalize()
		return self
	#
	#		Fractional part. Same code except chops the other bit.
	#
	def fractionalPart(self):
		assert self.type == Float.FLOAT 					# float in ?
		if self.exponent < 0:								# already fractional
			return self
		#
		mask = 0xFFFFFFFF >> self.exponent 					# strip mask.
		self.value &= mask						
		#
		if self.value == 0:									# if fractional part zero, return zero
			self.zero = 0xFF
		else:
			self.sign = 0
			self.normalize()
		return self
	#
	#		Compare two floats. Returns -1,0,1
	#
	def cmpFloat(self,float2):
		exp = (self.exponent + float2.exponent)/2 - 12		# this degree of accuracy required.
		diff = abs(self.exponent - float2.exponent) 		# difference of 2^ allowed
		if exp < -0x7F: 									# bottom out.
			exp = -0x7F
		self.subFloat(float2)								# calculate difference.
		if self.zero != 0:									# actually zero.
			return 0
		if self.exponent < exp and diff <= 1: 				# in range for 'nearly zero'
			return 0
		return -1 if self.sign else 1 						# compare values.
	#
	#		Convert number string to float/int.
	#
	def convertFromString(self,s):
		sign = 1 											# sign of value
		if s[0] == '-': 									# work out sign.
			sign = -1
			s = s[1:]
		self.decimals = -1									# count of DP.
		self.setInteger(0)									# set result to zero
		#
		#		Convert the body
		#
		while (s[0] >= '0' and s[0] <= '9') or s[0] == '.':	# while in number
			if s[0] >= '0' and s[0] <= '9':
				if (self.value >> 24) < 0x0C:
					self.value = self.value * 10			# multiply by 10
					self.value += int(s[0])					# add digit value.
					if self.decimals >= 0:					# bump dec count if past DP.
						self.decimals += 1
				else:
					if self.decimals < 0: 					# cannot throw non-decimals
						assert False,"Overflow"
			else:
				self.decimals = 0				
			s = s[1:]
		if sign < 0:
			self.value = (-self.value) & 0xFFFFFFFF
		#
		#		If self.decimals > 0 we need to divide by that many decimal places.
		#
		self.decimals = -self.decimals if self.decimals > 0 else 0
		#
		#		Look for exponents, which will change this.
		#
		if s[0].lower() == "e":								# exponents ?
			s = s[1:]
			countSign = 1									# direction ?
			if s[0] == "+" or s[0] == "-":					# handle + or -
				countSign = -1 if s[0] == "-" else 1 		# set direction.
				s = s[1:]
			countExp = 0
			while s[0] >= '0' and s[0] <= '9':				# get exponent
				countExp = countExp * 10 + int(s[0])
				s = s[1:]
				assert countExp < 120,"Exponent bad"
			self.decimals = self.decimals + countExp * countSign
		#
		if self.decimals != 0:								# decimal adjustment required.
			self.toFloat()									# we need fp work now.
			fScalar = Float().setInteger(1).toFloat() 		# workout the divider/multiplier
			for i in range(0,abs(self.decimals)):
				fScalar.times10()
			if self.decimals < 0:							# scale up or down.
				self.divFloat(fScalar)
			else:
				self.mulFloat(fScalar)
		return self
	#
	#		Convert float to string.
	#
	def convertToString(self):
		if self.type == Float.INTEGER:						# integer value.
			return str(self.value if (self.value & 0x80000000) == 0 else self.value-0x100000000)
		if self.zero != 0:
			return "0"
		#
		#	TODO: Exponent - shift to 0 ? - output the number - output the shift.
		#
		s = "-" if self.sign else ""						# start with sign
		self.sign = 0 										# now unsigned.
		#
		s = s + str(Float().copy(self).toInteger().value)	# convert to body to integer.
		self.fractionalPart() 								# get fractional part.
		if self.zero == 0 and len(s) < 10:
			s = s + "."
			while self.zero == 0: 							# while more data and digits
				self.times10() 								# x 10
				digit = str(Float().copy(self).toInteger().value)# add integer part
				s = s + digit 								# add digit
				self.fractionalPart()						# get fractional part.
			#
			while s[-1] == "0":								# strip trailing digits.
				s = s[:-1]
		return s

if __name__ == "__main__":
	#nlist = ["123456.604",".8","1.3e9","0","-1.2","-3456.78","-2e4","31","42.4","0.000000021471","987654.321","1.44e-5"]
	#nlist = ["0.000000021471"]
	#for s in nlist:
	#	f = FloatX().convertFromString(s+"!")
	#	print(s,float(s),f.toString())
	#	print("-----> "+f.convertToString())
	#	print("=====================")
	random.seed(42)
	for i in range(0,2000*1000):
		if i % 10000 == 0:
			print(i)
		n1 = random.randint(-10000000,10000000)/1000
		if random.randint(0,3) == 0:
			n1 = n1 / 10000
		if random.randint(0,5) == 0:
			n1 = int(n1)
		f = FloatX().convertFromString(str(n1)+"!")
		s = f.convertToString()
		#print("Us",s,"Python",n1,str(n1))
		if n1 != 0:
			error = abs(float(s)-n1)/abs(n1)		
			allowed = 0.00001 if n1 != int(n1) else 0
			assert error <= allowed,"{0} {1} {2}".format(s,n1,error)

		else:
			assert s == "0"