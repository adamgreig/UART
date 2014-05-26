module UART_TX (
    input        reset,

    input        clock,
    input [15:0] clock_div,

    input [07:0] tx_data,
    input        tx_ready,
    output reg   tx,
    output       tx_done);

    reg        bit_clock;
    reg [15:0] clock_counter;

    reg [11:0] tx_state;
    reg [07:0] tx_buffer;
    reg        tx_loaded;
    reg        tx_ready_last;
    reg        tx_complete;

    wire       tx_ready_edge;
    assign     tx_ready_edge = tx_ready && !tx_ready_last;
    assign     tx_done       = tx_complete && !tx_loaded;

    parameter STATE_IDLE  = 11'b00000000001;
    parameter STATE_START = 11'b00000000010;
    parameter STATE_0     = 11'b00000000100;
    parameter STATE_1     = 11'b00000001000;
    parameter STATE_2     = 11'b00000010000;
    parameter STATE_3     = 11'b00000100000;
    parameter STATE_4     = 11'b00001000000;
    parameter STATE_5     = 11'b00010000000;
    parameter STATE_6     = 11'b00100000000;
    parameter STATE_7     = 11'b01000000000;
    parameter STATE_STOP  = 11'b10000000000;

    // Run the clock counter off the master clock
    always @(posedge clock or negedge reset)
    begin
        if (!reset)
            clock_counter <= 0;
        else if (clock_counter == clock_div)
            clock_counter <= 0;
        else
            clock_counter <= clock_counter + 16'b1;
    end

    // Generate the bit clock from the clock counter
    always @(posedge clock or negedge reset)
    begin
        if (!reset)
            bit_clock <= 0;
        else if (clock_counter == clock_div)
            bit_clock <= ~bit_clock;
    end

    // Edge detect tx_ready
    always @(posedge clock or negedge reset)
    begin
        if (!reset)
            tx_ready_last <= 0;
        else
            tx_ready_last <= tx_ready;
    end

    // Load input data on rising edge of tx_ready
    always @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            tx_loaded <= 0;
        end

        else
        begin
            if (tx_ready_edge)
            begin
                tx_buffer <= tx_data;
                tx_loaded <= 1;
            end

            else if (tx_state != STATE_IDLE)
            begin
                tx_loaded <= 0;
            end

        end
    end

    // UART TX state machine
    always @(posedge bit_clock or negedge reset)
    begin
        if (!reset)
        begin
            tx_state     <= STATE_IDLE;
            tx_complete  <= 1;
            tx           <= 1;
        end
        
        else
        begin
            case(tx_state)
                STATE_IDLE:
                begin
                    tx      <= 1;

                    if (tx_loaded)
                    begin
                        tx_state    <= STATE_START;
                        tx_complete <= 0;
                    end

                    else
                        tx_complete <= 1;
                end

                STATE_START:
                begin
                    tx       <= 0;
                    tx_state <= STATE_0;
                end

                STATE_0:
                begin
                    tx       <= tx_buffer[0];
                    tx_state <= STATE_1;
                end

                STATE_1:
                begin
                    tx       <= tx_buffer[1];
                    tx_state <= STATE_2;
                end

                STATE_2:
                begin
                    tx       <= tx_buffer[2];
                    tx_state <= STATE_3;
                end

                STATE_3:
                begin
                    tx       <= tx_buffer[3];
                    tx_state <= STATE_4;
                end

                STATE_4:
                begin
                    tx       <= tx_buffer[4];
                    tx_state <= STATE_5;
                end

                STATE_5:
                begin
                    tx       <= tx_buffer[5];
                    tx_state <= STATE_6;
                end

                STATE_6:
                begin
                    tx       <= tx_buffer[6];
                    tx_state <= STATE_7;
                end

                STATE_7:
                begin
                    tx       <= tx_buffer[7];
                    tx_state <= STATE_STOP;
                end

                STATE_STOP:
                begin
                    tx          <= 1;
                    tx_complete <= 1;
                    tx_state    <= STATE_IDLE;
                end

                default:
                begin
                    tx_state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule
