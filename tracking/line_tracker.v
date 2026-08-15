module line_tracker #(
    parameter [7:0] EDGE_THRESHOLD  = 8'd100,

    parameter [8:0] SOBEL_WIDTH     = 9'd510,
    parameter [8:0] SOBEL_HEIGHT    = 9'd254,

    parameter [8:0] SAMPLE_Y_MIN    = 9'd96,
    parameter [8:0] SAMPLE_Y_MAX    = 9'd239,

    parameter [8:0] MIN_TRACK_WIDTH = 9'd20,
    parameter [8:0] MAX_TRACK_WIDTH = 9'd480,

    parameter [8:0] TARGET_CENTER_X = 9'd319
)(
    input  wire              clk,
    input  wire              rst_n,

    input  wire [7:0]        sobel_pixel,
    input  wire              sobel_valid,

    output reg signed [9:0]  track_error,
    output reg [8:0]         track_center,

    output reg               track_valid,
    output reg               track_lost,

    output reg               track_update
);

reg [8:0] sobel_x;
reg [8:0] sobel_y;

reg       first_edge_found;
reg [8:0] first_edge_x;
reg [8:0] last_edge_x;

reg [13:0] center_sum;
reg [5:0]  center_count;

wire edge_pixel;
wire line_end;
wire frame_end;

wire       row_has_edge;
wire [8:0] row_first_edge;
wire [8:0] row_last_edge;
wire [8:0] row_width;
wire [9:0] row_sum;
wire [8:0] row_center;
wire       row_valid;

wire       take_row;
wire [13:0] final_center_sum;
wire [5:0]  final_center_count;
wire [8:0]  frame_center;


assign edge_pixel =
    sobel_valid &&
    (sobel_pixel >= EDGE_THRESHOLD);


assign line_end =
    sobel_valid &&
    (sobel_x == SOBEL_WIDTH - 1'b1);


assign frame_end =
    line_end &&
    (sobel_y == SOBEL_HEIGHT - 1'b1);


assign row_has_edge =
    first_edge_found ||
    edge_pixel;


assign row_first_edge =
    first_edge_found ? first_edge_x :
    edge_pixel       ? sobel_x :
                       9'd0;


assign row_last_edge =
    edge_pixel       ? sobel_x :
    first_edge_found ? last_edge_x :
                       9'd0;


assign row_width =
    row_last_edge -
    row_first_edge;


assign row_sum =
    {1'b0, row_first_edge} +
    {1'b0, row_last_edge};


assign row_center =
    row_sum[9:1];


assign row_valid =
    row_has_edge &&
    (sobel_y >= SAMPLE_Y_MIN) &&
    (sobel_y <= SAMPLE_Y_MAX) &&
    (row_width >= MIN_TRACK_WIDTH) &&
    (row_width <= MAX_TRACK_WIDTH);


assign take_row =
    line_end &&
    row_valid &&
    (center_count < 6'd32);


assign final_center_sum =
    center_sum +
    (take_row ? {5'd0, row_center} : 14'd0);


assign final_center_count =
    center_count +
    (take_row ? 6'd1 : 6'd0);


assign frame_center =
    final_center_sum[13:5];


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sobel_x <= 9'd0;
        sobel_y <= 9'd0;
    end
    else if(sobel_valid) begin

        if(sobel_x == SOBEL_WIDTH - 1'b1) begin

            sobel_x <= 9'd0;

            if(sobel_y == SOBEL_HEIGHT - 1'b1)
                sobel_y <= 9'd0;
            else
                sobel_y <= sobel_y + 1'b1;

        end
        else begin

            sobel_x <= sobel_x + 1'b1;

        end
    end
end


always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin

        first_edge_found <= 1'b0;
        first_edge_x     <= 9'd0;
        last_edge_x      <= 9'd0;

        center_sum       <= 14'd0;
        center_count     <= 6'd0;

        track_center     <= TARGET_CENTER_X;
        track_error      <= 10'sd0;

        track_valid      <= 1'b0;
        track_lost       <= 1'b1;
        track_update     <= 1'b0;

    end
    else begin

        track_valid  <= 1'b0;
        track_update <= 1'b0;


        if(edge_pixel) begin

            if(!first_edge_found) begin
                first_edge_found <= 1'b1;
                first_edge_x     <= sobel_x;
            end

            last_edge_x <= sobel_x;
        end


        if(frame_end) begin

            track_update <= 1'b1;


            if(final_center_count == 6'd32) begin

                track_center <= frame_center;

                track_error <=
                    $signed({1'b0, frame_center})
                    -
                    $signed({1'b0, TARGET_CENTER_X});

                track_valid <= 1'b1;
                track_lost  <= 1'b0;

            end
            else begin

                track_valid <= 1'b0;
                track_lost  <= 1'b1;

            end


            center_sum   <= 14'd0;
            center_count <= 6'd0;

            first_edge_found <= 1'b0;
            first_edge_x     <= 9'd0;
            last_edge_x      <= 9'd0;

        end

        else if(line_end) begin

            if(row_valid && (center_count < 6'd32)) begin

                center_sum <=
                    center_sum +
                    {5'd0, row_center};

                center_count <=
                    center_count + 1'b1;

            end


            first_edge_found <= 1'b0;
            first_edge_x     <= 9'd0;
            last_edge_x      <= 9'd0;

        end
    end
end

endmodule