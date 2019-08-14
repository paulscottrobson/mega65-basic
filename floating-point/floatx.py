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
	#		Scale Float
	#
	def scale(self,power10):
		scalar = Float().setInteger(1).toFloat()
		for i in range(0,abs(power10)):
			scalar.times10()
		if power10 < 0:
			self.divFloat(scalar)
		else:
			self.mulFloat(scalar)
		return self
	#
	#		Convert number string to float/int.
	#
	def convertFromString(self,s):
		self.decimals = -1									# count of DP.
		self.setInteger(0)									# set result to zero
		#
		#		Convert the body
		#
		self.setInteger(0)
		m = re.match("^(\\d+)(.*)$",s)						# convert first bit.
		if m is not None:
			self.setInteger(int(m.group(1)))
			s = m.group(2)
		#
		#		Decimals bit.
		#
		m = re.match("^\\.(\\d+)(.*)$",s) 					# post decimals bit.	
		if m is not None:
			self.toFloat()									# make float			
			n = int(m.group(1))								# number part e.g. .[xxxx]
			fracPart = FloatX().setInteger(n).toFloat() 	# as a float
			fracPart.scale(-len(m.group(1)))				# divide by 10^Length to make 0-1
			self.addFloat(fracPart) 						# add to the integer part
			s = m.group(2)		
		#
		#		Look for exponents, which will change this.
		#
		m = re.match("^[Ee]([\\+\\-]?)(\\d+)(.*)",s)		# rip out exponent
		if m is not None:
			self.toFloat()									# make float
			scalar = int(m.group(2))						# convert exponent to integer
			if m.group(1) == "-":
				scalar = -scalar
			self.scale(scalar)								# multiply it.
			s = m.group(3)									# the leftovers.
		return self
	#
	#		Convert float to string.
	#
	def convertToString(self,exponentCheck = True):
		if self.type == Float.INTEGER:						# integer value.
			return str(self.value if (self.value & 0x80000000) == 0 else self.value-0x100000000)
		if self.zero != 0:									# zero ?
			return "0"
		#
		if exponentCheck: 									# checking for exponent
			if self.exponent < -16 or self.exponent > 20:	# do as exponent.
				exponent = 0 								# shift into range by scaling.
				self.toFloat()
				while self.exponent < 0 or self.exponent >= 4:
					if self.exponent < 0:
						self.times10()
						exponent -= 1
					else:
						self.divFloat(Float().setInteger(10).toFloat())
						exponent += 1
				return self.convertToString(False)+"e"+str(exponent)
		#
		s = "-" if self.sign else ""						# start with sign
		self.sign = 0 										# now unsigned.
		#
		s = s + str(Float().copy(self).toInteger().value)	# convert to body to integer.
		self.fractionalPart() 								# get fractional part.
		if self.zero == 0: 
			s = s + "."
			while self.zero == 0 and len(s) <= 10:			# while more data and not too long.
				self.times10() 								# x 10
				digit = str(Float().copy(self).toInteger().value)# add integer part
				s = s + digit 								# add digit
				self.fractionalPart()						# get fractional part.
			#
			while s[-1] == "0":								# strip trailing digits.
				s = s[:-1]
		return s

if __name__ == "__main__":
	nlist = ["123456.604","0.8","1.3e9","0","1.2","3456.78","2e4","31","42.1","0.000000021471","987654.321","1.44e-5"]
	#nlist = ["0.000000021471"]
	for s in nlist:
		f = FloatX().convertFromString(s+"!")
		print(s,float(s),f.toString())
		print("-----> "+f.convertToString())
		print("=====================")
