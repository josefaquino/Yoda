CC ?= cc
CFLAGS = -std=c11 -O2 -Wall -Wextra -Werror
all: bin/yoda-okf-gate
bin/yoda-okf-gate: src/okf_gate.c
	mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $<
.PHONY: all
