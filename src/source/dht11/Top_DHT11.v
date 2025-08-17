`timescale 1ns / 1ps

module Top_DHT11(
    input clk,
    input rst,
    input btnU,

    output [13:0] dht11_data,
    output go_ascii,
    output [7:0] ascii,

    inout dht11_io
    );

    wire [7:0] rh_data, t_data;
    wire [3:0] state_led;

    assign dht11_data = 100*rh_data + t_data;

    // hex2ascii 인스턴스
    hex2ascii_dht11 U_HEX2ASCII (
        .clk        (clk),
        .rst        (rst),
        .rh_data    (rh_data),
        .t_data     (t_data),
        .dht11_done (dht11_done),
        
        .ascii      (ascii),
        .go_ascii   (go_ascii)
    );

    dht11_controller U_DHT11_CNTL(
        .clk(clk),
        .rst(rst),
        .start(btnU),
        .rh_data(rh_data),
        .t_data(t_data),
        .dht11_done(dht11_done),
        .dth11_valid(dth11_valid),
        .state_led(state_led),
        .dht11_io(dht11_io)
    );

endmodule