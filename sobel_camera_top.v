module sobel_camera_top(
	input sys_clk,
   input sys_rst_n,
   input cam_pclk,
   input cam_vsync,
   input cam_href,
   input [7:0] cam_data,
   output cam_rst_n,
   output cam_sgm_ctrl,
   output cam_scl,
   inout cam_sda,
   output [1:0] led,
   output AIN1,
   output AIN2,
	output AIN3,
   output AIN4,
   output BIN1,
   output BIN2,
   output BIN3,
   output BIN4
);

parameter [7:0] EDGE_THRESHOLD = 8'd100;

wire rst_n;
wire cam_init_done;
wire cmos_frame_valid;
wire [15:0] wr_data;
wire [7:0] gray_data;
wire gray_valid;

reg [9:0] pixel_x;
reg [8:0] pixel_y;
wire crop_valid;
wire [7:0] sobel_pixel_raw;
wire sobel_valid_raw;
wire signed [9:0] track_error;
wire track_valid;
wire track_lost;
wire track_update;
wire [9:0] left_speed;
wire [9:0] right_speed;
wire left_dir;
wire right_dir;

reg motor_armed;
reg [9:0] left_speed_sync;
reg [9:0] left_speed_sys;
reg [9:0] right_speed_sync;
reg [9:0] right_speed_sys;
reg left_dir_sync;
reg left_dir_sys;
reg right_dir_sync;
reg right_dir_sys;
reg motor_armed_sync;
reg motor_armed_sys;

wire left_pwm;
wire right_pwm;
assign rst_n = sys_rst_n;
assign led = {cam_init_done, track_valid};
assign cam_rst_n = 1'b1;
assign cam_sgm_ctrl = 1'b1;
assign crop_valid = gray_valid && (pixel_x >= 10'd64) && (pixel_x <  10'd576) && (pixel_y >= 9'd224) && (pixel_y <  9'd480);

always @(posedge cam_pclk or negedge rst_n) begin
	if(!rst_n) begin
		pixel_x <= 10'd0;
      pixel_y <= 9'd0;
   end
   else if(gray_valid) begin
		if(pixel_x == 10'd639) begin
			pixel_x <= 10'd0;
         if(pixel_y == 9'd479)
				pixel_y <= 9'd0;
         else
				pixel_y <= pixel_y + 1'b1;
      end
      else begin
			pixel_x <= pixel_x + 1'b1;
      end
   end
end

ov7725_dri u_ov7725_dri(
	.clk (sys_clk),
   .rst_n (rst_n),
   .init_done (cam_init_done),
   .cam_scl (cam_scl),
   .cam_sda (cam_sda)
);

cmos_capture_data u_cmos_capture_data(
   .rst_n (rst_n),
   .cam_pclk (cam_pclk),
   .cam_vsync (cam_vsync),
   .cam_href (cam_href),
   .cam_data (cam_data),
   .cmos_frame_valid (cmos_frame_valid),
   .cmos_frame_data (wr_data)
);

rgb565_to_gray u_rgb565_to_gray(
   .clk (cam_pclk),
   .rst_n (rst_n),
   .rgb565_in (wr_data),
   .valid_in (cmos_frame_valid),
   .gray_out (gray_data),
   .valid_out (gray_valid)
);

sobel_top #(
   .LINE_WIDTH (512),
   .ADDR_WIDTH (9)
) u_sobel_top(
   .clk (cam_pclk),
   .rst_n (rst_n),
   .pixel_in (gray_data),
   .valid_in (crop_valid),
   .pixel_out (sobel_pixel_raw),
   .valid_out (sobel_valid_raw)
);

line_tracker #(
   .EDGE_THRESHOLD (EDGE_THRESHOLD),
   .SOBEL_WIDTH (9'd510),
   .SOBEL_HEIGHT (9'd254),
   .SAMPLE_Y_MIN (9'd96),
   .SAMPLE_Y_MAX (9'd239),
   .MIN_TRACK_WIDTH (9'd20),
   .MAX_TRACK_WIDTH (9'd480),
   .TARGET_CENTER_X (9'd319)
) u_line_tracker(
   .clk (cam_pclk),
   .rst_n (rst_n),
   .sobel_pixel (sobel_pixel_raw),
   .sobel_valid (sobel_valid_raw),
   .track_error (track_error),
   .track_center (),
   .track_valid (track_valid),
   .track_lost (track_lost),
   .track_update (track_update)
);

car_controller #(
   .STRAIGHT_SPEED (10'd400),
   .TURN_FAST_SPEED (10'd500),
   .TURN_SLOW_SPEED (10'd100),
   .REVERSE_SPEED (10'd270),
   .TURN_ENTER (10'sd15),
   .TURN_EXIT (10'sd10),
   .LOST_FRAMES (3'd3),
   .FOUND_FRAMES (3'd3)
) u_car_controller(
   .clk (cam_pclk),
   .rst_n (rst_n),
   .track_update (track_update),
   .track_valid (track_valid),
   .track_lost (track_lost),
   .track_error (track_error),
   .left_speed (left_speed),
   .right_speed (right_speed),
   .left_dir (left_dir),
   .right_dir (right_dir)
);

always @(posedge cam_pclk or negedge rst_n) begin
	if(!rst_n)
		motor_armed <= 1'b0;
   else if(cam_init_done && track_valid)
      motor_armed <= 1'b1;
end

always @(posedge sys_clk or negedge rst_n) begin
   if(!rst_n) begin
      left_speed_sync <= 10'd0;
      left_speed_sys <= 10'd0;
      right_speed_sync <= 10'd0;
      right_speed_sys <= 10'd0;

      left_dir_sync <= 1'b1;
      left_dir_sys <= 1'b1;
      right_dir_sync <= 1'b1;
      right_dir_sys <= 1'b1;

      motor_armed_sync <= 1'b0;
      motor_armed_sys <= 1'b0;
   end
   else begin
		left_speed_sync <= left_speed;
      left_speed_sys <= left_speed_sync;
      right_speed_sync <= right_speed;
      right_speed_sys <= right_speed_sync;

      left_dir_sync <= left_dir;
      left_dir_sys <= left_dir_sync;
      right_dir_sync <= right_dir;
      right_dir_sys <= right_dir_sync;

      motor_armed_sync <= motor_armed;
      motor_armed_sys <= motor_armed_sync;
    end
end

pwm_generator u_left_pwm(
	.clk (sys_clk),
   .rst_n (rst_n),
   .duty (left_speed_sys),
   .pwm_out (left_pwm)
);

pwm_generator u_right_pwm(
	.clk (sys_clk),
   .rst_n (rst_n),
   .duty (right_speed_sys),
   .pwm_out (right_pwm)
);

motor_driver u_motor_driver(
   .rst_n (rst_n),
   .left_pwm (left_pwm),
   .right_pwm (right_pwm),
   .motor_enable (motor_armed_sys),
   .left_dir (left_dir_sys),
   .right_dir (right_dir_sys),
   .AIN1 (AIN1),
   .AIN2 (AIN2),
   .AIN3 (AIN3),
   .AIN4 (AIN4),
   .BIN1 (BIN1),
   .BIN2 (BIN2),
   .BIN3 (BIN3),
   .BIN4 (BIN4)
);

endmodule