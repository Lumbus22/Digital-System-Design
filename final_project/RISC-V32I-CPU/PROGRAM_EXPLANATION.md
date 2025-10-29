# Test Program Explanation

## Program Flow

This test program demonstrates all major features of the RISC-V CPU through a series of functional tests.

## Memory Map

### Instruction Memory
- **0x00-0x34** (0-13): Variable initialization and Fibonacci setup
- **0x24-0x40** (9-16): Fibonacci calculation loop
- **0x44-0x50** (17-20): Arithmetic tests
- **0x54-0x64** (21-25): Logical operation tests
- **0x68-0x74** (26-29): Shift operation tests
- **0x78-0x80** (30-32): Comparison tests
- **0x84-0x8C** (33-35): Memory load/store tests
- **0x90-0xAC** (36-43): Branch tests
- **0xB0-0xB8** (44-46): Upper immediate tests
- **0xBC-0xC4** (47-49): Jump tests
- **0xC8-0xD0** (50-52): Program completion and infinite loop

### Data Memory
- **mem[0]**: Fibonacci[0] = 0
- **mem[1]**: Fibonacci[1] = 1
- **mem[4]**: Used for storing intermediate values
- **mem[6]**: Used for storing intermediate values
- **mem[16]**: Test value (100)
- **mem[24]**: Completion flag (0xFF)

## Detailed Program Analysis

### Section 1: Fibonacci Calculator (Instructions 0-16)

#### Goal
Calculate the first 8 Fibonacci numbers using a loop with branch instructions.

#### Algorithm
```
fib[0] = 0
fib[1] = 1
for i = 2 to 7:
    fib[i] = fib[i-1] + fib[i-2]
```

#### Register Usage
- **x1**: Previous-previous Fibonacci number (fib[n-2])
- **x2**: Previous Fibonacci number (fib[n-1])
- **x3**: Current Fibonacci number (fib[n]) / loop counter
- **x4**: Loop limit (8)
- **x5**: Memory index for storing results
- **x6**: Byte offset (index * 4)

#### Instructions

**Initialization (0-8):**
```assembly
addi x1, x0, 0        # x1 = 0 (first Fibonacci)
addi x2, x0, 1        # x2 = 1 (second Fibonacci)
addi x3, x0, 0        # x3 = 0 (counter)
addi x4, x0, 8        # x4 = 8 (loop until 8 numbers)
addi x5, x0, 0        # x5 = 0 (memory index)

sw   x1, 0(x0)        # Store fib[0] = 0 to mem[0]
sw   x2, 4(x0)        # Store fib[1] = 1 to mem[1]
addi x5, x0, 2        # Start at index 2
addi x3, x0, 2        # Already have 2 numbers
```

**Loop Body (9-16):**
```assembly
# Loop: (PC = 36, memory[9])
add  x3, x1, x2       # Calculate next Fibonacci: x3 = x1 + x2
slli x6, x5, 2        # Calculate byte offset: x6 = index * 4
sw   x3, 6(x0)        # Store to memory (simplified for testing)
add  x1, x2, x0       # Shift: x1 = x2 (old x2 becomes old x1)
add  x2, x3, x0       # Shift: x2 = x3 (new value becomes old x2)
addi x5, x5, 1        # Increment memory index
addi x3, x3, 1        # Increment counter

blt  x3, x4, -12      # if counter < 8, branch back to loop start
                      # Offset -12 = -0xC (back to PC=36)
```

#### Expected Results After Loop
- **x1**: Second-to-last Fibonacci (8)
- **x2**: Last Fibonacci (13)
- **mem[0]**: 0x00000000
- **mem[1]**: 0x00000001
- Intermediate values stored in memory

### Section 2: Arithmetic Tests (Instructions 17-20)

#### Purpose
Test ADD, SUB, and ADDI instructions.

```assembly
addi x7, x0, 20       # x7 = 20
addi x8, x0, 10       # x8 = 10
sub  x9, x7, x8       # x9 = 20 - 10 = 10
add  x11, x7, x8      # x11 = 20 + 10 = 30
```

#### Expected Results
- **x7** = 0x14 (20)
- **x8** = 0x0A (10)
- **x9** = 0x0A (10)
- **x11** = 0x1E (30)

### Section 3: Logical Operations (Instructions 21-25)

#### Purpose
Test AND, OR, and XOR instructions.

```assembly
addi x12, x0, 15      # x12 = 0xF (binary: 1111)
addi x13, x0, 12      # x13 = 0xC (binary: 1100)
and  x14, x12, x13    # x14 = 1111 & 1100 = 1100 = 0xC
or   x15, x12, x13    # x15 = 1111 | 1100 = 1111 = 0xF
xor  x16, x12, x13    # x16 = 1111 ^ 1100 = 0011 = 0x3
```

#### Expected Results
- **x12** = 0x0F
- **x13** = 0x0C
- **x14** = 0x0C (AND result)
- **x15** = 0x0F (OR result)
- **x16** = 0x03 (XOR result)

### Section 4: Shift Operations (Instructions 26-29)

#### Purpose
Test shift left logical (SLLI) and shift right logical (SRLI).

```assembly
addi x17, x0, 1       # x17 = 1
slli x17, x17, 3      # x17 = 1 << 3 = 8
addi x18, x0, 16      # x18 = 16
srli x18, x18, 2      # x18 = 16 >> 2 = 4
```

#### Expected Results
- **x17** = 0x08 (8)
- **x18** = 0x04 (4)

