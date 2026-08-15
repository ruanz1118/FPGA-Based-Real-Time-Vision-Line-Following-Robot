module ov7725_dri(
    input  clk,
    input  rst_n,

    output init_done,
    output cam_scl,
    inout  cam_sda
);

parameter SLAVE_ADDR = 7'h21;
parameter BIT_CTRL   = 1'b0;
parameter CLK_FREQ   = 26'd50_000_000;
parameter I2C_FREQ   = 18'd250_000;

wire        i2c_exec;
wire [15:0] i2c_data;
wire        i2c_done;
wire        i2c_dri_clk;

i2c_ov7725_rgb565_cfg u_i2c_cfg(
    .clk       (i2c_dri_clk),
    .rst_n     (rst_n),
    .i2c_done  (i2c_done),
    .i2c_exec  (i2c_exec),
    .i2c_data  (i2c_data),
    .init_done (init_done)
);

i2c_dri #(
    .SLAVE_ADDR (SLAVE_ADDR),
    .CLK_FREQ   (CLK_FREQ),
    .I2C_FREQ   (I2C_FREQ)
) u_i2c_dri(
    .clk        (clk),
    .rst_n      (rst_n),

    .i2c_exec   (i2c_exec),
    .bit_ctrl   (BIT_CTRL),
    .i2c_rh_wl  (1'b0),
    .i2c_addr   (i2c_data[15:8]),
    .i2c_data_w (i2c_data[7:0]),
    .i2c_data_r (),
    .i2c_done   (i2c_done),
    .i2c_ack    (),
    .scl        (cam_scl),
    .sda        (cam_sda),

    .dri_clk    (i2c_dri_clk)
);

endmodule