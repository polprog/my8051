ASSEMBLER=sdas8051
LINKER = sdld
OBJCOPY = objcopy
BIN2MEMH = ../tools/bin2memh.py
ifeq ($(BINARY),)
all: error
else
all: $(BINARY).mem
endif

error:
	@echo "specify which hexfile to build with BINARY=..."
	@exit 0

%.mem: %.bin
	@echo "// bin2memh $< > $@" > $@
	$(BIN2MEMH) < $< >> $@

%.bin: %.ihx
	 $(OBJCOPY) -I ihex -O binary $< $@

%.ihx: %.rel
	$(LINKER) -i $<

%.rel: %.s
	$(ASSEMBLER) -o $<
clean:
	rm -f *.ihx *.rel *.bin *.mem

.PHONY: clean 
