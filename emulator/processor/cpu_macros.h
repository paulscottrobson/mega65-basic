// *******************************************************************************************
// *******************************************************************************************
//
//		Name : 		cpu_macros.h
//		Purpose :	Macros and Support Functions
//		Date :		4th August 2019
//		Author : 	Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************
// *******************************************************************************************
//
//									Prototypes
//
static BYTE8 makeStatus(void);
static void setStatus(BYTE8 p);
static void add8Bit(void);
static void sub8Bit(void);

// *******************************************************************************************
//
//					EAC should put the target/source address in MAR
//
// *******************************************************************************************
//
//								EAC Absolutes
//
#define EAC_ABS()		FETCH16();MAR = MBR;
#define EAC_ABSIND()	EAC_ABS();READ16();MAR = MBR
#define EAC_ABSINDX()	EAC_ABSX();READ16();MAR = MBR
#define EAC_ABSX()		EAC_ABS();MAR = (MAR + X) & 0xFFFF
#define EAC_ABSY()		EAC_ABS();MAR = (MAR + Y) & 0xFFFF
//
//				  for LDA (ZP),Z in Far mode (e.g. preceded by NOP)
//
#define EAC_FAR()		FETCH8();MAR32 = (READLONG(MBR) + Z) & 0xFFFFFFFF
//
//								EAC Zero
//
#define BASEPAGE(x)		(x)			// Not implemented
//
#define EAC_ZERO() 		FETCH8();MAR = BASEPAGE(MBR)
#define EAC_ZEROX()		EAC_ZERO();MAR = BASEPAGE((MAR + X) & 0xFF)
#define EAC_ZEROY()		EAC_ZERO();MAR = BASEPAGE((MAR + Y) & 0xFF)
#define EAC_INDX()		FETCH8();MAR = BASEPAGE((MBR + X) & 0xFF);READ16();MAR = MBR
#define EAC_INDY()		FETCH8();MAR = BASEPAGE(MBR);READ16();MAR = (MBR + Y) & 0xFFFF
#define EAC_INDZ()		FETCH8();MAR = BASEPAGE(MBR);READ16();MAR = (MBR + Z) & 0xFFFF
//
//							   EAC Relative
//
#define EAC_REL16()		FETCH16();MAR = (PC + MBR) & 0xFFFF
#define EAC_REL8()		FETCH8();if (MBR & 0x80) MBR |= 0xFF00;MAR = (PC + MBR) & 0xFFFF
//
//							 EAC Miscellaneous
//
#define EAC_ACC()		{}			
#define EAC_IMM8()		MAR = PC;PC++
#define EAC_IMPLIED()	{}	
#define EAC_STKINDY()	{}			// Not implemented
//
//									Set NZ from a specific value.
//
#define SETNZ(c)		N_FLAG = ((c) & 0x80) ? 1 : 0;Z_FLAG = ((c) == 0) ? 1 : 0
//
//									Opcodes
//
#define OPC_ADC()		add8Bit();A = MBR

#define OPC_AND()		A &= MBR;SETNZ(A)
#define OPC_EOR()		A ^= MBR;SETNZ(A)
#define OPC_ORA()		A |= MBR;SETNZ(A)

#define OPC_CMP()		C_FLAG = 1;sub8Bit(A)
#define OPC_CPX()		C_FLAG = 1;sub8Bit(X)
#define OPC_CPY()		C_FLAG = 1;sub8Bit(Y)
#define OPC_CPZ()		C_FLAG = 1;sub8Bit(Z)
#define OPC_SBC()		sub8Bit(A);A = MBR

#define OPC_BIT()		N_FLAG = (MBR >> 7) & 1;V_FLAG = (MBR >> 6) * 1;Z_FLAG = ((A & MBR) == 0) ? 1 : 0

#define OPC_ASL()		C_FLAG = (MBR >> 7) & 1;MBR = (MBR << 1) & 0xFF;SETNZ(MBR)
#define OPC_ASR()		C_FLAG = MBR & 1;MBR = ((MBR >> 1) & 0x7F)|(MBR & 0x80);SETNZ(MBR)
#define OPC_LSR()		C_FLAG = MBR & 1;MBR = (MBR >> 1) & 0x7F;SETNZ(MBR)
#define OPC_ROL()		MBR = (MBR << 1)|C_FLAG;C_FLAG = (MBR >> 8) & 1;MBR = MBR & 0xFF;SETNZ(MBR)
#define OPC_ROR()		MBR = (MBR & 0xFF)|(C_FLAG << 8);C_FLAG = MBR & 1;MBR = (MBR >> 1) & 0xFF;SETNZ(MBR)

#define OPC_DEC()		MBR = (MBR - 1) & 0xFF;SETNZ(MBR)
#define OPC_INC()		MBR = (MBR + 1) & 0xFF;SETNZ(MBR)

