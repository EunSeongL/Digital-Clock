`timescale 1ns / 1ps

module watch_cu (
    input clk,
    input rst,
    input i_left,
    input i_right,
    input sw15,

    output o_set_idel,
    output o_set_sec,
    output o_set_min,
    output o_set_hour,
    output [2:0] watch_state
);

    // State Definition.
    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] SET_SEC = 2'b01;
    localparam [1:0] SET_MIN = 2'b10;
    localparam [1:0] SET_HOUR = 2'b11;


    reg [1:0] c_state, n_state;

    // State Register.
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    // Next state combinational logic.
    always @(*) begin
        n_state = c_state;  // 초기화를 통해 Latch 생성을 막음.
        case (c_state)
            IDLE: begin
                // 입력 조건에 따라 next state를 처리
                if (sw15 == 1) n_state = SET_SEC;
            end
            SET_SEC: begin
                if (sw15 == 0) n_state = IDLE;
                else if (i_left == 1'b1) n_state = SET_MIN;
                else if (i_right == 1'b1) n_state = SET_HOUR;
            end
            SET_MIN: begin
                if (sw15 == 0) n_state = IDLE;
                else if (i_left == 1'b1) n_state = SET_HOUR;
                else if (i_right == 1'b1) n_state = SET_SEC;
            end
            SET_HOUR: begin
                if (sw15 == 0) n_state = IDLE;
                else if (i_left == 1'b1) n_state = SET_SEC;
                else if (i_right == 1'b1) n_state = SET_MIN;
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

    assign o_set_idel = (c_state == IDLE) ? 1 : 0;
    assign o_set_sec  = (c_state == SET_SEC) ? 1 : 0;
    assign o_set_min  = (c_state == SET_MIN) ? 1 : 0;
    assign o_set_hour = (c_state == SET_HOUR) ? 1 : 0;
    assign watch_state = {o_set_hour, o_set_min, o_set_sec};

endmodule

