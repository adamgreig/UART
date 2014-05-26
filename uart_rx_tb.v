`timescale 10ns / 1ns

module UART_RX_TB();

    reg        clock;
    reg [15:0] clock_div = 15'd217;
    reg        reset;

    wire       rx;
    wire [7:0] rx_data;
    wire       rx_done;

    reg [7:0]  tx_data;
    reg        tx_ready;

    initial begin
        clock    = 0;
        reset    = 1;
        tx_data  = 0;
        tx_ready = 0;
    end

    always
        #1 clock = ~clock;

    UART_RX UART0_RX (
        .reset(reset),
        .clock(clock),
        .clock_div(clock_div),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    initial begin
        $dumpfile("rx.vcd");
        $dumpvars();
        $display("UART_RX Simulation starting...");

        #10

        $display("Resetting...");
        #10 reset = 0;
        #10 reset = 1;

        #1 tx_ready = 0;
        #1 tx_data  = 8'b01000001;
        #1 tx_ready = 1;
        @(posedge rx_done);
        $display("Received %c (0x%h)", rx_data, rx_data);

        #1 tx_ready = 0;
        #1 tx_data  = 8'b01000100;
        #1 tx_ready = 1;
        @(posedge rx_done);
        $display("Received %c (0x%h)", rx_data, rx_data);

        #1 tx_ready = 0;
        #1 tx_data  = 8'b01000001;
        #1 tx_ready = 1;
        @(posedge rx_done);
        $display("Received %c (0x%h)", rx_data, rx_data);

        #1 tx_ready = 0;
        #1 tx_data  = 8'b01001101;
        #1 tx_ready = 1;
        @(posedge rx_done);
        $display("Received %c (0x%h)", rx_data, rx_data);

        $display("Simulation complete.");
        $finish();
    end

    uart_encoder encoder(clock, tx_data, tx_ready, rx);

endmodule

module uart_encoder(
    input       clock,
    input [7:0] tx_data,
    input       tx_ready,
    output reg  rx);

    parameter uart_wait = 868;

    always @(posedge tx_ready)
        uart_encoder;

    task uart_encoder;
        begin
            $display("Transmitting %c (0x%h)", tx_data, tx_data);
                       rx = 0;
            #uart_wait rx = tx_data[0];
            #uart_wait rx = tx_data[1];
            #uart_wait rx = tx_data[2];
            #uart_wait rx = tx_data[3];
            #uart_wait rx = tx_data[4];
            #uart_wait rx = tx_data[5];
            #uart_wait rx = tx_data[6];
            #uart_wait rx = tx_data[7];
            #uart_wait rx = 1;
        end
    endtask
endmodule
