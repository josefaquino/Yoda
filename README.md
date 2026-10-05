# Yoda

## The verifiable derivation layer

**Information behaves less like inventory and more like lineage.**

Yoda is an open-source, local-first system for preserving the evidence, identities, relationships and history behind important results.

Its core question is simple:

> **Where did this result come from?**

Most systems are optimized to produce or store the final artifact.
Yoda is built to preserve the chain behind it.

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

Yoda does **not** claim that a scientific result is biologically, mathematically or operationally true.

It aims to make something narrower — and increasingly important — independently inspectable:

> **Which verifiable chain produced what we are looking at?**

---

## The mission

AI is making generation cheaper: more code, more hypotheses, more proofs, more biological designs, more experiments and more autonomous decisions.

As generation scales, provenance and verification become harder.

Yoda is exploring the infrastructure needed on the other side of that transition:

```text
more generation
      ↓
more artifacts
      ↓
more transformations
      ↓
more results
      ↓
more need for lineage, evidence and verification
```

We are building toward a world in which an important result does not have to be accepted on trust alone.

It should be possible to ask:

```text
What is this?
Where did it come from?
What produced it?
What came before it?
What changed?
What evidence supports it?
Can the chain be reconstructed later?
```

Read [MISSION.md](MISSION.md).

---

## Genesis

The project began with one idea:

> **The Internet is a living organism. Data is born, changes, forms relationships, conflicts, ages, and is replaced.**

That idea evolved into a broader thesis:

> **Information behaves less like inventory and more like lineage.**

The architecture emerged one question at a time:

```text
Sputnik observes the living world of data.
Kyber preserves its state.
Yoda reconstructs its lineage.
Agents decide from the evidence that survives.
```

Or:

```text
Sputnik
OBSERVATION
    ↓
Kyber
STATE
    ↓
Yoda
DERIVATION
    ↓
Agents / Humans
DECISION
```

Read [GENESIS.md](GENESIS.md).

---

## Yoda and KyberDB

Yoda and KyberDB solve different problems.

### KyberDB — state integrity

KyberDB is the embedded C11 state engine and storage research substrate.

Its questions are:

> Can this state survive commit, close and reopen exactly?

> Can it be verified?

> Can corruption be detected?

> Can post-reopen state be compared against an independent oracle?

KyberDB focuses on exact local state, durability, verification and reconstruction.

### Yoda — derivation integrity

Yoda is the user-facing evidence and lineage layer.

Its questions are:

> Where did this result come from?

> Which artifacts, tools, transformations and evidence produced it?

> Can that context be recovered later?

Yoda focuses on:

- evidence;
- identity;
- provenance;
- relationships;
- history;
- bounded context;
- verification;
- decision-relevant state.

The distinction is deliberate:

```text
KyberDB:
Can the state survive exactly?

Yoda:
Can the derivation of that state be reconstructed?
```

> **Kyber makes state durable. Yoda makes derivation inspectable.**

---

## A useful contrast

One internal mental model is:

```text
Axiom:
Can the reasoning be proved?

Yoda:
Can the derivation be proved?
```

This is a conceptual contrast, not an official Axiom slogan.

Formal systems such as Lean can verify whether a proof satisfies a formal statement.
Yoda is exploring a complementary problem: preserving the lineage around results and artifacts that move through real software and scientific workflows.

```text
formal world                    empirical / software world

premises                        observation
   ↓                               ↓
reasoning                       artifact
   ↓                               ↓
proof                           transformation
   ↓                               ↓
formal verification             result
                                   ↓
                                lineage
```

Current research direction: test whether those two properties can compose.

See [RESEARCH.md](RESEARCH.md).

---

## Why now

Three trends are colliding:

### 1. Agent systems are scaling generation

Parallel agents can increase the rate at which hypotheses, code, candidate solutions and research paths are explored.

### 2. Provenance is becoming infrastructure

Google DeepMind's SynthID Bio is an example of provenance moving into AI-generated biological artifacts themselves.

### 3. Validation may become the bottleneck

As AI produces more scientific outputs, the scarce resource may shift from generating candidates to validating, tracing and reproducing them.

Yoda is not an agent orchestrator, watermarking system or scientific truth machine.

It is exploring the layer that can connect these worlds:

```text
artifact identity
      +
workflow lineage
      +
evidence
      +
history
      +
verification
```

Read [WHY-NOW.md](WHY-NOW.md).

---

## Evidence before narrative

Yoda is developed through small falsifiable CASEs.

The rule is:

> **Do not change the engine because a feature sounds useful. Change it only when repeated evidence demonstrates a structural limitation.**

The project has been tested against independent real-world workloads including:

- NASA FIRMS satellite observations;
- USGS earthquake events;
- RIPE RIS BGP routing mutations;
- LANL authentication events;
- NCBI / ENA genomic data;
- BWA alignment workflows;
- bcftools variant calling.

The genomics ladder progressively changed the object under test:

