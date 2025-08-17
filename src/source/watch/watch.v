`timescale 1ns / 1ps

module watch(
    input           clk,
    input           rst,
    input           i_btnL,
    input           i_btnR,
    input           i_btnU,
    input           i_btnD,
    input           i_set_mode_command,
    input           i_display_switch,

    output [13:0]   watch_data,
    output [6:0]    msec,
    output [2:0]    watch_state

    );

    wire w_clear, w_runstop;
    wire w_set_sec, w_set_min, w_set_hour;
    
    wire [6:0] o_w_msec, o_w_sec, o_w_min, o_w_hour;
    wire [13:0] display1, display2;

    assign msec = o_w_msec;

    assign display1 = o_w_sec*100 + o_w_msec;
    assign display2 = o_w_hour*100 + o_w_min;

    assign watch_data = (i_display_switch)? display1 : display2;

    watch_cu U_WATCH_CU (
        .clk(clk),
        .rst(rst),
        .i_left(i_btnL),
        .i_right(i_btnR),
        .sw15(i_set_mode_command),

        .o_set_idel(o_led15),
        .o_set_sec(w_set_sec),
        .o_set_min(w_set_min),
        .o_set_hour(w_set_hour),
        .watch_state(watch_state)
    );

    watch_dp U_STOPWATCH_DP (
        .clk(clk),
        .rst(rst),
        .i_up(i_btnU),
        .i_down(i_btnD),
        .i_set_sec(w_set_sec),
        .i_set_min(w_set_min),
        .i_set_hour(w_set_hour),

        .msec(o_w_msec),
        .sec(o_w_sec),
        .min(o_w_min),
        .hour(o_w_hour)
    );

endmodule