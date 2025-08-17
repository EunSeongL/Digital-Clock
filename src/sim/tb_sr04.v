`timescale 1ns / 1ps


module tb_sr04();

    reg clk, rst, btnU, btnD, echo;

    wire trig, go_ascii;
    wire [13:0] sr04_data;
    wire [7:0] ascii;

    parameter us_10 = 10_000;
    parameter ms_1 = 1_000_000;

    Top_sr04 U_Top_sr04(
        .clk(clk),
        .rst(rst),
        .btnU(btnU),
        .btnD(btnD),
        .echo(echo),

        .trig(trig),
        .sr04_data(sr04_data),
        .go_ascii(go_ascii),
        .ascii(ascii)
    );

    always #5 clk = ~clk;
    

    initial begin
        #0; clk = 0; rst = 1; btnU = 0; btnD = 0; echo = 0;
        #20; rst = 0;

        #20; btnU = 1;
        #20; btnU = 0;
        
        #25000;  //25us
        echo = 1'b1;
        #(1000*1000); // 1000ms
        echo = 1'b0;
        #25000;  //25us
        echo = 1'b1;
        #(1000*1000); // 1000ms
        echo = 1'b0;

        
        #ms_1;

        btnD = 1;
        #10; btnD = 0;

        #(ms_1*7);
        #25000;  //25us
        echo = 1'b1;
        #(1000*1000); // 1000ms
        echo = 1'b0;
        #25000;  //25us
        echo = 1'b1;
        #(1000*1000); // 1000ms
        echo = 1'b0;

        #ms_1;
        btnU = 1;
        #20; btnU = 0;

        #ms_1;
        btnU = 1;
        #20; btnU = 0;

        #ms_1;
        btnU = 1;
        #20; btnU = 0;

        #(ms_1*5);
        #25000;  //25us
        echo = 1'b1;
        #(1000*3000); // 1000ms
        echo = 1'b0;
        #25000;  //25us
        echo = 1'b1;
        #(1000*3000); // 1000ms
        echo = 1'b0;

        #ms_1;
        btnD = 1;
        #10; btnD = 0;

        #ms_1;
        btnU = 1;
        #20; btnU = 0;
      
        #25000;  //25us
        echo = 1'b1;
        #(1000*1000); // 1000ms
        echo = 1'b0;
        #25000;  //25us
        echo = 1'b1;
        #(1000*1000); // 1000ms
        echo = 1'b0;

        $stop;
    end

endmodule
