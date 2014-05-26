`timescale 10ns / 1ns

module DE0NANO_TB();

    reg        clock;
    reg  [1:0] key;
    reg  [3:0] sw;
    
    wire [7:0] led;
    wire       uart_rx;
    wire       uart_tx;
    wire       uart_gnd;

    initial begin
        clock   = 0;
        key     = 2'b11;
        sw      = 4'b0000;
    end

    always
        #1 clock = ~clock;

    DE0NANO DE0NANO0 (
        .CLOCK_50(clock),
        .KEY(key),
        .SW(sw),
        .UART_RX(uart_rx),
        .UART_TX(uart_tx),
        .UART_GND(uart_gnd),
        .LED(led));

    reg [7:0] tx_data;
    reg       tx_ready;

    uart_decoder decoder(clock, uart_tx);
    uart_encoder encoder(clock, tx_data, tx_ready, uart_rx);

    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars();
        $display("Simulation starting...");

        #10 $display("Resetting...");
        #10 key[0] = 0;
        #10 key[0] = 1;

        #50 $display("Pushing button...");
        #10 key[1] = 0;
        #10 key[1] = 1;

        $display("Waiting for greeting to be transmitted...");
        @(posedge DE0NANO0.txs0_string_done_edge);
        $display();

        $display("Greeting sent, sending name in response...");
        #1 tx_ready = 0;
        #1 tx_data  = 8'h41;
        #1 tx_ready = 1;
        @(posedge DE0NANO0.UART0.RX.rx_done);

        #1 tx_ready = 0;
        #1 tx_data  = 8'h44;
        #1 tx_ready = 1;
        @(posedge DE0NANO0.UART0.RX.rx_done);

        #1 tx_ready = 0;
        #1 tx_data  = 8'h41;
        #1 tx_ready = 1;
        @(posedge DE0NANO0.UART0.RX.rx_done);

        #1 tx_ready = 0;
        #1 tx_data  = 8'h4D;
        #1 tx_ready = 1;
        @(posedge DE0NANO0.UART0.RX.rx_done);

        #1 tx_ready = 0;
        #1 tx_data  = 8'h0D;
        #1 tx_ready = 1;
        @(posedge DE0NANO0.UART0.RX.rx_done);

        #1 tx_ready = 0;
        #1 tx_data  = 8'h0A;
        #1 tx_ready = 1;
        @(posedge DE0NANO0.UART0.RX.rx_done);

        @(posedge DE0NANO0.rxl0_line_done_edge);
        
        $display();
        $display("Receiving response...");
        @(posedge DE0NANO0.txs0_string_done_edge);
        @(posedge DE0NANO0.txs1_string_done_edge);

        $display();
        $display("Simulation complete.");
        $finish;
    end
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
        $write("TX %h ", tx_byte);
    end
    endtask
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
            $write("RX %h ", tx_data);
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
