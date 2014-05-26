module UART_RX (
    input            reset,

    input            clock,
    input     [15:0] clock_div,

    input            rx,
    output reg [7:0] rx_data,
    output reg       rx_done);

    reg        bit_clock;
    reg [16:0] clock_counter;

    reg [10:0] rx_state;
    reg [07:0] rx_buffer;
    reg        rx_last;
    wire       rx_start_detect;
    assign     rx_start_detect = !rx && rx_last && rx_state == STATE_IDLE;

    parameter STATE_IDLE  = 10'b0000000001;
    parameter STATE_0     = 10'b0000000010;
    parameter STATE_1     = 10'b0000000100;
    parameter STATE_2     = 10'b0000001000;
    parameter STATE_3     = 10'b0000010000;
    parameter STATE_4     = 10'b0000100000;
    parameter STATE_5     = 10'b0001000000;
    parameter STATE_6     = 10'b0010000000;
    parameter STATE_7     = 10'b0100000000;
    parameter STATE_STOP  = 10'b1000000000;

    // Run the clock counter off the master clock
    // Also detect the start condition and jump the RX clock to be 90 degrees
    // out of phase with the start transition.
    always @(posedge clock or negedge reset)
    begin
        if (!reset)
            clock_counter <= 0;

        else
        begin
            if (rx_start_detect)
                clock_counter <= 0;

            else if (clock_counter == clock_div << 1)
                clock_counter <= 0;
        
            else
                clock_counter <= clock_counter + 17'b1;
        end
    end

    // Generate the bit clock from the clock counter
    always @(posedge clock or negedge reset)
    begin
        if (!reset)
            bit_clock <= 0;

        else
        begin
            if (clock_counter == 0)
                bit_clock <= 0;
            if (clock_counter == clock_div)
                bit_clock <= 1;
        end
    end

    // Edge detect RX falling for start condition
    always @(posedge clock or negedge reset)
    begin
        if (!reset)
            rx_last <= 1;
        else
            rx_last <= rx;
    end

    // UART RX state machine
    always @(posedge bit_clock or negedge reset)
    begin
        if (!reset)
        begin
            rx_state     <= STATE_IDLE;
            rx_done      <= 0;
        end
        
        else
        begin
            case(rx_state)
                STATE_IDLE:
                begin
                    rx_done  <= 0;
                    if (rx == 0)
                        rx_state <= STATE_0;
                end

                STATE_0:
                begin
                    rx_buffer[0] <= rx;
                    rx_state     <= STATE_1;
                end

                STATE_1:
                begin
                    rx_buffer[1] <= rx;
                    rx_state     <= STATE_2;
                end

                STATE_2:
                begin
                    rx_buffer[2] <= rx;
                    rx_state     <= STATE_3;
                end

                STATE_3:
                begin
                    rx_buffer[3] <= rx;
                    rx_state     <= STATE_4;
                end

                STATE_4:
                begin
                    rx_buffer[4] <= rx;
                    rx_state     <= STATE_5;
                end

                STATE_5:
                begin
                    rx_buffer[5] <= rx;
                    rx_state     <= STATE_6;
                end

                STATE_6:
                begin
                    rx_buffer[6] <= rx;
                    rx_state     <= STATE_7;
                end

                STATE_7:
                begin
                    rx_buffer[7] <= rx;
                    rx_state     <= STATE_STOP;
                end

                STATE_STOP:
                begin
                    rx_data  <= rx_buffer;
                    rx_done  <= 1;
                    rx_state <= STATE_IDLE;
                end

                default:
                begin
                    rx_state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule
