module two_line_buffer#(
	parameter LINE_WIDTH = 512,
	parameter ADDR_WIDTH = 9
)( 
	input clk,
	input rst_n,
	input [7:0] pixel_in,
	input valid_in,
	
	output wire [7:0] row0,
	output wire [7:0] row1,
	output wire [7:0] row2,
	output wire valid0,
	output wire valid1,
	output wire valid2
);

assign row0 = pixel_in;
assign valid0 = valid_in;

line_buffer#(
	.LINE_WIDTH(LINE_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH)
) lb1(
	.clk(clk),
	.rst_n(rst_n),
	.pixel_in(row0),
	.valid_in(valid0),
	.pixel_out(row1),
	.valid_out(valid1)
);
line_buffer#(
	.LINE_WIDTH(LINE_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH)
) lb2(
	.clk(clk),
	.rst_n(rst_n),
	.pixel_in(row1),
	.valid_in(valid1),
	.pixel_out(row2),
	.valid_out(valid2)
);

endmodule