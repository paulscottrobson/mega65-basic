//
// This file is generated from 65CE02.txt
//

case 0x00: // *** $00 brk implied ***
	OPC_BRK();
	break;

case 0x01: // *** $01 ora indx ***
	EAC_INDX();READ8();OPC_ORA();
	break;

case 0x02: // *** $02 cle implied ***
	E_FLAG = 0;
	break;

case 0x03: // *** $03 see implied ***
	E_FLAG = 1;
	break;

case 0x05: // *** $05 ora zero ***
	EAC_ZERO();READ8();OPC_ORA();
	break;

case 0x06: // *** $06 asl zero ***
	EAC_ZERO();READ8();OPC_ASL();WRITE8();
	break;

case 0x08: // *** $08 php implied ***
	OPC_PHP();
	break;

case 0x09: // *** $09 ora imm8 ***
	EAC_IMM8();READ8();OPC_ORA();
	break;

case 0x0a: // *** $0a asl acc ***
	EAC_ACC();MBR = A;OPC_ASL();A = MBR;
	break;

case 0x0b: // *** $0b tsy implied ***
	OPC_TSY();
	break;

case 0x0d: // *** $0d ora abs ***
	EAC_ABS();READ8();OPC_ORA();
	break;

case 0x0e: // *** $0e asl abs ***
	EAC_ABS();READ8();OPC_ASL();WRITE8();
	break;

case 0x10: // *** $10 bpl rel8 ***
	EAC_REL8();if (TEST_BPL()) PC = MAR;
	break;

case 0x11: // *** $11 ora indy ***
	EAC_INDY();READ8();OPC_ORA();
	break;

case 0x12: // *** $12 ora indz ***
	EAC_INDZ();READ8();OPC_ORA();
	break;

case 0x13: // *** $13 bpl rel16 ***
	EAC_REL16();if (TEST_BPL()) PC = MAR;
	break;

case 0x15: // *** $15 ora zerox ***
	EAC_ZEROX();READ8();OPC_ORA();
	break;

case 0x16: // *** $16 asl zerox ***
	EAC_ZEROX();READ8();OPC_ASL();WRITE8();
	break;

case 0x18: // *** $18 clc implied ***
	C_FLAG = 0;
	break;

case 0x19: // *** $19 ora absy ***
	EAC_ABSY();READ8();OPC_ORA();
	break;

case 0x1a: // *** $1a inc acc ***
	EAC_ACC();MBR = A;OPC_INC();A = MBR;
	break;

case 0x1b: // *** $1b inz implied ***
	MBR = Z;OPC_INC();Z = MBR;
	break;

case 0x1d: // *** $1d ora absx ***
	EAC_ABSX();READ8();OPC_ORA();
	break;

case 0x1e: // *** $1e asl absx ***
	EAC_ABSX();READ8();OPC_ASL();WRITE8();
	break;

case 0x20: // *** $20 jsr abs ***
	EAC_ABS();OPC_JSR();
	break;

case 0x21: // *** $21 and indx ***
	EAC_INDX();READ8();OPC_AND();
	break;

case 0x22: // *** $22 jsr absind ***
	EAC_ABSIND();OPC_JSR();
	break;

case 0x23: // *** $23 jsr absindx ***
	EAC_ABSINDX();OPC_JSR();
	break;

case 0x24: // *** $24 bit zero ***
	EAC_ZERO();READ8();OPC_BIT();
	break;

case 0x25: // *** $25 and zero ***
	EAC_ZERO();READ8();OPC_AND();
	break;

case 0x26: // *** $26 rol zero ***
	EAC_ZERO();READ8();OPC_ROL();WRITE8();
	break;

case 0x28: // *** $28 plp implied ***
	OPC_PLP();
	break;

case 0x29: // *** $29 and imm8 ***
	EAC_IMM8();READ8();OPC_AND();
	break;

case 0x2a: // *** $2a rol acc ***
	EAC_ACC();MBR = A;OPC_ROL();A = MBR;
	break;

case 0x2b: // *** $2b tys implied ***
	OPC_TYS();
	break;

case 0x2c: // *** $2c bit abs ***
	EAC_ABS();READ8();OPC_BIT();
	break;

case 0x2d: // *** $2d and abs ***
	EAC_ABS();READ8();OPC_AND();
	break;

