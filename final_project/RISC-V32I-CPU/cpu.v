//Top-Level CPU

module cpu(
	input clk,
	input reset,
	output [31:0] pc,
	output [31:0] instr

);

	wire [31:0] pc_next, pc_plus4; 
	wire [31:0] rs1_data, rs2_data, alu_result, mem_read_data;
	wire [31:0] imm_extended; // Immediate value after extension
	wire [31:0] write_back_data; // Data to write back to register
	wire RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, Branch;
	wire Jump, JALRSel, LUISel, AUIPCSel; // New control signals
	wire Zero, LT, LTU, GE, GEU; // ALU flags
	wire [3:0] ALUOp;

	// Immediate Generation - decode and sign-extend immediates based on instruction type
	wire [31:0] imm_I = {{20{instr[31]}}, instr[31:20]};  // I-type: sign-extend bits [31:20]
	wire [31:0] imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};  // S-type: store offset
	wire [31:0] imm_B = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};  // B-type: branch offset
	wire [31:0] imm_U = {instr[31:12], 12'b0};  // U-type: upper immediate
	wire [31:0] imm_J = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};  // J-type: jump offset
	
	// Select appropriate immediate based on instruction opcode
	reg [31:0] imm_sel;
	always @(*) begin
		case(instr[6:0])
			7'b0010011, 7'b0000011, 7'b1100111: imm_sel = imm_I; // I-type: ADDI, LW, JALR
			7'b0100011: imm_sel = imm_S;  // S-type: SW
			7'b1100011: imm_sel = imm_B;  // B-type: branches
			7'b0110111, 7'b0010111: imm_sel = imm_U;  // U-type: LUI, AUIPC
			7'b1101111: imm_sel = imm_J;  // J-type: JAL
			default: imm_sel = imm_I;
		endcase
	end
	
	assign imm_extended = imm_sel;
	
	// Program Counter (PC)
	
	reg [31:0] PC;
	assign pc = PC;
	assign pc_plus4 = PC + 4;
	
	// Branch/Jump target calculations
	wire [31:0] branch_target = PC + imm_extended;  // Branch or JAL target
	wire [31:0] jalr_target = (rs1_data + imm_extended) & ~32'd1;  // JALR target (LSB cleared)
	
	// Branch condition evaluation based on funct3
	wire branch_taken;
	reg branch_cond;
	always @(*) begin
		case(instr[14:12])  // funct3
			3'b000: branch_cond = Zero;      // BEQ
			3'b001: branch_cond = ~Zero;     // BNE
			3'b100: branch_cond = LT;        // BLT
			3'b101: branch_cond = GE;        // BGE
			3'b110: branch_cond = LTU;       // BLTU
			3'b111: branch_cond = GEU;       // BGEU
			default: branch_cond = 0;
		endcase
	end
	assign branch_taken = Branch & branch_cond;
	
	// PC update logic
	always @(posedge clk or posedge reset)
		begin
			if(reset)
				PC <= 0;
			else if(Jump && JALRSel)
				PC <= jalr_target;  // JALR
			else if(Jump)
				PC <= branch_target;  // JAL
			else if(branch_taken)
				PC <= branch_target;  // Branch
			else
				PC <= pc_plus4;  // Sequential
		end
		
		// Instruction Memory
		imem IMEM (
			.addr(pc), 			//the cpu asks imem for the instruction using the current pc
			.instr(instr)
		); 
		
		// Control Unit
		
		// The control unit decodes the instructions opcode (bits[6:0]) and generates control signals
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
		assign write_back_data = LUISel ? imm_extended :           // LUI: write upper immediate
		                         AUIPCSel ? (PC + imm_extended) :  // AUIPC: write PC + upper immediate
		                         Jump ? pc_plus4 :                  // JAL/JALR: write return address (PC+4)
		                         MemToReg ? mem_read_data :        // LW: write memory data
		                         alu_result;                        // Default: write ALU result
		
		//The Register file holds the 32 RISC-V registers (0x-x31)
		regfile RF (
			
			.clk(clk),
			.RegWrite(RegWrite),
			.rs1(instr[19:15]),
			.rs2(instr[24:20]),
			.rd(instr[11:7]),
			.WriteData(write_back_data),
			.ReadData1(rs1_data),
			.ReadData2(rs2_data)
		);
		
		
		
		//ALU
		
		//This line chooses the second ALU operand
		wire [31:0] alu_in2 = ALUSrc ? imm_extended : rs2_data; // Use immediate or register value
		
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
		
		
		
		//Data Memory
		//Accessed when using lw and sw instrucitons
		dmem DMEM (
			.clk(clk), 
			.MemWrite(MemWrite), 
			.MemRead(MemRead),
			.addr(alu_result), 
			.WriteData(rs2_data), 
			.ReadData(mem_read_data)
		);
						
	endmodule
		
		
		
		
		
		
		
	