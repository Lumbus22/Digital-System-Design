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
		  .instr(instr)
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
        reset = 1;          // Assert reset high at time 0
        #100; 					 // Hold reset for 100ns
		  reset = 0;     	

    end

	 initial begin
		// Display header
		$display("=========================================================================");
		$display("                    RISC-V CPU Testbench - Fibonacci Demo");
		$display("=========================================================================");
		$display("Program: Calculate Fibonacci sequence and test CPU instructions");
		$display("Expected: Fibonacci numbers stored in memory (0,1,1,2,3,5,8,13,...)");
		$display("=========================================================================");
		$display("");
		
		// Monitor signals in console with enhanced formatting
		$monitor("Time=%0t ns | PC=%3d (0x%3h) | Instr=0x%h | Reset=%b", 
		         $time, pc/4, pc, instr, reset);
		
		//Run simulation long enough to complete the program
		#3000; // Run for 3000ns (300 clock cycles)
		
		$display("");
		$display("=========================================================================");
		$display("                         Simulation Complete");
		$display("=========================================================================");
		$display("Check the following in the waveform viewer:");
		$display("  - Register x1, x2, x3 should show Fibonacci progression");
		$display("  - Data memory locations 0-7 should contain: 0,1,1,2,3,5,8,13");
		$display("  - Register x30 should be 0xFF (test complete marker)");
		$display("  - PC should be stuck at 208 (0xD0) in infinite loop");
		$display("=========================================================================");
		$finish;
	end
	 
	 
endmodule
