// I2S(24bit) 转 SPDIF(光纤) — Gowin SPDIF_TX IP (IPUG547)
//
// §2.2 特性对照(本工程):
//   I_clk = fs*64          → bclk (48k时3.072MHz / 44.1k时2.8224MHz)
//   采样率 8k~192k         → 本板 48k / 44.1k (sample_sel)
//   位宽 16~24             → SPDIF_DATA_WIDTH=24, I_audio_d[23:0]
//   IEC60958/AES3 PCM      → Consumer CS + V=0 线性PCM
//
// §3.3 帧结构 (IP负责打包/前导/校验; 用户只提供样点与V/U/C):
//   Block = 192 Frame;  Frame = Sub-frame0(Ch A/左) + Sub-frame1(Ch B/右)
//   子帧32bit: Preamble | Aux(4) | Audio(20) | V | U | C | P
//   前导: Z=块起始(Ch A)  X=Ch A  Y=Ch B  — 由 IP 据 block/sub_frame flag 自动插入
//   24bit样点: Aux存放高4bit多余取样, Audio为20bit; IP在SPDIF_DATA_WIDTH=24时自动安排
//   音频在子帧内LSB优先传送 → I_audio_d[0]为样点LSB (本模块I2S收完后[0]即为LSB)
//   V=0数据有效; U用户位; C通道状态(Consumer时bit0=0); P偶校验 — P由IP计算
//
// §3.5 工作过程:
//  1) 复位初始化 → ip_rst_n
//  2) I_clk=fs*64 → bclk
//  3) IP发 flag/req → 本模块响应
//  4) 回送 L/R + V/U/C
//  5)6) 打包/BMC/ODDR → IP内部 → spdif_o
//
// §6: 上升沿对齐; req仅1拍; req高电平上升沿送出数据供IP下一拍采样
module i2s_spdif_converter(
    input wire bclk,
    input wire fsclk,
    input wire data,
    input wire sample_sel,  //0=48kHz, 1=44.1kHz
    input wire reset,       //高有效
    output wire spdif_o
);

    // ---------------- I2S 接收 → 左右声道缓冲 (供步骤4) ----------------
    reg        fs_d;
    reg [2:0]  i2s_arm;
    reg [5:0]  i2s_bit;
    reg [23:0] shift_reg;
    reg [23:0] left_buf;
    reg [23:0] right_buf;

    wire i2s_ready = (i2s_arm == 3'd7);

    always @(posedge bclk or posedge reset) begin
        if (reset) begin
            fs_d      <= 1'b0;
            i2s_arm   <= 3'd0;
            i2s_bit   <= 6'd32;
            shift_reg <= 24'd0;
            left_buf  <= 24'd0;
            right_buf <= 24'd0;
        end else if (!i2s_ready) begin
            i2s_arm <= i2s_arm + 1'b1;
            fs_d    <= fsclk;
            i2s_bit <= 6'd32;
        end else begin
            fs_d <= fsclk;
            if (fsclk != fs_d)
                i2s_bit <= 6'd0;
            else if (i2s_bit < 6'd32)
                i2s_bit <= i2s_bit + 1'b1;

            if (i2s_bit < 6'd24)
                shift_reg <= {shift_reg[22:0], data};

            if (i2s_bit == 6'd23) begin
                if (fs_d == 1'b0)
                    left_buf  <= {shift_reg[22:0], data};
                else
                    right_buf <= {shift_reg[22:0], data};
            end
        end
    end

    // Consumer Mode0 CS; byte3 带采样率
    wire [3:0]   fs_code = sample_sel ? 4'b0000 : 4'b0100;
    wire [191:0] cs_word = {164'd0, fs_code, 20'd0, 4'b0100};

    // -------- §3.5-1 复位 --------
    reg [4:0] ip_rst_cnt;
    reg       ip_rst_n;

    always @(posedge bclk or posedge reset) begin
        if (reset) begin
            ip_rst_cnt <= 5'd0;
            ip_rst_n   <= 1'b0;
        end else if (ip_rst_cnt != 5'd31) begin
            ip_rst_cnt <= ip_rst_cnt + 1'b1;
            ip_rst_n   <= 1'b0;
        end else begin
            ip_rst_n   <= 1'b1;
        end
    end

    // -------- §3.5-3/4 响应 IP 定时请求 --------
    reg  [23:0] audio_d;
    reg         validity_bit;       // 0 = PCM有效
    reg         user_bit;           // 0
    reg         chan_status_bit;
    reg         is_right_ch;        // sub_frame1 = 右
    reg  [7:0]  cs_idx;
    reg         chan_status_bit_req_d;

    wire audio_d_req;
    wire validity_bit_req;
    wire user_bit_req;
    wire chan_status_bit_req;
    wire block_start_flag;
    wire sub_frame0_flag;           // 左
    wire sub_frame1_flag;           // 右

    always @(posedge bclk or posedge reset) begin
        if (reset || !ip_rst_n) begin
            audio_d               <= 24'd0;
            validity_bit          <= 1'b0;
            user_bit              <= 1'b0;
            chan_status_bit       <= 1'b0;
            is_right_ch           <= 1'b0;
            cs_idx                <= 8'd0;
            chan_status_bit_req_d <= 1'b0;
        end else begin
            chan_status_bit_req_d <= chan_status_bit_req;

            // Sub-frame0=Ch A/左(X或Z), Sub-frame1=Ch B/右(Y); block_start时为Z
            if (audio_d_req) begin
                is_right_ch <= sub_frame1_flag;
                audio_d     <= sub_frame1_flag ? right_buf : left_buf; // [0]=LSB
                if (block_start_flag)
                    cs_idx <= 8'd0;   // 新Block, 两声道CS均从bit0重计
            end

            // V: 0=本子帧数据有效可接收
            if (validity_bit_req)
                validity_bit <= 1'b0;

            // U: 每样点1bit, 每声道各自积成192bit用户信息 (本设计全0)
            if (user_bit_req)
                user_bit <= 1'b0;

            // C: 每样点1bit→每声道192bit; bit0=0为Consumer模式
            if (chan_status_bit_req)
                chan_status_bit <= cs_word[cs_idx];

            // 右声道(Ch B)送完本帧C后推进; 左声道共用同一CS内容
            if (chan_status_bit_req_d & ~chan_status_bit_req) begin
                if (is_right_ch)
                    cs_idx <= (cs_idx >= 8'd191) ? 8'd0 : (cs_idx + 1'b1);
            end
        end
    end

    // -------- §3.5-2/5/6 IP: 定时/打包/BMC/ODDR --------
    spdif_tx spdif_txd(
        .I_clk(bclk),
        .I_rst_n(ip_rst_n),
        .I_audio_d(audio_d),
        .I_validity_bit(validity_bit),
        .I_user_bit(user_bit),
        .I_chan_status_bit(chan_status_bit),
        .O_audio_d_req(audio_d_req),
        .O_validity_bit_req(validity_bit_req),
        .O_user_bit_req(user_bit_req),
        .O_chan_status_bit_req(chan_status_bit_req),
        .O_block_start_flag(block_start_flag),
        .O_sub_frame0_flag(sub_frame0_flag),
        .O_sub_frame1_flag(sub_frame1_flag),
        .O_Spdif_tx_data(spdif_o)
    );
endmodule
