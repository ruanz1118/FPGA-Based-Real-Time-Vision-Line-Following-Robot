module shift_register_3(
	input clk,
   input rst_n,
	input [7:0] pixel_in,
   input valid_in,

   output reg [7:0] pixel_d1,
   output reg [7:0] pixel_d2
);

always @(posedge clk) begin
	if(!rst_n) begin
		pixel_d1 <= 0;
      pixel_d2 <= 0;
   end
   else if(valid_in) begin
		pixel_d1 <= pixel_in;
      pixel_d2 <= pixel_d1;
	end
end

endmodule