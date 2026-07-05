module i2s_mux2(
    input  wire clk_48k,         // PLL1: 98.304MHz
    input  wire locked_48k,      // PLL1 lock
    
    input  wire clk_44k1,        // PLL2: 90.3168MHz
    input  wire locked_44k1,     // PLL2 lock
    
    input  wire sample_sel,      // 0=44.1KHz, 1=48KHz
    
    output wire pll_4x,          // 选中的PLL时钟
    output wire locked           // 选中的PLL lock状态
);
    

    assign pll_4x = sample_sel ? clk_48k : clk_44k1;
    assign locked = sample_sel ? locked_48k : locked_44k1;

endmodule