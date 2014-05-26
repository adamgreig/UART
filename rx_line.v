module RX_LINE (
    input            reset,
    input            clock,
    input      [7:0] start_addr,
    output reg [7:0] addr,
    output reg [7:0] data,
    output reg       write,
    output reg       rx_line_done,
    input      [7:0] rx_data,
    input            rx_done);

    reg [2:0] state;
    reg       rx_done_last;
    
    wire   rx_done_edge;
    assign rx_done_edge = rx_done && !rx_done_last;

    parameter STATE_IDLE = 3'b001;
    parameter STATE_SAVE = 3'b010;
    parameter STATE_WAIT = 3'b100;

    always @(posedge clock or negedge reset)
    begin
        if (!reset)
            rx_done_last <= 1;

        else
            rx_done_last <= rx_done;
    end

    always @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            state        <= STATE_IDLE;
            rx_line_done <= 0;
            write        <= 0;
        end

        else
        begin
            case (state)
                STATE_IDLE:
                begin
                    write        <= 0;
                    rx_line_done <= 0;
                    addr         <= start_addr;

                    if (rx_done_edge)
                    begin
                        state <= STATE_SAVE;
                    end
                end

                STATE_SAVE:
                begin
                    if (rx_data == 8'h0A)
                    begin
                        data         <= 8'h00;
                        write        <= 1;
                        rx_line_done <= 1;
                        state        <= STATE_IDLE;
                    end

                    else if (rx_data < 8'h20 || rx_data > 8'h7E)
                    begin
                        addr  <= addr - 8'd1;
                        state <= STATE_WAIT;
                    end

                    else
                    begin
                        data  <= rx_data;
                        write <= 1;
                        state <= STATE_WAIT;
                    end
                end

                STATE_WAIT:
                begin
                    write <= 0;

                    if (rx_done_edge)
                    begin
                        addr  <= addr + 8'd1;
                        state <= STATE_SAVE;
                    end
                end

                default:
                    state <= STATE_IDLE;
            endcase
        end
    end

endmodule
