`timescale 1ns / 1ps

module btn_command(
    input  clk,
    input  rst,
    input  btnL,
    input  btnR,
    input  btnU,
    input  btnD,
    
    output L_edge,
    output R_edge,
    output U_edge,
    output D_edge
);

    btn_debounce BTNL_DB_LEFT(
    .clk(clk),
    .rst(rst),
    .i_btn(btnL),
          
    .o_btn(L_edge)
    );

    btn_debounce BTNR_DB_RIGHT(
    .clk(clk),
    .rst(rst),
    .i_btn(btnR),

    .o_btn(R_edge)
    );

    btn_debounce BTNR_DB_UP(
    .clk(clk),
    .rst(rst),
    .i_btn(btnU),

    .o_btn(U_edge)
    );

    btn_debounce BTNR_DB_DOWN(
    .clk(clk),
    .rst(rst),
    .i_btn(btnD),

    .o_btn(D_edge)
    );

endmodule
