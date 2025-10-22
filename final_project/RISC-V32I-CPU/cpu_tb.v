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
		// monitor signal in console
		$monitor("Time=%0t | PC=%h | Instr=%h | Reset=%b", $time, pc, instr, reset);
		
		//Run simulation for a fixed time 
		#10000; //1000ns
		$finish;
	end
	 
	 
endmodule
