// Instruction Memory with Debug Access
// Dual-port memory: CPU can read, Debug interface can read/write

module imem_debug(
    input clk,
    
    // CPU Port (Read Only)
    input [31:0] cpu_addr,
    output [31:0] cpu_instr,
    
    // Debug Port (Read/Write)
    input debug_write_enable,
    input [5:0] debug_addr,        // Direct address (0-63)
    input [31:0] debug_data_in,
    output [31:0] debug_data_out
);

    // 64 instructions memory
    reg [31:0] memory [0:63];
    integer i;
    
    // Initialize with default test program
    initial begin
        //========================================================================
        // RISC-V CPU Test Program
        // Purpose: Fibonacci sequence calculator with array storage
        //========================================================================
        
        // ===== Initialize Variables =====
        memory[0]  = 32'h00000093; // addi x1, x0, 0        | x1 = 0 (fib[0])
        memory[1]  = 32'h00100113; // addi x2, x0, 1        | x2 = 1 (fib[1])
        memory[2]  = 32'h00000193; // addi x3, x0, 0        | x3 = 0 (counter)
        memory[3]  = 32'h00800213; // addi x4, x0, 8        | x4 = 8 (loop limit)
        memory[4]  = 32'h00000293; // addi x5, x0, 0        | x5 = 0 (memory index)
        
        // ===== Store First Two Fibonacci Numbers =====
        memory[5]  = 32'h00102023; // sw   x1, 0(x0)        | mem[0] = 0
        memory[6]  = 32'h00202223; // sw   x2, 4(x0)        | mem[1] = 1
        memory[7]  = 32'h00200293; // addi x5, x0, 2        | x5 = 2 (index counter)
        memory[8]  = 32'h00200193; // addi x3, x0, 2        | x3 = 2 (already have 2 fib numbers)
        
        // ===== LOOP: Calculate and Store Remaining Fibonacci Numbers =====
        memory[9]  = 32'h002081b3; // add  x3, x1, x2       | x3 = fib[n-2] + fib[n-1]
        memory[10] = 32'h00229313; // slli x6, x5, 2        | x6 = index * 4 (byte offset)
        memory[11] = 32'h00302323; // sw   x3, 6(x0)        | Workaround: store to fixed location
        memory[12] = 32'h00000093; // add  x1, x2, x0       | x1 = x2 (shift values)
        memory[13] = 32'h00018113; // add  x2, x3, x0       | x2 = x3 (new becomes old)
        memory[14] = 32'h00128293; // addi x5, x5, 1        | x5++ (increment index)
        memory[15] = 32'h00118193; // addi x3, x3, 1        | x3++ (increment counter)
        
        // ===== Check Loop Condition and Branch =====
        memory[16] = 32'hfe41cae3;  // blt  x3, x4, -12      | if counter < 8, loop back to memory[9]
        
        // ===== Arithmetic Test Section =====
        memory[17] = 32'h01400393; // addi x7, x0, 20       | x7 = 20
        memory[18] = 32'h00a00413; // addi x8, x0, 10       | x8 = 10
        memory[19] = 32'h408384b3; // sub  x9, x7, x8       | x9 = 20 - 10 = 10
        memory[20] = 32'h008385b3; // add  x11, x7, x8      | x11 = 20 + 10 = 30
        
        // ===== Logical Operations Test =====
        memory[21] = 32'h00f00613; // addi x12, x0, 15      | x12 = 0xF
        memory[22] = 32'h00c00693; // addi x13, x0, 12      | x13 = 0xC
        memory[23] = 32'h00d67733; // and  x14, x12, x13    | x14 = 0xF & 0xC = 0xC
        memory[24] = 32'h00d667b3; // or   x15, x12, x13    | x15 = 0xF | 0xC = 0xF
        memory[25] = 32'h00d64833; // xor  x16, x12, x13    | x16 = 0xF ^ 0xC = 0x3
        
        // ===== Shift Operations Test =====
        memory[26] = 32'h00100893; // addi x17, x0, 1       | x17 = 1
        memory[27] = 32'h00389893; // slli x17, x17, 3      | x17 = 1 << 3 = 8
        memory[28] = 32'h01000913; // addi x18, x0, 16      | x18 = 16
        memory[29] = 32'h00295913; // srli x18, x18, 2      | x18 = 16 >> 2 = 4
        
        // ===== Comparison Test =====
        memory[30] = 32'h00500993; // addi x19, x0, 5       | x19 = 5
        memory[31] = 32'h00f00a13; // addi x20, x0, 15      | x20 = 15
        memory[32] = 32'h0149aa33; // slt  x20, x19, x20    | x20 = (5 < 15) = 1
        
        // ===== Memory Load/Store Test =====
        memory[33] = 32'h06400a93; // addi x21, x0, 100     | x21 = 100
        memory[34] = 32'h01502823; // sw   x21, 16(x0)      | mem[16] = 100
        memory[35] = 32'h01002b03; // lw   x22, 16(x0)      | x22 = mem[16] = 100
        
        // ===== Branch Test: BEQ (taken) =====
        memory[36] = 32'h00a00b93; // addi x23, x0, 10      | x23 = 10
        memory[37] = 32'h00a00c13; // addi x24, x0, 10      | x24 = 10
        memory[38] = 32'h018b8463; // beq  x23, x24, 8      | if x23==x24, jump to [40] (TAKEN)
        memory[39] = 32'h00000c93; // addi x25, x0, 0       | x25 = 0 (SKIPPED)
        memory[40] = 32'h00100c93; // addi x25, x0, 1       | x25 = 1 (EXECUTED)
        
        // ===== Branch Test: BNE (not taken) =====
        memory[41] = 32'h019b9463; // bne  x23, x25, 8      | if x23!=x25, jump (TAKEN, 10!=1)
        memory[42] = 32'h00200d13; // addi x26, x0, 2       | x26 = 2 (SKIPPED)
        memory[43] = 32'h00300d13; // addi x26, x0, 3       | x26 = 3 (EXECUTED)
        
        // ===== Upper Immediate Test =====
        memory[44] = 32'h12345db7; // lui   x27, 0x12345    | x27 = 0x12345000
        memory[45] = 32'h67800e13; // addi  x28, x0, 1656   | x28 = 0x678
        memory[46] = 32'h01cdee33; // or    x28, x27, x28   | x28 = 0x12345678
        
        // ===== JAL Test: Jump and Link =====
        memory[47] = 32'h008000ef; // jal  x1, 8            | x1 = PC+4, jump to [49]
        memory[48] = 32'h00000e93; // addi x29, x0, 0       | x29 = 0 (SKIPPED)
        memory[49] = 32'h00100e93; // addi x29, x0, 1       | x29 = 1 (EXECUTED)
        
        // ===== Final Results Summary =====
        memory[50] = 32'h0ff00f13; // addi x30, x0, 255     | x30 = 0xFF (test complete marker)
        memory[51] = 32'h01e02c23; // sw   x30, 24(x0)      | mem[24] = 0xFF
        
        // ===== Infinite Loop: End of Program =====
        memory[52] = 32'h0000006f; // jal  x0, 0            | Infinite loop (stay at PC=208)
        
        // Initialize remaining memory to NOP
        for(i = 53; i < 64; i = i + 1) begin
            memory[i] = 32'h00000013;
        end
    end
    
    // CPU read port (combinational)
    assign cpu_instr = memory[cpu_addr[7:2]];
    
    // Debug read port (combinational)
    assign debug_data_out = memory[debug_addr];
    
    // Debug write port (synchronous)
    always @(posedge clk) begin
        if (debug_write_enable) begin
            memory[debug_addr] <= debug_data_in;
        end
    end
    
endmodule

