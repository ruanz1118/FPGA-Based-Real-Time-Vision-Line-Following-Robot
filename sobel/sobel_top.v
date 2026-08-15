module sobel_top #(
	parameter LINE_WIDTH = 512,
   parameter ADDR_WIDTH = 9
)(
	input clk,
   input rst_n,

   input [7:0] pixel_in,
   input valid_in,

   output wire [7:0] pixel_out,
   output wire valid_out
);

wire [7:0] row0;
wire [7:0] row1;
wire [7:0] row2;

wire valid0;
wire valid1;
wire valid2;

wire [7:0] A;
wire [7:0] B;
wire [7:0] C;
wire [7:0] D;
wire [7:0] E;
wire [7:0] F;
wire [7:0] G;
wire [7:0] H;
wire [7:0] I;

wire valid_window;

two_line_buffer#(
	.LINE_WIDTH(LINE_WIDTH),
   .ADDR_WIDTH(ADDR_WIDTH)
) u_two_line_buffer (
	.clk(clk),
   .rst_n(rst_n),
   .pixel_in(pixel_in),
   .valid_in(valid_in),

   .row0(row0),
   .row1(row1),
   .row2(row2),
	.valid0(valid0),
   .valid1(valid1),
   .valid2(valid2)
);

window_generator#(
	.LINE_WIDTH(LINE_WIDTH)
) u_window_generator (
   .clk(clk),
   .rst_n(rst_n),

   .row0(row0),
   .row1(row1),
   .row2(row2),
	.valid0(valid0),
   .valid1(valid1),
   .valid2(valid2),

   .A(A),
   .B(B),
   .C(C),
   .D(D),
   .E(E),
   .F(F),
   .G(G),
   .H(H),
   .I(I),
   .valid_window (valid_window)
);

sobel_filter u_sobel (
   .clk(clk),
   .rst_n(rst_n),

   .A(A),
   .B(B),
   .C(C),
   .D(D),
   .F(F),
   .G(G),
   .H(H),
   .I(I),
   .valid_window(valid_window),
   .pixel_out(pixel_out),
   .valid_out(valid_out)
);

endmodule