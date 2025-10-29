// Top-Level CPU with Debug Interface
// Integrates RISC-V CPU with UART-based debug capabilities

module cpu_with_debug(
    input clk,
    input reset_btn,              // External reset button
    
    // UART Interface to ESP32
    input uart_rx,
    output uart_tx,
    
    // Optional: Status LEDs
    output [3:0] status_leds,
    
    // Optional: PC output for debugging
    output [31:0] pc_out,
    output [31:0] instr_out
);

    // Internal signals
    wire cpu_clk;
    wire cpu_reset;
    wire cpu_enable;
    wire cpu_step;
    wire system_reset;
    
    // Synchronize external reset
    // NOTE: DE10-Lite KEY buttons are active-LOW (pressed=0, released=1)
    // So we invert the signal to get active-HIGH reset
    reg reset_sync1, reset_sync2;
    always @(posedge clk) begin
        reset_sync1 <= ~reset_btn;  // Invert: button not pressed = 0 (no reset)
        reset_sync2 <= reset_sync1;
    end
    assign system_reset = reset_sync2;
    
    // CPU internal signals
    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] rs1_data, rs2_data, alu_result, mem_read_data;
    wire [31:0] imm_extended;
    wire [31:0] write_back_data;
    wire RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch;
    wire Jump, JALRSel, LUISel, AUIPCSel;
    wire Zero, LT, LTU, GE, GEU;
    wire [3:0] ALUOp;
    
    // Debug interface signals
    wire debug_cpu_enable;
    wire debug_cpu_reset;
    wire debug_cpu_step;
    wire debug_cpu_halted;
    
    wire [4:0] debug_reg_addr;
    wire [31:0] debug_reg_data;
    
    wire imem_debug_we;
    wire [5:0] imem_debug_addr;
    wire [31:0] imem_debug_din;
    wire [31:0] imem_debug_dout;
    
    wire [5:0] dmem_debug_addr;
    wire [31:0] dmem_debug_dout;
    
    wire [7:0] debug_status;
    
    // CPU clock control - gate clock when not enabled
    assign cpu_clk = clk & (debug_cpu_enable | debug_cpu_step);
    assign cpu_reset = system_reset | debug_cpu_reset;
    assign debug_cpu_halted = ~debug_cpu_enable;
    
    // Output assignments
    assign pc_out = pc;
    assign instr_out = instr;
    assign status_leds = {debug_cpu_enable, ~debug_cpu_halted, debug_status[1:0]};
    
    // ====== Debug Interface Module ======
    debug_interface #(
        .CLOCK_FREQ(50000000),
        .BAUD_RATE(115200)
    ) debug_if (
        .clk(clk),
        .reset(system_reset),
        
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        
        .cpu_enable(debug_cpu_enable),
        .cpu_reset(debug_cpu_reset),
        .cpu_step(debug_cpu_step),
        .cpu_halted(debug_cpu_halted),
        
        .pc_in(pc),
        .current_instr(instr),
        
        .debug_reg_addr(debug_reg_addr),
        .debug_reg_data(debug_reg_data),
        
        .imem_write_enable(imem_debug_we),
        .imem_addr(imem_debug_addr),
        .imem_data_in(imem_debug_din),
        .imem_data_out(imem_debug_dout),
        
        .dmem_addr(dmem_debug_addr),
        .dmem_data_out(dmem_debug_dout),
        
        .debug_status(debug_status)
    );
    
    // ====== CPU Core (from original cpu.v) ======
    
    // Immediate Generation
    wire [31:0] imm_I = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_B = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_U = {instr[31:12], 12'b0};
    wire [31:0] imm_J = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    
    reg [31:0] imm_sel;
    always @(*) begin
        case(instr[6:0])
            7'b0010011, 7'b0000011, 7'b1100111: imm_sel = imm_I;
            7'b0100011: imm_sel = imm_S;
            7'b1100011: imm_sel = imm_B;
            7'b0110111, 7'b0010111: imm_sel = imm_U;
            7'b1101111: imm_sel = imm_J;
            default: imm_sel = imm_I;
        endcase
    end
    assign imm_extended = imm_sel;
    
    // Program Counter
    reg [31:0] PC;
    assign pc = PC;
    wire [31:0] pc_plus4 = PC + 4;
    
    // Branch/Jump targets
    wire [31:0] branch_target = PC + imm_extended;
    wire [31:0] jalr_target = (rs1_data + imm_extended) & ~32'd1;
    
    // Branch condition evaluation
    wire branch_taken;
    reg branch_cond;
    always @(*) begin
        case(instr[14:12])
            3'b000: branch_cond = Zero;
            3'b001: branch_cond = ~Zero;
            3'b100: branch_cond = LT;
            3'b101: branch_cond = GE;
            3'b110: branch_cond = LTU;
            3'b111: branch_cond = GEU;
            default: branch_cond = 0;
        endcase
    end
    assign branch_taken = Branch & branch_cond;
    
    // PC update logic
    always @(posedge cpu_clk or posedge cpu_reset) begin
        if(cpu_reset)
            PC <= 0;
        else if(Jump && JALRSel)
            PC <= jalr_target;
        else if(Jump)
            PC <= branch_target;
        else if(branch_taken)
            PC <= branch_target;
        else
            PC <= pc_plus4;
    end
    
    // Instruction Memory with Debug
    imem_debug IMEM (
        .clk(clk),
        .cpu_addr(pc),
        .cpu_instr(instr),
        .debug_write_enable(imem_debug_we),
        .debug_addr(imem_debug_addr),
        .debug_data_in(imem_debug_din),
        .debug_data_out(imem_debug_dout)
    );
    
    // Control Unit
    control CTRL (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .Jump(Jump),
        .JALRSel(JALRSel),
        .LUISel(LUISel),
        .AUIPCSel(AUIPCSel),
        .ALUOp(ALUOp)
    );
    
    // Write-back data selection
    assign write_back_data = LUISel ? imm_extended :
                             AUIPCSel ? (PC + imm_extended) :
                             Jump ? pc_plus4 :
                             MemToReg ? mem_read_data :
                             alu_result;
    
    // Register File with Debug
    regfile_debug RF (
        .clk(cpu_clk),
        .RegWrite(RegWrite),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .WriteData(write_back_data),
        .ReadData1(rs1_data),
        .ReadData2(rs2_data),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg_data(debug_reg_data)
    );
    
    // ALU
    wire [31:0] alu_in2 = ALUSrc ? imm_extended : rs2_data;
    
    alu ALU (
        .A(rs1_data),
        .B(alu_in2),
        .ALUControl(ALUOp),
        .Result(alu_result),
        .Zero(Zero),
        .LT(LT),
        .LTU(LTU),
        .GE(GE),
        .GEU(GEU)
    );
    
    // Data Memory with Debug
    dmem_debug DMEM (
        .clk(cpu_clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .cpu_addr(alu_result),
        .WriteData(rs2_data),
        .ReadData(mem_read_data),
        .debug_addr(dmem_debug_addr),
        .debug_data_out(dmem_debug_dout)
    );
    
endmodule

