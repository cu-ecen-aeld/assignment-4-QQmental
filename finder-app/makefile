CROSS_COMPILE = 

cc = gcc

ifeq ($(CROSS_COMPILE), aarch64-none-linux-gnu-)
	cc = $(CROSS_COMPILE)gcc
else ifneq ($(CROSS_COMPILE), )
	cc = $(CROSS_COMPILE)gcc
endif


BIN = ./writer

all:$(BIN)
	@exit 0 

$(BIN):writer.c
	$(cc) writer.c -o $@
ifeq ($(CROSS_COMPILE), aarch64-none-linux-gnu-)
	@file $(BIN) | cat > ../assignments/assignment2/fileresult.txt
endif

clean:
	rm -rf $(BIN)