case 0x2e: // *** $2e rol abs ***
	EAC_ABS();READ8();OPC_ROL();WRITE8();
	break;

case 0x30: // *** $30 bmi rel8 ***
	EAC_REL8();if (TEST_BMI()) PC = MAR;
	break;

case 0x31: // *** $31 and indy ***
	EAC_INDY();READ8();OPC_AND();
	break;

case 0x32: // *** $32 and indz ***
	EAC_INDZ();READ8();OPC_AND();
	break;

case 0x33: // *** $33 bmi rel16 ***
	EAC_REL16();if (TEST_BMI()) PC = MAR;
	break;

case 0x34: // *** $34 bit zerox ***
	EAC_ZEROX();READ8();OPC_BIT();
	break;

case 0x35: // *** $35 and zerox ***
	EAC_ZEROX();READ8();OPC_AND();
	break;

case 0x36: // *** $36 rol zerox ***
	EAC_ZEROX();READ8();OPC_ROL();WRITE8();
	break;

case 0x38: // *** $38 sec implied ***
	C_FLAG = 1;
	break;

case 0x39: // *** $39 and absy ***
	EAC_ABSY();READ8();OPC_AND();
	break;

case 0x3a: // *** $3a dec acc ***
	EAC_ACC();MBR = A;OPC_DEC();A = MBR;
	break;

case 0x3b: // *** $3b dez implied ***
	MBR = Z;OPC_DEC();Z = MBR;
	break;

case 0x3c: // *** $3c bit absx ***
	EAC_ABSX();READ8();OPC_BIT();
	break;

case 0x3d: // *** $3d and absx ***
	EAC_ABSX();READ8();OPC_AND();
	break;

case 0x3e: // *** $3e rol absx ***
	EAC_ABSX();READ8();OPC_ROL();WRITE8();
	break;

case 0x40: // *** $40 rti implied ***
	OPC_RTI();
	break;

case 0x41: // *** $41 eor indx ***
	EAC_INDX();READ8();OPC_EOR();
	break;

case 0x42: // *** $42 neg implied ***
	OPC_NEG();
	break;

case 0x43: // *** $43 asr acc ***
	EAC_ACC();MBR = A;OPC_ASR();A = MBR;
	break;

case 0x44: // *** $44 asr zero ***
	EAC_ZERO();READ8();OPC_ASR();WRITE8();
	break;

case 0x45: // *** $45 eor zero ***
	EAC_ZERO();READ8();OPC_EOR();
	break;

case 0x46: // *** $46 lsr zero ***
	EAC_ZERO();READ8();OPC_LSR();WRITE8();
	break;

case 0x48: // *** $48 pha implied ***
	PUSH8(A);
	break;

case 0x49: // *** $49 eor imm8 ***
	EAC_IMM8();READ8();OPC_EOR();
	break;

case 0x4a: // *** $4a lsr acc ***
	EAC_ACC();MBR = A;OPC_LSR();A = MBR;
	break;

case 0x4b: // *** $4b taz implied ***
	Z = A;SETNZ(Z);
	break;

case 0x4c: // *** $4c jmp abs ***
	EAC_ABS();OPC_JMP();
	break;

case 0x4d: // *** $4d eor abs ***
	EAC_ABS();READ8();OPC_EOR();
	break;

case 0x4e: // *** $4e lsr abs ***
	EAC_ABS();READ8();OPC_LSR();WRITE8();
	break;

case 0x50: // *** $50 bvc rel8 ***
	EAC_REL8();if (TEST_BVC()) PC = MAR;
	break;

case 0x51: // *** $51 eor indy ***
	EAC_INDY();READ8();OPC_EOR();
	break;

case 0x52: // *** $52 eor indz ***
	EAC_INDZ();READ8();OPC_EOR();
	break;

case 0x53: // *** $53 bvc rel16 ***
	EAC_REL16();if (TEST_BVC()) PC = MAR;
	break;

case 0x54: // *** $54 asr zerox ***
	EAC_ZEROX();READ8();OPC_ASR();WRITE8();
	break;

case 0x55: // *** $55 eor zerox ***
	EAC_ZEROX();READ8();OPC_EOR();
	break;

case 0x56: // *** $56 lsr zerox ***
	EAC_ZEROX();READ8();OPC_LSR();WRITE8();
	break;

case 0x58: // *** $58 cli implied ***
	I_FLAG = 0;
	break;

