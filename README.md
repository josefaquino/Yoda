# Yoda

## The verifiable derivation layer

**Information behaves less like inventory and more like lineage.**

Yoda is an open-source, local-first system for preserving the evidence, identities, relationships and history behind important results.

Its core question is simple:

> **Where did this result come from?**

The thesis that now guides the project is:

> **Yoda does not need to be the authority that decides whether something is true. Yoda preserves the derivation required for independent authorities to decide again.**

Most systems are optimized to produce or store the final artifact.
Yoda is built to preserve the chain behind it.

```text
source / observation
       ↓
artifact
       ↓
transformation
       ↓
result
       ↓
evidence + lineage + verification
```

We call this **verifiable derivation**.

---

## Why this matters now

AI is making generation cheaper: more code, more hypotheses, more proofs, more biological designs, more experiments and more autonomous decisions.

As generation scales, the trust problem shifts.

```text
more generation
      ↓
more artifacts
      ↓
more transformations
      ↓
more results
      ↓
more need for provenance, lineage and verification
```

The working hypothesis is:

> **Generation is becoming abundant. Verification, provenance and reproducibility are not.**

Yoda is exploring the trust layer between a result and its origin.

---

## The architecture

The project began with one idea:

> **The Internet is a living organism. Data is born, changes, forms relationships, conflicts, ages, and is replaced.**

That evolved into a broader thesis:

> **Information behaves less like inventory and more like lineage.**

The architecture emerged one question at a time:

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
Independent Authorities / Humans / Agents
EVALUATION + DECISION
```

**Sputnik** observes changing data.

**Kyber** preserves exact local state.

**Yoda** reconstructs lineage, evidence and derivation.

> **Kyber makes state durable. Yoda makes derivation inspectable.**

Read [GENESIS.md](GENESIS.md) and [MISSION.md](MISSION.md).

---

## Independent Authority Replay

Two recent CASEs exposed the same architectural pattern:

```text
independent authority
        ↓
measurement / decision
        ↓
       Yoda
        ↓
exact recovery + lineage
        ↓
same independent authority
        ↓
same measurement / decision
```

We use **independent authority replay** as an internal name for this pattern.

It does not mean Yoda becomes a theorem prover, scientific oracle or watermark detector.

It means the authority remains external while Yoda preserves the derivation needed to evaluate the result again.

---

## Evidence before narrative

Yoda is developed through narrow, falsifiable CASEs.

The rule is:

> **Do not change the engine because a feature sounds useful. Change it only when repeated evidence demonstrates a structural limitation.**

The project has been tested against independent real-world workloads including satellite observations, earthquake events, Internet routing mutations, security events, genomic workflows, formal proof verification and biological artifact provenance.

Three evidence blocks now define the current research thesis.

### 1. GENOME-LINEAGE-001 — scientific lineage

A controlled public-data workflow progressed through:

```text
Reference + ReadSet
       ↓
      BWA
       ↓
   Alignment
       ↓
   bcftools
       ↓
 Variant State
       ↓
      Yoda
       ↓
reconstructed scientific lineage
```

Yoda recovered the lineage behind the final result, including prior scientific states, tools, evidence and cryptographic identities.

```text
GENOME-LINEAGE-001=VALIDATED
FULL_GENOMIC_LINEAGE_RECOVERY=PASS
YODA_VERIFY=PASS
PRODUCT_CHANGE=NO
KYBER_CHANGE=NO
```

Narrow claim:

> **Verifiable scientific lineage was demonstrated for one controlled genomic workflow.**

See [`cases/GENOME-LINEAGE-001-verifiable-scientific-lineage/`](cases/GENOME-LINEAGE-001-verifiable-scientific-lineage/).

---

### 2. AXIOM-YODA-PROOF-LINEAGE-001 — formal authority replay

Axiom Math's public AXLE infrastructure remained the formal-verification authority.

Yoda preserved the formal statement, proof artifacts, selected environment, verification evidence and lineage.

The positive proof was accepted by AXLE before Yoda and accepted again after byte-exact recovery from Yoda.

The negative candidate was valid Lean proving a different theorem. AXLE rejected it before Yoda and rejected it again after recovery for the same semantic reason.

```text
AXIOM_YODA_PROOF_LINEAGE_001=VALIDATED
YODA_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
AXLE_POSITIVE_DECISION_REPRODUCED=PASS
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS
PROOF_DERIVATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Authority separation:

```text
AXLE
→ formal validity

Yoda
→ derivation integrity
```

> **AXLE verifies the proof. Yoda preserves the derivation required to verify it again.**

See [`cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/`](cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/).

---

