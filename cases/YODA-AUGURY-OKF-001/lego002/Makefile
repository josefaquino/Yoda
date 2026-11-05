CC ?= cc
CFLAGS ?= -std=c11 -O2 -Wall -Wextra -Werror
all: bin/yoda-okf-trust
bin/yoda-okf-trust: src/okf_trust.c
	mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $<
.PHONY: all
