PROJ=top
TRELLIS?=/usr/share/trellis
DEPS= top.v r8051.v uart.v hexrom.v myport.v

all: ${PROJ}.bit

%.json: %.v ${DEPS}
	yosys -p "hierarchy -top top8051; synth_ecp5 -json $@; stat" $^

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --25k --package CABGA256 --lpf pin_assignments.lpf --lpf-allow-unconstrained

%.bit: %_out.config
	ecppack --svf ${PROJ}.svf $< $@

${PROJ}.svf : ${PROJ}.bit

prog: ${PROJ}.svf
	../program_jlink.sh $<

simulate: ${DEPS} ${PROJ}.v test.v
	iverilog -DTEST_ICARUS $^
	./a.out


clean:
	rm -f *.svf *.bit *.config *.json

.PHONY: prog clean