### 3. SYNTHID-BIO-YODA-PROVENANCE-001 — composed provenance

Google DeepMind's public SynthID Bio implementation gave us a different external authority model: a provenance signal carried inside a biological artifact and measured by the official detector.

Stage A0 reproduced the official detector behavior before Yoda entered the experiment.

Stage A1 stored the control and watermarked biological artifacts, measurements, detector identity, parameters and evidence in Yoda, then recovered the artifacts byte-for-byte.

Stage B submitted only the Yoda-recovered artifacts back to the frozen SynthID Bio detector.

The same four measurements were reproduced exactly:

```text
CONTROL      0.5037 → 0.5037
CONTROL      0.5130 → 0.5130
WATERMARKED  0.7961 → 0.7961
WATERMARKED  0.7184 → 0.7184
```

```text
SYNTHID_BIO_YODA_PROVENANCE_001=VALIDATED
CONTROL_DETECTOR_EQUIVALENCE=PASS
WATERMARKED_DETECTOR_EQUIVALENCE=PASS
G_VALUE_MATRIX_EQUIVALENCE=PASS
INTRINSIC_PROVENANCE_MEASUREMENT_EQUIVALENCE=PASS
EXTERNAL_WORKFLOW_PROVENANCE_RECOVERY=PASS
COMPOSED_PROVENANCE=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Authority separation:

```text
SynthID Bio
→ intrinsic provenance measurement

Yoda
→ external derivation integrity
```

This demonstrates **composed provenance** in one controlled workflow:

```text
inside the artifact
→ intrinsic provenance signal
→ SynthID Bio

outside the artifact
→ workflow provenance / derivation
→ Yoda
```

Narrow claim:

> **For one controlled SynthID Bio workflow, Yoda preserved external workflow provenance and recovered the biological artifacts byte-exactly, while the independent SynthID Bio detector reproduced the same intrinsic provenance measurements after recovery.**

Google DeepMind did not participate in or endorse this experiment. The CASE uses public code and tests as an independent external authority.

See [`cases/SYNTHID-BIO-YODA-PROVENANCE-001-composed-provenance/`](cases/SYNTHID-BIO-YODA-PROVENANCE-001-composed-provenance/).

---

## What the combined evidence suggests

The same small Yoda architecture has now survived three qualitatively different settings:

```text
GENOME-LINEAGE
→ empirical scientific lineage

AXLE
→ independent formal decision replay

SynthID Bio
→ independent provenance measurement replay
  + composed provenance
```

No Genome Mode was required.
No Math Mode was required.
No SynthID Mode was required.
No Yoda or Kyber engine change was required for the AXLE or SynthID Bio CASEs.

This strengthens — but does not prove — the hypothesis that **verifiable derivation may be a cross-domain infrastructure property**.

The emerging category thesis is:

> **Verifiable Derivation Infrastructure**

A possible market-facing description is:

> **Trust infrastructure for AI-native science.**

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

The design principle is **composition over expansion**: Yoda should preserve derivation around domain tools rather than absorb them.

---

## Authority model

For Yoda v0.1:

```text
data.yoda
```

is authoritative.

Derived indexes accelerate access but do not define truth. They remain rebuildable.

See [PRODUCT-CONTRACT.md](PRODUCT-CONTRACT.md).

---

## Current research program

### Track A — formal reasoning

`AXIOM-YODA-PROOF-LINEAGE-001` — **VALIDATED**

### Track B — artifact provenance

`SYNTHID-BIO-YODA-PROVENANCE-001` — **VALIDATED**

### Track C — external empirical biology

`BIO-DESIGN-LINEAGE-001` — **NEXT**

The next adversary should be a real biological R&D question selected by an external scientific team.

```text
Design → Build → Test → Learn → Candidate
                         ↑
                  verifiable derivation
```

The next CASE should be defined by the partner's problem before Yoda code or schema is added.

See [RESEARCH.md](RESEARCH.md).

---

## What Yoda is not

Yoda is not currently claiming to be:

- a scientific truth oracle;
- a theorem prover;
- a watermark detector;
- a proof-of-origin system;
- a bioinformatics suite;
- a workflow orchestrator;
- an agent framework;
- an LLM runtime;
- a vector database;
- a distributed database;
- a cloud platform;
- a replacement for independent domain authorities.

The goal is composition, not absorption.

> **Preserve the derivation behind an important result so the right authority can inspect and evaluate it again.**

---

## Principles

```text
Local first.
Evidence first.
History is preserved.
Derived state is disposable.
Verification is explicit.
Composition over expansion.
Independent authorities stay independent.
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

- [ONE-PAGER.md](ONE-PAGER.md)
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