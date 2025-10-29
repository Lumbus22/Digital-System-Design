# ModelSim Simulation Guide

## Quick Start

### Method 1: Command Line (Fastest)

```bash
# Navigate to your project directory
cd "C:\Users\Laptop\Documents\GitHub\Digital-System-Design\final_project\RISC-V32I-CPU"

# Compile all Verilog files
vlog alu.v regfile.v imem.v dmem.v control.v cpu.v cpu_tb.v

# Run simulation
vsim -do "run -all" cpu_tb

# Or with waveform viewer
vsim -do "add wave -r /*; run -all" cpu_tb
```

### Method 2: Using DO File (Recommended)

Create a file called `run_sim.do`:

```tcl
# Compile all source files
vlog alu.v
vlog regfile.v  
vlog imem.v
vlog dmem.v
vlog control.v
vlog cpu.v
vlog cpu_tb.v

# Start simulation
vsim cpu_tb

# Add all signals to waveform
add wave -r /*

# Add specific signals with better organization
add wave -divider "CPU Signals"
add wave -hex /cpu_tb/uut/PC
add wave -hex /cpu_tb/uut/instr
add wave -binary /cpu_tb/uut/RegWrite
add wave -binary /cpu_tb/uut/MemWrite
add wave -binary /cpu_tb/uut/MemRead
add wave -binary /cpu_tb/uut/Branch
add wave -binary /cpu_tb/uut/Jump

add wave -divider "Register File (x0-x10)"
add wave -hex /cpu_tb/uut/RF/regs[1]
add wave -hex /cpu_tb/uut/RF/regs[2]
add wave -hex /cpu_tb/uut/RF/regs[3]
add wave -hex /cpu_tb/uut/RF/regs[4]
add wave -hex /cpu_tb/uut/RF/regs[5]
add wave -hex /cpu_tb/uut/RF/regs[6]
add wave -hex /cpu_tb/uut/RF/regs[7]
add wave -hex /cpu_tb/uut/RF/regs[8]
add wave -hex /cpu_tb/uut/RF/regs[9]
add wave -hex /cpu_tb/uut/RF/regs[10]

add wave -divider "Data Memory (First 8 Words)"
add wave -hex /cpu_tb/uut/DMEM/memory[0]
add wave -hex /cpu_tb/uut/DMEM/memory[1]
add wave -hex /cpu_tb/uut/DMEM/memory[2]
add wave -hex /cpu_tb/uut/DMEM/memory[3]
add wave -hex /cpu_tb/uut/DMEM/memory[4]
add wave -hex /cpu_tb/uut/DMEM/memory[5]
add wave -hex /cpu_tb/uut/DMEM/memory[6]
add wave -hex /cpu_tb/uut/DMEM/memory[7]

add wave -divider "ALU Signals"
add wave -hex /cpu_tb/uut/ALU/A
add wave -hex /cpu_tb/uut/ALU/B
add wave -hex /cpu_tb/uut/ALU/Result
add wave -binary /cpu_tb/uut/ALU/Zero
add wave -binary /cpu_tb/uut/ALU/LT

# Run simulation
run 3000ns

# Zoom to fit
wave zoom full
```

Then run:
```bash
vsim -do run_sim.do
```

### Method 3: Using ModelSim GUI

1. **File → New → Project**
   - Name: `RISC_V_CPU`
   - Location: Your project directory

2. **Add Files:**
   - alu.v
   - regfile.v
   - imem.v
   - dmem.v
   - control.v
   - cpu.v
   - cpu_tb.v

3. **Compile:**
   - Right-click on project → Compile → Compile All

4. **Simulate:**
   - Click "Simulate" → Start Simulation
   - Select `work.cpu_tb`
   - Click OK

5. **Add Signals:**
   - Right-click in Objects window → Add Wave → All items in region

6. **Run:**
   - Type in console: `run 3000ns`

## Test Program Overview

The CPU executes a comprehensive test program:

### Section 1: Fibonacci Calculator (Memory [0-16])
- Calculates first 8 Fibonacci numbers
- Uses loop with branch instructions
- Stores results in data memory
- **Expected Results:**
  - mem[0] = 0x00000000
  - mem[1] = 0x00000001
  - mem[4] = 0x00000002
  - mem[6] = 0x00000006 (stores to offset 6)

