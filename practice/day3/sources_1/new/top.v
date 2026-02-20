`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input btn1,
    input btn2,
    input btn3,
    input [1:0] sw,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );

    wire sw_runstop, sw_clear;
    wire w_up, w_down, w_shift;

    wire [1:0] mode;
    wire [3:0] fnd_dot;
    wire [6:0] sw_msec, w_msec;
    wire [5:0] sw_sec, w_sec;
    wire [5:0] sw_min, w_min;
    wire [4:0] sw_hour, w_hour;
    wire [6:0] time0;
    wire [5:0] time1;

    mode_controller U_mode_controller(
        .clk            (clk),
        .reset          (reset),
        .sw             (sw[1]),
        .btn1           (btn1),
        .btn2           (btn2),
        .btn3           (btn3),
        .w_up           (w_up),
        .w_down         (w_down),
        .w_shift        (w_shift),
        .sw_runstop     (sw_runstop),
        .sw_clear       (sw_clear)
    );

    watch U_watch(
        .clk        (clk),
        .reset      (reset),
        .sw         (sw[0]),
        .up         (w_up),
        .down       (w_down),
        .shift      (w_shift),
        .mode       (mode),
        .fnd_dot    (fnd_dot),
        .msec       (w_msec),
        .sec        (w_sec),
        .min        (w_min),
        .hour       (w_hour)
    );

    stopwatch U_stopwatch(
        .clk        (clk),
        .reset      (reset),
        .runstop    (sw_runstop),
        .clear      (sw_clear),
        .msec       (sw_msec),
        .sec        (sw_sec),
        .min        (sw_min),
        .hour       (sw_hour)
    );

    sel_time U_sel_time(
        .sw         (sw),
        .mode       (mode),
        .sw_msec    (sw_msec),
        .sw_sec     (sw_sec),
        .sw_min     (sw_min),
        .sw_hour    (sw_hour),
        .w_msec     (w_msec),
        .w_sec      (w_sec),
        .w_min      (w_min),
        .w_hour     (w_hour),
        .time0      (time0),
        .time1      (time1)
    );

    fndcontroller U_fndcontroller(
        .clk            (clk),
        .reset          (reset),
        .time0          (time0),
        .time1          (time1),
        .fnd_dot        (fnd_dot),
        .fnd_data       (fnd_data),
        .fnd_com        (fnd_com)
    );


endmodule

module sel_time (
    input [1:0] sw,
    input [1:0] mode,
    input [6:0] sw_msec,
    input [5:0] sw_sec,
    input [5:0] sw_min,
    input [4:0] sw_hour,
    input [6:0] w_msec,
    input [5:0] w_sec,
    input [5:0] w_min,
    input [4:0] w_hour,
    output reg [6:0] time0,
    output reg [5:0] time1
);

    always @(*) begin
        case (sw[1])
            0: begin
                if(sw[0] == 0) begin
                    time0 = sw_msec;
                    time1 = sw_sec;
                end
                else begin
                    time0 = sw_min;
                    time1 = sw_hour;
                end
            end 
            1: begin
                case (mode)
                0 : begin
                    time0 = w_msec;
                    time1 = w_sec;
                end
                1 :  begin
                    time0 = w_sec;
                    time1 = w_min;
                end
                2 :  begin
                    time0 = w_min;
                    time1 = w_hour;
                end
                3 :  begin
                    time0 = w_hour;
                    time1 = w_msec;
                end
                endcase
            end
        endcase
    end

    
endmodule
