module rgb565_to_gray(
	input clk,
   input rst_n,
   input [15:0] rgb565_in,
   input valid_in,
   output reg [7:0] gray_out,
   output reg valid_out
);

wire [7:0] r;
wire [7:0] g;
wire [7:0] b;
wire [9:0] gray_sum;

assign r = {rgb565_in[15:11], rgb565_in[15:13]};
assign g = {rgb565_in[10:5],  rgb565_in[10:9]};
assign b = {rgb565_in[4:0],   rgb565_in[4:2]};

assign gray_sum = (r >> 2) + (r >> 5) + (g >> 1) + (g >> 4) + (b >> 3);

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		gray_out  <= 8'd0;
      valid_out <= 1'b0;
   end
   else begin
      valid_out <= valid_in;
      if(valid_in)
			gray_out <= gray_sum[7:0];
      else
         gray_out <= 8'd0;
   end
end

endmodule