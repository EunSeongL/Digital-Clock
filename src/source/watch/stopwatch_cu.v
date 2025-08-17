`timescale 1ns / 1ps

module stopwatch_cu(
    input clk,
    input rst,
    input i_clear,
    input i_runstop,

    output o_clear,
    output o_runstop
    );

    // State Definition.
    localparam [1:0] STOP   = 2'b00;
    localparam [1:0] RUN    = 2'b01;
    localparam [1:0] CLEAR  = 2'b10;


    reg [1:0] c_state, n_state;

    // State Register.
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            c_state <= STOP;
        end
        else begin
            c_state <= n_state;
        end
    end

    // Next state combinational logic.
    always @(*) begin
        n_state = c_state;      // 초기화를 통해 Latch 생성을 막음.
        case(c_state)
            STOP: begin
                // 입력 조건에 따라 next state를 처리
                if (i_clear == 1'b1) n_state = CLEAR;
                else if (i_runstop == 1'b1) n_state = RUN;
            end
            RUN: begin
                if (i_runstop == 1'b1) n_state = STOP;
            end
            CLEAR: begin
                if (i_clear == 1'b1) n_state = STOP;
            end
        endcase
    end
/* 
    // Output Combinational Logic
    always @(*) begin       // always @(c_state) begin 도 가능
        o_clear = 0;
        o_runstop = 0;
        case (c_state) 
            STOP: begin
                o_clear = 0;
                o_runstop = 0;
            end
            RUN: begin
                o_clear = 0;
                o_runstop = 1;
            end
            CLEAR: begin
                o_clear = 1;
                o_runstop = 0;
            end
        endcase
    end */

    assign o_clear = (c_state == CLEAR) ? 1 : 0;
    assign o_runstop = (c_state == RUN) ? 1 : 0;

endmodule

