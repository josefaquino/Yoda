# Yoda

**A local, verifiable knowledge layer for results you need to explain.**

Yoda is built around a simple question:

> **Where did this result come from?**

Most systems are good at storing an artifact or producing an answer.
Yoda is interested in the chain behind it:

```text
observation
   ↓
artifact
   ↓
transformation
   ↓
result
   ↓
verifiable derivation
```

The goal is not to prove that a scientific result is biologically, mathematically, or operationally correct.

The goal is narrower and more concrete:

> **Preserve the verifiable chain that produced what we are looking at.**

That means identity, provenance, relationships, history, tools, evidence, and the state needed to reconstruct context later.

---

## A useful mental model

One internal contrast we use is:

```text
Axiom:
Prove the reasoning.

Yoda:
Prove the origin of the result.
```

This is a conceptual contrast, not an official Axiom slogan.

The distinction matters.

A proof-oriented reasoning system may care about:

```text
premises
   ↓
reasoning
   ↓
mathematical result
```

Yoda is exploring a different problem:

```text
observation
   ↓
artifact
   ↓
transformation
   ↓
result
   ↓
verifiable lineage
```

Yoda does not claim to prove scientific truth.

It aims to make the origin of a result inspectable, durable, and independently verifiable.

---

# Yoda and KyberDB

Yoda and KyberDB solve different problems.

## KyberDB

KyberDB is the embedded C11 state engine and storage research substrate.

Its job is to answer questions such as:

> Can this state be persisted exactly?

> Can it survive commit, close, reopen, and verification?

> Can corruption be detected?

> Can the exact post-reopen state be compared with an independent oracle?

KyberDB focuses on:

- local embedded state;
- C11 and POSIX;
- exact key/value persistence;
- durable commits;
- explicit verification;
- close/reopen reconstruction;
- content identity;
- corruption detection;
- public embedded ABI experiments.

KyberDB is deliberately domain-agnostic.

It does not need to understand genomics, routing, security logs, earthquakes, or satellite observations.

It needs to preserve state correctly.

## Yoda

Yoda is the user-facing verifiable knowledge and evidence layer.

Its job is to answer questions such as:

> What is this result?

> Where did it come from?

> What produced it?

> What evidence supports it?

> What changed?

> What is related to it?

> What context should an agent or developer see before making a decision?

Yoda focuses on:

- evidence;
- identity;
- provenance;
- relationships;
- history;
- bounded context;
- verification;
- decision-relevant state.

Its CLI intentionally remains small:

```text
init
put
get
find
link
log
verify
context
```

The separation can be summarized like this:

```text
KyberDB:
Can the state survive exactly?

Yoda:
Can the meaning and lineage of that state be reconstructed?
```

Or more simply:

> **Kyber keeps state. Yoda keeps meaning attached to state.**

---

# The architecture

Yoda is not intended to replace scientific tools, agent runtimes, workflow engines, or domain software.

It composes with them.

```text
observations / source data
          │
          ▼
   domain tools and code
          │
          ▼
     derived artifacts
          │
          ├──────────────► exact durable state
          │                    │
          │                    ▼
          │                  KyberDB
          │
          ▼
        Yoda
   evidence + identity
   relations + history
   provenance + context
          │
          ▼
   verifiable context
          │
          ▼
 developer / agent / decision process
```

Yoda does not need to make every decision itself.

A healthier boundary is:

```text
Reality
   ↓
Evidence
   ↓
Yoda
   ↓
Verifiable Context
   ↓
External Decision
   ↓
Decision + Evidence IDs
```

The reasoning or policy layer may change.
The evidence should remain inspectable.

---

# What genomics taught us

Genomics is currently Yoda's primary scientific proving ground and product-discovery lab.

It is not a hard-coded product mode.

We deliberately did **not** add a special Genome Mode, VCF engine, BAM subsystem, or biology-specific storage layer before the experiments demanded one.

Instead, the same core was exposed to progressively stronger questions.

The research ladder became:

