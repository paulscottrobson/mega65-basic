# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		float.py
#		Purpose :	Floating point in Python
#		Date :		3rd August 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random,re

# *******************************************************************************************
#
#		This is the Python version of the floating point routines, which can be
#		implemented in and should map onto the assembler equivalents.
#
#		Math ops : addFloat/sub can have 32 bit integer tests at the top, so that
#		integer calculations can be done using integer calculations *OR* float
#		conversions can be called at the start to coerce any integers to floats.
#
#		This is a MS design where everything is actually done in Floats.
#
# *******************************************************************************************
#
#							32 bit floating point/integer class
#
# *******************************************************************************************

class Float(object):
	#
	#		Initialise number class. The real thing holds integer, float or string.
	#
	def __init__(self):
		self.value = 0 										# 32 bit integer or mantissa with bit 31 set.
		self.exponent = 0 									# unbiased exponent (-$80 .. $7F)
		self.sign = 0 										# sign ($FF is signed)
		self.zero = 0 										# zero ($FF is zero)
		self.type = Float.INTEGER 							# initially integer zero.
	#
	#		Get number as a Python float.
	#
	def getFloatValue(self):
		assert self.type == Float.FLOAT
		v = pow(2,self.exponent)*self.value / 65536.0 / 65536.0
		return v if self.sign == 0 else -v
	#
	#		Get number as an integer
	#
	def getIntegerValue(self):
		assert self.type == Float.INTEGER
		return self.value if (self.value & 0x80000000) == 0 else self.value-0x100000000
	#
	#		Convert to information string 
	#
	def toString(self):
		if self.type == Float.INTEGER:
			return "INT:{0}".format(self.value if (self.value & Float.ISIGN) == 0 else self.value-0x100000000)
		if self.type == Float.STRING:
			return "STR: @${0:04x}".format(self.value & 0xFFFF)
		if self.zero != 0:
			return "FLO: 0.0"
		return "FLO: {0} ({1},{2:x})".format(self.getFloatValue(),self.exponent,self.value)
	#
	#		Set integer value.
	#
	def setInteger(self,n):
		self.value = n & 0xFFFFFFFF 						# mask to 32 bits.
		self.type = Float.INTEGER 							# type as integer.
		return self
	#
	#		Convert integer to floating point.
	#
	def toFloat(self):
		if self.type == Float.FLOAT: 						# already a floating point value.
			return self
		assert self.type == Float.INTEGER 					# not coeercing string.
		#
		self.type = Float.FLOAT 							# type as float.
		#
		if self.value == 0:									# special case of zero.
			self.zero = 0xFF 								# so we just set the zero flag.
			return self
		#
		self.sign = 0 										# reset sign and zero.
		self.zero = 0
		if self.value & Float.ISIGN:						# if is a  negative integer.
			self.value = (-self.value) & 0xFFFFFFFF 		# make it +ve.
			self.sign = 0xFF 								# set the sign flag.
		#
		self.exponent = 32 									# the exponent value, as is.
		self.normalize()									# normalize the float.
		return self
	#
	#		Normalize the floating point value.
	#
	def normalize(self):
		assert self.zero == 0 and self.type == Float.FLOAT 	# validate input.
		#
		while (self.value & Float.ISIGN) == 0: 				# shift left till MSB set.
			self.value <<= 1
			self.exponent -= 1
			if self.exponent < -0x7F:						# if reached lowest exponent
				self.zero = 0xFF 		 					# we now have zero.
				return
	#
	#		Convert floating point to integer
	#
	def toInteger(self):
		if self.type == Float.INTEGER:						# Nothing to do.
			return self
		assert self.type == Float.FLOAT 
		#
		self.type = Float.INTEGER 							# reset the type
		if self.zero:										# special case of zero.
			self.value = 0 
			return self
		#
		assert self.exponent <= 32,"Overflow"				# overflow error
		while self.exponent < 32:							# need to denormalise to exponent 32
			self.value >>= 1
			self.exponent += 1
		if self.sign:										# reapply sign.
			self.value = (-self.value) & 0xFFFFFFFF
		return self
	#
	#		Copy a floating point value into this one.
	#
	def copy(self,copy):
		self.type = copy.type 								# copy all the data in.
		self.value = copy.value
		self.exponent = copy.exponent
		self.sign = copy.sign
		self.zero = copy.zero
		return self
	#
	#		Add 2 floating point values. First is +ve, second is +ve or -ve. 
	#		This is a helper function for a generalised version.
	#
	def addFloatWorker(self,fp):
		assert self.type == Float.FLOAT and fp.type == Float.FLOAT
		#
		if fp.zero != 0: 									# adding zero.
			return self
		if self.zero != 0:									# adding non-zero to zero.
			self.copy(fp)									# the answer is what you are adding
			return self
		#
		while self.exponent != fp.exponent:					# firstly, align the exponents.
			if self.exponent < fp.exponent: 				# to the higher of the two exponents.
				self.exponent += 1
				self.value >>= 1
			else:
				fp.exponent += 1
				fp.value >>= 1
		#
		if fp.sign == 0:									# adding a positive value
			self.value += fp.value							# add 2nd mantissa to first.
			if self.value >= 0x100000000:					# carry out ?
				self.exponent += 1 							# adjust exponent and mantissa
				self.value = self.value >> 1
				assert self.exponent < 0x7F,"Overflow"		# result is too large.
		#
		else:												# adding a negative value.
			self.value -= fp.value 							# calculate the result			
			if self.value & 0x100000000:					# borrow ?
				self.value = (-self.value) & 0xFFFFFFFF 	# make the result positive in mantiassa
				self.sign = self.sign ^ 0xFF 				# flip the sign.
		#
		self.normalize()									# normalize the result.
		return self
	#
	#		Add, handles all cases.
	#
	def addFloat(self,fp):
		assert self.type == Float.FLOAT and fp.type == Float.FLOAT
		if self.sign == 0: 									# worker is designed for +ve values.
			return self.addFloatWorker(fp)
		self.sign ^= 0xFF 									# flip both signs
		fp.sign ^= 0xFF
		self.addFloatWorker(fp)								# do the same calculation.
		self.sign ^= 0xFF 									# flip result sign.
		return self
	#
	#		Subtract, simple variation on add, just flip the right hand sign.
	#
	def subFloat(self,fp):
		assert self.type == Float.FLOAT and fp.type == Float.FLOAT
		fp.sign ^= 0xFF 									# negate second value.
		self.addFloat(fp)									# and add
		return self
	#
	#		Multiply floating point integers
	#
	def mulFloat(self,fp):
		assert self.type == Float.FLOAT and fp.type == Float.FLOAT
		#
		if self.zero: 										# special cases 0 x n = 0
			return self
		if fp.zero:
			self.copy(fp)
			return self
		#
		self.exponent = self.exponent + fp.exponent 		# calculate new exponent
		assert self.exponent < 0x80,"Overflow"				# overflow, product is too large.
		#
		productLeft = 0 									# 64 bit shift multiply.
		productRight = self.value 
		#
		for i in range(0,32):
			if (productRight & 1) != 0: 					# add multiplicand in if bit set
				productLeft = (productLeft + fp.value) 		# Note CARRY HERE, 33 bit value.
															# shift everything right INC CARRY
			productRight = (productRight >> 1) | ((productLeft & 1) << 31)
			productLeft = productLeft >> 1
		#
		self.value = productLeft 							# result.
		#
		self.sign = self.sign ^ fp.sign 					# work out result sign.
		self.normalize()									# normalize the result.
		return self
	#
	#		Divide floating point integers.
	#
	def divFloat(self,fp):
		assert self.type == Float.FLOAT and fp.type == Float.FLOAT
		#
		assert fp.zero == 0,"Division by zero"				# can't divide by zero.
		if self.zero: 										# 0/n = n (if n is not zero)		
			return self
		#
		self.exponent = self.exponent - fp.exponent + 1 		# calculate new exponent
		assert self.exponent < 0x80,"Overflow"				# overflow, product is too large.
		#
		result = 0
		for i in range(0,32):
			if self.value >= fp.value:						# subtraction possible ? 
				self.value = self.value-fp.value 			# do the subtraction
				result |= Float.ISIGN 						# set the result bit.
			fp.value = fp.value >> 1
															# straight 32 bit rotate left.
			result = ((result << 1) | (result >> 31)) & Float.IMASK

		self.value = result 	 							# get result
		self.sign = self.sign ^ fp.sign 					# work out result sign.
		self.normalize()									# and normalize 
		return self
	#
	#		Multiply float by 10
	#
	def times10(self):
		assert self.type == Float.FLOAT 					# float in ?
		self.value = self.value + (self.value >> 2)
		if self.value > self.IMASK:							# carry out.
			self.value >>= 1
			self.exponent += 1
		self.exponent += 3
		return self		

Float.INTEGER = 0x00										# type values.
Float.FLOAT = 0x80
Float.STRING = 0x40		

Float.ISIGN = 0x80000000 									# various constants.
Float.IMASK = 0xFFFFFFFF

