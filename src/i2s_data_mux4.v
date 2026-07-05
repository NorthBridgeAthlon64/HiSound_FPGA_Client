module i2s_data_mux4(
//00:do0, 01:do1, 10:do2, 11:reset
    input wire[1:0] cs_bin,
    input wire di,
    output wire do0,
    output wire do1,
    output wire do2,
    output wire reset //高电平有效
);

    assign do0 = (cs_bin == 2'd0) ? di : 1'b0;
    assign do1 = (cs_bin == 2'd1) ? di : 1'b0;
    assign do2 = (cs_bin == 2'd2) ? di : 1'b0;
    assign reset = (cs_bin == 2'd3) ? 1'b1 : 1'b0;

endmodule