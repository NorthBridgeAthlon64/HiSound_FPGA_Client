module i2s_clk_mux2(
    input  wire pll_4x_48k,         // PLL1: 98.304MHz
    input  wire locked_48k,      // PLL1 lock
    
    input  wire pll_4x_44k1,        // PLL2: 90.3168MHz
    input  wire locked_44k1,     // PLL2 lock
    
    input  wire sample_sel,      // 0=48KHz, 1=44.1KHz
    
    output wire pll_4x,          // 选中的PLL时钟
    output wire locked           // 选中的PLL lock状态
);
    
    //弃用，选用遥遥领先的DCS
//    assign pll_4x = sample_sel ? pll_4x_48k : pll_4x_48k;
    assign locked = sample_sel ? locked_44k1: locked_48k ;

    i2s_clk_dcs dcs(
        .clkout(pll_4x), //output clkout
        .clksel({2'b0,sample_sel,~sample_sel}), //input [3:0] clksel
        .clk0(pll_4x_48k), //input clk0
        .clk1(pll_4x_44k1), //input clk1
        .clk2(1'b0), //input clk2
        .clk3(1'b0) //input clk3
    );
endmodule