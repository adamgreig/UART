module TX_STRING (
    input            reset,
    input            clock,
    input            tx_string_ready,
    input      [7:0] start_addr,
    output reg [7:0] addr,
    input      [7:0] data,
    output reg       tx_string_done,
    output     [7:0] tx_data,
    output reg       tx_ready,
    input            tx_done);

    reg [2:0] state;
    reg       tx_string_ready_last;
    wire      tx_string_ready_edge;

    assign tx_string_ready_edge = tx_string_ready && !tx_string_ready_last;
    assign tx_data              = data;
    
    parameter STATE_IDLE  = 3'b001;
    parameter STATE_READY = 3'b010;
    parameter STATE_WAIT  = 3'b100;

    always @(posedge clock or negedge reset)
    begin
        if (!reset)
            tx_string_ready_last <= 0;

        else
            tx_string_ready_last <= tx_string_ready;
    end

    always @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state          <= STATE_IDLE;
            tx_ready       <= 0;
            tx_string_done <= 0;
            addr           <= start_addr;
        end

        else
        begin
            case (state)
                STATE_IDLE:
                begin
                    tx_ready       <= 0;
                    tx_string_done <= 0;
                    addr           <= start_addr;

                    if (tx_string_ready_edge)
                    begin
                        state <= STATE_READY;
                    end
                end

                STATE_READY:
                begin
                    if (data != 8'h00)
                    begin
                        tx_ready <= 1;
                        if (!tx_done)
                            state <= STATE_WAIT;
                    end

                    else
                    begin
                        tx_string_done <= 1;
                        state          <= STATE_IDLE;
                    end
                end

                STATE_WAIT:
                begin
                    if (tx_done)
                    begin
                        tx_ready <= 0;
                        addr     <= addr + 8'b1;
                        state    <= STATE_READY;
                    end
                end

                default:
                    state <= STATE_IDLE;
            endcase
        end
    end

endmodule
