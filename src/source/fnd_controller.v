`timescale 1ns / 1ps

module fnd_Controller (
    input clk,
    input reset,
    input [13:0] count_data,
    input [6:0] msec,

    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output dot_clk
);

    wire [3:0] w_b;
    wire [3:0] w_d_1, w_d_10, w_d_100, w_d_1000;
    wire [2:0] fnd_sel;
    wire w_oclk;

    clk_1sec U_CLK_1SEC (
        .clk(clk),
        .rst(reset),
        .msec(msec),

        .clk_1sec(clk_1sec)
    );

    clk_div U_CLK_Div (
        .clk(clk),
        .reset(reset),
        .o_clk(w_oclk)
    );

    counter_8  U_Counter_8 (
        .clk(w_oclk),
        .reset(reset),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel[1:0]),
        .fnd_com(fnd_com)
    );

    digit_splitter U_DS (
        .count_data(count_data),
        .disit_1(w_d_1),
        .disit_10(w_d_10),
        .disit_100(w_d_100),
        .disit_1000(w_d_1000)
    );

    MUX_8x1 U_MUX_8x1 (
        .sel(fnd_sel),
        .disit_1(w_d_1),
        .disit_10(w_d_10),
        .disit_100(w_d_100),
        .disit_1000(w_d_1000),
        .dot_display(clk_1sec),
        .bcd(w_b)
    );

    BCD U_BCD (
        .bcd(w_b),

        .fnd_data(fnd_data)
    );

    assign dot_clk = clk_1sec;

endmodule

module clk_1sec (
    input clk,
    input [6:0] msec,
    input rst,

    output clk_1sec
);
    reg [6:0] r_counter;  
    reg r_clk;
    assign clk_1sec = r_clk;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_clk       <= 1'b0;
        end else begin
            if (msec <= 49) begin
                r_clk <= 1'b0;
            end else begin
                r_clk <= 1'b1;
            end
        end
    end
endmodule


// clock divider
module clk_div (
    input clk,
    input reset,

    output o_clk
);
    // clk 100_000_000, r_count = 100_000 ==> 1kHz로 간다. 17bit 사용하면 된다.
//  reg [16:0] r_counter;
    reg [$clog2(100_000) - 1:0] r_counter;  // $clog2()로 계산해줘서 사용가능
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter   <= 0;
            r_clk       <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end
endmodule

// 8진 카운터.
module counter_8 (
    input clk,
    input reset,

    output [2:0] fnd_sel
);
    reg [2:0] r_counter;
    assign fnd_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule


module decoder_2x4 (
    input [1:0] fnd_sel,

    output reg [3:0] fnd_com  // always 문의 출력은 "reg"
);

    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00:   fnd_com = 4'b1110;  // fnd 1의 자리 on.
            2'b01:   fnd_com = 4'b1101;  // fnd 10의 자리 on.
            2'b10:   fnd_com = 4'b1011;  // fnd 100의 자리 on. 
            2'b11:   fnd_com = 4'b0111;  // fnd 1000의 자리 on.
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule

module digit_splitter (
    input [13:0] count_data,

    output [3:0] disit_1,
    output [3:0] disit_10,
    output [3:0] disit_100,
    output [3:0] disit_1000
);
    assign disit_1 = count_data % 10;
    assign disit_10 = (count_data / 10) % 10;
    assign disit_100 = (count_data / 100) % 10;
    assign disit_1000 = (count_data / 1000) % 10;

endmodule

module MUX_8x1 (
    input [2:0] sel,
    input dot_display,
    input [3:0] disit_1,
    input [3:0] disit_10,
    input [3:0] disit_100,
    input [3:0] disit_1000,

    output reg [3:0] bcd
);
    always @(*) begin  // always 출력은 "reg"를 씀.
        case ({sel})
            3'b000: bcd = disit_1;
            3'b001: bcd = disit_10;
            3'b010: bcd = disit_100;
            3'b011: bcd = disit_1000;
            3'b100: bcd = 4'h0b;
            3'b101: bcd = 4'h0b;
            3'b110: bcd = (dot_display) ? 4'h0a : 4'h0b;
            3'b111: bcd = 4'h0b;
        endcase
    end
endmodule


module BCD (
    input [3:0] bcd, // 3bit면 2^3=8 까지밖에 표현이 안됨, FND에 9까지 표현 필요.

    output reg [7:0] fnd_data
);
    always @(*) begin  // always 출력은 "reg"를 씀.
        case (bcd)
            4'h00:   fnd_data = 8'hc0;
            4'h01:   fnd_data = 8'hf9;
            4'h02:   fnd_data = 8'ha4;
            4'h03:   fnd_data = 8'hb0;
            4'h04:   fnd_data = 8'h99;
            4'h05:   fnd_data = 8'h92;
            4'h06:   fnd_data = 8'h82;
            4'h07:   fnd_data = 8'hf8;
            4'h08:   fnd_data = 8'h80;
            4'h09:   fnd_data = 8'h90;
            4'h0a:   fnd_data = 8'h7f;
            4'h0b:   fnd_data = 8'hff;
            default: fnd_data = 8'h00;  // ??
        endcase
    end

endmodule