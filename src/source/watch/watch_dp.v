`timescale 1ns / 1ps

module watch_dp(
    input clk,
    input rst,
    input i_up,
    input i_down,
    input i_set_sec,
    input i_set_min,
    input i_set_hour,

    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
    );

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick, w_day_tick;
    wire up_s, up_m, up_h, down_s, down_m, down_h;

    assign up_s     = i_set_sec & i_up;
    assign down_s   = i_set_sec & i_down;
    assign up_m     = i_set_min & i_up;
    assign down_m   = i_set_min & i_down;
    assign up_h     = i_set_hour & i_up;
    assign down_h   = i_set_hour & i_down;

    time_counter_W #(
        .BIT_WIDTH(7),
        .TICK_COUNT(100)
    ) U_MSEC_W (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .i_up(0),
        .i_down(0),
        .i_hour(0),

        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    time_counter_W #(
        .BIT_WIDTH(6),
        .TICK_COUNT(60)
    ) U_SEC_W (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick),
        .i_up(up_s),
        .i_down(down_s),
        .i_hour(0),

        .o_time(sec),
        .o_tick(w_min_tick)
    );

    time_counter_W #(
        .BIT_WIDTH(6),
        .TICK_COUNT(60)
    ) U_MIN_W (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick),
        .i_up(up_m),
        .i_down(down_m),
        .i_hour(0),

        .o_time(min),
        .o_tick(w_hour_tick)
    );

    time_counter_W #(
        .BIT_WIDTH(5),
        .TICK_COUNT(24),
        .INITIAL_VALUE(12)
    ) U_HOUR_W (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick),
        .i_up(up_h),
        .i_down(down_h),
        .i_hour(1),

        .o_time(hour),
        .o_tick(w_day_tick)
    );

    tick_gen_100Hz_W #(
        //.FCOUNT(10)
        .FCOUNT(1_000_000)
    ) U_Tick_100hz_W (
        .clk(clk),
        .rst(rst),

        .o_tick_100(w_tick_100hz)
    );

endmodule

module time_counter_W #(
    parameter BIT_WIDTH = 7,
    parameter TICK_COUNT = 100,
    parameter INITIAL_VALUE = 0
) (
    input clk,
    input rst,
    input i_tick,
    input i_up,
    input i_down,
    input i_hour,

    output [BIT_WIDTH-1 : 0]    o_time,
    output                      o_tick
);
    reg [$clog2(TICK_COUNT - 1) - 1:0] count_reg, count_next;
    reg o_tick_reg, o_tick_next;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    // state register => only update
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            count_reg <= INITIAL_VALUE;
            o_tick_reg <= 0;
        end
        else begin
            count_reg <= count_next;
            o_tick_reg <= o_tick_next;
        end
    end

    // CL next state => calculate logic
    always @(*) begin
        count_next = count_reg;
        o_tick_next = 1'b0;
        if (i_tick == 1'b1) begin
            if (count_reg == (TICK_COUNT - 1)) begin
                count_next = 0;
                o_tick_next = 1'b1;
            end
            else begin
                count_next = count_reg + 1;
                o_tick_next = 0;
            end
        end
        
        else if (i_up) begin
            if (i_hour) count_next = (count_next == 23)? 0 : count_next + 1;
            else        count_next = (count_next == 59)? 0 : count_next + 1;
        end
        else if (i_down) begin
            if (i_hour) count_next = (count_next == 0)? 23 : count_next - 1;
            else        count_next = (count_next == 0)? 59 : count_next - 1;
        end

/*         
        else if (i_up) count_next = (count_next == 59)? 0 : count_next + 1;
        else if (i_down) count_next = (count_next == 0)? 59 : count_next - 1;
 */
/* 
        else if (i_up) count_next = count_next + 1;
        else if (i_down) count_next = count_next - 1;
  */       
    end
endmodule

module tick_gen_100Hz_W #(
    parameter FCOUNT = 1_000_000
)(
    input clk,
    input rst,

    output reg o_tick_100
);
    reg [$clog2(FCOUNT)-1 : 0] r_counter;

    // state register
    always @(posedge clk) begin
        if(rst) begin
            r_counter <= 0;
            o_tick_100 <= 0;
        end
        else begin
            if (r_counter == FCOUNT - 1) begin
                o_tick_100 <= 1'b1; // 카운트 값이 일치했을 때 상승
                r_counter <= 0;
            end
            else begin
                o_tick_100 <= 1'b0;
                r_counter <= r_counter + 1;
            end
        end
    end
endmodule