#define OPC_BSR() 		OPC_JSR()
#define OPC_JMP()		PC = MAR
#define OPC_JSR()		temp16 = MAR;PC--;PUSH8(PC >> 8);PUSH8(PC & 0xFF);PC = temp16

#define OPC_BRK()       PC++;PUSH8(PC >> 8);PUSH8(PC & 0xFF);PUSH8(makeStatus()|0x10);MAR=0xFFFE;READ16(); PC=MBR 

#define OPC_LDA()		A = MBR & 0xFF;SETNZ(A)
#define OPC_LDX()		X = MBR & 0xFF;SETNZ(X)
#define OPC_LDY()		Y = MBR & 0xFF;SETNZ(Y)
#define OPC_LDZ()		Z = MBR & 0xFF;SETNZ(Z)

#define OPC_NEG()		A = (-A & 0xFF);SETNZ(A)
#define OPC_NOP()		{}
#define OPC_PHP()		PUSH8(makeStatus())
#define OPC_PLP()		setStatus(PULL8())
#define OPC_RTI()		OPC_PLP();OPC_RTS()
#define OPC_RTS()		tmp8 = PULL8();PC = (PULL8() << 8)|tmp8;PC++


#define OPC_TAB()		{}
#define OPC_TBA()		{}

#define OPC_TSX()		X = (SP & 0xFF);SETNZ(X)
#define OPC_TSY() 		Y = (SP >> 8);SETNZ(Y)
#define OPC_TXS()		SP = (SP & 0xFF00)|X; if (E_FLAG == 0) SP = X|0x100;
#define OPC_TYS()		SP = (SP & 0x00FF)|(Y << 8); if (E_FLAG == 0) SP = (SP & 0xFF)|0x100;

#define OPC_MAP()       CPUExit()

#define TEST_BCC()		(C_FLAG == 0)
#define TEST_BCS()		(C_FLAG != 0)
#define TEST_BEQ()		(Z_FLAG != 0)
#define TEST_BMI()		(N_FLAG != 0)
#define TEST_BNE()		(Z_FLAG == 0)
#define TEST_BPL()		(N_FLAG == 0)
#define TEST_BRA()		(1)
#define TEST_BVC()		(V_FLAG == 0)
#define TEST_BVS()		(V_FLAG != 0)

//
//		Create status byte from individual flags, for PHP
//
static BYTE8 makeStatus(void) {
	return (N_FLAG << 7)|(V_FLAG << 6)|(E_FLAG << 5)|(B_FLAG << 4)|
									(D_FLAG << 3)|(I_FLAG << 2)|(Z_FLAG << 1)|C_FLAG;
}

//
//		Set individual flags fom status byte for PLP and RTI.
//
static void setStatus(BYTE8 p) {
	N_FLAG = (p >> 7) & 1;V_FLAG = (p >> 6) & 1;E_FLAG = (p >> 5) & 1;
	D_FLAG = (p >> 3) & 1;I_FLAG = (p >> 2) & 1;Z_FLAG = (p >> 1) & 1;C_FLAG = (p >> 0) & 1;
}

//
//		8 bit addition MBR := A + MBR + C, set NZCV. Does not update A.
//
static void add8Bit(void) {
	WORD16 result;
 	BYTE8 r,t;
 	if (D_FLAG != 0) {
       	r = (A & 0xf)+(MBR & 0xf)+C_FLAG;
        if (r > 9) r += 6;
        t = (A >> 4)+(MBR >> 4)+ (r >= 0x10 ? 1 : 0);
        if (t > 9) t += 6;
        result = (r & 0xF) | (t << 4);
        C_FLAG = (t >= 0x10 ? 1 : 0);
    } else {
        result = A + MBR + C_FLAG;
        V_FLAG = ((A & 0x80) == (MBR & 0x80) && (A & 0x80) != (result & 0x80)) ? 1 : 0;
        C_FLAG = (result >> 8) & 1;
    }
 	MBR = result & 0xFF;
 	SETNZ(MBR);
}

//
//		8 bit subtraction MBR := n1 - MBR - (~C), set NZCV. Does not update A
//
static void sub8Bit(BYTE8 n1) {
 	WORD16 result;
 	BYTE8 r,t;
 	if (D_FLAG != 0) {
 		r = (n1 & 0xf) - (MBR & 0xf) - (C_FLAG ^ 1);
        if (r & 0x10) r -= 6;
 		t = (n1 >> 4) - (MBR >> 4) - ((r & 0x10)>>4);
        if (t & 0x10) t -= 6;
 		result = (r & 0xF) | (t << 4);
 		C_FLAG = (t > 15) ? 0 : 1;
    } else {
        result = n1 + (MBR ^ 0xFF) + C_FLAG;
 		C_FLAG = (result >> 8) & 1;
 		V_FLAG = ((n1 & 0x80) != (MBR & 0x80) && (n1 & 0x80) != (result & 0x80)) ? 1 : 0;
 	}
 	MBR = result & 0xFF;
 	SETNZ(MBR);
}
