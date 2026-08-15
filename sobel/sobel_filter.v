module sobel_filter(
	input clk,
	input rst_n,
	
	input [7:0] A,
	input [7:0] B,
	input [7:0] C,
	input [7:0] D,
	input [7:0] F,
	input [7:0] G,
	input [7:0] H,
	input [7:0] I,
	input valid_window,
	output wire valid_out,
	output reg [7:0] pixel_out
);

reg signed [10:0] gx;
reg signed [10:0] gy;
reg [10:0] abs_gx;
reg [10:0] abs_gy;

reg [11:0] gradient_sum;

reg [3:0] valid_pipe;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		gx <= 11'sd0;
		gy <= 11'sd0;
		abs_gx <= 11'd0;
		abs_gy <= 11'd0;
		gradient_sum <= 12'd0;
		pixel_out<= 8'd0;
		valid_pipe <= 4'b0000;
	end
	else begin
		valid_pipe[0] <= valid_window;
		valid_pipe[1] <= valid_pipe[0];
		valid_pipe[2] <= valid_pipe[1];
		valid_pipe[3] <= valid_pipe[2];
		if (valid_window) begin
			gx <= -$signed({3'b000,A})          //A,B,C are unsigned,3'b000 is for 
					+$signed({3'b000,C})	         //signed extension to match bit widths
					-($signed({3'b000,D}) <<< 1)	//and make signed arithmetic work correctly
					+($signed({3'b000,F}) <<< 1)
					-$signed({3'b000,G})   
					+$signed({3'b000,I});
					
			gy <= -$signed({3'b000,A})           
					+$signed({3'b000,G})	         
					-($signed({3'b000,B}) <<< 1)	
					+($signed({3'b000,H}) <<< 1)
					-$signed({3'b000,C})   
					+$signed({3'b000,I});
		end
		if (valid_pipe[0]) begin
			if (gx[10]) begin
				abs_gx <= -gx;
			end
			else abs_gx <= gx;
			
			if (gy[10]) begin
				abs_gy <= -gy;
			end
			else abs_gy <= gy;
		end
		if (valid_pipe[1]) begin
			gradient_sum <= abs_gx + abs_gy;
		end
		if (valid_pipe[2]) begin
			if (gradient_sum > 12'd255)
				pixel_out <= 8'd255;
			else
				pixel_out <= gradient_sum[7:0];
		end
	end
end
assign valid_out = valid_pipe[3];

endmodule