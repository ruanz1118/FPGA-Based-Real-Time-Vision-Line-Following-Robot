module motor_driver(
	input wire rst_n,
   input wire left_pwm,
   input wire right_pwm,
   input wire motor_enable,
   input wire left_dir,
   input wire right_dir,
 
	output wire AIN1,
   output wire AIN2,
   output wire AIN3,
   output wire AIN4,
   output wire BIN1,
   output wire BIN2,
   output wire BIN3,
   output wire BIN4
);

wire left_drive;
wire right_drive;

assign left_drive = rst_n && motor_enable && left_pwm;
assign right_drive = rst_n && motor_enable && right_pwm;

assign AIN1 = left_dir ? left_drive : 1'b0;
assign AIN2 = left_dir ? 1'b0 : left_drive;
assign AIN3 = right_dir ? right_drive : 1'b0;
assign AIN4 = right_dir ? 1'b0 : right_drive;

assign BIN1 = left_dir ? left_drive : 1'b0;
assign BIN2 = left_dir ? 1'b0 : left_drive;
assign BIN3 = right_dir ? right_drive : 1'b0;
assign BIN4 = right_dir ? 1'b0 : right_drive;

endmodule