module line_buffer#(
	parameter LINE_WIDTH = 512,
	parameter ADDR_WIDTH = 9
)(
	input clk,
	input rst_n,
	input [7:0] pixel_in,
	input valid_in,
	
	output reg [7:0] pixel_out,
	output reg valid_out
);

reg [7:0] mem [0:LINE_WIDTH-1];
reg [ADDR_WIDTH-1:0] addr;
reg first_line;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		valid_out <= 1'b0;
		first_line <= 1'b1;
		addr <= 0;
	end
	else if (valid_in) begin
		pixel_out <= mem[addr];
		mem[addr] <= pixel_in;
		if (addr == LINE_WIDTH-1) begin
			addr <= 0;
			first_line <= 1'b0;
		end
		else begin
			addr <= addr + 1'b1;
		end
		valid_out <= !first_line;
	end
	else begin
		valid_out <= 1'b0;
	end
end

endmodule