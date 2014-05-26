all: tx rx

tx: uart_tx.v uart_tx_tb.v
	iverilog uart_tx.v uart_tx_tb.v -D VCP -D IV_DUMP -o tx
	./tx

rx: uart_rx.v uart_rx_tb.v
	iverilog uart_rx.v uart_rx_tb.v -D VCP -D IV_DUMP -o rx
	./rx

