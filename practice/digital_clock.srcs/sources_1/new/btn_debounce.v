`timescale 1ns / 1ps

module btn_debounce(
    input clk,
    input reset,
    input in_button,
    output rising_edge,
    output falling_edge,
    output both_edge
    );

    wire tick_1ms;
    wire [7:0] sh_reg;
    wire debounce;

    clk_div #(
        .F_COUNT(100_000) 
    ) U_clk_div (
        .clk    (clk),
        .reset  (reset),
        .tick   (tick_1ms)
    );

    shift_register U_shift_register (
        .clk        (clk),
        .reset      (reset),
        .tick_1ms   (tick_1ms),
        .in_data    (in_button),
        .out_data   (sh_reg)
    );

    assign debounce = &sh_reg;

    edge_detect U_edge_detect (
        .clk            (clk),
        .reset          (reset),
        .debounce       (debounce),
        .rising_edge    (rising_edge),
        .falling_edge   (falling_edge),
        .both_edge      (both_edge)
    );

endmodule

module shift_register (
    input clk,
    input reset,
    input tick_1ms,
    input in_data,
    output [7:0] out_data
    );
    reg [7:0] shift_reg;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            shift_reg <= 0;
        end
        else begin
            if(tick_1ms) begin
                shift_reg <= {in_data, shift_reg[7:1]};
            end
        end
    end

    assign out_data = shift_reg;

endmodule

module edge_detect (
    input clk,
    input reset,
    input debounce,
    output rising_edge,
    output falling_edge,
    output both_edge
);

    reg btn_prev;

    always @(posedge clk or posedge reset) begin
        if(reset)begin
            btn_prev <= 0;
        end
        else begin
            btn_prev <= debounce;
        end
    end

    assign rising_edge = debounce & (~btn_prev);
    assign falling_edge = ~debounce & btn_prev;
    assign both_edge = rising_edge | falling_edge;
    
endmodule

