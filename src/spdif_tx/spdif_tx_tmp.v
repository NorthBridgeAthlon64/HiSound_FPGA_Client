//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.02_SP1 (64-bit)
//IP Version: 1.0
//Part Number: GW1NSR-LV4CQN48PC6/I5
//Device: GW1NSR-4C
//Created Time: Thu Jul 30 16:26:12 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	spdif_tx your_instance_name(
		.I_clk(I_clk), //input I_clk
		.I_rst_n(I_rst_n), //input I_rst_n
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
		.O_Spdif_tx_data(O_Spdif_tx_data) //output O_Spdif_tx_data
	);

//--------Copy end-------------------
