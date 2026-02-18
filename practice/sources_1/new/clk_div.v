`timescale 1ns / 1ps

module clk_div #(
    F_COUNT = 100_000
) (
    input clk,
    input reset,
    output reg tick
);

    reg [$clog2(F_COUNT)-1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tick <= 0;
            counter <= 0;
        end else begin
            if (counter == F_COUNT - 1) begin
                tick <= 1;
                counter <= 0;
            end else begin
                tick <= 0;
                counter <= counter + 1;
            end
        end
    end
endmodule
