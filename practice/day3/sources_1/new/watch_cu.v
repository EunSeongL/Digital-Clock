`timescale 1ns / 1ps

module watch_cu(
    input clk,
    input reset,
    input btn_shift,
    input sw,
    output [1:0] mode      
);

    localparam SEC_MS   = 2'd0; 
    localparam MIN_SEC  = 2'd1; 
    localparam HOUR_MIN = 2'd2; 
    localparam MS_HOUR  = 2'd3; 

    reg sw_d;
    wire sw_changed = sw ^ sw_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sw_d <= 1'b0;
        end
        else begin
            sw_d <= sw;
        end
    end

    reg [1:0] state, n_state;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= SEC_MS;
        end
        else begin
            state <= n_state;
        end
    end

    always @(*) begin
        n_state = state;
        if (sw_changed) begin
            n_state = (sw == 1'b0) ? SEC_MS : HOUR_MIN; 
        end
        else if (btn_shift) begin
            if (sw == 1'b0) begin
                case (state)
                    SEC_MS   : n_state = MIN_SEC;
                    MIN_SEC  : n_state = HOUR_MIN;
                    HOUR_MIN : n_state = MS_HOUR;
                    MS_HOUR  : n_state = SEC_MS;
                    default  : n_state = SEC_MS;
                endcase
            end
            else begin
                case (state)
                    HOUR_MIN : n_state = MS_HOUR;
                    MS_HOUR  : n_state = SEC_MS;
                    SEC_MS   : n_state = MIN_SEC;
                    MIN_SEC  : n_state = HOUR_MIN;
                    default  : n_state = HOUR_MIN;
                endcase
            end
        end
    end

    assign mode = state;

endmodule
