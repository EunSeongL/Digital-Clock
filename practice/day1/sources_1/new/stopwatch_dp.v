`timescale 1ns / 1ps

module stopwatch_dp(
    input clk,
    input reset,
    input runstop,
    input clear,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire o_clk, sec_tick, min_tick, hour_tick;

    clk_div #(
        .F_COUNT(100_0)
    ) U_clk_div (
        .clk    (clk | !runstop),
        .reset  (reset | clear),
        .tick   (o_clk)
    );

    msec U_msec(
        .clk    (o_clk),
        .reset  (reset | clear),
        .tick   (sec_tick),
        .msec   (msec)
    );

    sec U_sec(
        .clk    (sec_tick),
        .reset  (reset | clear),
        .tick   (min_tick),
        .sec    (sec)
    );

    min U_min(
        .clk    (min_tick),
        .reset  (reset | clear),
        .tick   (hour_tick),
        .min    (min)
    );

    hour U_hour(
        .clk    (hour_tick),
        .reset  (reset | clear),
        .hour    (hour)
    );

endmodule

module msec (
    input clk,
    input reset,
    output reg tick,
    output reg [6:0] msec
);

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            tick <= 0;
            msec <= 0;
        end
        else begin
            if(msec == 100 - 1) begin
                msec <= 0;
                tick <= 1;
            end
            else begin
                msec <= msec + 1;
                tick <= 0;
            end
        end
    end
    
endmodule

module sec (
    input clk,
    input reset,
    output reg tick,
    output reg [5:0] sec
);

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            sec <= 0;
        end
        else begin
            if(sec == 60 - 1) begin
                sec <= 0;
                tick <= 1;
            end
            else begin
                sec <= sec + 1;
                tick <= 0;
            end
        end
    end
    
endmodule

module min (
    input clk,
    input reset,
    output reg tick,
    output reg [5:0] min
);

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            min <= 0;
        end
        else begin
            if(min == 60 - 1) begin
                min <= 0;
                tick <= 1;
            end
            else begin
                min <= min + 1;
                tick <= 0;
            end
        end
    end
    
endmodule

module hour (
    input clk,
    input reset,
    output reg [4:0] hour
);

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            hour <= 0;
        end
        else begin
            if(hour == 24 - 1) begin
                hour <= 0;
            end
            else begin
                hour <= hour + 1;
            end
        end
    end
    
endmodule