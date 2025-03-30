export PATH+=$PATH:/home/chiut/arm-gnu-toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin

CROSS_COMPILE = 

cc = gcc

ifeq ($(CROSS_COMPILE), aarch64-none-linux-gnu-)
	cc = aarch64-none-linux-gnu-gcc-10.3.1
else ifneq ($(CROSS_COMPILE), )
	cc = $(CROSS_COMPILE)gcc
endif


BIN = writer

all:$(BIN)
	@exit 0 

$(BIN):writer.c
	$(cc) writer.c -o $@

clean:
	rm -rf $(BIN)