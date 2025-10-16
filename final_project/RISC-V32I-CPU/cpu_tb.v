`timescale 1ns/1ps   // Simulation time unit = 1 ns, time precision = 1 ps

module cpu_tb();     // Testbench module has no ports — it's the top-level test environment

    reg clk, reset;  // Declare two testbench signals: clock and reset (both type 'reg')

    // Instantiate the CPU module under test (UUT = Unit Under Test)
    // Connect testbench signals 'clk' and 'reset' to the CPU's inputs
    cpu CPU (
        .clk(clk),
        .reset(reset)
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
        #10 reset = 0;      // Deassert reset after 10 ns → CPU begins normal operation

        // Let the simulation run for 200 ns (enough time for several instructions)
        #200 $stop;         // Stop simulation and open waveform viewer
    end

endmodule
