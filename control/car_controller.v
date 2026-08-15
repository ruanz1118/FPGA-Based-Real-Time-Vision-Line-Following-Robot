module car_controller#(
	parameter [9:0] STRAIGHT_SPEED = 10'd400,
   parameter [9:0] TURN_FAST_SPEED = 10'd500,
   parameter [9:0] TURN_SLOW_SPEED = 10'd100,
   parameter [9:0] REVERSE_SPEED = 10'd270,
   parameter signed [9:0] TURN_ENTER = 10'sd15,
   parameter signed [9:0] TURN_EXIT = 10'sd10,
   parameter [2:0] LOST_FRAMES = 3'd3,
   parameter [2:0] FOUND_FRAMES = 3'd3
)(
   input wire clk,
   input wire rst_n,

   input wire track_update,
   input wire track_valid,
   input wire track_lost,
   input wire signed [9:0] track_error,
	
   output reg [9:0] left_speed,
   output reg [9:0] right_speed,

   output reg left_dir,
   output reg right_dir
);

localparam STATE_FORWARD = 2'd0;
localparam STATE_LEFT    = 2'd1;
localparam STATE_RIGHT   = 2'd2;
localparam STATE_REVERSE = 2'd3;

reg [1:0] state;

reg [2:0] lost_count;
reg [2:0] found_count;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state <= STATE_FORWARD;
      lost_count <= 3'd0;
      found_count <= 3'd0;

      left_speed <= 10'd0;
      right_speed <= 10'd0;

      left_dir <= 1'b1;
      right_dir <= 1'b1;
   end
   else begin
		if (track_update) begin
			case(state)
				STATE_FORWARD: begin
					found_count <= 3'd0;
					if (track_lost) begin
						if (lost_count >= LOST_FRAMES - 1'b1) begin
							state <= STATE_REVERSE;
						end
						else lost_count <= lost_count + 1'b1;
               end
					else if (track_valid) begin
						lost_count <= 3'd0;
						if (track_error > TURN_ENTER)
							state <= STATE_RIGHT;
						else if (track_error < -TURN_ENTER)
							state <= STATE_LEFT;
					end
				end
				STATE_RIGHT: begin
					found_count <= 3'd0;
					if (track_lost) begin
						if (lost_count >= LOST_FRAMES - 1'b1) begin
							state <= STATE_REVERSE;
						end
						else lost_count <= lost_count + 1'b1;
               end
               else if (track_valid) begin
						lost_count <= 3'd0;
                  if (track_error <= TURN_EXIT)
							state <= STATE_FORWARD;
               end
            end
				STATE_LEFT: begin
					found_count <= 3'd0;
					if (track_lost) begin
						if (lost_count >= LOST_FRAMES - 1'b1) begin
							state <= STATE_REVERSE;
						end
						else lost_count <= lost_count + 1'b1;
               end
               else if (track_valid) begin
						lost_count <= 3'd0;
                  if (track_error >= -TURN_EXIT)
							state <= STATE_FORWARD;
               end
            end
            STATE_REVERSE: begin
					lost_count <= 3'd0;
               if (track_valid && !track_lost) begin
						if (found_count >= FOUND_FRAMES - 1'b1) begin
							found_count <= 3'd0;
							if (track_error > TURN_ENTER)
								state <= STATE_RIGHT;
							else if (track_error < -TURN_ENTER)
								state <= STATE_LEFT;
							else
                        state <= STATE_FORWARD;
						end
						else found_count <= found_count + 1'b1;   
               end
               else begin
						found_count <= 3'd0;
               end
            end
            default: begin
					state <= STATE_FORWARD;
               lost_count <= 3'd0;
               found_count <= 3'd0;
            end
			endcase
		end
      case(state)
			STATE_FORWARD: begin
				left_speed <= STRAIGHT_SPEED;
            right_speed <= STRAIGHT_SPEED;
				left_dir <= 1'b1;
            right_dir <= 1'b1;
         end
         STATE_RIGHT: begin
				left_speed <= TURN_SLOW_SPEED;
            right_speed <= TURN_FAST_SPEED;
            left_dir <= 1'b1;
            right_dir <= 1'b1;
         end
         STATE_LEFT: begin
				left_speed <= TURN_FAST_SPEED;
            right_speed <= TURN_SLOW_SPEED;
            left_dir <= 1'b1;
            right_dir <= 1'b1;
         end
         STATE_REVERSE: begin
				left_speed <= REVERSE_SPEED;
            right_speed <= REVERSE_SPEED;
            left_dir <= 1'b0;
            right_dir <= 1'b0;
         end
		endcase
   end
end

endmodule