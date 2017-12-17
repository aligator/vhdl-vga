GHDL=ghdl
GHDLFLAGS=
name=vga_sync_gen
others=

MODULES=\
	$(others) \
	$(name).o \
	$(name)_tb


test: $(MODULES)
	./$(name)_tb --vcd=$(name)_tb.vcd
	gtkwave -F -o $(name)_tb.vcd

# Binary depends on the object file
%: %.o
	$(GHDL) -e $(GHDLFLAGS) $@

# Object file depends on source
%.o: %.vhdl
	$(GHDL) -a $(GHDLFLAGS) $<

clean:
	echo "Cleaning up..."
	rm -f *.o *_tb $(name) work*.cf e*.lst *.vcd *.fst