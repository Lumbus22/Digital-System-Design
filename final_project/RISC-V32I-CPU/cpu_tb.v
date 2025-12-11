`timescale 1ns/1ps   // Simulation time unit = 1 ns, time precision = 1 ps

module cpu_tb();     // Testbench module has no ports — it's the top-level test environment

    reg clk, reset;  // Declare two testbench signals: clock and reset (both type 'reg')

    // Instantiate the CPU module under test (UUT = Unit Under Test)
    // Connect testbench signals 'clk' and 'reset' to the CPU's inputs
	 
	 wire [31:0] pc; //Allows us to see the contents of the PC
	 wire [31:0] instr; // Allows us to view the instruction being exectuted
	 
    cpu uut ( 			//uut  "unit under test" | Creates a cpu named uut
        .clk(clk),
        .reset(reset),
		  .pc(pc),
		  .instr(instr),
		  .LEDOut(),
		  .sevenSegementDisplayValues(),
		  .updateDisplay(1'b0),
		  .selectRegisterBits(5'b0),
		  .DeadBits()
    );

    // --------------------------
    // CLOCK GENERATION BLOCK
    // --------------------------
    // This 'initial' block runs once at the start of simulation
    // It creates an oscillating clock with a 10 ns period (100 MHz)
    initial begin
        clk = 0;                 // Start clock at logic 0
        forever #5 clk = ~clk;   // Toggle every 5 ns → 10 ns total period
    end

    // --------------------------
    // RESET AND SIMULATION CONTROL
    // --------------------------
    // This block drives the reset and determines how long the simulation runs
    initial begin
        reset = 0;          // Assert reset (active-low) at time 0
        #100; 				  // Hold reset for 100ns
        reset = 1;          // Release reset, CPU starts running
    end

	 initial begin
		//Run simulation for a fixed time 
		#10000; //10000ns
		$finish;
	end
	
	// Debug: Display execution info after each clock cycle
	always @(posedge clk) begin
		if (reset) begin
			$display("--------------------------------------------------");
			$display("Time=%0t | PC=%h | Instr=%h", $time, pc, instr);
			$display("  Control: RegWrite=%b ALUSrc=%b ALUOp=%b", 
				uut.RegWrite, uut.ALUSrc, uut.ALUOp);
			$display("  Decode: rs1=%d rs2=%d rd=%d funct7=%b", 
				instr[19:15], instr[24:20], instr[11:7], instr[31:25]);
			$display("  RegFile: rs1_data=%h rs2_data=%h", 
				uut.rs1_data, uut.rs2_data);
			$display("  ALU: A=%h B=%h Result=%h", 
				uut.alu_in1, uut.alu_in2, uut.alu_result);
			$display("  Registers: x1=%h x5=%h x7=%h x10=%h", 
				uut.RF.regs[1], uut.RF.regs[5], uut.RF.regs[7], uut.RF.regs[10]);
		end
	end
	 
	 
endmodule
