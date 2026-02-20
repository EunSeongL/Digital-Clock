`timescale 1ns / 1ps

module watch_dp(
    input clk,    
    input reset,      
    input up,           
    input down,        
    input [1:0] mode,  
    output [3:0] fnd_dot,      
    output [6:0] msec,         
    output [5:0] sec,         
    output [5:0] min,          
    output [4:0] hour         
);

    wire o_clk;     
    wire sec_tick;  

    clk_div #(
        .F_COUNT(100_0000) 
    ) U_clk_div (
        .clk  (clk),
        .reset(reset),
        .tick (o_clk)
    );

    msec U_msec (
        .clk  (clk),
        .reset(reset),
        .en   (o_clk),      
        .tick (sec_tick),
        .msec (msec)
    );

    generate_dot U_generate_dot(
        .msec   (msec),
        .fnd_dot(fnd_dot)
    );

    time_counter U_time (
        .clk      (clk),
        .reset    (reset),
        .sec_tick (sec_tick),
        .up       (up),
        .down     (down),
        .mode     (mode),
        .sec      (sec),
        .min      (min),
        .hour     (hour)
    );

endmodule

module time_counter (
    input clk,
    input reset,
    input sec_tick,
    input up,
    input down,
    input [1:0] mode,
    output reg [5:0] sec,
    output reg [5:0] min,
    output reg [4:0] hour
);

    wire inc_sec = sec_tick || (mode == 1 && up);
    wire dec_sec =             (mode == 1 && down);
    
    wire inc_min = (inc_sec && sec == 59) || (mode == 2 && up);
    wire dec_min = (dec_sec && sec == 0)  || (mode == 2 && down);
    
    wire inc_hour = (inc_min && min == 59) || (mode == 3 && up);
    wire dec_hour = (dec_min && min == 0)  || (mode == 3 && down);


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sec <= 0; 
            min <= 0; 
            hour <= 0;
        end else begin
            if (inc_sec) begin
                sec <= (sec == 59) ? 0 : sec + 1;
            end
            else if (dec_sec) begin
                sec <= (sec == 0)  ? 59 : sec - 1;
            end
            if (inc_min) begin
                min <= (min == 59) ? 0 : min + 1;
            end
            else if (dec_min) begin
                min <= (min == 0)  ? 59 : min - 1;
            end
            if (inc_hour) begin
                hour <= (hour == 23) ? 0 : hour + 1;
            end
            else if (dec_hour) begin
                hour <= (hour == 0)  ? 23 : hour - 1;
            end
        end
    end
endmodule

module msec (
    input clk,
    input reset,
    input en,           
    output reg tick,
    output reg [6:0] msec
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tick <= 0;
            msec <= 0;
        end else begin
            tick <= 0; 
            if (en) begin
                if (msec == 99) begin
                    msec <= 0;
                    tick <= 1;
                end else begin
                    msec <= msec + 1;
                end
            end
        end
    end
endmodule

module generate_dot (
    input  [6:0] msec,
    output [3:0] fnd_dot
);
    assign fnd_dot = (msec < 50) ? 4'he : 4'hf;
endmodule



