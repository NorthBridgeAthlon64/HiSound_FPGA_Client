module i2s_clk_gen(
    input wire pll_4x,         // PLL输出时钟
    input wire locked,         // PLL锁定状态
    input wire reset,         //  高电平复位
    
    output reg mclk,                // 主时钟 MCLK
    output reg bclk,                // 位时钟 BCLK
    output reg fsclk                 // 帧时钟 FSCLK (LRCK)
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
    
    reg [MCLK_CNT_WIDTH-1:0]  mclk_cnt;
    reg [BCLK_CNT_WIDTH-1:0]  bclk_cnt;
    reg [FSCLK_CNT_WIDTH-1:0] fsclk_cnt;

    //mclk = 24.576 * 4 / 8 = 12.288Mhz 计数器技术到一半即翻转电平
    always @(posedge pll_4x or posedge reset) begin
        if (reset) begin
            mclk_cnt <= 3'b0;
            mclk <= 1'b0;
        end else if (locked) begin
            if (mclk_cnt == MCLK_HALF - 1) begin
                mclk_cnt <= 3'b0;
                mclk <= ~mclk;
            end else begin
                mclk_cnt <= mclk_cnt + 1'b1;
            end
        end
    end

    //bclk = 24.576 *4 / 32 = 3.072Mhz 计数器计数到一半即翻转电平
    always @(posedge pll_4x or posedge reset) begin
        if (reset) begin
            bclk_cnt <= 5'b0;
            bclk <= 1'b0;
        end else if (locked) begin
            if (bclk_cnt == BCLK_HALF - 1) begin
                bclk_cnt <= 5'b0;
                bclk <= ~bclk;
            end else begin
                bclk_cnt <= bclk_cnt + 1'b1;
            end
        end
    end

    //fsclk: 翻转点偏移半BCLK，对齐BCLK下降沿
    always @(posedge pll_4x or posedge reset) begin
        if (reset) begin
            fsclk_cnt <= 10'b0;
            fsclk <= 1'b0;
        end else if (locked) begin
            if (fsclk_cnt == FSCLK_HALF - 1) begin
                fsclk_cnt <= 10'b0;
                fsclk <= ~fsclk;
            end else begin
                fsclk_cnt <= fsclk_cnt + 1'b1;
            end
        end
    end

endmodule