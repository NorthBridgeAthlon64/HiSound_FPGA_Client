module i2s_dev_38cs(
    input [2:0] bin,
    output reg[7:0] out_io
);
    always@(*)
    begin
        out_io = 8'b0;
        out_io[bin] = 1'b1;
    end
endmodule

module i2s_dev_24cs(
    input [1:0] bin,
    output reg[3:0] out_io
);
    always@(*)
    begin
        out_io = 4'b0;
        out_io[bin] = 1'b1;
    end
endmodule
