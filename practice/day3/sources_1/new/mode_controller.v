`timescale 1ns / 1ps

module mode_controller(
    input clk,
    input reset,
    input sw,
    input btn1,
    input btn2,
    input btn3,
    output w_up,
    output w_down,
    output w_shift,
    output sw_runstop,
    output sw_clear
    );

    btn_debounce U_btn1(
        .clk            (clk),
        .reset          (reset),
        .in_button      (btn1),
        .rising_edge    (o_btn1),
        .falling_edge   (),
        .both_edge      ()
    );

    btn_debounce U_btn2(
        .clk            (clk),
        .reset          (reset),
        .in_button      (btn2),
        .rising_edge    (o_btn2),
        .falling_edge   (),
        .both_edge      ()
    );

    btn_debounce U_btn3(
        .clk            (clk),
        .reset          (reset),
        .in_button      (btn3),
        .rising_edge    (o_btn3),
        .falling_edge   (),
        .both_edge      ()
    );

    mode_btn U_mode_btn(
        .btn1           (o_btn1),
        .btn2           (o_btn2),
        .btn3           (o_btn3),
        .sw             (sw),   
        .w_up           (w_up),
        .w_down         (w_down),
        .w_shift        (w_shift),
        .sw_runstop     (sw_runstop),
        .sw_clear       (sw_clear)
    );

endmodule

module mode_btn (
    input btn1,
    input btn2,
    input btn3,
    input sw,
    output reg w_up,
    output reg w_down,
    output reg w_shift,
    output reg sw_runstop,
    output reg sw_clear
);

    always @(*) begin
        w_up       = 0;
        w_down     = 0;
        w_shift    = 0;
        sw_runstop = 0;
        sw_clear   = 0;
        case (sw)
            0: begin
                sw_runstop = btn3;
                sw_clear = btn2;
            end 
            1: begin
                w_up = btn3;
                w_down = btn2;
                w_shift = btn1;
            end
        endcase
    end
    
endmodule
