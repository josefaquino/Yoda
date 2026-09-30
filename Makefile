CC ?= cc

CFLAGS ?= \
	-std=c11 \
	-O2 \
	-Wall \
	-Wextra \
	-Werror \
	-D_POSIX_C_SOURCE=200809L

LDFLAGS ?=

all: yoda

yoda: yoda.c
	$(CC) $(CFLAGS) yoda.c -o yoda $(LDFLAGS)

clean:
	rm -f yoda
