`timescale 10ns / 1ns

module DE0NANO_TB();

    reg        clock;
    reg  [1:0] key;
    reg  [3:0] sw;
    
    wire [7:0] led;
    wire       uart_tx;
    wire       uart_gnd;

    initial begin
        clock = 0;
        key   = 2'b11;
        sw    = 4'b0000;
    end

    always
        #1 clock = ~clock;

    DE0NANO DE0NANO0 (
        .CLOCK_50(clock),
        .KEY(key),
        .SW(sw),
        .LED(led),
        .UART_TX(uart_tx),
        .UART_GND(uart_gnd));

    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars();
        $display("Simulation starting...");

        #10
        #10 key[0] = 0;
        #10 key[0] = 1;
        #10
        #10 key[1] = 0;
        #10 key[1] = 1;

        #100000

        $display("Simulation complete.");
        $finish;
    end

endmodule
