# PCBoy -- Sam's 8bitMUSH Computer Emulator Documentation

- Foreward
- System Overview
   - Overview
   - Memory Map
- Input
- Display
- Sound
- CPU
  - Registers and Flags
  - Instruction Set
  - Interrupts
  - Comparison to GameBoy CPU
  - Comparison to 8080
  - Comparison to Z80
- Programming
  - Small Programs
  - Large Programs

---

## Foreward

This is some wild project you might not care about. It's a working CPU emulator attatched to virtual hardware on 8bitMUSH. Yes, I can hear you cringing.


## History
Early to Mid 2020 -- Started CPU project after being on hiatus for a while time. Made basic CPU emulation with the first chunk of instructions (Not $CB prefix). Scripts to convert binaries to attributes to copy and past in made to facilitate large programming.

October 21st, 2020 -- Help documentation and underlying help system added.

October 28th, 2020 -- Interrupts added.

December, 2020 -- Screen and input added.

---

## System

### Overview
- CPU
  - 8-bit clone of the GameBoy's SHARP LR35902 CPU (similar to an Intel 8080 & Zilog Z80)
- Memory
  - 65KB separated into 256 pages/attributes stored in decimal
- Screen
  - 80x25 characters
    - 1 byte per character, no color
    - 2000 bytes
- Colors
  - TBD
- Sound
  - TBD, likely just play() format

### Memory Map
    0000 - 003F	    RST Vectors
    0040 - 9FFF	    General Memory
    A000 - AFFF	    VRAM
    B000 - FDFF	    General Memory
    FE00 - FEFF	    Input Buffer
    FF00 - FFFF	    Zero Page

---

## Input

In the second last page, 254 ($FE00-$FEFF), there is a buffer with the last input text in ascii format. When the input command is used, the input text is converted into byte format and stored in this page in memory in order. Next, the input interrupt is executed if interrupts are enabled, jumping back to the appropriate address (see Interrupts for more information). Special characters are currently not supported but most typical ASCII alphanumeric characters are fine. Extended characters should not be inputted.

---

## Display

The screen is 40x20 characters and 256 colours. The video memory (VRAM) begins at $A000, consisting of 3 bytes per screen character. The first byte is the character itself, using codepage 437 and then the next two bytes are the fore and background colours respectively. This means the screen memory takes up 2400 bytes of memory.

    Byte 0        Byte 1        Byte 2
    Character     Fore-Color    Back-Color    ...

---

## Sound

TBD

---

## CPU

### Registers and Flags
Registers can be used as smaller 8-bit units but also paired up as specific 16-bit registers for addressing and larger numbers. Pairs cannot be mix and matched.Stack pointer and program counter/pointer are 16-bit pointers.

    16-bit Pair	High	Low	Name/Function
    AF		A	F	Accumulator and Flags
    BC		B	C	General Purpose
    DE		D	E	General Purpose
    HL		H	L	General Purpose, Pointer
    SP		-	-	Stack Pointer
    PC		-	-	Program Counter

The flag register, F, uses the upper nibble (bits 7-4) as flags for various purposes.

    7   6   5   4   3   2   1   0
    zf  n   h   cy  -   -   -   -
    
    zf	- Zero flag
    n	- Add/subtract flag (for BCD)
    h	- half carry flag (for BCD)
    cy	- carry flag

Zero flag is set when the result of the operation is zero. It's used for conditional jumps. The carry flag is set an operation is bigger than the 8 or 16 bits of the register it is using, when the result is less than zero, or when a rotate/shift instruction rotates out a set bit. The add/subtract flag is used for BCD calculations and is filled when the operation was addition but cleared when it is subtraction. The half-carry flag is used when the lowest nibble overflows because of the operation.