case 0x59: // *** $59 eor absy ***
	EAC_ABSY();READ8();OPC_EOR();
	break;

case 0x5a: // *** $5a phy implied ***
	PUSH8(Y);
	break;

case 0x5b: // *** $5b tab implied ***
	OPC_TAB();
	break;

case 0x5d: // *** $5d eor absx ***
	EAC_ABSX();READ8();OPC_EOR();
	break;

case 0x5e: // *** $5e lsr absx ***
	EAC_ABSX();READ8();OPC_LSR();WRITE8();
	break;

case 0x60: // *** $60 rts implied ***
	OPC_RTS();
	break;

case 0x61: // *** $61 adc indx ***
	EAC_INDX();READ8();OPC_ADC();
	break;

case 0x62: // *** $62 rts imm8 ***
	EAC_IMM8();OPC_RTS();
	break;

case 0x63: // *** $63 bsr rel16 ***
	EAC_REL16();OPC_BSR();
	break;

case 0x64: // *** $64 stz zero ***
	EAC_ZERO();MBR = Z;WRITE8();
	break;

case 0x65: // *** $65 adc zero ***
	EAC_ZERO();READ8();OPC_ADC();
	break;

case 0x66: // *** $66 ror zero ***
	EAC_ZERO();READ8();OPC_ROR();WRITE8();
	break;

case 0x68: // *** $68 pla implied ***
	A = PULL8();SETNZ(A);
	break;

case 0x69: // *** $69 adc imm8 ***
	EAC_IMM8();READ8();OPC_ADC();
	break;

case 0x6a: // *** $6a ror acc ***
	EAC_ACC();MBR = A;OPC_ROR();A = MBR;
	break;

case 0x6b: // *** $6b tza implied ***
	A = Z;SETNZ(A);
	break;

case 0x6c: // *** $6c jmp absind ***
	EAC_ABSIND();OPC_JMP();
	break;

case 0x6d: // *** $6d adc abs ***
	EAC_ABS();READ8();OPC_ADC();
	break;

case 0x6e: // *** $6e ror abs ***
	EAC_ABS();READ8();OPC_ROR();WRITE8();
	break;

case 0x70: // *** $70 bvs rel8 ***
	EAC_REL8();if (TEST_BVS()) PC = MAR;
	break;

case 0x71: // *** $71 adc indy ***
	EAC_INDY();READ8();OPC_ADC();
	break;

case 0x72: // *** $72 adc indz ***
	EAC_INDZ();READ8();OPC_ADC();
	break;

case 0x73: // *** $73 bvs rel16 ***
	EAC_REL16();if (TEST_BVS()) PC = MAR;
	break;

case 0x74: // *** $74 stz zerox ***
	EAC_ZEROX();MBR = Z;WRITE8();
	break;

case 0x75: // *** $75 adc zerox ***
	EAC_ZEROX();READ8();OPC_ADC();
	break;

case 0x76: // *** $76 ror zerox ***
	EAC_ZEROX();READ8();OPC_ROR();WRITE8();
	break;

case 0x78: // *** $78 sei implied ***
	I_FLAG = 1;
	break;

case 0x79: // *** $79 adc absy ***
	EAC_ABSY();READ8();OPC_ADC();
	break;

case 0x7a: // *** $7a ply implied ***
	Y = PULL8();SETNZ(Y);
	break;

case 0x7b: // *** $7b tba implied ***
	OPC_TBA();
	break;

case 0x7c: // *** $7c jmp absindx ***
	EAC_ABSINDX();OPC_JMP();
	break;

case 0x7d: // *** $7d adc absx ***
	EAC_ABSX();READ8();OPC_ADC();
	break;

case 0x7e: // *** $7e ror absx ***
	EAC_ABSX();READ8();OPC_ROR();WRITE8();
	break;

case 0x80: // *** $80 bra rel8 ***
	EAC_REL8();if (TEST_BRA()) PC = MAR;
	break;

case 0x81: // *** $81 sta indx ***
	EAC_INDX();MBR = A;WRITE8();
	break;

case 0x82: // *** $82 sta stkindy ***
	EAC_STKINDY();MBR = A;WRITE8();
	break;

case 0x83: // *** $83 bra rel16 ***
	EAC_REL16();if (TEST_BRA()) PC = MAR;
	break;

case 0x84: // *** $84 sty zero ***
	EAC_ZERO();MBR = Y;WRITE8();
	break;

