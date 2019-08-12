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
			self.zero = 0
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
			self.zero = 0
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
	#		Convert float to string.
	#
	def convertToString(self):
		assert self.type == Float.FLOAT 					# float in ?
		#
		if abs(self.exponent) > 26:							# exponent too large
			displayExponent = 0 							# adjust it by mul/div by 10.
			if self.exponent > 0:
				while self.getFloatValue() >= 10.0:
					displayExponent += 1
					self.divFloat(Float().setInteger(10).toFloat())
			else:
				while self.getFloatValue() < 1.0:
					self.mulFloat(Float().setInteger(10).toFloat())
					displayExponent -= 1
			return self.convertToString()+"e"+str(displayExponent)
		#
		s = "-" if self.sign else ""						# - sign if negative
		ip = Float().copy(self).toInteger()					# get integer part
		s  = s + str(abs(ip.getIntegerValue()))		
		placeCount = 10-len(s)								# don't print silly things.
		self.fractionalPart()
		self.sign = 0x00 									# never show any signs.
		if self.zero != 0:									# fractional zero, no decimals		
			return s
		#
		s = s + "."											# add DP
		while self.zero == 0x00 and placeCount > 0: 		# while not zero or silly place levels
			self.mulFloat(Float().setInteger(10).toFloat())	# x 10 and add integer part.
			s = s + str(Float().copy(self).toInteger().getIntegerValue())
			self.fractionalPart()
			placeCount -= 1
		while s.endswith("0"):								# remove trailing zeros
			s = s[:-1]
		return s
	#
	#		Convert number string to float/int.
	#
	def convertFromString(self,s):
		self.setInteger(0)
		sign = 1 											# sign value.
		if s.startswith("-"):								# handle -ve numbers.
			sign = -1
			s = s[1:]
		#
		while s != "" and s[0] >= '0' and s[0] <= '9':		# input first bit as an integer
			self.value = self.value * 10 + int(s[0])
			assert self.value < 0x100000000,"Overflow"
			s = s[1:]
		#
		self.value = (self.value * sign) & 0xFFFFFFFF		# apply sign if provided
		if s.startswith("."):								# decimal number.
			s = s[1:]
			self.toFloat() 									# make float
			self.sign = 0									# and absolute
			scalar = Float().setInteger(1).toFloat()
			while s != "" and s[0] >= '0' and s[0] <= '9':
				scalar.divFloat(Float().setInteger(10).toFloat())
				f1 = Float().setInteger(int(s[0])).toFloat().mulFloat(scalar)
				self.addFloat(f1)
				s = s[1:]
			self.sign = 0xFF if sign < 0 else 0x00			# restore signs
		#
		m = re.match("^[eE]([\-\+]?)(\d+)(.*)",s) 			# exponent format ?
		if m is not None:
			self.toFloat()
			if m.group(1) == "-":
				for i in range(0,int(m.group(2))):
					c10 = Float().setInteger(10).toFloat()
					self.divFloat(c10)
			else:
				for i in range(0,int(m.group(2))):
					c10 = Float().setInteger(10).toFloat()
					self.mulFloat(c10)
		return self

if __name__ == "__main__":
	for s in ["0","-1.2","-2","31","42.4","0.000000021471","987654.321","1.44e-5"]:
		print(s)
		f = FloatX().convertFromString(s).toFloat()
		f.integerPart()
		print(f.toString())
		f = FloatX().convertFromString(s).toFloat()
		f.fractionalPart()
		print(f.toString())
		print("=====================")