```text
GENOME-KMER-001
      ↓
identity and exact reconstruction

GENOME-REFERENCE-001
      ↓
reference state and coordinate equivalence

GENOME-READ-001
      ↓
real paired-read preservation

GENOME-ALIGNMENT-001
      ↓
workflow-native derived state

GENOME-VARIANT-001
      ↓
downstream workflow continuity

GENOME-LINEAGE-001
      ↓
verifiable scientific lineage
```

The important change was not scale.

The object under test changed.

At first the question was:

```text
Can Kyber preserve this state?
```

Later it became:

```text
Can Yoda explain how this state came to exist?
```

---

## A concrete genomic workflow

The controlled validation path used real public genomic data and standard ecosystem tools.

A matched reference and read set were carried through alignment and variant calling:

```text
Reference
GCA_009015325.1

        +

ReadSet
SRR10058842
10,000 paired reads

        ↓

BWA alignment
20,074 canonical alignment records

        ↓

Kyber persist / verify / reopen

        ↓

alignment state reconstructed exactly

        ↓

SAM/BAM rehydration

        ↓

bcftools mpileup / call

        ↓

327 variant records
325 SNPs
2 indels

        ↓

Kyber persist / verify / reopen

        ↓

variant state reconstructed exactly
```

The final variant oracle and the post-reopen Kyber state had the same SHA-256:

```text
7bb54f1c2786ec562e68e8f77c546e6f4da8f6d3a9abd21916cdc8c105b85ff1
```

The key property was not simply VCF persistence.

The alignment consumed by `bcftools` had already been reconstructed from post-reopen Kyber state.

That demonstrated a narrow but important property:

> **Durable reconstructed state can participate in the next real scientific workflow step.**

See:

```text
cases/GENOME-REFERENCE-001-faidx-region-equivalence/
cases/GENOME-READ-001-verifiable-readset-state/
cases/GENOME-ALIGNMENT-001-verifiable-workflow-alignment-state/
cases/GENOME-VARIANT-001-verifiable-variant-state/
```

---

# From scientific state to scientific lineage

The next question was not another file format.

It was:

> Given a result, can Yoda recover the chain that produced it?

A controlled lineage experiment represented:

```text
Variant State
    │
    ├── produced-by ─────► bcftools
    ├── called-against ──► Reference
    ├── has-evidence ────► Variant Evidence
    └── derived-from ────► Alignment State
                              │
                              ├── produced-by ─────► BWA
                              ├── aligned-against ─► Reference
                              ├── has-evidence ────► Alignment Evidence
                              └── derived-from ────► ReadSet
```

Yoda's current `context` contract is intentionally bounded.

It provides lexical retrieval plus direct one-hop relational expansion.
It does **not** claim arbitrary multi-hop graph planning.

The lineage experiment therefore composed two bounded neighborhoods externally:

```text
Variant context
      +
Alignment context
      ↓
Reference → ReadSet → Alignment → Variant
      +
Tools
      +
Evidence
      +
SHA-256 identities
```

This distinction is important.

The knowledge is not hard-coded into a query.
It is represented as durable evidence and explicit relationships, then reconstructed when needed.

---

# What this proves — and what it does not

The current evidence supports a narrow claim:

> Yoda can represent and recover verifiable scientific lineage for a controlled genomic workflow using durable evidence, explicit relations, identities, tools, and independently frozen experimental results.

It does **not** yet prove:

- a general-purpose scientific lineage platform;
- biotech-scale lineage;
- arbitrary multi-project knowledge graphs;
- biological correctness of a variant call;
- replacement of FASTA, BAM, CRAM, VCF, BWA, samtools, bcftools, or HTSlib;
- clinical suitability;
- product-market fit;
- production readiness for every scientific workload.

A successful CASE demonstrates a capability.
It does not magically turn that capability into a market claim.

---

# Why this matters

Scientific and autonomous systems increasingly produce results through chains of software, data, models, tools, transformations, and intermediate state.

The final answer is often easier to store than the explanation of how it was produced.

Yoda is exploring the opposite priority:

