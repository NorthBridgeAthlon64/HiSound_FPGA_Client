module i2s_spdif_converter(
    input wire bclk,
    input wire fsclk,
    input wire data,
    input wire reset,
    output wire spdif_o
);


    spdif_tx spdif_txd(
        .I_clk(I_clk), //input I_clk
        .I_rst_n(!reset), //input I_rst_n
        .I_audio_d(I_audio_d), //input [23:0] I_audio_d
        .I_validity_bit(I_validity_bit), //input I_validity_bit
        .I_user_bit(I_user_bit), //input I_user_bit
        .I_chan_status_bit(I_chan_status_bit), //input I_chan_status_bit
        .O_audio_d_req(O_audio_d_req), //output O_audio_d_req
        .O_validity_bit_req(O_validity_bit_req), //output O_validity_bit_req
        .O_user_bit_req(O_user_bit_req), //output O_user_bit_req
        .O_chan_status_bit_req(O_chan_status_bit_req), //output O_chan_status_bit_req
        .O_block_start_flag(O_block_start_flag), //output O_block_start_flag
        .O_sub_frame0_flag(O_sub_frame0_flag), //output O_sub_frame0_flag
        .O_sub_frame1_flag(O_sub_frame1_flag), //output O_sub_frame1_flag
        .O_Spdif_tx_data(spdif_o) //output O_Spdif_tx_data
    );
endmodule