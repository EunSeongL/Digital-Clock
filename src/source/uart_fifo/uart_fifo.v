`timescale 1ns / 1ps

module uart_fifo_controller (
    input        clk,
    input        rst,
    input        btn_start,
    input        rx,
    input [7:0]  i_push_data,
    input        i_push,

    output       rx_done,
    output [7:0] rx_data,
    output       tx_done,
    output       tx
);


    wire w_bd_tick, w_start;
    wire w_tx_busy, w_tx_done;
    wire [7:0] w_dout;
    wire w_rx_done;

    wire [7:0] rx_fifo_data, tx_fifo_data;

    assign rx_done = w_rx_done;
    assign rx_data = rx_fifo_data;

    wire tx_push;
    wire [7:0] tx_push_data;

    assign tx_push = (i_push)? i_push : ~rx_fifo_empty;
    assign tx_push_data = (i_push)? i_push_data : rx_fifo_data;

    // RX FIFO
    fifo U_RX_FIFO (
        .clk        (clk),
        .rst        (rst),
        .push       (w_rx_done),        // 수신 완료 시 push
        .pop        (~tx_fifo_full),      // TX_FIFO에 push할 때 pop
        .push_data  (w_dout),

        .full       (rx_fifo_full),
        .empty      (rx_fifo_empty),
        .pop_data   (rx_fifo_data)
    );

    // TX FIFO
    fifo U_TX_FIFO (
        .clk        (clk),
        .rst        (rst),
        .push       (tx_push),     // RX_FIFO에서 받아올 때 push
        .pop        (~w_tx_busy),      // UART로 보낼 때 pop
        .push_data  (tx_push_data),

        .full       (tx_fifo_full),
        .empty      (tx_fifo_empty),
        .pop_data   (tx_fifo_data)
    );

    btn_debounce U_BTN_DB_START (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_start),
        .o_btn(w_start)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick),
        .start({w_start|~tx_fifo_empty}),
        .din(tx_fifo_data),

        .o_tx_done(w_tx_done),
        .o_tx_busy(w_tx_busy),
        .o_tx(tx)
    );

    uart_rx U_UARD_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_bd_tick),
        .rx(rx),

        .o_dout(w_dout),
        .o_rx_done(w_rx_done)
    );

    baudrate U_BR (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick)
    );


endmodule