### Section 2: Arithmetic Tests (Memory [17-20])
- Tests ADD, SUB, ADDI
- x7 = 20, x8 = 10
- x9 = 20 - 10 = 10
- x11 = 20 + 10 = 30

### Section 3: Logical Operations (Memory [21-25])
- Tests AND, OR, XOR
- x12 = 0xF, x13 = 0xC
- x14 = 0xF & 0xC = 0xC
- x15 = 0xF | 0xC = 0xF
- x16 = 0xF ^ 0xC = 0x3

### Section 4: Shift Operations (Memory [26-29])
- Tests SLLI, SRLI
- x17 = 1 << 3 = 8
- x18 = 16 >> 2 = 4

### Section 5: Comparison (Memory [30-32])
- Tests SLT (set less than)
- x20 = (5 < 15) ? 1 : 0 = 1

### Section 6: Memory Operations (Memory [33-35])
- Tests SW/LW
- Stores 100 to mem[16]
- Loads back to x22

### Section 7: Branch Tests (Memory [36-43])
- BEQ: Tests equal branch (taken)
- BNE: Tests not-equal branch (taken)
- Verifies conditional execution

### Section 8: Upper Immediate (Memory [44-46])
- Tests LUI
- Creates 0x12345678 using LUI + ORI

### Section 9: Jump Test (Memory [47-49])
- Tests JAL instruction
- Verifies return address storage

### Section 10: Completion (Memory [50-52])
- Stores 0xFF to x30 and mem[24]
- Infinite loop at memory[52]

## What to Look For in Waveforms

### During Reset (0-100ns)
- PC should be 0
- All control signals low

### After Reset (100ns onwards)
- PC increments by 4 each cycle (except branches/jumps)
- Register file updates on clock edges
- Memory operations at correct addresses

### Key Checkpoints

**After ~200ns (Fibonacci initialization):**
- x1 = 0, x2 = 1
- mem[0] = 0, mem[1] = 1

**After ~500ns (Fibonacci loop):**
- Watch x1, x2, x3 show Fibonacci progression
- Branch instruction at PC=64 should loop back

**After ~1000ns (Arithmetic section):**
- x9 = 0x0A (10)
- x11 = 0x1E (30)

**After ~1500ns (Logical section):**
- x14 = 0x0C
- x15 = 0x0F
- x16 = 0x03

**After ~2000ns (Branch section):**
- x25 = 1 (branch taken, skipped x25=0)
- x26 = 3 (branch taken, skipped x26=2)

**Final State (~2800ns):**
- x30 = 0xFF (completion marker)
- mem[24] = 0xFF
- PC stuck at 208 (0xD0) - infinite loop

## Troubleshooting

### No output / blank waveforms
- Make sure you added signals with `add wave`
- Run simulation with `run 3000ns`

### Compilation errors
- Check all files are in the correct directory
- Ensure no syntax errors with `vlog -lint <file>`

### Simulation stops early
- Increase run time: `run 5000ns`
- Check for $finish in testbench

### Wrong results
- Check PC is incrementing correctly
- Verify control signals match instruction type
- Look at ALU inputs and outputs
- Check branch conditions

## Console Output

You should see output like:
```
=========================================================================
                    RISC-V CPU Testbench - Fibonacci Demo
=========================================================================
Program: Calculate Fibonacci sequence and test CPU instructions
Expected: Fibonacci numbers stored in memory (0,1,1,2,3,5,8,13,...)
=========================================================================

Time=0 ns | PC=  0 (0x  0) | Instr=0x00000093 | Reset=1
Time=105 ns | PC=  0 (0x  0) | Instr=0x00000093 | Reset=0
Time=115 ns | PC=  1 (0x  4) | Instr=0x00100113 | Reset=0
Time=125 ns | PC=  2 (0x  8) | Instr=0x00000193 | Reset=0
...
```

## Performance Tips

1. **Only add needed signals** - Adding everything slows simulation
2. **Use specific signal paths** - More efficient than wildcards
3. **Limit simulation time** - 3000ns is enough for this program
4. **Save waveform format** - Create .do file for repeated runs

## Register Naming Reference

For easier debugging, remember:
- x0 = zero (always 0)
- x1 = ra (return address / fib[n-2])
- x2 = s0 (fib[n-1])
- x3 = counter / new fib value
- x4 = loop limit (8)
- x5 = memory index
- x30 = completion flag (should be 0xFF at end)