### Section 5: Comparison (Instructions 30-32)

#### Purpose
Test SLT (Set Less Than) instruction.

```assembly
addi x19, x0, 5       # x19 = 5
addi x20, x0, 15      # x20 = 15
slt  x20, x19, x20    # x20 = (5 < 15) ? 1 : 0 = 1
```

#### Expected Results
- **x19** = 0x05
- **x20** = 0x01 (true, 5 < 15)

### Section 6: Memory Operations (Instructions 33-35)

#### Purpose
Test SW (Store Word) and LW (Load Word).

```assembly
addi x21, x0, 100     # x21 = 100
sw   x21, 16(x0)      # mem[16] = 100
lw   x22, 16(x0)      # x22 = mem[16] = 100
```

#### Expected Results
- **x21** = 0x64 (100)
- **x22** = 0x64 (100)
- **mem[16]** = 0x00000064

### Section 7: Branch Tests (Instructions 36-43)

#### Purpose
Test BEQ (Branch if Equal) and BNE (Branch if Not Equal).

**Test 1: BEQ (should branch)**
```assembly
addi x23, x0, 10      # x23 = 10
addi x24, x0, 10      # x24 = 10
beq  x23, x24, 8      # if x23==x24, jump forward 8 bytes
addi x25, x0, 0       # x25 = 0 (THIS SHOULD BE SKIPPED)
addi x25, x0, 1       # x25 = 1 (THIS SHOULD EXECUTE)
```

**Test 2: BNE (should branch because 10 != 1)**
```assembly
bne  x23, x25, 8      # if x23!=x25 (10!=1), jump forward
addi x26, x0, 2       # x26 = 2 (THIS SHOULD BE SKIPPED)
addi x26, x0, 3       # x26 = 3 (THIS SHOULD EXECUTE)
```

#### Expected Results
- **x23** = 0x0A (10)
- **x24** = 0x0A (10)
- **x25** = 0x01 (branch taken, skipped 0)
- **x26** = 0x03 (branch taken, skipped 2)

### Section 8: Upper Immediate (Instructions 44-46)

#### Purpose
Test LUI (Load Upper Immediate) and demonstrate building a large constant.

```assembly
lui   x27, 0x12345    # x27 = 0x12345000
addi  x28, x0, 1656   # x28 = 0x678
or    x28, x27, x28   # x28 = 0x12345000 | 0x678 = 0x12345678
```

#### Expected Results
- **x27** = 0x12345000
- **x28** = 0x12345678

### Section 9: Jump Test (Instructions 47-49)

#### Purpose
Test JAL (Jump and Link) instruction.

```assembly
jal  x1, 8            # Jump to PC+8, save return address in x1
addi x29, x0, 0       # x29 = 0 (THIS SHOULD BE SKIPPED)
addi x29, x0, 1       # x29 = 1 (THIS SHOULD EXECUTE)
```

#### Expected Results
- **x1** = Return address (PC of skipped instruction)
- **x29** = 0x01 (jump successful)

### Section 10: Program Completion (Instructions 50-52)

#### Purpose
Mark successful completion and enter infinite loop.

```assembly
addi x30, x0, 255     # x30 = 0xFF (completion marker)
sw   x30, 24(x0)      # mem[24] = 0xFF
jal  x0, 0            # Infinite loop: jump to self
```

#### Expected Results
- **x30** = 0xFF
- **mem[24]** = 0xFF
- **PC** = 208 (0xD0) stuck in infinite loop

## Verification Checklist

### Fibonacci Calculation
- [ ] x1 starts at 0, x2 starts at 1
- [ ] Values progress through sequence (0,1,1,2,3,5,8,13)
- [ ] Loop executes correct number of times
- [ ] Branch instruction correctly loops back
- [ ] mem[0] = 0, mem[1] = 1

### Arithmetic
- [ ] x9 = 10 (20 - 10)
- [ ] x11 = 30 (20 + 10)

### Logical
- [ ] x14 = 0xC (0xF & 0xC)
- [ ] x15 = 0xF (0xF | 0xC)
- [ ] x16 = 0x3 (0xF ^ 0xC)

### Shifts
- [ ] x17 = 8 (1 << 3)
- [ ] x18 = 4 (16 >> 2)

### Comparison
- [ ] x20 = 1 (5 < 15 is true)

### Memory
- [ ] mem[16] = 100
- [ ] x22 = 100 (loaded from memory)

### Branches
- [ ] x25 = 1 (BEQ taken)
- [ ] x26 = 3 (BNE taken)

### Upper Immediate
- [ ] x27 = 0x12345000
- [ ] x28 = 0x12345678

### Jump
- [ ] x29 = 1 (JAL skipped instruction)

### Completion
- [ ] x30 = 0xFF
- [ ] mem[24] = 0xFF
- [ ] PC stuck at 208

## Timing Estimate

With a 10ns clock period:
- **Initialization**: ~90ns
- **Fibonacci Loop**: ~500-700ns (depends on iterations)
- **Arithmetic Tests**: ~40ns
- **Logical Tests**: ~50ns
- **Shift Tests**: ~40ns
- **Comparison**: ~30ns
- **Memory Tests**: ~30ns
- **Branch Tests**: ~80ns
- **Upper Immediate**: ~30ns
- **Jump Test**: ~30ns
- **Completion**: ~20ns

**Total**: ~1000-1200ns before reaching infinite loop
**Recommended sim time**: 3000ns to see everything clearly

