`timescale 1ns / 1ps

module fndcontroller (
    input clk,
    input reset,
    input [6:0] time0,
    input [5:0] time1,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire o_clk;
    wire [1:0] fnd_sel;
    wire [3:0] w_bcd, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;

    clk_div #(
        .F_COUNT(100_000)
    ) U_clk_div (
        .clk  (clk),
        .reset(reset),
        .tick (o_clk)
    );

    counter_4 U_counter_4 (
        .clk    (o_clk),
        .reset  (reset),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_decoder_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

    digit_splitter U_DS (
        .time0     (time0),
        .time1     (time1),
        .digit_1   (w_digit_1),
        .digit_10  (w_digit_10),
        .digit_100 (w_digit_100),
        .digit_1000(w_digit_1000)
    );

    mux_4x1 U_mux_4x1 (
        .sel       (fnd_sel),
        .digit_1   (w_digit_1),
        .digit_10  (w_digit_10),
        .digit_100 (w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd       (w_bcd)
    );

    bcd U_bcd (
        .bcd     (w_bcd),
        .fnd_data(fnd_data)
    );

endmodule

module counter_4 (
    input clk,
    input reset,
    output reg [1:0] fnd_sel
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fnd_sel <= 0;
        end else begin
            fnd_sel <= fnd_sel + 1;
        end
    end

endmodule

module decoder_2x4 (
    input [1:0] fnd_sel,
    output reg [3:0] fnd_com
);

    always @(*) begin
        case (fnd_sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end
endmodule

module mux_4x1 (
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output reg [3:0] bcd
);
    always @(*) begin
        case (sel)
            2'b00: bcd = digit_1;
            2'b01: bcd = digit_10;
            2'b10: bcd = digit_100;
            2'b11: bcd = digit_1000;
        endcase
    end
endmodule

module digit_splitter (
    input  [6:0] time0,
    input  [5:0] time1,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1 = time0 % 10;
    assign digit_10 = (time0 / 10) % 10;
    assign digit_100 = time1 % 10;
    assign digit_1000 = (time1 / 10) % 10;

endmodule

module bcd (
    input [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(*) begin
        case (bcd)
            4'h0: fnd_data = 8'h3f;
            4'h1: fnd_data = 8'h06;
            4'h2: fnd_data = 8'h5b;
            4'h3: fnd_data = 8'h4f;
            4'h4: fnd_data = 8'h66;
            4'h5: fnd_data = 8'h6d;
            4'h6: fnd_data = 8'h7d;
            4'h7: fnd_data = 8'h07;
            4'h8: fnd_data = 8'h7f;
            4'h9: fnd_data = 8'h6f;
            4'ha: fnd_data = 8'h00;
            4'hb: fnd_data = 8'h00;
            4'hc: fnd_data = 8'h00;
            4'hd: fnd_data = 8'h00;
            4'he: fnd_data = 8'h80;
            4'hf: fnd_data = 8'h00;
            default: fnd_data = 8'h00;
        endcase
    end

endmodule
