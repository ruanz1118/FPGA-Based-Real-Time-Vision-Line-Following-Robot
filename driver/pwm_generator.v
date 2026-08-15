module pwm_generator(
	input wire clk,
   input wire rst_n,
   input wire [9:0] duty,
   output wire pwm_out
);

reg [5:0] div_cnt;
reg [9:0] pwm_cnt;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		div_cnt <= 6'd0;
      pwm_cnt <= 10'd0;
   end
   else begin
      if(div_cnt == 6'd49) begin
			div_cnt <= 6'd0;
         if(pwm_cnt == 10'd999)
				pwm_cnt <= 10'd0;
         else
            pwm_cnt <= pwm_cnt + 1'b1;
      end
      else begin
			div_cnt <= div_cnt + 1'b1;
      end
   end
end

assign pwm_out = (duty >= 10'd1000) ? 1'b1 : (pwm_cnt < duty);

endmodule