### Instruction Set
The instruction set is similar to an 8080 with a few Z80 elements and it's syntax.

    Movement
    LD -- Load
    LDD -- Load, then Decrement
    LDI -- Load, then Increment
    LDH -- Load from High memory

    Arithmetic
    ADD -- Add
    ADC -- Add with Carry
    SUB -- Subtract
    SBC -- Subtract with Carry
    INC -- Increment
    DEC -- Decrement
    CP -- Compare

    Bitwise Operations
    AND -- Bitwise AND
    OR -- Bitwise OR
    XOR -- Bitwise XOR
    BIT -- Bit Test
    SET -- Bit Set
    RES -- Bit Reset
    CPL -- Complement

    Rotates and Shifts
    RL -- Rotate Left with carry
    RR -- Rotate Right with carry
    RLA -- Rotate Accumulator Left
    RRA -- Rotate Accumulator Right
    RLC -- Rotate Left set carry accordingly
    RRC -- Rotate Right set carry accordingly
    RLCA -- Rotate Accumulator Left set carry accordingly
    RRCA -- Rotate Accumulator Right set carry accordingly
    SLA -- Shift Left zero 0th bit
    SRA -- Shift Right 7th bit repeat
    SRL -- Shift Right zero 7th bit

    Jumps
    JP -- Jump
    JR -- Jump Relative
    CALL -- Call routine
    RST -- Reset vector
    RET -- Return from subroutine
    RETI -- Return from Interrupt

    Stack
    POP -- Pop from stack
    PUSH -- Push to stack

    Miscellaneous
    CCF -- Clear Carry flag
    DAA -- Decimal Arithmetic Adjust
    DI -- Disable Interrupts
    EI -- Enable Interrupts
    HALT -- Halt
    STOP -- Halt CPU
    NOP -- No Operation
    SCF -- Set Carry flag
    SWAP -- Swap nibbles


### Interrupts
The CPU has 7 interrupts, all using the reset vectors (RST $00, $08, $10, $18, $20, $28, $30, $38 respectively). The first vector ($00) is reserved for a software reset of the system as this is where the processor begins execution. Reset 7 (RST $38), is a commonly used filling byte ($FF) so it may be used for a reset for safety.

    Vector  Use
    $00	    Computer Reset
    $08	    Screen "VBlank"
    $10	    Input
    $18	
    $20	    @AMINUTELY
    $28	    @AHOURLY
    $30	
    $38	    
    
An interrupt is called by putting a Reset Vector byte into the INT attribute. This will likely be a decimal value of one of the RST commands. If the internal register INTE, is 1, and INTE filled with something non-zero, the CPU will sense an interrupt before reading the next command byte. It will then run the instruction in INTE before resuming normal execution (unless another interrupt is sensed).

### Comparison to GameBoy CPU
DAA instruction currently does nothing. The half-carry flag is currently not set correctly in many, thus BCD is largely unsupported.
The GameBoy starts execution with the BIOS where it will show the GameBoy logo and check for a legitimate cartridge, afterwards leaving the program counter at $100. The header is right after this so usually, you would soon jump somewhere else in the cartridge where there is more space. Instead of starting execution at $100 like the GameBoy, the emulator starts execution at $0000 (effectively the first reset vector, RST $00).

### Comparison to 8080
Syntax resembles Z80 instead of the 8080's syntax. The interrupts somewhat resemble an 8080s in that the device requesting the interrupt provides a single byte (usually an RST instruction) to execute. Some instructions do not exist on the CPU: IN, OUT, ...TODO

### Comparison to Z80
Many features of the Z80 are absent including: IX & IY registers, Extra register set (A`, F`, etc.), ...TODO

---

## Programming

### Small Programs
Direct, single byte edits can be done on the mush using z/set and z/hset commands. z/set is used for decimal and z/hset is used for hexadecimal edits for convenience. These commands will only edit a single byte at a time.

### Large Programs
Larger programs can be imported by programming outside of the MUSH using any GameBoy compiler to create binaries, then run through a script to convert to a copy-paste-able chunk of text to load into the mush.
