module i2s_dual_pll_sync(
    input  wire clk,
    input  wire sample_sel,
    input  wire reset,

    output wire cnt_reset
);

    reg [2:0] sel_sync;
    reg       sel_d1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sel_sync <= 3'b0;
            sel_d1   <= 1'b0;
        end else begin
            sel_sync <= {sel_sync[1:0], sample_sel};
            sel_d1   <= sel_sync[2];
        end
    end

    wire sel_changed = sel_sync[2] != sel_d1;

    // 切换后 cnt_reset 保持 4096 周期（~42us），大于 fsclk 周期（~21us），
    // 确保 DAC/ADC 采样到至少一个完整帧周期后再恢复
    reg [11:0] rst_cnt;
    reg        rst_active;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rst_cnt    <= 12'b0;
            rst_active <= 1'b0;
        end else begin
            if (sel_changed)
                rst_active <= 1'b1;
            else if (rst_active)
                rst_cnt <= rst_cnt + 1'b1;
            if (rst_cnt == 10'd0 && rst_active && !sel_changed)
                rst_active <= 1'b0;
        end
    end

    assign cnt_reset = reset | rst_active;

endmodule
