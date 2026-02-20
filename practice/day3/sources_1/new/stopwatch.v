`timescale 1ns / 1ps

module stopwatch(
    input clk,
    input reset,
    input runstop,
    input clear,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_runstop, w_clear;

    stopwatch_dp U_stopwatch_dp(
        .clk            (clk),
        .reset          (reset),
        .runstop        (w_runstop),
        .clear          (w_clear),
        .msec           (msec),
        .sec            (sec),
        .min            (min),
        .hour           (hour)
    );

    stopwatch_cu U_stopwatch_cu(
        .clk            (clk),
        .reset          (reset),
        .btn_clear      (clear),
        .btn_runstop    (runstop),
        .clear          (w_clear),
        .runstop        (w_runstop)
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

