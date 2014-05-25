module DE0NANO (
    input        CLOCK_50,
    input  [1:0] KEY,
    input  [3:0] SW,
    output [7:0] LED,
    output       UART_TX,
    output       UART_GND);

    reg       button_last;
    reg       tx_ready;
    reg [7:0] addr;
    reg [3:0] state;

    wire       reset;
    wire       button;
    wire       button_edge;
    wire       tx_done;
    wire [7:0] data;

    assign LED         = data;
    assign reset       = KEY[0];
    assign button      = KEY[1];
    assign UART_GND    = 0;
    assign button_edge = button && !button_last;

    parameter STATE_IDLE  = 4'b0001;
    parameter STATE_READY = 4'b0010;
    parameter STATE_WAIT  = 4'b0100;

    UART UART0 (
        .reset(reset),
        .clock(CLOCK_50),
        .clock_div(16'd217),
        .tx_data(data),
        .tx_ready(tx_ready),
        .tx(UART_TX),
        .tx_done(tx_done)
    );

    ROM ROM0 (
        .clock(CLOCK_50),
        .addr(addr),
        .data(data)
    );

    always @(posedge CLOCK_50 or negedge reset)
    begin
        if (!reset)
            button_last <= 1;
        else
            button_last <= button;
    end
    
    always @(posedge CLOCK_50 or negedge reset)
    begin
        if (!reset)
        begin
            tx_ready    <= 0;
            state       <= STATE_IDLE;
            addr        <= 0;
        end

        else
        begin
            case(state)
                STATE_IDLE:
                begin
                    tx_ready <= 0;
                    addr     <= 0;
                    if (button_edge)
                        state <= STATE_READY;
                end

                STATE_READY:
                begin
                    tx_ready <= 1;
                    if (!tx_done)
                        state    <= STATE_WAIT;
                end

                STATE_WAIT:
                begin
                    if (tx_done)
                    begin
                        if (data == 8'h00)
                        begin
                            state <= STATE_IDLE;
                        end

                        else
                        begin
                            tx_ready <= 0;
                            addr     <= addr + 8'b1;
                            state    <= STATE_READY;
                        end
                    end
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
    output reg [7:0] data
);
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
