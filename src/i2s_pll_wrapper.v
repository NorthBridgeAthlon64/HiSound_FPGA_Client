module i2s_pll_wrapper(
    input wire clk_24_576,      
    input wire clk_22_5792,     
    input wire reset,           //高电平复位
    
    output wire pll_4x_48k,      //PLL1输出：98.304MHz
    output wire locked_48k,      //PLL1锁定
    
    output wire pll_4x_44k1,     //PLL2输出：90.3168MHz
    output wire locked_44k1      //PLL2锁定
);


    pll_i2s_48k pll_48k (
        .clkin  (clk_24_576),
        .clkout (pll_4x_48k),
        .lock   (locked_48k),
        .reset  (reset)          //高电平复位
    );
    

    pll_i2s_44_1k pll_44k1 (
        .clkin  (clk_22_5792),
        .clkout (pll_4x_44k1),
        .lock   (locked_44k1),
        .reset  (reset)          //高电平复位
    );

endmodule