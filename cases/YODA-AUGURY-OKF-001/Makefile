CC ?= gcc
CFLAGS ?= -std=c11 -O2 -Wall -Wextra -Werror
BIN = bin/yoda-okf
all: $(BIN)
$(BIN): src/yoda_okf.c
	mkdir -p bin
	$(CC) $(CFLAGS) -o $(BIN) src/yoda_okf.c
clean:
	rm -f $(BIN)
.PHONY: all clean
