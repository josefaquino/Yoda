# Yoda v0.1

Yoda is a local, verifiable decision-state layer for autonomous software.

## Vision

> The internet is a living organism. Data is born, changes, forms relationships, conflicts, ages, and is replaced. Yoda does not try to own the internet. It records the verifiable DNA of the data it observes: origin, identity, relationships, history, mutations, and the evidence produced by experiments.

Yoda grows through propagation: real problems become reproducible evidence, reproducible evidence becomes reusable experiments, and reusable experiments generate new knowledge.

See `PROPAGATION-MODEL.md` for the product and community growth model behind this idea.

## Try the Preview

Download these two files from the current GitHub prerelease:

    yoda-v0.1.0-preview.1-linux-x86_64.tar.gz
    yoda-v0.1.0-preview.1-linux-x86_64.tar.gz.sha256

Verify the downloaded archive:

    sha256sum -c yoda-v0.1.0-preview.1-linux-x86_64.tar.gz.sha256

Extract it:

    tar -xzf yoda-v0.1.0-preview.1-linux-x86_64.tar.gz
    cd yoda-v0.1.0-preview.1-linux-x86_64

Run Yoda:

    ./yoda init ./memory

No server, account, network connection, Python, Node, or JVM is required.

Release:

    https://github.com/josefaquino/Yoda/releases/tag/v0.1.0-preview.1

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

## Field Cases

Yoda grows by propagation: real problems become reproducible evidence, reproducible evidence becomes reusable experiments, and reusable experiments generate new knowledge.

### FIELD-001 — Multi-Agent Decision State

Can independent decision processes recover consistent, decision-relevant evidence from shared durable state without sharing transient conversational context?

    cases/FIELD-001-multi-agent-decision-state/

The case is designed to be reproduced, adapted, forked, and republished.

See `PROPAGATION-MODEL.md` for the propagation model.

---

## License

Yoda v0.1.0-preview.1 is distributed under the Apache License, Version 2.0.

See:

    LICENSE
