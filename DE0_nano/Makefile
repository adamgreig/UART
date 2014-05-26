DESIGN_NAME=de0nano

sim: de0nano.v de0nano_tb.v ../uart_tx.v
	iverilog ../uart_tx.v de0nano.v de0nano_tb.v -D VCD -D IV_DUMP -o sim
	./sim

build: output_files/$(DESIGN_NAME).sof

pgm: output_files/$(DESIGN_NAME).sof
	quartus_pgm --mode=jtag -o p\;output_files/$(DESIGN_NAME).sof

sta: asm
	quartus_sta $(DESIGN_NAME)

output_files/$(DESIGN_NAME).sof: output_files/$(DESIGN_NAME).fit.rpt
	quartus_asm $(DESIGN_NAME)

output_files/$(DESIGN_NAME).fit.rpt: output_files/$(DESIGN_NAME).map.rpt
	quartus_fit $(DESIGN_NAME)

output_files/$(DESIGN_NAME).map.rpt: de0nano.qpf
	quartus_map $(DESIGN_NAME)

de0nano.qpf: de0nano.tcl ../uart_tx.v de0nano.v
	quartus_sh -t de0nano.tcl

clean:
	rm -rf db incremental_db output_files
	rm $(DESIGN_NAME).{flow.rpt,map.rpt,map.summary,qpf,qsf}
