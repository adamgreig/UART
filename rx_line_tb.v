`timescale 10ns / 1ns

module RX_LINE_TB();

    reg        clock;
    reg        reset;
    reg        rx_done;
    reg  [7:0] rx_data;

    wire [7:0] addr;
    wire       write;
    wire [7:0] data_write;
    wire [7:0] data_read;
    wire       rx_line_done;

    initial begin
        clock = 0;
        reset = 1;
        rx_done = 1;
    end
    
    always
        #1 clock = ~clock;

    RX_LINE RX_LINE_0 (
        .reset(reset),
        .clock(clock),
        .start_addr(8'd1),
        .addr(addr),
        .data(data_write),
        .write(write),
        .rx_line_done(rx_line_done),
        .rx_data(rx_data),
        .rx_done(rx_done));

    RAM RAM0 (
        .clock(clock),
        .write(write),
        .addr(addr),
        .data_in(data_write),
        .data_out(data_read));

    initial begin
        $dumpfile("rx_line.vcd");
        $dumpvars();
        $display("RX_LINE Simulation starting...");

        #10

        $display("Resetting...");
        #10 reset = 0;
        #10 reset = 1;

        $display("Receiving line...");

        #10 rx_done = 0;
        #10 rx_data = 8'h41;
        #10 rx_done = 1;

        #10 rx_done = 0;
        #10 rx_data = 8'h44;
        #10 rx_done = 1;

        #10 rx_done = 0;
        #10 rx_data = 8'h41;
        #10 rx_done = 1;

        #10 rx_done = 0;
        #10 rx_data = 8'h4D;
        #10 rx_done = 1;

        #10 rx_done = 0;
        #10 rx_data = 8'h0D;
        #10 rx_done = 1;

        @(posedge rx_line_done);

        #10

        $display("Contents of RAM:");
        $write("%h ", RAM0.ram[0]);
        $write("%h ", RAM0.ram[1]);
        $write("%h ", RAM0.ram[2]);
        $write("%h ", RAM0.ram[3]);
        $write("%h ", RAM0.ram[4]);
        $write("%h ", RAM0.ram[5]);
        $write("%h ", RAM0.ram[6]);
        $write("%h ", RAM0.ram[7]);
        $write("%h ", RAM0.ram[8]);

        $display("\nExpected:");
        $display("xx 41 44 41 4d 00 xx xx xx");

        $display("Simulation finished.");
        $finish();
        
    end

endmodule

module RAM (
    input        clock,
    input        write,
    input  [7:0] addr,
    input  [7:0] data_in,
    output [7:0] data_out);

    reg [7:0] ram[255:0];
    reg [7:0] addr_reg;

    always @(posedge clock)
    begin
        if (write)
        begin
            $write("%t ", $time);
            $display("RAM: Storing %h at address %h", data_in, addr);
            ram[addr] <= data_in;
        end
        addr_reg <= addr;
    end

    assign data_out = ram[addr_reg];

endmodule