case 0x85: // *** $85 sta zero ***
	EAC_ZERO();MBR = A;WRITE8();
	break;

case 0x86: // *** $86 stx zero ***
	EAC_ZERO();MBR = X;WRITE8();
	break;

case 0x88: // *** $88 dey implied ***
	MBR = Y;OPC_DEC();Y = MBR;
	break;

case 0x89: // *** $89 bit imm8 ***
	EAC_IMM8();READ8();OPC_BIT();
	break;

case 0x8a: // *** $8a txa implied ***
	A = X;SETNZ(A);
	break;

case 0x8b: // *** $8b sty absx ***
	EAC_ABSX();MBR = Y;WRITE8();
	break;

case 0x8c: // *** $8c sty abs ***
	EAC_ABS();MBR = Y;WRITE8();
	break;

case 0x8d: // *** $8d sta abs ***
	EAC_ABS();MBR = A;WRITE8();
	break;

case 0x8e: // *** $8e stx abs ***
	EAC_ABS();MBR = X;WRITE8();
	break;

case 0x90: // *** $90 bcc rel8 ***
	EAC_REL8();if (TEST_BCC()) PC = MAR;
	break;

case 0x91: // *** $91 sta indy ***
	EAC_INDY();MBR = A;WRITE8();
	break;

case 0x92: // *** $92 sta indz ***
	EAC_INDZ();MBR = A;WRITE8();
	break;

case 0x93: // *** $93 bcc rel16 ***
	EAC_REL16();if (TEST_BCC()) PC = MAR;
	break;

case 0x94: // *** $94 sty zerox ***
	EAC_ZEROX();MBR = Y;WRITE8();
	break;

case 0x95: // *** $95 sta zerox ***
	EAC_ZEROX();MBR = A;WRITE8();
	break;

case 0x96: // *** $96 stx zeroy ***
	EAC_ZEROY();MBR = X;WRITE8();
	break;

case 0x98: // *** $98 tya implied ***
	A = Y;SETNZ(A);
	break;

case 0x99: // *** $99 sta absy ***
	EAC_ABSY();MBR = A;WRITE8();
	break;

case 0x9a: // *** $9a txs implied ***
	OPC_TXS();
	break;

case 0x9b: // *** $9b stx absy ***
	EAC_ABSY();MBR = X;WRITE8();
	break;

case 0x9c: // *** $9c stz abs ***
	EAC_ABS();MBR = Z;WRITE8();
	break;

case 0x9d: // *** $9d sta absx ***
	EAC_ABSX();MBR = A;WRITE8();
	break;

case 0x9e: // *** $9e stz absx ***
	EAC_ABSX();MBR = Z;WRITE8();
	break;

case 0xa0: // *** $a0 ldy imm8 ***
	EAC_IMM8();READ8();OPC_LDY();
	break;

case 0xa1: // *** $a1 lda indx ***
	EAC_INDX();READ8();OPC_LDA();
	break;

case 0xa2: // *** $a2 ldx imm8 ***
	EAC_IMM8();READ8();OPC_LDX();
	break;

case 0xa3: // *** $a3 ldz imm8 ***
	EAC_IMM8();READ8();OPC_LDZ();
	break;

case 0xa4: // *** $a4 ldy zero ***
	EAC_ZERO();READ8();OPC_LDY();
	break;

case 0xa5: // *** $a5 lda zero ***
	EAC_ZERO();READ8();OPC_LDA();
	break;

case 0xa6: // *** $a6 ldx zero ***
	EAC_ZERO();READ8();OPC_LDX();
	break;

case 0xa8: // *** $a8 tay implied ***
	Y = A;SETNZ(Y);
	break;

case 0xa9: // *** $a9 lda imm8 ***
	EAC_IMM8();READ8();OPC_LDA();
	break;

case 0xaa: // *** $aa tax implied ***
	X = A;SETNZ(X);
	break;

case 0xab: // *** $ab ldz abs ***
	EAC_ABS();READ8();OPC_LDZ();
	break;

case 0xac: // *** $ac ldy abs ***
	EAC_ABS();READ8();OPC_LDY();
	break;

case 0xad: // *** $ad lda abs ***
	EAC_ABS();READ8();OPC_LDA();
	break;

case 0xae: // *** $ae ldx abs ***
	EAC_ABS();READ8();OPC_LDX();
	break;

