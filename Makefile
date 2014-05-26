all: tx rx tx_string

tx: uart_tx.v uart_tx_tb.v
	iverilog uart_tx.v uart_tx_tb.v -D VCP -D IV_DUMP -o tx
	./tx

rx: uart_rx.v uart_rx_tb.v
	iverilog uart_rx.v uart_rx_tb.v -D VCP -D IV_DUMP -o rx
	./rx

tx_string: tx_string.v tx_string_tb.v
	iverilog tx_string.v tx_string_tb.v -D VCP -D IV_DUMP -o tx_string
	./tx_string

rx_line: rx_line.v rx_line_tb.v
	iverilog rx_line.v rx_line_tb.v -D VCP -D IV_DUMP -o rx_line
	./rx_line
