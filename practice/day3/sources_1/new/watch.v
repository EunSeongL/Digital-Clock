`timescale 1ns / 1ps

module watch(
    input clk,
    input reset,
    input sw,
    input up,
    input down,
    input shift,
    output [1:0] mode,
    output [3:0] fnd_dot,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
    );

    wire [1:0] w_mode;
    assign mode = w_mode;

    watch_dp U_watch_dp(
        .clk            (clk),
        .reset          (reset),
        .up             (up),
        .down           (down),
        .mode           (w_mode),
        .fnd_dot        (fnd_dot),
        .msec           (msec),
        .sec            (sec),
        .min            (min),
        .hour           (hour)
    );

    watch_cu U_watch_cu(
        .clk            (clk),
        .reset          (reset),
        .sw             (sw),
        .btn_shift      (shift),
        .mode           (w_mode)
    );


endmodule