case 0xb0: // *** $b0 bcs rel8 ***
	EAC_REL8();if (TEST_BCS()) PC = MAR;
	break;

case 0xb1: // *** $b1 lda indy ***
	EAC_INDY();READ8();OPC_LDA();
	break;

case 0xb2: // *** $b2 lda indz ***
	EAC_INDZ();READ8();OPC_LDA();
	break;

case 0xb3: // *** $b3 bcs rel16 ***
	EAC_REL16();if (TEST_BCS()) PC = MAR;
	break;

case 0xb4: // *** $b4 ldy zerox ***
	EAC_ZEROX();READ8();OPC_LDY();
	break;

case 0xb5: // *** $b5 lda zerox ***
	EAC_ZEROX();READ8();OPC_LDA();
	break;

case 0xb6: // *** $b6 ldx zeroy ***
	EAC_ZEROY();READ8();OPC_LDX();
	break;

case 0xb8: // *** $b8 clv implied ***
	V_FLAG = 0;
	break;

case 0xb9: // *** $b9 lda absy ***
	EAC_ABSY();READ8();OPC_LDA();
	break;

case 0xba: // *** $ba tsx implied ***
	OPC_TSX();
	break;

case 0xbb: // *** $bb ldz absx ***
	EAC_ABSX();READ8();OPC_LDZ();
	break;

case 0xbc: // *** $bc ldy absx ***
	EAC_ABSX();READ8();OPC_LDY();
	break;

case 0xbd: // *** $bd lda absx ***
	EAC_ABSX();READ8();OPC_LDA();
	break;

case 0xbe: // *** $be ldx absy ***
	EAC_ABSY();READ8();OPC_LDX();
	break;

case 0xc0: // *** $c0 cpy imm8 ***
	EAC_IMM8();READ8();OPC_CPY();
	break;

case 0xc1: // *** $c1 cmp indx ***
	EAC_INDX();READ8();OPC_CMP();
	break;

case 0xc2: // *** $c2 cpz imm8 ***
	EAC_IMM8();READ8();OPC_CPZ();
	break;

case 0xc4: // *** $c4 cpy zero ***
	EAC_ZERO();READ8();OPC_CPY();
	break;

case 0xc5: // *** $c5 cmp zero ***
	EAC_ZERO();READ8();OPC_CMP();
	break;

case 0xc6: // *** $c6 dec zero ***
	EAC_ZERO();READ8();OPC_DEC();WRITE8();
	break;

case 0xc8: // *** $c8 iny implied ***
	MBR = Y;OPC_INC();Y = MBR;
	break;

case 0xc9: // *** $c9 cmp imm8 ***
	EAC_IMM8();READ8();OPC_CMP();
	break;

case 0xca: // *** $ca dex implied ***
	MBR = X;OPC_DEC();X = MBR;
	break;

case 0xcc: // *** $cc cpy abs ***
	EAC_ABS();READ8();OPC_CPY();
	break;

case 0xcd: // *** $cd cmp abs ***
	EAC_ABS();READ8();OPC_CMP();
	break;

case 0xce: // *** $ce dec abs ***
	EAC_ABS();READ8();OPC_DEC();WRITE8();
	break;

case 0xd0: // *** $d0 bne rel8 ***
	EAC_REL8();if (TEST_BNE()) PC = MAR;
	break;

case 0xd1: // *** $d1 cmp indy ***
	EAC_INDY();READ8();OPC_CMP();
	break;

case 0xd2: // *** $d2 cmp indz ***
	EAC_INDZ();READ8();OPC_CMP();
	break;

case 0xd3: // *** $d3 bne rel16 ***
	EAC_REL16();if (TEST_BNE()) PC = MAR;
	break;

case 0xd4: // *** $d4 cpz zero ***
	EAC_ZERO();READ8();OPC_CPZ();
	break;

case 0xd5: // *** $d5 cmp zerox ***
	EAC_ZEROX();READ8();OPC_CMP();
	break;

case 0xd6: // *** $d6 dec zerox ***
	EAC_ZEROX();READ8();OPC_DEC();WRITE8();
	break;

case 0xd8: // *** $d8 cld implied ***
	D_FLAG = 0;
	break;

case 0xd9: // *** $d9 cmp absy ***
	EAC_ABSY();READ8();OPC_CMP();
	break;

case 0xda: // *** $da phx implied ***
	PUSH8(X);
	break;

