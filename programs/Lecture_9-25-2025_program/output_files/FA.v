module D_Filp_Flop(x, CLK, Q, notQ);

input x, CLK;
output reg Q, notQ;


always @(posedge CLK)

begin	
	Q = x;
	notQ = ~x;
end 

endmodule