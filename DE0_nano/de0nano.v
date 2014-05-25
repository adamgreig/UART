module DE0NANO (
    input        CLOCK_50,
    input  [1:0] KEY,
    output [7:0] LED,
    output       UART_TX);

    reg       button_last;
    reg [7:0] tx_data;
    reg       tx_ready;

    wire reset;
    wire button;
    wire button_edge;
    wire tx_done;

    assign LED    = 8'b01010101;
    assign reset  = KEY[0];
    assign button = KEY[1];

    assign button_edge = button && !button_last;
    
    UART UART0 (
        .reset(reset),
        .clock(CLOCK_50),
        .clock_div(15'd217),
        .tx_data(tx_data),
        .tx_ready(tx_ready),
        .tx(UART_TX),
        .tx_done(tx_done)
    );
    
    always @(posedge CLOCK_50)
    begin
        if (!reset)
        begin
            button_last <= 0;
            tx_ready    <= 0;
            tx_data     <= 8'b01000001;
        end
        else
        begin
            if (button_edge)
                tx_ready <= 1;
            else
                tx_ready <= 0;
        end
    end

endmodule
