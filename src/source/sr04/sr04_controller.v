`timescale 1ns / 1ps

module sr04_controller(
    input clk,
    input rst,
    input btnU,
    input btnD,
    input echo,
    
    output trig,
    output [9:0] dist,
    output dist_done,
    output [7:0] ascii,
    output go_ascii
    );

    wire w_tick, w_sec_tick;
    wire auto_start;
    wire start;

    assign start = (auto_start) ? w_sec_tick : btnU;

    sr04_mode u_sr04_mode(
        .clk(clk),
        .rst(rst),
        .btnU(btnU),
        .btnD(btnD),
        .auto_start(auto_start)
    );

    hex2ascii U_HEX2ASCII (
        .clk(clk),
        .rst(rst),
        .dist(dist),
        .dist_done(dist_done),

        .ascii(ascii),
        .go_ascii(go_ascii)
    );

    distance DIST (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick),
        .echo(echo),

        .dist(dist),
        .dist_done(dist_done)
    );

    start_trigger U_START_TRIG (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick),
        .start(start),

        .o_sr04_tigger(trig)
    );

    tick_gen U_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick)
    );

    tick_gen #(
        .F_COUNT(1_0000)
    )U_TICK_GEN_1S(
        .clk(w_tick),
        .rst(rst),

        .o_tick(w_sec_tick)
    );

endmodule
module hex2ascii (
    input  wire       clk,
    input  wire       rst,
    input  wire [9:0] dist,       // 거리 데이터 (0…1023)
    input  wire       dist_done,  // 측정 완료 펄스

    output reg  [7:0] ascii,      // 출력 ASCII 코드
    output wire       go_ascii    // 출력 유효 펄스
);

    // 상태 인코딩
    localparam 
        S_IDLE      = 4'd0,
        S_SPACE     = 4'd1,  // 처음에 SPACE 한 글자
        S_DIGIT1000 = 4'd2,
        S_DIGIT100  = 4'd3,
        S_DOT       = 4'd4,
        S_DIGIT10   = 4'd5,
        S_DIGIT1    = 4'd6,
        S_METER     = 4'd7,
        S_ENTER     = 4'd8;

    // 계산용 4비트 숫자
    wire [3:0] digit_1    =  dist % 10;
    wire [3:0] digit_10   = (dist / 10) % 10;
    wire [3:0] digit_100  = (dist / 100) % 10;
    wire [3:0] digit_1000 =  dist / 1000;

    reg [3:0] c_state, n_state;
    reg       go_reg,  go_next;
    reg [3:0] hex_reg, hex_next;

    assign go_ascii = go_reg;

    // 동기 상태 전이
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state  <= S_IDLE;
            go_reg   <= 1'b0;
            hex_reg  <= 4'd0;
        end else begin
            c_state  <= n_state;
            go_reg   <= go_next;
            hex_reg  <= hex_next;
        end
    end

    // 조합 논리: 다음 상태·출력 결정
    always @(*) begin
        // 기본 유지
        n_state  = c_state;
        go_next  =  go_reg;
        hex_next = hex_reg;

        case (c_state)
            S_IDLE: begin
                go_next  = 1'b0;
                if (dist_done) begin
                    n_state  = S_SPACE;
                end
            end

            S_SPACE: begin
                go_next   = 1'b1;
                hex_next  = 4'hE;         // 코드 14: SPACE
                n_state   = S_DIGIT1000;
            end

            S_DIGIT1000: begin
                go_next   = 1'b1;
                hex_next  = digit_1000;
                n_state   = S_DIGIT100;
            end

            S_DIGIT100: begin
                go_next   = 1'b1;
                hex_next  = digit_100;
                n_state   = S_DOT;
            end

            S_DOT: begin
                go_next   = 1'b1;
                hex_next  = 4'd10;        // 코드 10: '.'
                n_state   = S_DIGIT10;
            end

            S_DIGIT10: begin
                go_next   = 1'b1;
                hex_next  = digit_10;
                n_state   = S_DIGIT1;
            end

            S_DIGIT1: begin
                go_next   = 1'b1;
                hex_next  = digit_1;
                n_state   = S_METER;
            end

            S_METER: begin
                go_next   = 1'b1;
                hex_next  = 4'd11;        // 코드 11: 'm'
                n_state   = S_ENTER;
            end

            S_ENTER: begin
                go_next   = 1'b1;
                hex_next  = 4'd14;        // 코드 12: Line Feed (LF)
                n_state   = S_IDLE;
            end

            default: n_state = S_IDLE;
        endcase
    end

    // 16진→ASCII 매핑
    always @(*) begin
        case (hex_reg)
            4'd0 : ascii = "0";
            4'd1 : ascii = "1";
            4'd2 : ascii = "2";
            4'd3 : ascii = "3";
            4'd4 : ascii = "4";
            4'd5 : ascii = "5";
            4'd6 : ascii = "6";
            4'd7 : ascii = "7";
            4'd8 : ascii = "8";
            4'd9 : ascii = "9";
            4'd10: ascii = ".";         // DOT
            4'd11: ascii = "m";         // METER
            4'd12: ascii = 8'h0A;       // ENTER (LF)
            4'd14: ascii = " ";         // SPACE
            default: ascii = 8'h00;
        endcase
    end
endmodule

module distance (
    input clk,
    input rst,
    input echo,
    input i_tick,

    output [9:0] dist,
    output dist_done
    );

    reg echo_reg, echo_next;
    reg [9:0] dist_reg, dist_next;
    reg done_reg, done_next;
    reg [5:0] count_reg, count_next;

    assign dist = dist_reg;
    assign dist_done = done_reg;

    always @(posedge clk or posedge rst) begin
        if(rst)begin
            echo_reg <= 0;
            dist_reg <= 0;
            done_reg <= 0;
            count_reg <= 0;
        end
        else begin
            echo_reg <= echo_next;
            dist_reg <= dist_next;
            done_reg <= done_next;
            count_reg <= count_next;
        end    
    end

    always @(*) begin
        echo_next       = echo_reg;
        dist_next       = dist_reg;
        done_next       = done_reg;
        count_next      = count_reg;
        case (echo_reg)
            0: begin
                count_next = 0;
                done_next = 0;
                if(echo)begin
                    dist_next = 0;
                    echo_next = 1;
                end
            end

            1: begin
                if(echo == 0) begin
                    dist_next = dist_reg;
                    echo_next = 1'b0;
                    done_next = 1;
                end
                else if(i_tick) begin
                    count_next = count_reg + 1;
                    if(count_reg == 57) begin   
                        count_next = 0;
                        dist_next = dist_reg + 1;
                    end
                end
            end 
        endcase
    end
    
endmodule

module start_trigger (
    input clk,
    input rst,
    input i_tick,
    input start,

    output o_sr04_tigger
);

    reg start_reg, start_next;
    reg [3:0] count_reg, count_next;
    reg sr04_trigger_reg, sr04_trigger_next;

    assign o_sr04_tigger = sr04_trigger_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            start_reg           <= 0;
            sr04_trigger_reg    <= 0;
            count_reg           <= 0;
        end
        else begin
            start_reg           <= start_next;
            sr04_trigger_reg    <= sr04_trigger_next;
            count_reg           <= count_next;
        end
    end

    always @(*) begin
        start_next          = start_reg;
        sr04_trigger_next   = sr04_trigger_reg;
        count_next          = count_reg;
        case(start_reg)
            0: begin
                count_next = 0;
                sr04_trigger_next = 1'b0;
                if (start) begin
                    start_next = 1;
                end
            end
            1: begin
                if (i_tick) begin
                    sr04_trigger_next = 1'b1;
                    if(count_reg == 10) begin
                        start_next = 0;
                    end
                    count_next = count_reg + 1;
                end
            end
        endcase
    end
endmodule

module sr04_mode (
    input clk,
    input rst,
    input btnU,
    input btnD,

    output auto_start
    );

    parameter n_auto = 0;
    parameter auto = 1;

    reg c_state, n_state;

    always @(posedge clk or posedge rst) begin
        if(rst)begin
            c_state <= 0;
        end
        else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (c_state)
            n_auto: begin
                if(btnU) begin
                    n_state = c_state;
                end
                else if(btnD) begin
                    n_state = auto;
                end
            end

            auto: begin
                if(btnD) begin
                    n_state = n_auto;
                end
            end
        endcase
    end

    assign auto_start = (c_state == auto) ? 1 : 0;

endmodule