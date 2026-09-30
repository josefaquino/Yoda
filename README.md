# Yoda v0.1

Yoda is a local, verifiable decision-state layer for autonomous software.

## Platform

Current validated binary:

- GNU/Linux
- x86_64
- dynamically linked against glibc

Source:

- ISO C11
- POSIX.1-2008

## Quick Start

Create a database:

    ./yoda init ./memory

Store evidence:

    printf '%s\n' 'PostgreSQL 16 approved for production' |
        ./yoda -d ./memory put evidence/db-validation \
            source=production-validation

Retrieve exact evidence:

    ./yoda -d ./memory get evidence/db-validation

Find evidence:

    ./yoda -d ./memory find production

Build bounded context:

    ./yoda -d ./memory context production

Verify authoritative state:

    ./yoda -d ./memory verify

## Commands

    init
    put
    get
    find
    link
    log
    verify
    context

## Build From Source

    make

Compiler requirements:

    ISO C11
    POSIX.1-2008

The validated build uses:

    -std=c11
    -O2
    -Wall
    -Wextra
    -Werror
    -D_POSIX_C_SOURCE=200809L

## Authority

`data.yoda` is authoritative.

Derived indexes are rebuildable and must not become the source of truth.

See `PRODUCT-CONTRACT.md` for the complete Yoda v0.1 product contract.

---

## External Validation Case

A small decision-state example is included:

    cd examples/decision-state
    ./run.sh

The example demonstrates:

- historical evidence;
- newer evidence;
- an explicit `supersedes` relation;
- lexical retrieval;
- bounded context retrieval;
- authoritative-state verification.

No network connection, model API, Python runtime, server, or account is required.

After testing, see:

    CASE-EXTERNAL-001.md
    FEEDBACK.md

---

## License

Yoda v0.1.0-preview.1 is distributed under the Apache License, Version 2.0.

See:

    LICENSE