case 0xdb: // *** $db phz implied ***
	PUSH8(Z);
	break;

case 0xdc: // *** $dc cpz abs ***
	EAC_ABS();READ8();OPC_CPZ();
	break;

case 0xdd: // *** $dd cmp absx ***
	EAC_ABSX();READ8();OPC_CMP();
	break;

case 0xde: // *** $de dec absx ***
	EAC_ABSX();READ8();OPC_DEC();WRITE8();
	break;

case 0xe0: // *** $e0 cpx imm8 ***
	EAC_IMM8();READ8();OPC_CPX();
	break;

case 0xe1: // *** $e1 sbc indx ***
	EAC_INDX();READ8();OPC_SBC();
	break;

case 0xe2: // *** $e2 lda stkindy ***
	EAC_STKINDY();READ8();OPC_LDA();
	break;

case 0xe4: // *** $e4 cpx zero ***
	EAC_ZERO();READ8();OPC_CPX();
	break;

case 0xe5: // *** $e5 sbc zero ***
	EAC_ZERO();READ8();OPC_SBC();
	break;

case 0xe6: // *** $e6 inc zero ***
	EAC_ZERO();READ8();OPC_INC();WRITE8();
	break;

case 0xe8: // *** $e8 inx implied ***
	MBR = X;OPC_INC();X = MBR;
	break;

case 0xe9: // *** $e9 sbc imm8 ***
	EAC_IMM8();READ8();OPC_SBC();
	break;

case 0xea: // *** $ea nop implied ***
	OPC_NOP();
	break;

case 0xec: // *** $ec cpx abs ***
	EAC_ABS();READ8();OPC_CPX();
	break;

case 0xed: // *** $ed sbc abs ***
	EAC_ABS();READ8();OPC_SBC();
	break;

case 0xee: // *** $ee inc abs ***
	EAC_ABS();READ8();OPC_INC();WRITE8();
	break;

case 0xf0: // *** $f0 beq rel8 ***
	EAC_REL8();if (TEST_BEQ()) PC = MAR;
	break;

case 0xf1: // *** $f1 sbc indy ***
	EAC_INDY();READ8();OPC_SBC();
	break;

case 0xf2: // *** $f2 sbc indz ***
	EAC_INDZ();READ8();OPC_SBC();
	break;

case 0xf3: // *** $f3 beq rel16 ***
	EAC_REL16();if (TEST_BEQ()) PC = MAR;
	break;

case 0xf5: // *** $f5 sbc zerox ***
	EAC_ZEROX();READ8();OPC_SBC();
	break;

case 0xf6: // *** $f6 inc zerox ***
	EAC_ZEROX();READ8();OPC_INC();WRITE8();
	break;

case 0xf8: // *** $f8 sed implied ***
	D_FLAG = 1;
	break;

case 0xf9: // *** $f9 sbc absy ***
	EAC_ABSY();READ8();OPC_SBC();
	break;

case 0xfa: // *** $fa plx implied ***
	X = PULL8();SETNZ(X);
	break;

case 0xfb: // *** $fb plz implied ***
	Z = PULL8();SETNZ(Z);
	break;

case 0xfd: // *** $fd sbc absx ***
	EAC_ABSX();READ8();OPC_SBC();
	break;

case 0xfe: // *** $fe inc absx ***
	EAC_ABSX();READ8();OPC_INC();WRITE8();
	break;

case 0x112: // *** $112 ora indz ***
	EAC_FAR();READFAR();OPC_ORA();
	break;

case 0x132: // *** $132 and indz ***
	EAC_FAR();READFAR();OPC_AND();
	break;

case 0x152: // *** $152 eor indz ***
	EAC_FAR();READFAR();OPC_EOR();
	break;

case 0x172: // *** $172 adc indz ***
	EAC_FAR();READFAR();OPC_ADC();
	break;

case 0x192: // *** $192 sta indz ***
	EAC_FAR();MBR = A;WRITEFAR();
	break;

case 0x1b2: // *** $1b2 lda indz ***
	EAC_FAR();READFAR();OPC_LDA();
	break;

case 0x1d2: // *** $1d2 cmp indz ***
	EAC_FAR();READFAR();OPC_CMP();
	break;

case 0x1f2: // *** $1f2 sbc indz ***
	EAC_FAR();READFAR();OPC_SBC();
	break;

