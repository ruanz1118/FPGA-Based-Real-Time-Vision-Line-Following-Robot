module window_generator#(
	parameter LINE_WIDTH = 512
)(
	input clk,
	input rst_n,
	input valid0,
	input valid1,
	input valid2,
	input [7:0] row0,
	input [7:0] row1,
	input [7:0] row2,
	
	output [7:0] A,
	output [7:0] B,
	output [7:0] C,
	output [7:0] D,
	output [7:0] E,
	output [7:0] F,
	output [7:0] G,
	output [7:0] H,
	output [7:0] I,
	output valid_window
);
reg [8:0] col_count;
always @(posedge clk) begin
	if(!rst_n) begin
		col_count <= 9'b0;
	end
	else if (valid2) begin
		if (col_count == LINE_WIDTH-1) begin
			col_count <= 9'b0;
		end
		else col_count <= col_count + 9'b1;
	end
end

shift_register_3 sr2(
	.clk(clk),
	.rst_n(rst_n),
	.pixel_in(row2),
	.valid_in(valid2),
	.pixel_d1(B),
	.pixel_d2(A)
);

shift_register_3 sr1(
	.clk(clk),
	.rst_n(rst_n),
	.pixel_in(row1),
	.valid_in(valid2),
	.pixel_d1(E),
	.pixel_d2(D)
);

shift_register_3 sr0(
	.clk(clk),
	.rst_n(rst_n),
	.pixel_in(row0),
	.valid_in(valid2),
	.pixel_d1(H),
	.pixel_d2(G)
);

assign I = row0;
assign F = row1;
assign C = row2;
assign valid_window = valid2 && (col_count >= 9'd2);

endmodule		