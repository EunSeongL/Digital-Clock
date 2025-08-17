`timescale 1ns / 1ps

module uart_tx (
    input clk,
    input rst,
    input baud_tick,
    input start,
    input [7:0] din,
    output o_tx_done,
    output o_tx_busy,
    output o_tx
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3, WAIT = 4;

    reg [2:0] c_state, n_state;
    reg tx_reg, tx_next;
    reg [2:0] data_cnt_reg, data_cnt_next;  // 데이터 비트 위치 (0~7)
    reg [3:0] b_cnt_reg, b_cnt_next;  // baud_tick을 8개 동안 유지하기 위한 카운터 (0~7)
    reg tx_done_reg, tx_done_next;
    reg tx_busy_reg, tx_busy_next;

    // FIFO din을 받아 줌
    reg [7:0] din_reg, din_next;

    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg;
    assign o_tx_busy = tx_busy_reg;
    // assign o_tx_done = ((c_state == STOP) & (b_cnt_reg == 7)) ? 1'b1 : 1'b0;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state      <= 0;
            tx_reg       <= 1'b1;
            data_cnt_reg <= 0;  // data bit 전송 반복구조를 위해서
            b_cnt_reg    <= 0;  // baud tick을 0부터7까지 count
            tx_done_reg  <= 0;
            tx_busy_reg  <= 0;
            din_reg      <= 0;
        end else begin
            c_state      <= n_state;
            tx_reg       <= tx_next;
            data_cnt_reg <= data_cnt_next;
            b_cnt_reg    <= b_cnt_next;
            tx_done_reg  <= tx_done_next;
            tx_busy_reg  <= tx_busy_next;
            din_reg      <= din_next;
        end
    end

    // next state CL
    always @(*) begin
        n_state       = c_state;
        tx_next       = tx_reg;
        data_cnt_next = data_cnt_reg;
        b_cnt_next    = b_cnt_reg;
        tx_done_next  = 0;
        tx_busy_next  = tx_busy_reg;
        din_next      = din_reg;
        case (c_state)
            IDLE: begin
                b_cnt_next = 0;
                data_cnt_next = 0;
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tx_busy_next = 1'b0;
                if (start == 1'b1) begin
                    din_next = din;
                    n_state = START;
                    tx_busy_next = 1'b1;
                end
            end
            START: begin
                if (baud_tick == 1'b1) begin
                    tx_next = 1'b0;
                    if (b_cnt_reg == 8) begin
                        n_state = DATA;
                        data_cnt_next = 0;
                        b_cnt_next = 0;
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = din_reg[data_cnt_reg];
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin
                        if (data_cnt_reg == 3'b111) begin
                            n_state = STOP;
                        end
                        b_cnt_next = 0;
                        data_cnt_next = data_cnt_reg + 1;
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin
                        n_state = IDLE;
                        tx_busy_next = 1'b0;
                        tx_done_next = 1'b1;
                    end
                    b_cnt_next = b_cnt_reg + 1;
                end
            end
        endcase
    end

endmodule


/*
            DATA0: begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[0];
                    n_state = DATA1;
                end
            end
            DATA1: begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[1];
                    n_state = DATA2;
                end
            end
            DATA2: begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[2];
                    n_state = DATA3;
                end
            end
            DATA3: begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[3];
                    n_state = DATA4;
                end
            end
            DATA4: begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[4];
                    n_state = DATA5;
                end
            end
            DATA5: begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[5];
                    n_state = DATA6;
                end
            end
            DATA6: begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[6];
                    n_state = DATA7;
                end
            end
            DATA7: begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[7];
                    n_state = STOP;
                end
            end
            */
