# Yoda COMMAND-NATIVE-001 — Command Contract for Agents

This is a Yoda research case about the database interface itself.

It asks a narrow question:

> Can an autonomous agent recover decision-relevant durable state using only a small Yoda command vocabulary, without SQL, raw database access, or a full state dump in its prompt?

The tested read-only command vocabulary was:

    find
    get
    log
    context
    verify

The storage engine was not changed for this case.

## Why this case exists

Yoda already exposes a small Unix