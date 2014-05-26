`timescale 10ns / 1ns

module UART_TX_TB();

    reg        clock;
    reg [15:0] clock_div = 15'd217;
    reg        reset;
    reg [07:0] tx_data;
    reg        tx_ready;

    wire tx;
    wire tx_done;

    initial begin
        clock = 0;
        reset = 1;
        tx_data = 8'd0;
        tx_ready = 0;
    end

    always
        #1 clock = ~clock;

    UART_TX UART0_TX (
        .reset(reset),
        .clock(clock),
        .clock_div(clock_div),
        .tx_data(tx_data),
        .tx_ready(tx_ready),
        .tx(tx),
        .tx_done(tx_done)
    );

    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars();
        $display("UART_TX Simulation starting...");

        #10

        $display("Resetting...");
        #10 reset = 0;
        #10 reset = 1;

        $display("Transmitting 8'b01000001...");
        #1 tx_ready = 0;
        #1 tx_data  = 8'b01000001;
        #1 tx_ready = 1;
        @(posedge tx_done);

        $display("Transmitting 8'b01000100...");
        #1 tx_ready = 0;
        #1 tx_data  = 8'b01000100;
        #1 tx_ready = 1;
        @(posedge tx_done);

        $display("Transmitting 8'b01000001...");
        #1 tx_ready = 0;
        #1 tx_data  = 8'b01000001;
        #1 tx_ready = 1;
        @(posedge tx_done);

        $display("Transmitting 8'b01001101...");
        #1 tx_ready = 0;
        #1 tx_data  = 8'b01001101;
        #1 tx_ready = 1;
        @(posedge tx_done);

        $display("Simulation complete.");
        $finish();
    end

    uart_decoder decoder(clock, tx);

endmodule

module uart_decoder(
    input clock,
    input tx);

    parameter uart_wait = 868;
    reg waiting_for_start = 0;
    reg [7:0] tx_byte;

    always @(posedge clock)
        uart_decoder;

    task uart_decoder;
    begin
        while (tx !== 1)
            @(tx);
        waiting_for_start = 1;
        while (tx !== 0)
            @(tx);
        waiting_for_start = 0;
        #(uart_wait/2)
        #uart_wait tx_byte[0] = tx;
        #uart_wait tx_byte[1] = tx;
        #uart_wait tx_byte[2] = tx;
        #uart_wait tx_byte[3] = tx;
        #uart_wait tx_byte[4] = tx;
        #uart_wait tx_byte[5] = tx;
        #uart_wait tx_byte[6] = tx;
        #uart_wait tx_byte[7] = tx;
        if (tx != 1)
        begin
            while (tx != 1)
                @(tx);
        end
        $display("Received: %t %c (0x%h)", $time, tx_byte, tx_byte);
    end
    endtask
endmodule
