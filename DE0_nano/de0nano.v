module DE0NANO (
    input        CLOCK_50,
    input  [1:0] KEY,
    input  [3:0] SW,
    input        UART_RX,
    output       UART_TX,
    output       UART_GND,
    output [7:0] LED);

    // Actual IO
    wire       reset;
    wire       button;

    wire       button_edge;
    reg        button_last;

    assign reset       = KEY[0];
    assign button      = KEY[1];
    assign UART_GND    = 0;
    assign button_edge = button && !button_last;

    // Internal state
    reg [4:0] state;
    parameter STATE_IDLE     = 5'b00001;
    parameter STATE_TX_GREET = 5'b00010;
    parameter STATE_RX_NAME  = 5'b00100;
    parameter STATE_TX_RESP  = 5'b01000;
    parameter STATE_TX_NAME  = 5'b10000;

    // Logic we use directly from the modules
    reg       ram0_addr_sel;
    reg       tx_data_sel;
    reg       tx_ready_sel;
    reg       uart_tx_sel;
    reg [7:0] txs0_start_addr;
    reg       txs0_string_ready;
    wire      txs0_string_done;
    reg       txs1_string_ready;
    wire      txs1_string_done;
    wire      rxl0_line_done;

    // Edge detect on module status lines
    reg    txs0_string_done_last;
    wire   txs0_string_done_edge;
    assign txs0_string_done_edge = txs0_string_done && !txs0_string_done_last;
    reg    txs1_string_done_last;
    wire   txs1_string_done_edge;
    assign txs1_string_done_edge = txs1_string_done && !txs1_string_done_last;
    reg    rxl0_line_done_last;
    wire   rxl0_line_done_edge;
    assign rxl0_line_done_edge = rxl0_line_done && !rxl0_line_done_last;

    // Logic being wired between modules
    wire [7:0] rom_addr;
    wire [7:0] rom_data;
    wire [7:0] ram_addr;
    wire       ram_write;
    wire [7:0] ram_data_out;
    wire [7:0] ram_data_in;
    wire [7:0] rx_data;
    wire       rx_done;
    wire [7:0] tx_data;
    wire       tx_ready;
    wire       tx_done;
    wire [7:0] txs0_tx_data;
    wire       txs0_tx_ready;
    wire [7:0] txs1_tx_data;
    wire       txs1_tx_ready;
    wire [7:0] txs1_ram_addr;
    wire [7:0] rxl0_ram_addr;
    wire       uart_tx;

    // ROM stores the greeting message and resposne message prefix.
    ROM ROM0 (
        .clock(CLOCK_50),
        .addr(rom_addr),
        .data(rom_data)
    );

    // RAM stores the input user name.
    RAM RAM0 (
        .clock(CLOCK_50),
        .addr(ram_addr),
        .write(ram_write),
        .data_out(ram_data_out),
        .data_in(ram_data_in)
    );

    // Instantiate a UART
    UART UART0 (
        .reset(reset),

        .clock(CLOCK_50),
        .clock_div(16'd217),
        
        .rx(UART_RX),
        .rx_data(rx_data),
        .rx_done(rx_done),

        .tx_data(tx_data),
        .tx_ready(tx_ready),
        .tx(uart_tx),
        .tx_done(tx_done)
    );

    // TXS0 transmits a string from start_addr until a NULL is read, from ROM.
    TX_STRING TXS0 (
        .reset(reset),
        .clock(CLOCK_50),
        .tx_string_ready(txs0_string_ready),
        .start_addr(txs0_start_addr),
        .addr(rom_addr),
        .data(rom_data),
        .tx_string_done(txs0_string_done),
        .tx_data(txs0_tx_data),
        .tx_ready(txs0_tx_ready),
        .tx_done(tx_done)
    );

    // TXS0 transmits a string from start_addr until a NULL is read, from RAM.
    TX_STRING TXS1 (
        .reset(reset),
        .clock(CLOCK_50),
        .tx_string_ready(txs1_string_ready),
        .start_addr(8'h00),
        .addr(txs1_ram_addr),
        .data(ram_data_out),
        .tx_string_done(txs1_string_done),
        .tx_data(txs1_tx_data),
        .tx_ready(txs1_tx_ready),
        .tx_done(tx_done)
    );

    // RXL0 reads characters from the UART until a carriage return is seen,
    // storing them in RAM.
    RX_LINE RXL0 (
        .reset(reset),
        .clock(CLOCK_50),
        .start_addr(8'h00),
        .addr(rxl0_ram_addr),
        .data(ram_data_in),
        .write(ram_write),
        .rx_line_done(rxl0_line_done),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Multiplex access to the RAM's address port between RXL0 and TXS1
    TWOMUX RAM0_ADDR_MUX (
        .select(ram0_addr_sel),
        .inA(rxl0_ram_addr),
        .inB(txs1_ram_addr),
        .out(ram_addr)
    );

    // Multiplex access to the UART's tx_data port between TXS0 and TXS1
    TWOMUX TX_DATA_MUX (
        .select(tx_data_sel),
        .inA(txs0_tx_data),
        .inB(txs1_tx_data),
        .out(tx_data)
    );

    // Multiplex access to the UART's tx_ready port between TXS0 and TXS1
    TWOMUX #(.N(1)) TX_READY_MUX (
        .select(tx_ready_sel),
        .inA(txs0_tx_ready),
        .inB(txs1_tx_ready),
        .out(tx_ready)
    );

    // Multiplex access to the UART_TX pin between the UART_TX and (loopback)
    // the UART_RX.
    TWOMUX #(.N(1)) UART_TX_MUX (
        .select(uart_tx_sel),
        .inA(uart_tx),
        .inB(UART_RX),
        .out(UART_TX)
    );

    // Edge detection
    always @(posedge CLOCK_50 or negedge reset)
    begin
        if (!reset)
        begin
            button_last           <= 1;
            txs0_string_done_last <= 1;
            txs1_string_done_last <= 1;
            rxl0_line_done_last   <= 1;
        end

        else
        begin
            button_last           <= button;
            txs0_string_done_last <= txs0_string_done;
            txs1_string_done_last <= txs1_string_done;
            rxl0_line_done_last   <= rxl0_line_done;
        end
    end
    
    always @(posedge CLOCK_50 or negedge reset)
    begin
        if (!reset)
        begin
            state             <= STATE_IDLE;
            ram0_addr_sel     <= 0;
            tx_data_sel       <= 0;
            tx_ready_sel      <= 0;
            uart_tx_sel       <= 0;
            txs0_start_addr   <= 8'd0;
            txs0_string_ready <= 0;
            txs1_string_ready <= 0;
        end

        else
        begin
            case(state)
                STATE_IDLE:
                begin
                    ram0_addr_sel     <= 0;
                    tx_data_sel       <= 0;
                    tx_ready_sel      <= 0;
                    uart_tx_sel       <= 0;
                    txs0_string_ready <= 0;
                    txs1_string_ready <= 0;
                    txs0_start_addr   <= 8'h00;

                    if (button_edge)
                        state <= STATE_TX_GREET;
                end

                STATE_TX_GREET:
                begin
                    ram0_addr_sel     <= 0;
                    tx_data_sel       <= 0;
                    tx_ready_sel      <= 0;
                    uart_tx_sel       <= 0;
                    txs0_string_ready <= 1;
                    txs1_string_ready <= 0;
                    txs0_start_addr   <= 8'h00;

                    if(txs0_string_done_edge)
                        state <= STATE_RX_NAME;
                end

                STATE_RX_NAME:
                begin
                    ram0_addr_sel     <= 0;
                    tx_data_sel       <= 0;
                    tx_ready_sel      <= 0;
                    uart_tx_sel       <= 1;
                    txs0_string_ready <= 0;
                    txs1_string_ready <= 0;
                    txs0_start_addr   <= 8'h00;

                    if(rxl0_line_done_edge)
                        state <= STATE_TX_RESP;
                end

                STATE_TX_RESP:
                begin
                    ram0_addr_sel     <= 0;
                    tx_data_sel       <= 0;
                    tx_ready_sel      <= 0;
                    uart_tx_sel       <= 0;
                    txs0_string_ready <= 1;
                    txs1_string_ready <= 0;
                    txs0_start_addr   <= 8'h30;

                    if(txs0_string_done_edge)
                        state <= STATE_TX_NAME;
                end

                STATE_TX_NAME:
                begin
                    ram0_addr_sel     <= 1;
                    tx_data_sel       <= 1;
                    tx_ready_sel      <= 1;
                    uart_tx_sel       <= 0;
                    txs0_string_ready <= 0;
                    txs1_string_ready <= 1;
                    txs0_start_addr   <= 8'h00;

                    if(txs1_string_done_edge)
                        state <= STATE_IDLE;
                end

                default:
                begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule

module ROM (
    input            clock,
    input      [7:0] addr,
    output reg [7:0] data);

    reg [7:0] rom[255:0];
    
    initial
    begin
        $readmemh("de0nano_rom.txt", rom);
    end

    always @(posedge clock)
    begin
        data <= rom[addr];
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
            ram[addr] <= data_in;
        addr_reg <= addr;
    end

    assign data_out = ram[addr_reg];

endmodule

module TWOMUX (
    input  select,
    input  [N-1:0] inA,
    input  [N-1:0] inB,
    output [N-1:0] out);

    parameter N = 8;

    assign out = select ? inB : inA;

endmodule
