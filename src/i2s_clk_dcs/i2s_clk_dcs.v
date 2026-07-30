//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12.02_SP1 (64-bit)
//IP Version: 1.0
//Part Number: GW1NSR-LV4CQN48GC6/I5
//Device: GW1NSR-4C
//Created Time: Tue Jul  7 14:02:19 2026

module i2s_clk_dcs (clkout, clksel, clk0, clk1, clk2, clk3);

output clkout;
input [3:0] clksel;
input clk0;
input clk1;
input clk2;
input clk3;

wire gw_gnd;

assign gw_gnd = 1'b0;

DCS dcs_inst (
    .CLKOUT(clkout),
    .CLKSEL(clksel),
    .CLK0(clk0),
    .CLK1(clk1),
    .CLK2(clk2),
    .CLK3(clk3),
    .SELFORCE(gw_gnd)
);

defparam dcs_inst.DCS_MODE = "RISING";

endmodule //i2s_clk_dcs
