`timescale 1ns / 1ps

module stopwatch(
    input clk,
    input reset,
    input btn3,
    input btn2,
    input sw,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [6:0] msec;
    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour;

    wire [6:0] time0;
    wire [5:0] time1;
    
    wire w_runstop, w_clear;
    wire runstop, clear; 

    btn_debounce U_btn3_RS(
        .clk            (clk),
        .reset          (reset),
        .in_button      (btn3),
        .rising_edge    (w_runstop),
        .falling_edge   (),
        .both_edge      ()
    );

    btn_debounce U_btn2_CL(
        .clk            (clk),
        .reset          (reset),
        .in_button      (btn2),
        .rising_edge    (w_clear),
        .falling_edge   (),
        .both_edge      ()
    );

    stopwatch_dp U_stopwatch_dp(
        .clk            (clk),
        .reset          (reset),
        .runstop        (runstop),
        .clear          (clear),
        .msec           (msec),
        .sec            (sec),
        .min            (min),
        .hour           (hour)
    );

    stopwatch_cu U_stopwatch_cu(
        .clk            (clk),
        .reset          (reset),
        .btn_clear      (w_clear),
        .btn_runstop    (w_runstop),
        .clear          (clear),
        .runstop        (runstop)
    );

    sel_time U_sel_time(
        .sw             (sw),
        .msec           (msec),
        .sec            (sec),
        .min            (min),
        .hour           (hour),
        .time0          (time0),
        .time1          (time1)
    );

    fndcontroller U_fndcontroller(
        .clk            (clk),
        .reset          (reset),
        .time0          (time0),
        .time1          (time1),
        .fnd_data       (fnd_data),
        .fnd_com        (fnd_com)
    );

endmodule

/*
module counter_10000 (
    input clk,
    input reset,
    output reg [13:0] count_data
    );

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            count_data <= 0;
        end
        else begin
            if(count_data == 10000 - 1) begin
                count_data <= 0;
            end
            else begin
                count_data <= count_data + 1;
            end
        end
    end
    
    endmodule
*/

module sel_time (
    input sw,
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    output reg [6:0] time0,
    output reg [5:0] time1
);

    always @(*) begin
        case (sw)
            0 : begin
                time0 = msec;
                time1 = sec;
            end
            1 :  begin
                time0 = min;
                time1 = hour;
            end
        endcase
    end
    
endmodule