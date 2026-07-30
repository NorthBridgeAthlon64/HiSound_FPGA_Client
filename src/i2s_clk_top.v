module i2s_clk_top(
    input wire clk_24_576,      //24.576MHz晶振（48KHz系列）
    input wire clk_22_5792,     //22.5792MHz晶振（44.1KHz系列）
    input wire sample_sel,      //采样率选择：0=48KHz, 1=44.1KHz
    
    //I2S输出（DAC用）        
    output wire bclk0,           //位时钟
    output wire fsclk0,          //帧时钟
    output wire do0,

    //I2S输出（DAC-RJ12）
    output wire mclk1,            //主时钟
    output wire bclk1,
    output wire fsclk1,
    output wire do1,

    //SPDIF输出
    output wire spdif_do,

    //选择是ADC还是RJ12还是PDM 三选一输入
    //ADC:00 RJ12:01 PDM:10 Reset:11
    input wire[1:0] dev_cs_bin_3863,
    
    //I2S输入（Hi3863）
    output wire bclk2,
    output wire fsclk2,
    input wire di2

);
    //高电平有效
    wire reset;
    
    //PLL输出
    wire pll_4x_48k, locked_48k;
    wire pll_4x_44k1, locked_44k1;
    
    //MUX 输出
    wire pll_4x, locked;
    
    //时钟生成输出
    wire mclk, bclk, fsclk;
    wire cnt_reset;

    //mux分配给SPDIF通道的I2S数据
    wire i2s_di_spdif;
       
    //PLL封装（双PLL并行干活）
    i2s_pll_wrapper u_pll (
        .clk_24_576    (clk_24_576),
        .clk_22_5792   (clk_22_5792),
        .reset         (reset),
        
        .pll_4x_48k    (pll_4x_48k),
        .locked_48k    (locked_48k),
        
        .pll_4x_44k1   (pll_4x_44k1),
        .locked_44k1   (locked_44k1)
    );
    
    //时钟mux2
    i2s_clk_mux2 u_mux (
        .pll_4x_48k    (pll_4x_48k),
        .locked_48k    (locked_48k),
        .pll_4x_44k1   (pll_4x_44k1),
        .locked_44k1   (locked_44k1),
        .sample_sel    (sample_sel),
        
        .pll_4x        (pll_4x),
        .locked        (locked)
    );

    //时钟切换检测，cnt_reset 复位计数器
    i2s_dual_pll_sync u_sync (
        .clk           (pll_4x),
        .sample_sel    (sample_sel),
        .reset         (reset),
        .cnt_reset     (cnt_reset)
    );
    
    //I2S时钟分频生成器
    i2s_clk_gen u_clkgen (
        .pll_4x        (pll_4x),
        .locked        (locked),
        .reset         (cnt_reset),
        
        .mclk          (mclk),
        .bclk          (bclk),
        .fsclk         (fsclk)
    );  
    
    // DAC时钟
    assign bclk0  = bclk;
    assign fsclk0 = fsclk;

    
    // RJ12时钟
    assign mclk1  = mclk;
    assign bclk1  = bclk;
    assign fsclk1 = fsclk;


    //3863时钟
    assign bclk2 = bclk;
    assign fsclk2 = fsclk;
    
    //DAC、DAC-RJ12、SPDIF、Reset对接mux4
    i2s_data_mux4 mux4(
    //归一化data_cs解码器，按位与
        .cs_bin(dev_cs_bin_3863),
        .do0(do0),
        .do1(do1),
        .do2(i2s_di_spdif),
        .di(di2),
        .reset(reset) //高电平有效
    );

    //I2S转SPDIF光纤输出 (Gowin SPDIF_TX IP, IPUG547)
    i2s_spdif_converter u_i2s2spdif(
        .bclk      (bclk),
        .fsclk     (fsclk),
        .data      (i2s_di_spdif),
        .sample_sel(sample_sel),
        .reset     (reset),
        .spdif_o   (spdif_do)
    );

endmodule
