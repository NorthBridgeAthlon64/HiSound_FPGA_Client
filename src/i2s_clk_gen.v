    module i2s_clk_gen(
    input wire pll_4x,         // PLL输出时钟
    input wire locked,         // PLL锁定状态
    input wire reset,         //  高电平复位
    
    output wire mclk,                // 主时钟 MCLK
    output wire bclk,                // 位时钟 BCLK
    output wire fsclk                 // 帧时钟 FSCLK (LRCK)
);
    
    // MCLK: PLL/8  (98.304/8=12.288 或 90.3168/8=11.2896)
    localparam MCLK_HALF = 4;           //8分频 → 半周期=4
    localparam MCLK_CNT_WIDTH = 3;      //计数器位宽(0~3)
    
    // BCLK: PLL/32 (98.304/32=3.072 或 90.3168/32=2.8224)
    localparam BCLK_HALF = 16;          //32分频 → 半周期=16
    localparam BCLK_CNT_WIDTH = 5;      //计数器位宽(0~15)
    
    // FSCLK: PLL/2048 (98.304/2048=48K 或 90.3168/2048=44.1K)
    localparam FSCLK_HALF = 1024;       //2048分频 → 半周期=1024
    localparam FSCLK_CNT_WIDTH = 10;    //计数器位宽(0~1023)

    wire g_pll_4x;
    wire g_mclk;
    wire g_bclk;
    wire g_fsclk;

    wire mclk_int;
    reg bclk_int;
    reg fsclk_int;

    BUFG pll_4x_bufg (.I(pll_4x), .O(g_pll_4x));   
    BUFG mclk_bufg (.I(mclk_int), .O(g_mclk));   
    BUFG bclk_bufg (.I(bclk_int), .O(g_bclk));
    BUFG fsclk_bufg (.I(fsclk_int), .O(g_fsclk));

    //reg [MCLK_CNT_WIDTH-1:0]  mclk_cnt;
    reg [BCLK_CNT_WIDTH-1:0]  bclk_cnt;
    reg [FSCLK_CNT_WIDTH-1:0] fsclk_cnt;

    //mclk与bclk、fsclk无严格相位对齐，直接使用硬件分频
    //mclk = 24.576 * 4 / 4 = 24.Mhz
    i2s_clk_div4 pll4x_div4(
        .clkout(mclk_int), 
        .hclkin(g_pll_4x),
        .resetn(!reset)
    );

    //bclk = 24.576 * 4 / 32 = 3.072Mhz
    always @(posedge g_pll_4x or posedge reset) begin
        if (reset) begin
            bclk_cnt <= 5'b0;
            bclk_int <= 1'b0;
        end else if (locked) begin
            if (bclk_cnt == BCLK_HALF - 1) begin
                bclk_cnt <= 5'b0;
                bclk_int <= ~bclk_int;
            end else begin
                bclk_cnt <= bclk_cnt + 1'b1;
            end
        end else begin
            bclk_cnt <= {BCLK_CNT_WIDTH{1'b0}};
            bclk_int <= 1'b0;
        end
    end

    //fsclk: 24.576 * 4 / 2048 = 3.072Mhz
    always @(posedge g_pll_4x or posedge reset) begin
        if (reset) begin
            fsclk_cnt <= 10'b0;
            fsclk_int <= 1'b0;
        end else if (locked) begin
            if (fsclk_cnt == FSCLK_HALF - 1) begin
                fsclk_cnt <= 10'b0;
                fsclk_int <= ~fsclk_int;
            end else begin
                fsclk_cnt <= fsclk_cnt + 1'b1;
            end
        end else begin
            fsclk_cnt <= {FSCLK_CNT_WIDTH{1'b0}};
            fsclk_int <= 1'b0;
        end
    end

    assign mclk = g_mclk;
    assign bclk = g_bclk;
    assign fsclk = g_fsclk;
    
endmodule