```text
GENOME-KMER-001
identity and exact reconstruction
      ↓
GENOME-REFERENCE-001
reference-state equivalence
      ↓
GENOME-READ-001
real read-set preservation
      ↓
GENOME-ALIGNMENT-001
workflow-derived state
      ↓
GENOME-VARIANT-001
workflow continuity
      ↓
GENOME-LINEAGE-001
verifiable scientific lineage
```

The strongest current controlled result is not "we stored VCF".

It is that Yoda recovered a scientific lineage connecting:

```text
Reference
   +
ReadSet
   ↓
Alignment
   ↓
Variant State
```

with explicit relationships to tools, evidence and cryptographic identities.

See [EVIDENCE.md](EVIDENCE.md) and [`cases/`](cases/).

---

## What the genomics work demonstrated

In a controlled public-data workflow:

```text
Reference GCA_009015325.1
        +
ReadSet SRR10058842
        ↓
BWA
        ↓
20,074 alignment records
        ↓
Kyber persist / verify / reopen
        ↓
rehydrated alignment state
        ↓
bcftools
        ↓
327 variant records
        ↓
Kyber persist / verify / reopen
        ↓
byte-exact reconstructed variant state
```

Then Yoda represented and recovered lineage around that result:

```text
Variant
  ├── produced-by ─────► bcftools
  ├── called-against ──► Reference
  ├── has-evidence ────► Variant Evidence
  └── derived-from ────► Alignment
                            ├── produced-by ─────► BWA
                            ├── aligned-against ─► Reference
                            ├── has-evidence ────► Alignment Evidence
                            └── derived-from ────► ReadSet
```

This supports a narrow claim:

> **Verifiable scientific lineage has been demonstrated for one controlled genomic workflow.**

It does not establish biological truth, clinical validity, biotech-scale operation or product-market fit.

---

## Current research program

The next phase deliberately leaves the comfort of our own datasets.

### AXIOM-YODA-PROOF-LINEAGE-001

Use public AXLE proof-verification infrastructure to test whether Yoda can preserve and reconstruct the lineage of a formally verified proof such that recovered artifacts can be verified again.

Goal:

```text
Proof of Derivation
        +
Proof Verification
```

### BIO-DESIGN-LINEAGE-001

Work with a real biological R&D workflow to test whether a final candidate can be traced back through design, build, test, analysis and evidence without inventing biology-specific storage features.

Goal:

```text
Design → Build → Test → Learn → Candidate
                         ↑
                  verifiable lineage
```

### Future direction: artifact provenance + workflow provenance

Systems such as SynthID Bio suggest that provenance can travel *inside* an AI-generated artifact.
Yoda is exploring provenance *across* the workflow around that artifact.

The long-term question is whether both can compose.

---

## Product surface

Yoda intentionally exposes a small CLI:

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

No server is required.
No account is required.
The current preview is local-first.

### Quick start

```bash
./yoda init ./memory

printf '%s\n' 'experiment result' |
  ./yoda -d ./memory put evidence/result \
    source=experiment-001

./yoda -d ./memory link \
  evidence/result \
  derived-from \
  evidence/source \
  source=experiment-001

./yoda -d ./memory context result
./yoda -d ./memory verify
```

Current preview:

https://github.com/josefaquino/Yoda/releases/tag/v0.1.0-preview.1

---

## Authority model

For Yoda v0.1:

```text
data.yoda
```

is authoritative.

Derived indexes accelerate access but do not define truth.
They remain rebuildable.

See [PRODUCT-CONTRACT.md](PRODUCT-CONTRACT.md).

---

## What Yoda is not

Yoda is not currently claiming to be:

- a scientific truth oracle;
- a theorem prover;
- a bioinformatics suite;
- a workflow orchestrator;
- an agent framework;
- an LLM runtime;
- a vector database;
- a distributed database;
- a cloud platform;
- a replacement for domain tools.

The goal is composition, not absorption.

---

## Principles

```text
Local first.
Evidence first.
History is preserved.
Derived state is disposable.
Verification is explicit.
Composition over expansion.
Evidence before features.
```

> **Big vision. Small steps. Evidence always.**

---

## Collaborate

We are looking for researchers, engineers, scientific teams and early partners who have a result whose origin matters.

Good collaboration candidates include workflows where it is important to reconstruct:

- which data produced a result;
- which tools and versions transformed it;
- which evidence justified a decision;
- what changed over time;
- whether the derivation can be independently replayed or checked.

We are also interested in conversations with investors who believe that as AI makes generation abundant, **verification, provenance and reproducibility become infrastructure**.

The project is early. The claims are intentionally narrow. The ambition is not.

---

## Further reading

- [MISSION.md](MISSION.md)
- [GENESIS.md](GENESIS.md)
- [WHY-NOW.md](WHY-NOW.md)
- [EVIDENCE.md](EVIDENCE.md)
- [RESEARCH.md](RESEARCH.md)
- [PRODUCT-CONTRACT.md](PRODUCT-CONTRACT.md)
- [PROPAGATION-MODEL.md](PROPAGATION-MODEL.md)
- [`cases/`](cases/)

---

## License

Apache License 2.0. See [LICENSE](LICENSE).
