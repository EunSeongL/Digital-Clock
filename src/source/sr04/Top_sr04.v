`timescale 1ns / 1ps

module Top_sr04(
    input clk,
    input rst,
    input btnU,
    input btnD,
    input echo,

    output trig,
    output [13:0] sr04_data,
    output go_ascii,
    output [7:0] ascii
    );

    sr04_controller SR04_CNTL (
        .clk(clk),
        .rst(rst),
        .btnU(btnU),
        .btnD(btnD),
        .echo(echo),

        .trig(trig),
        .dist(sr04_data),
        .dist_done(dist_done),
        .ascii(ascii),
        .go_ascii(go_ascii)
    );


endmodule
