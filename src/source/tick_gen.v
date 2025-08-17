`timescale 1ns / 1ps

module tick_gen #(
    parameter F_COUNT = 100
    ) (
    input clk,
    input rst,

    output o_tick
);

    reg [$clog2(F_COUNT- 1) - 1 : 0] count;
    reg tick;

    assign o_tick = tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count   <= 0;
            tick    <= 0; 
        end
        else begin
            if (count == F_COUNT - 1) begin
                count   <= 0;
                tick    <= 1'b1;
            end
            else begin
                count   <= count + 1;
                tick    <= 1'b0;
            end
        end
    end
endmodule