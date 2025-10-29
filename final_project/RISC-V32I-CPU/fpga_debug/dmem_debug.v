// Data Memory with Debug Access
// CPU can read/write, Debug interface can read

module dmem_debug(
    input clk,
    
    // CPU Port
    input MemWrite,
    input MemRead,
    input [31:0] cpu_addr,
    input [31:0] WriteData,
    output reg [31:0] ReadData,
    
    // Debug Port (Read Only)
    input [5:0] debug_addr,
    output [31:0] debug_data_out
);

    reg [31:0] memory [0:63];  // 64 words = 256 bytes
    
    // CPU Write (synchronous)
    always @(posedge clk) begin
        if (MemWrite)
            memory[cpu_addr[7:2]] <= WriteData;
    end
    
    // CPU Read (combinational)
    always @(*) begin
        if (MemRead)
            ReadData <= memory[cpu_addr[7:2]];
        else
            ReadData <= 0;
    end
    
    // Debug Read Port (combinational)
    assign debug_data_out = memory[debug_addr];
    
endmodule

