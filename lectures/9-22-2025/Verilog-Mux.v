//Proggramming a MUX in verilog

module MUX(w0, w1, S, F);

input w0, w1, S;
output F;

assign F = (~S & w0) | (S & w1); //if S is 0, F = w0; if S is 1, F = w1

endmodule

//another way to write it usign the internal logic of a mux

module moreMUX(w0, w1, S, F);
input w0, w1, S;
output F;

wire F0, F1, F3;

and A1 (F0, w0, F3);
and A2 (F1, S, w1);
not A3 (F3, S);

or A4 (F, F0, F1);

endmodule
