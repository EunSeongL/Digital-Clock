`timescale 1ns / 1ps

module Top(
    input clk,
    input rst,
    input [3:0] sw,
    input [1:0] sw_sub,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    input echo,
    input rx,

    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output trig,
    output tx,
    output [3:0] led,
    output [1:0] sw_sub_led,
    output [2:0] watch_state_led,

    inout dht11_io
    );

    wire [3:0] fnd_signal;
    wire [13:0] watch_data, stopwatch_data, sr04_data, dht11_data;
    wire [1:0] mode;
    reg [13:0] fnd_in_data;
    wire [6:0] msec;
    wire [7:0] ascii_sr04, ascii_dht11;
    reg [7:0] push_data;
    wire go_ascii_sr04, go_ascii_dht11, push;
    wire [7:0] rx_data_fifo;
    wire [2:0] watch_state;

    assign push = go_ascii_sr04 | go_ascii_dht11;
    always @(*) begin
        if(go_ascii_sr04) push_data = ascii_sr04;
        else if(go_ascii_dht11) push_data = ascii_dht11;
        else push_data = 0;
    end

    // FND 입력 데이터 MUX
    always @(*) begin
        case(mode)
            2'b00: fnd_in_data = watch_data;
            2'b01: fnd_in_data = stopwatch_data;
            2'b10: fnd_in_data = sr04_data;
            2'b11: fnd_in_data = dht11_data;
        endcase
    end

    // UART FIFO 컨트롤러 인스턴스화
    uart_fifo_controller u_uart_fifo_controller (
        .clk        (clk),
        .rst        (rst | uart_R),
        .btn_start  ( ),           // 예: btnU를 시작 신호로
        .rx         (rx),
        .i_push_data  (push_data),
        .i_push       (push),

        .rx_done    (rx_done_fifo),
        .rx_data    (rx_data_fifo),
        .tx_done    (tx_done_fifo),
        .tx         (tx)
    );

    // command_controller 인스턴스화
    command_controller u_command_controller (
        .clk            (clk),
        .rst            (rst),
        .sw             (sw),
        .sw_sub         (sw_sub),

        .L_edge         (L_edge),
        .R_edge         (R_edge),
        .U_edge         (U_edge),
        .D_edge         (D_edge),

        .uart_0         (uart_0),
        .uart_1         (uart_1),
        .uart_2         (uart_2),
        .uart_3         (uart_3),
        .uart_Q         (uart_Q),
        .uart_F         (uart_F),
        .uart_R         (uart_R),
        .uart_W         (uart_W),
        .uart_S         (uart_S),
        .uart_A         (uart_A),
        .uart_D         (uart_D),

        .c_btnL_w       (c_btnL_w),
        .c_btnR_w       (c_btnR_w),
        .c_btnU_w       (c_btnU_w),
        .c_btnD_w       (c_btnD_w),
        .c_btnL_sw      (c_btnL_sw),
        .c_btnR_sw      (c_btnR_sw),
        .c_btnU_sr04    (c_btnU_sr04),
        .c_btnD_sr04    (c_btnD_sr04),
        .c_btnU_dht11   (c_btnU_dht11),
        .c_runset       (c_runset),
        .c_display      (c_display),
        .mode           (mode)
    );

    // 버튼 엣지 검출 모듈
    btn_command u_btn_command (
        .clk       (clk),
        .rst       (rst | uart_R),
        .btnL      (btnL),
        .btnR      (btnR),
        .btnU      (btnU),
        .btnD      (btnD),

        .L_edge    (L_edge),
        .R_edge    (R_edge),
        .U_edge    (U_edge),
        .D_edge    (D_edge)
    );

    // UART 명령 처리 모듈
    uart_command u_uart_command (
        .clk       (clk),
        .rst       (rst | uart_R),
        .rx_done   (rx_done_fifo),
        .rx_data   (rx_data_fifo),

        .uart_0    (uart_0),
        .uart_1    (uart_1),
        .uart_2    (uart_2),
        .uart_3    (uart_3),
        .uart_Q    (uart_Q),
        .uart_F    (uart_F),
        .uart_R    (uart_R),
        .uart_W    (uart_W),
        .uart_S    (uart_S),
        .uart_A    (uart_A),
        .uart_D    (uart_D)
    );

    // Top_sr04 인스턴스화
    Top_sr04 u_top_sr04 (
        .clk        (clk),
        .rst        (rst | uart_R),
        .btnU       (c_btnU_sr04),
        .btnD       (c_btnD_sr04),
        .echo       (echo),

        .trig       (trig),
        .sr04_data  (sr04_data),
        .go_ascii   (go_ascii_sr04),
        .ascii      (ascii_sr04)
    );

    // Top_DHT11 인스턴스화
    Top_DHT11 u_top_dht11 (
        .clk         (clk),
        .rst         (rst | uart_R),
        .btnU        (c_btnU_dht11),    // start 버튼

        .dht11_data  (dht11_data),
        .go_ascii    (go_ascii_dht11),
        .ascii       (ascii_dht11),

        .dht11_io    (dht11_io)
    );

    // stopwatch 모듈 인스턴스화
    stopwatch u_stopwatch (
        .clk                (clk),
        .rst                (rst | uart_R),
        .i_btnL             (c_btnL_sw),
        .i_btnR             (c_btnR_sw),
        .i_display_switch   (~c_display),

        .stopwatch_data     (stopwatch_data)
    );

    // watch 모듈 인스턴스화
    watch u_watch (
        .clk                  (clk),
        .rst                  (rst | uart_R),
        .i_btnL               (c_btnL_w),
        .i_btnR               (c_btnR_w),
        .i_btnU               (c_btnU_w),
        .i_btnD               (c_btnD_w),
        .i_set_mode_command   (c_runset),
        .i_display_switch     (~c_display),

        .watch_data           (watch_data),
        .msec                 (msec),
        .watch_state          (watch_state)
    );

    // FND 표시 컨트롤러
    fnd_Controller u_fnd_controller (
        .clk        (clk),
        .reset      (rst | uart_R),
        .count_data (fnd_in_data),
        .msec       (msec),

        .fnd_data   (fnd_data),
        .fnd_com    (fnd_com),
        .dot_clk    (dot_clk)
    );

     // LED 표시 컨트롤러
    led_controller u_led_controller (
        .dot_clk        (dot_clk),
        .mode           (mode),
        .watch_state    (watch_state),
        .c_display      (c_display),
        .c_runset       (c_runset),
        .led            (led),
        .sw_sub_led     (sw_sub_led),
        .watch_state_led(watch_state_led)
    );


endmodule

module led_controller (
    input dot_clk,
    input [1:0] mode,
    input [2:0] watch_state,
    input c_display,
    input c_runset,
    output [3:0] led,
    output [3:0] sw_sub_led,
    output [3:0] watch_state_led
    );

    assign led = 4'b0001 << mode;
    assign sw_sub_led = {c_display, c_runset};
    assign watch_state_led = (mode == 0 && dot_clk) ? watch_state : 3'b000;

    endmodule
