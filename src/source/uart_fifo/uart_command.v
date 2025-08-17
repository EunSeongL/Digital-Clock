`timescale 1ns / 1ps

module uart_command(
    input clk,
    input rst,
    input rx_done,
    input [7:0] rx_data,

    output uart_0,
    output uart_1,
    output uart_2,
    output uart_3,
    output uart_Q,
    output uart_F,
    output uart_R,
    output uart_W,
    output uart_S,
    output uart_A, 
    output uart_D
    );

    localparam IDLE = 0, DATA_IN = 1, COMMAND_OUT = 2;

    reg [1:0] c_state, n_state;
    reg [7:0] data_reg, data_next;
    reg sw0_reg, sw0_next, sw1_reg, sw1_next, sw2_reg, sw2_next, sw3_reg, sw3_next;
    reg Q_reg, Q_next, F_reg, F_next, R_reg, R_next, W_reg, W_next;
    reg S_reg, S_next, A_reg, A_next, D_reg, D_next;

    assign uart_0 = sw0_reg;
    assign uart_1 = sw1_reg;
    assign uart_2 = sw2_reg;
    assign uart_3 = sw3_reg;
    assign uart_Q = Q_reg;
    assign uart_F = F_reg;
    assign uart_R = R_reg;
    assign uart_W = W_reg;
    assign uart_S = S_reg;
    assign uart_A = A_reg; 
    assign uart_D = D_reg;

    // state
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state     <= 0;
            data_reg    <= 0;
            sw0_reg     <= 0;
            sw1_reg     <= 0;
            sw2_reg     <= 0;
            sw3_reg     <= 0;
            Q_reg       <= 0;
            F_reg       <= 0;
            R_reg       <= 0;
            W_reg       <= 0;
            S_reg       <= 0;
            A_reg       <= 0; 
            D_reg       <= 0;
        end
        else begin
            c_state     <= n_state;
            data_reg    <= data_next;
            sw0_reg     <= sw0_next;
            sw1_reg     <= sw1_next;
            sw2_reg     <= sw2_next;
            sw3_reg     <= sw3_next;
            Q_reg       <= Q_next;
            F_reg       <= F_next;
            R_reg       <= R_next;
            W_reg       <= W_next;
            S_reg       <= S_next;
            A_reg       <= A_next; 
            D_reg       <= D_next;
        end
    end

    // next 
    always @(*) begin
        n_state = c_state;
        data_next   = data_reg;
        sw0_next    = sw0_reg;
        sw1_next    = sw1_reg;
        sw2_next    = sw2_reg;
        sw3_next    = sw3_reg;
        Q_next      = Q_reg;
        F_next      = F_reg;
        R_next      = R_reg;
        W_next      = W_reg;
        S_next      = S_reg;
        A_next      = A_reg; 
        D_next      = D_reg;
        case(c_state)
            IDLE: begin
                    sw0_next    = 1'b0;
                    sw1_next    = 1'b0;
                    sw2_next    = 1'b0;
                    sw3_next    = 1'b0;
                    Q_next      = 1'b0;
                    F_next      = 1'b0;
                    R_next      = 1'b0;
                    W_next      = 1'b0;
                    S_next      = 1'b0;
                    A_next      = 1'b0; 
                    D_next      = 1'b0;
                if(rx_done) n_state = DATA_IN;
            end
            DATA_IN: begin
                data_next   = rx_data;
                n_state     = COMMAND_OUT;
            end
            COMMAND_OUT: begin
                case(data_reg)
                    "0": sw0_next = 1'b1;
                    "1": sw1_next = 1'b1;
                    "2": sw2_next = 1'b1;
                    "3": sw3_next = 1'b1;
                    "Q": Q_next = 1'b1;
                    "F": F_next = 1'b1;
                    "R": R_next = 1'b1;
                    "W": W_next = 1'b1;
                    "S": S_next = 1'b1;
                    "A": A_next = 1'b1; 
                    "D": D_next = 1'b1;
                endcase
                n_state = IDLE;
            end
        endcase
    end
endmodule
