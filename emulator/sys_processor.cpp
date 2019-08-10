// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_processor.c
//		Purpose:	Processor Emulation.
//		Created:	15th July 2019
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdio.h>
#include "sys_processor.h"
#include "sys_debug_system.h"
#include "gfx.h"

// *******************************************************************************************************************************
//														   Timing
// *******************************************************************************************************************************

#define CYCLE_RATE 		(4*1000*1000)												// Cycles per second (0.96Mhz)
#define FRAME_RATE		(60)														// Frames per second (50 arbitrary)
#define CYCLES_PER_FRAME (CYCLE_RATE / FRAME_RATE)									// Cycles per frame (20,000)

// *******************************************************************************************************************************
//														CPU / Memory
// *******************************************************************************************************************************

static BYTE8 A,X,Y,Z,tmp8;															// 6502 A,X,Y and Stack registers
static BYTE8 C_FLAG,I_FLAG,B_FLAG,E_FLAG,											// Values representing status reg
			 D_FLAG,V_FLAG,Z_FLAG,N_FLAG;
static WORD16 PC,temp16,MAR,MBR,SP;													// Program Counter.
static BYTE8 ramMemory[RAMSIZE];													// Memory at $0000 upwards
static LONG32 cycles,MAR32;															// Cycle Count.

// *******************************************************************************************************************************
//											 Memory and I/O read and write macros.
// *******************************************************************************************************************************

#define READ8() 	MBR = ramMemory[MAR]
#define WRITE8() 	ramMemory[MAR] = MBR & 0xFF
#define FETCH8() 	MBR = ramMemory[PC++]

#define READ16()	MBR = ramMemory[MAR] | (ramMemory[MAR+1] << 8)
#define WRITE16() 	ramMemory[MAR] = MBR & 0xFF;ramMemory[MAR+1] = MBR >> 8
#define FETCH16() 	MAR = PC;PC = PC + 2;READ16()

#define PUSH8(n)	ramMemory[SP--] = (n)
#define PULL8() 	ramMemory[++SP]

#define READFAR()	MBR = ramMemory[MAR32 & MEMMASK]
#define WRITEFAR()	ramMemory[MAR32 & MEMMASK] = MBR & 0xFF

#define READLONG(x) ramMemory[x]+(ramMemory[(x)+1] << 8)+(ramMemory[(x)+2] << 16)+(ramMemory[(x)+3] << 24)

#include "processor/cpu_macros.h"

// *******************************************************************************************************************************
//														Reset the CPU
// *******************************************************************************************************************************

#ifdef INCLUDE_DEBUGGING_SUPPORT
static void CPULoadChunk(FILE *f,BYTE8* memory,int count);
#endif	

static void resetProcessor(void) {
	MAR = 0xFFFC;
	READ16();
	PC = MBR;
	I_FLAG = 1;
	D_FLAG = 0;
	E_FLAG = 0;
}

void CPUReset(void) {
	FILE *f = fopen("rom.bin","rb");
	if (f != NULL) {
		CPULoadChunk(f,ramMemory,0x10000);
		fclose(f);
	}
	resetProcessor();																// Reset CPU
}

// *******************************************************************************************************************************
//												Execute a single instruction
// *******************************************************************************************************************************

BYTE8 CPUExecuteInstruction(void) {
	FETCH8();																		// Fetch opcode.
	switch(MBR) {																	// Execute it.
		#include "processor/cpu_opcodes.h"
	}
	cycles = cycles + 4;
	if (cycles < CYCLES_PER_FRAME) return 0;										// Not completed a frame.
	cycles = cycles - CYCLES_PER_FRAME;												// Adjust this frame rate.
	ramMemory[0xB801] = (GFXIsKeyPressed(GFXKEY_CONTROL) && GFXIsKeyPressed('C')) ? 1 : 0;
	return FRAME_RATE;																// Return frame rate.
}

// *******************************************************************************************************************************
//												Read/Write Memory
// *******************************************************************************************************************************

BYTE8 CPUReadFarMemory(LONG32 address) {
	return ramMemory[address & MEMMASK];
}

#ifdef INCLUDE_DEBUGGING_SUPPORT

#include "gfx.h"

// *******************************************************************************************************************************
//												Process keyboard keys
// *******************************************************************************************************************************

int CPUKeyHandler(int key,int inRunMode) {
	if (inRunMode != 0) {
		int akey = GFXToASCII(key,-1);
		//printf("%d\n",akey);
		ramMemory[0xB800] = akey & 0xFF;
		return 0;
	}
	return key;
}

// *******************************************************************************************************************************
//		Execute chunk of code, to either of two break points or frame-out, return non-zero frame rate on frame, breakpoint 0
// *******************************************************************************************************************************

BYTE8 CPUExecute(WORD16 breakPoint1,WORD16 breakPoint2) { 
	BYTE8 next;
	do {
		BYTE8 r = CPUExecuteInstruction();											// Execute an instruction
		if (r != 0) return r; 														// Frame out.
		next = CPUReadFarMemory(PC);
	} while (PC != breakPoint1 && PC != breakPoint2 && next != 0xEA);				// Stop on breakpoint or $EA break
	return 0; 
}

// *******************************************************************************************************************************
//									Return address of breakpoint for step-over, or 0 if N/A
// *******************************************************************************************************************************

WORD16 CPUGetStepOverBreakpoint(void) {
	BYTE8 opcode = CPUReadFarMemory(PC);												// Current opcode.
	if (opcode == 0x20 || opcode == 0x63) return (PC+3) & 0xFFFF;					// Step over JSR.
	return 0;																		// Do a normal single step
}

void CPUEndRun(void) {
}

void CPUExit(void) {	
	FILE *f = fopen("memory.dump","wb");
	fwrite(ramMemory,1,RAMSIZE,f);
	fclose(f);
	GFXExit();
}

static void CPULoadChunk(FILE *f,BYTE8* memory,int count) {
	while (count != 0) {
		int qty = (count > 4096) ? 4096 : count;
		fread(memory,1,qty,f);
		count = count - qty;
		memory = memory + qty;
	}
}
void CPULoadBinary(char *fileName) {
	FILE *f = fopen(fileName,"rb");
	if (f != NULL) {
		CPULoadChunk(f,ramMemory,RAMSIZE);
		fclose(f);
		resetProcessor();
	}
}

// *******************************************************************************************************************************
//											Retrieve a snapshot of the processor
// *******************************************************************************************************************************

static CPUSTATUS st;																	// Status area

CPUSTATUS *CPUGetStatus(void) {
	st.a = A;st.x = X;st.y = Y;st.z = Z;st.sp = SP;st.pc = PC;
	st.carry = C_FLAG;st.interruptDisable = I_FLAG;st.zero = Z_FLAG;
	st.decimal = D_FLAG;st.brk = B_FLAG;st.overflow = V_FLAG;
	st.sign = N_FLAG;st.extStack = E_FLAG;
	st.status = makeStatus();
	st.cycles = cycles;
	return &st;
}

#endif
