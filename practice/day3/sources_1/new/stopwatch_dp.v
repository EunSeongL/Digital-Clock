`timescale 1ns / 1ps

module stopwatch_dp (
    input clk,         
    input reset,      
    input runstop,   
    input clear,     
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire o_clk;

    clk_div #(
        .F_COUNT(100_0000)
    ) U_clk_div (
        .clk  (clk),
        .reset(reset),
        .tick (o_clk) 
    );

    stopwatch_counter U_counter (
        .clk     (clk),
        .reset   (reset | clear),
        .tick_10ms(o_clk),
        .runstop (runstop),
        .msec    (msec),
        .sec     (sec),
        .min     (min),
        .hour    (hour)
    );


endmodule

module stopwatch_counter (
    input clk,
    input reset,
    input tick_10ms, 
    input runstop,   
    output reg [6:0] msec,
    output reg [5:0] sec,
    output reg [5:0] min,
    output reg [4:0] hour
);

    wire inc_msec = tick_10ms && runstop;
    wire inc_sec  = inc_msec && (msec == 99);
    wire inc_min  = inc_sec  && (sec == 59);
    wire inc_hour = inc_min  && (min == 59);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            msec <= 0;
            sec  <= 0;
            min  <= 0;
            hour <= 0;
        end else begin
            if (inc_msec) msec <= (msec == 99) ? 0 : msec + 1;
            
            if (inc_sec)  sec  <= (sec == 59)  ? 0 : sec + 1;
            
            if (inc_min)  min  <= (min == 59)  ? 0 : min + 1;
            
            if (inc_hour) hour <= (hour == 23) ? 0 : hour + 1;
        end
    end

endmodule
