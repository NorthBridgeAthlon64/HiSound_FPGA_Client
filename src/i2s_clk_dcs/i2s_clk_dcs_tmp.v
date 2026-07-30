//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.02_SP1 (64-bit)
//IP Version: 1.0
//Part Number: GW1NSR-LV4CQN48GC6/I5
//Device: GW1NSR-4C
//Created Time: Tue Jul  7 14:02:19 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    i2s_clk_dcs your_instance_name(
        .clkout(clkout), //output clkout
        .clksel(clksel), //input [3:0] clksel
        .clk0(clk0), //input clk0
        .clk1(clk1), //input clk1
        .clk2(clk2), //input clk2
        .clk3(clk3) //input clk3
    );

//--------Copy end-------------------
