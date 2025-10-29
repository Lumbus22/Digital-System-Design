// Register File with Debug Access
// Normal CPU operations plus debug read port

module regfile_debug(
    input clk,
    
    // CPU Ports
    input RegWrite,
    input [4:0] rs1, rs2, rd,
    input [31:0] WriteData,
    output [31:0] ReadData1, ReadData2,
    
    // Debug Port (Read Only)
    input [4:0] debug_reg_addr,
    output [31:0] debug_reg_data
);

    reg [31:0] regs [0:31];  // 32 registers, 32 bits wide
    
    // CPU Read Ports
    assign ReadData1 = (rs1 != 0) ? regs[rs1] : 0;
    assign ReadData2 = (rs2 != 0) ? regs[rs2] : 0;
    
    // Debug Read Port
    assign debug_reg_data = (debug_reg_addr != 0) ? regs[debug_reg_addr] : 0;
    
    // CPU Write Port
    always @(posedge clk) begin
        if (RegWrite && rd != 0)
            regs[rd] <= WriteData;
        regs[0] <= 0;  // x0 always zero
    end
    
endmodule

