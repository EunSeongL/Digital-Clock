`timescale 1ns / 1ps

module stopwatch_cu(
    input clk,
    input reset,
    input btn_clear,
    input btn_runstop,
    output clear,
    output runstop
    );

    parameter STOP = 2'b00;
    parameter RUN = 2'b01;
    parameter CLEAR = 2'b10;

    reg [1:0] state, n_state;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= STOP;
        end
        else begin
            state <= n_state;
        end
    end 

    always @(*) begin
        n_state = state;
        case (state)
            STOP : begin
                if(btn_runstop) begin
                    n_state = RUN;
                end
                if(btn_clear) begin
                    n_state = CLEAR;
                end
            end
            RUN : begin
                if(btn_runstop) begin
                    n_state = STOP;
                end
            end
            CLEAR : begin
                if(btn_clear) begin
                    n_state = STOP;
                end
            end  
        endcase
    end

    assign clear = (state == CLEAR) ? 1 : 0;
    assign runstop = (state == RUN) ? 1 : 0;

endmodule
