all: sim

sim: uart.v uart_tb.v
	iverilog uart.v uart_tb.v -D VCP -D IV_DUMP -o sim
	./sim

