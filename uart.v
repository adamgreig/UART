module UART (
    input         reset,

    input         clock,
    input  [15:0] clock_div,

    input         rx,
    output [7:0]  rx_data,
    output        rx_done,

    input  [7:0]  tx_data,
    input         tx_ready,
    output        tx,
    output        tx_done);

    UART_TX TX(
        .reset(reset),
        .clock(clock),
        .clock_div(clock_div),
        .tx_data(tx_data),
        .tx_ready(tx_ready),
        .tx(tx),
        .tx_done(tx_done));

    UART_RX RX(
        .reset(reset),
        .clock(clock),
        .clock_div(clock_div),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done));

endmodule
