`timescale 1ns / 1ps

module command_controller (
    // UART command inputs
    input clk,
    input rst,
    input [3:0] sw,
    input [1:0] sw_sub,
    
    // btn 신호
    input L_edge,
    input R_edge,
    input U_edge,
    input D_edge,  
    
    // UART 신호
    input uart_0,
    input uart_1,
    input uart_2,
    input uart_3,
    input uart_Q,   // watch에서 set/run mode
    input uart_F,   // watch/stopwatch에서 display switching
    input uart_R,   // reset 신호
    input uart_W,   // btnU
    input uart_S,   // btnD
    input uart_A,   // btnL
    input uart_D,   // btnR

    // 출력 control 신호
    output c_btnL_w,
    output c_btnR_w,
    output c_btnU_w,
    output c_btnD_w,

    output c_btnL_sw,
    output c_btnR_sw,

    output c_btnU_sr04,
    output c_btnD_sr04,

    output c_btnU_dht11,

    output c_runset,
    output c_display,

    output [1:0] mode
);
/*         
    // 필요한 제어 신호 있으면 추가해서 쓸 것.
        Watch       : mode == 0
        Stopwatch   : mode == 1
        sr04        : mode == 2
        dht11       : mode == 3
 */
 
    // Watch control signal
    assign c_btnL_w = ((L_edge | uart_A) & (mode == 0));
    assign c_btnR_w = ((R_edge | uart_D) & (mode == 0));
    assign c_btnU_w = ((U_edge | uart_W) & (mode == 0));
    assign c_btnD_w = ((D_edge | uart_S) & (mode == 0));

    // Stopwatch control signal
    assign c_btnL_sw = ((L_edge | uart_A) & (mode == 1));
    assign c_btnR_sw = ((R_edge | uart_D) & (mode == 1));

    // sr04 control signal
    assign c_btnU_sr04 = ((U_edge | uart_W) & (mode == 2));
    assign c_btnD_sr04 = ((D_edge | uart_S) & (mode == 2));
    
    // dht11 control signal
    assign c_btnU_dht11 = ((U_edge | uart_W) & (mode == 3));

    // etc control signal
    assign c_runset = c_sw_runset;
    assign c_display = c_sw_display;

    // 스위치 컨트롤러
    sw_controller u_sw_controller (
        .clk           (clk),
        .rst           (rst | uart_R),
        .sw_sub        (sw_sub),
        .uart_Q        (uart_Q),
        .uart_F        (uart_F),

        .c_sw_runset   (c_sw_runset),
        .c_sw_display  (c_sw_display)
    );

    // 모드 컨트롤러 모듈
    mode_controller MODE_CNTL (
        .clk    (clk),
        .rst    (rst | uart_R),
        .sw     (sw),
        .uart_0 (uart_0),
        .uart_1 (uart_1),
        .uart_2 (uart_2),
        .uart_3 (uart_3),

        .mode   (mode)
    );

endmodule

module mode_controller (
    input clk,
    input rst,
    input [3:0] sw,
    input uart_0,
    input uart_1,
    input uart_2,
    input uart_3,

    output reg [1:0] mode
);

    wire pos_sw0;
    wire pos_sw1;
    wire pos_sw2;
    wire pos_sw3;

    sw_edge_detector U_SW0_EDGE (
        .clk(clk),
        .rst(rst),
        .signal_in(sw[0]),
        .posedge_detected(pos_sw0)
    );

    sw_edge_detector U_SW1_EDGE (
        .clk(clk),
        .rst(rst),
        .signal_in(sw[1]),
        .posedge_detected(pos_sw1)
    );

    sw_edge_detector U_SW2_EDGE (
        .clk(clk),
        .rst(rst),
        .signal_in(sw[2]),
        .posedge_detected(pos_sw2)
    );

    sw_edge_detector U_SW3_EDGE (
        .clk(clk),
        .rst(rst),
        .signal_in(sw[3]),
        .posedge_detected(pos_sw3)
    );

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            mode <= 0;
        end else begin
            // sw0 처리
            if (uart_0 | pos_sw0)       mode <= 0;
            else if (uart_1 | pos_sw1)  mode <= 1;
            else if (uart_2 | pos_sw2)  mode <= 2;
            else if (uart_3 | pos_sw3)  mode <= 3;
        end
    end

endmodule


module sw_controller (
    input clk,
    input rst,
    
    input [1:0] sw_sub,

    input uart_Q,
    input uart_F,

    output reg c_sw_runset,
    output reg c_sw_display
);

    wire pos_sw_runset, neg_sw_runset;
    wire pos_sw_display, neg_sw_display;

    sw_edge_detector U_SW0_EDGE (
        .clk(clk),
        .rst(rst),
        .signal_in(sw_sub[0]),
        .posedge_detected(pos_sw_runset),
        .negedge_detected(neg_sw_runset)
    );

    sw_edge_detector U_SW1_EDGE (
        .clk(clk),
        .rst(rst),
        .signal_in(sw_sub[1]),
        .posedge_detected(pos_sw_display),
        .negedge_detected(neg_sw_display)
    );

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_sw_runset    <= 0;
            c_sw_display   <= 0;
        end else begin
            // sw14 처리
            if (uart_Q)
                c_sw_runset <= ~c_sw_runset;
            else if (pos_sw_runset)
                c_sw_runset <= 1;
            else if (neg_sw_runset)
                c_sw_runset <= 0;

            // sw15 처리
            if (uart_F)
                c_sw_display <= ~c_sw_display;
            else if (pos_sw_display)
                c_sw_display <= 1;
            else if (neg_sw_display)
                c_sw_display <= 0;
        end
    end
endmodule

module sw_edge_detector (
    input clk,
    input rst,
    input signal_in,               // 감지 대상 신호

    output reg posedge_detected,  // 상승 에지
    output reg negedge_detected   // 하강 에지
);

    reg signal_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            signal_prev <= 0;
            posedge_detected <= 0;
            negedge_detected <= 0;
        end else begin
            // 에지 감지
            posedge_detected <= ~signal_prev & signal_in;
            negedge_detected <= signal_prev & ~signal_in;
            signal_prev <= signal_in;
        end
    end

endmodule