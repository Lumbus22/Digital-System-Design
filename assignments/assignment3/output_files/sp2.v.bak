module sp2(x1, x3, x3, F);

input x1, x2, x3;

output F;

and (F0, ~x1, ~x2, x3);
and (F1, ~x1, x2, ~x3);
and (F2, x1, ~x2, ~x3);
and (F3, ~x1, ~x2, ~x3):

or (F, F0, F1, F2, F3);

endmodule 

