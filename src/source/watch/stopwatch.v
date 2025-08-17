`timescale 1ns / 1ps

module stopwatch(
    input           clk,
    input           rst,
    input           i_btnL,
    input           i_btnR,
    input           i_display_switch,

    output [13:0]   stopwatch_data
    );

    wire w_clear, w_runstop;

    wire [6:0] o_sw_msec, o_sw_sec, o_sw_min, o_sw_hour;
    wire [13:0] display1, display2;

    assign display1 = o_sw_sec*100 + o_sw_msec;
    assign display2 = o_sw_hour*100 + o_sw_min;

    assign stopwatch_data = (i_display_switch)? display1 : display2;

    stopwatch_cu U_STOPWATCH_CU (
        .clk(clk),
        .rst(rst),
        .i_clear(i_btnL),
        .i_runstop(i_btnR),

        .o_clear(w_clear),
        .o_runstop(w_runstop)
    );

    stopwatch_dp U_STOPWATCH_DP (
        .clk(clk),
        .rst(rst),
        .clear(w_clear),
        .run_stop(w_runstop),

        .msec(o_sw_msec),
        .sec(o_sw_sec),
        .min(o_sw_min),
        .hour(o_sw_hour)
    );

endmodule