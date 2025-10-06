module SLOW_CLK(clk, clk_1hz);

input clk;
output reg clk_1hz;

integer k;

always @(posedge clk)
	if (k == 25000000)
	begin
		clk_1hz = ~clk_1hz;
		k = 0;
	end
	
	else
		k = k + 1; 
		
endmodule
		