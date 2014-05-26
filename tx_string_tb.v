`timescale 10ns / 1ns

module TX_STRING_TB();

    reg        clock;
    reg        reset;
    reg        tx_string_ready;
    reg        tx_done;

    wire [7:0] addr;
    wire [7:0] data;
    wire [7:0] tx_data;
    wire       tx_ready;
    wire       tx_string_done;

    initial begin
        clock = 0;
        reset = 1;
        tx_string_ready = 0;
        tx_done  = 1;
    end

    always
        #1 clock = ~clock;

    TX_STRING TX_STRING_0 (
        .reset(reset),
        .clock(clock),
        .tx_string_ready(tx_string_ready),
        .start_addr(8'd1),
        .addr(addr),
        .data(data),
        .tx_string_done(tx_string_done),
        .tx_data(tx_data),
        .tx_ready(tx_ready),
        .tx_done(tx_done));

    ROM ROM0 (
        .clock(clock),
        .addr(addr),
        .data(data));

    initial begin
        $dumpfile("tx_string.vcd");
        $dumpvars();
        $display("TX_STRING Simulation starting...");

        #10
        
        $display("Resetting...");
        #10 reset = 0;
        #10 reset = 1;

        $display("Transmitting string...");
        tx_string_ready = 1;

        @(posedge tx_ready);
        #10  tx_done = 0;
        $display("TX %h", tx_data);
        #100 tx_done = 1;

        @(posedge tx_ready);
        #10  tx_done = 0;
        $display("TX %h", tx_data);
        #100 tx_done = 1;

        @(posedge tx_ready);
        #10  tx_done = 0;
        $display("TX %h", tx_data);
        #100 tx_done = 1;

        @(posedge tx_ready);
        #10  tx_done = 0;
        $display("TX %h", tx_data);
        #100 tx_done = 1;

        @(posedge tx_string_done);

        #10

        $display("Simulation complete.");
        $finish();
        
    end

endmodule

module ROM (
    input            clock,
    input      [7:0] addr,
    output reg [7:0] data);

    always @(posedge clock)
    begin
        case(addr)
            0: data = 8'hf8;
            1: data = 8'h41;
            2: data = 8'h44;
            3: data = 8'h41;
            4: data = 8'h4D;
            5: data = 8'h00;

            default: data = 8'hFF;
        endcase
    end
endmodule