```text
result
   ↓
identity
   ↓
provenance
   ↓
relationships
   ↓
history
   ↓
evidence
   ↓
verification
```

The emerging product thesis is:

> **Verifiable Scientific Knowledge**

or, more specifically:

> **Given a result, show its verifiable origin.**

That is the bridge from storage to knowledge.

---

# Cross-domain evidence

Genomics is not the only workload used to test the underlying ideas.

The project has also exercised the same evidence-first discipline against independent public datasets and workloads, including:

- NASA FIRMS satellite observations;
- USGS earthquake events;
- RIPE RIS BGP routing-state mutations;
- LANL authentication-event forensics;
- genomic k-mer state;
- genomic reference state;
- sequencing reads;
- alignment state;
- variant state.

The principle is consistent:

> **Do not change the engine because a feature sounds useful. Change it only when repeated evidence demonstrates a real structural limitation.**

Negative results count as evidence too.

---

# Try Yoda

The current preview is local-first and requires no server, account, Python, Node, JVM, or network connection at runtime.

Download from the current prerelease:

```text
yoda-v0.1.0-preview.1-linux-x86_64.tar.gz
yoda-v0.1.0-preview.1-linux-x86_64.tar.gz.sha256
```

Verify:

```bash
sha256sum -c yoda-v0.1.0-preview.1-linux-x86_64.tar.gz.sha256
```

Extract:

```bash
tar -xzf yoda-v0.1.0-preview.1-linux-x86_64.tar.gz
cd yoda-v0.1.0-preview.1-linux-x86_64
```

Initialize a local store:

```bash
./yoda init ./memory
```

Store evidence:

```bash
printf '%s\n' 'PostgreSQL 16 approved for production' |
    ./yoda -d ./memory put evidence/db-validation \
        source=production-validation
```

Retrieve it:

```bash
./yoda -d ./memory get evidence/db-validation
```

Find related evidence:

```bash
./yoda -d ./memory find production
```

Create an explicit relation:

```bash
./yoda -d ./memory link \
    evidence/new-result \
    derived-from \
    evidence/source-result \
    source=experiment
```

Build bounded context:

```bash
./yoda -d ./memory context production
```

Verify authoritative state:

```bash
./yoda -d ./memory verify
```

Release:

https://github.com/josefaquino/Yoda/releases/tag/v0.1.0-preview.1

---

# Platform

Validated binary:

- GNU/Linux;
- x86_64;
- dynamically linked against glibc.

Source:

- ISO C11;
- POSIX.1-2008.

Validated build flags:

```text
-std=c11
-O2
-Wall
-Wextra
-Werror
-D_POSIX_C_SOURCE=200809L
```

Build from source:

```bash
make
```

---

# Authority model

For Yoda v0.1:

```text
data.yoda
```

is authoritative.

Derived indexes accelerate access but do not define truth.
They must remain rebuildable.

See:

```text
PRODUCT-CONTRACT.md
PROPAGATION-MODEL.md
```

---

# What Yoda is not

Yoda v0.1 is not trying to become:

- a bioinformatics suite;
- a variant caller;
- a workflow orchestrator;
- an agent framework;
- an LLM runtime;
- a vector database;
- a distributed database;
- a cloud service;
- a graph-database product;
- a sandbox;
- an IAM system;
- a replacement for domain tools.

Yoda should stay small enough to compose with those systems.

---

# Product principles

```text
Local first.
Evidence first.
History is preserved.
Derived state is disposable.
Verification is explicit.
Composition over expansion.
Evidence before features.
```

And the engineering rule behind the project remains:

> **Big vision. Small steps. Evidence always.**

---

# Current status

The controlled genomics research ladder has reached its planned technical endpoint:

```text
state
  ↓
workflow
  ↓
derived state
  ↓
lineage
```

That is a technical research milestone, not a claim of commercial maturity.

The next product question is no longer:

> Can we store another scientific format?

It is:

> **What decision becomes possible because Yoda supplied verifiable evidence and lineage?**

---

# License

Yoda v0.1.0-preview.1 is distributed under the Apache License, Version 2.0.

See `LICENSE`.
