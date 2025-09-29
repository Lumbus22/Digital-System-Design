module sp3(A, B, cin, cout, S);

input [3:0] A, B;
input cin;

output [3:0] S;
output cout;

wire [4:0] binary_sum; //imagine wires as tempory values for storing data
wire [4:0] corrected_sum;


wire isGreaterThan9;

assign binary_sum = A + B + cin;

assign isGreaterThan9 = (binary_sum > 9);

assign corrected_sum = isGreaterThan9 ? (binary_sum + 6) : binary_sum;

assign S = corrected_sum[3:0];
assign cout = corrected_sum[4];

endmodule


