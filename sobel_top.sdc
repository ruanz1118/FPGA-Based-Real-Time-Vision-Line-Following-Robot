create_clock -period 20.0 [get_ports sys_clk]
create_clock -period 40.0 [get_ports cam_pclk]

derive_clock_uncertainty