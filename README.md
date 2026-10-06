# Yoda

<p align="center">
  <img src="assets/yoda-logo.png" alt="Yoda logo" width="256">
</p>


> **Canonical active repository.** Historical predecessors are preserved for provenance and are no longer the active project surface. See [HISTORY.md](HISTORY.md).

## Canonical repository

```text
ACTIVE_PROJECT=Yoda
HISTORICAL_PREDECESSORS=PRESERVED
```

Start here for the current architecture, research program, evidence, cases and product surface.


## The verifiable derivation layer

**Information behaves less like inventory and more like lineage.**

Yoda is an open-source, local-first system for preserving the evidence, identities, relationships, transformations and history behind important results.

The project now asks two connected questions:

> **Where did this result come from?**
>
> **How did it become what it is now?**

The thesis is:

> **Yoda preserves not only where a result came from, but how it became what it is now.**

Yoda does not need to become the authority that decides whether something is true. It preserves the derivation required for the appropriate authority to inspect or evaluate a result again.

```text
source / observation
       ↓
prior state
       ↓
transformation
       ↓
resulting state
       ↓
evidence + lineage + verification
```

We call this **verifiable derivation**.

---

## Why this matters now

AI is making generation cheaper: more code, hypotheses, proofs, biological designs, experiments and autonomous decisions.

As generation scales, the trust problem shifts.

```text
more generation
      ↓
more artifacts
      ↓
more transformations
      ↓
more state changes
      ↓
more need for provenance, lineage and verification
```

The working hypothesis is:

> **Generation is becoming abundant. Verification, provenance and reproducibility are not.**

A current state is useful. A recoverable explanation of how that state came to exist can be more useful still.

---

## Architecture

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

**Yoda** preserves derivation around state: identity, evidence, relationships, history, transformations and recoverable context.

> **Kyber makes state durable. Yoda makes derivation inspectable.**

A newly demonstrated property fits inside this architecture rather than adding another subsystem:

```text
Lineage of Change
=
derivation integrity across state transitions
```

See [PROJECT-THESIS.md](PROJECT-THESIS.md), [MISSION.md](MISSION.md), [`properties/LINEAGE-OF-CHANGE.md`](properties/LINEAGE-OF-CHANGE.md) and [`properties/DECISION-LINEAGE.md`](properties/DECISION-LINEAGE.md).

---

## Evidence before narrative

Yoda is developed through narrow, falsifiable CASEs.

> **Do not change the engine because a feature sounds useful. Change it only when repeated evidence demonstrates a structural limitation.**

Six evidence blocks now define the current research thesis.

### 1. GENOME-LINEAGE-001 — Lineage of State

Question:

> **Where did this result come from?**

A controlled genomic workflow preserved prior scientific states, tools, evidence and cryptographic identities, then reconstructed the bounded lineage behind the final result.

```text
GENOME-LINEAGE-001=VALIDATED
FULL_GENOMIC_LINEAGE_RECOVERY=PASS
YODA_VERIFY=PASS
PRODUCT_CHANGE=NO
KYBER_CHANGE=NO
```

See [`cases/GENOME-LINEAGE-001-verifiable-scientific-lineage/`](cases/GENOME-LINEAGE-001-verifiable-scientific-lineage/).

### 2. AXIOM-YODA-PROOF-LINEAGE-001 — Independent Authority Replay

Axiom Math's public AXLE infrastructure remained the formal-verification authority.

Yoda recovered proof artifacts byte-exactly. AXLE reproduced both the original positive acceptance and the controlled negative rejection.

```text
AXIOM_YODA_PROOF_LINEAGE_001=VALIDATED
AXLE_POSITIVE_DECISION_REPRODUCED=PASS
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS
PROOF_DERIVATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

> **AXLE verifies the proof. Yoda preserves the derivation required to verify it again.**

See [`cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/`](cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/).

### 3. SYNTHID-BIO-YODA-PROVENANCE-001 — Composed Provenance

Google DeepMind's public SynthID Bio implementation provided an independent intrinsic provenance measurement.

Yoda preserved external workflow provenance around the biological artifacts. After byte-exact recovery, the frozen detector reproduced the same four measurements exactly.

```text
CONTROL      0.5037 → 0.5037
CONTROL      0.5130 → 0.5130
WATERMARKED  0.7961 → 0.7961
WATERMARKED  0.7184 → 0.7184
```

```text
SYNTHID_BIO_YODA_PROVENANCE_001=VALIDATED
COMPOSED_PROVENANCE=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

See [`cases/SYNTHID-BIO-YODA-PROVENANCE-001-composed-provenance/`](cases/SYNTHID-BIO-YODA-PROVENANCE-001-composed-provenance/).

### 4. SYNTHID-BIO-EVOLVING-PROVENANCE-001 — Lineage of Change

Question:

> **How did this become what it is now?**

A controlled transformation created a new artifact identity while Yoda preserved both endpoint states, the derivation between them, the transformation evidence and the state-specific measurements.

```text
Artifact A
SHA256=da6b1b6b239fc3c870f9750f7b29c816f4d700462a160fc8ced7922dbecbfad0
measurement=0.7961

        │
        │ controlled transformation
        ▼

Artifact B
SHA256=defc97981f115f1c1792e53946dcf81f5cce28fafdcccf917c80470fa3cfaa00
measurement=0.6990
```

After byte-exact Yoda recovery, the independent SynthID Bio detector reproduced each state's original measurement:

```text
A  0.7961 → 0.7961
B  0.6990 → 0.6990
```

```text
SYNTHID_BIO_EVOLVING_PROVENANCE_001=VALIDATED
LINEAGE_OF_CHANGE=DEMONSTRATED
INDEPENDENT_AUTHORITY_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The narrow demonstrated-property statement is:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

This is scoped to the validating CASE; it is not a universal guarantee.

See [`cases/SYNTHID-BIO-EVOLVING-PROVENANCE-001-lineage-of-change/`](cases/SYNTHID-BIO-EVOLVING-PROVENANCE-001-lineage-of-change/) and [`properties/LINEAGE-OF-CHANGE.md`](properties/LINEAGE-OF-CHANGE.md).

Google DeepMind did not participate in or endorse either SynthID Bio experiment. Public code and publications were used as independent external authorities.

### 5. FORMAL-MATH-EVOLVING-DERIVATION-001 — Cross-domain Lineage of Change

Question:

> **Does the same Lineage of Change model survive a formal-proof transition under independent formal authorities, without changing Yoda or Kyber?**

A frozen MiniF2F theorem was represented by two different proof states of the same proposition:

```text
Nat.gcd 180 168 = 12
```

Proof A used direct kernel computation. Proof B exposed an explicit Euclidean derivation.

Both proof states passed Lean and were independently VERIFIED by OxiLean before Yoda preservation.

After Yoda preservation, B-R1 recovered the proof states from the frozen Yoda store and reproduced:

```text
LEAN_AUTHORITY_REPLAY=PASS

LEAN4EXPORT_A_IDENTITY_REPRODUCED=PASS
LEAN4EXPORT_B_IDENTITY_REPRODUCED=PASS

OXILEAN_AUTHORITY_REPLAY=PASS

INDEPENDENT_FORMAL_REPLAY=PASS
FORMAL_LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS

DATA_YODA_IDENTITY_UNCHANGED=PASS
```

Final result:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001=VALIDATED
CROSS_DOMAIN_LINEAGE_OF_CHANGE=DEMONSTRATED

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The negative and non-evaluable measurements remain part of the record: A1.0 preserved an OxiLean capability boundary, and the A2-R1 one-shot preserved a harness query-tokenization mismatch rather than silently rerunning either measurement.

This strengthens the cross-domain evidence for Lineage of Change, but does not establish universal generality.

See [`cases/FORMAL-MATH-EVOLVING-DERIVATION-001-cross-domain-lineage-of-change/`](cases/FORMAL-MATH-EVOLVING-DERIVATION-001-cross-domain-lineage-of-change/).

### 6. MARKET-REGIME-LINEAGE-001 — Decision Lineage

Question:

> **Can Yoda preserve successive deterministic decision states and the evidence behind them such that independent implementations reproduce the original decisions after recovery?**

A controlled public-data workflow froze three point-in-time market-observation states before classification.

Two independent deterministic authorities — C11 and POSIX awk — agreed byte-for-byte on:

```text
A  2025-04-25  STRESSED
B  2025-08-29  FRAGILE
C  2025-12-26  FRAGILE
```

Yoda then preserved 18 objects and 31 explicit relations covering source snapshots, decision states, the classification contract, authority implementations, original evaluation evidence and transition evidence.

The lineage captured two distinct kinds of change:

```text
A -> B
STRESSED -> FRAGILE
classification_changed=YES

B -> C
FRAGILE -> FRAGILE
classification_changed=NO
underlying_evidence_changed=YES
```

Stage B recovered the snapshots, C11 source, awk source and original evaluations **only from Yoda**, recompiled/replayed both authorities and reproduced the original canonical bytes exactly:

```text
MARKET_REGIME_LINEAGE_001=VALIDATED
DECISION_LINEAGE=DEMONSTRATED
INDEPENDENT_CLASSIFICATION_REPLAY=PASS

REPLAY_INPUT_SOURCE=YODA_GET_ONLY
DATA_YODA_IDENTITY_UNCHANGED=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The narrow demonstrated-property statement is:

> **Yoda preserved not only a deterministic decision, but the evidence required to reconstruct why that decision existed at that point in time — including a later state where the label stayed the same while the supporting evidence changed.**

This is an infrastructure and reproducibility result. It is not a market forecast, trading strategy, investment recommendation or claim about the true market regime.

See [`cases/MARKET-REGIME-LINEAGE-001-decision-lineage/`](cases/MARKET-REGIME-LINEAGE-001-decision-lineage/).

---

## What the combined evidence suggests

The evidence ladder now looks like this:

```text
LINEAGE OF STATE
Where did this result come from?
        ↓
INDEPENDENT AUTHORITY REPLAY
Can the right authority evaluate it again?
        ↓
COMPOSED PROVENANCE
Can independent forms of provenance coexist?
        ↓
LINEAGE OF CHANGE
How did this become what it is now?
        ↓
DECISION LINEAGE
Why did a deterministic system make this decision then,
and can that decision be reproduced from recovered evidence?
```

The same small Yoda surface survived these settings without a Genome Mode, Math Mode, SynthID Mode or Change Mode.

This strengthens — but does not prove — the hypothesis that **verifiable derivation may be a cross-domain infrastructure property**.

The emerging category thesis is:

> **Verifiable Derivation Infrastructure**

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

For Yoda v0.1, `data.yoda` is authoritative.

Derived indexes accelerate access but do not define truth. They remain rebuildable.

See [PRODUCT-CONTRACT.md](PRODUCT-CONTRACT.md).

---

## Current research program

Validated:

```text
GENOME-LINEAGE-001
→ scientific lineage

AXIOM-YODA-PROOF-LINEAGE-001
→ independent formal decision replay

SYNTHID-BIO-YODA-PROVENANCE-001
→ composed provenance + measurement replay

SYNTHID-BIO-EVOLVING-PROVENANCE-001
→ Lineage of Change + state-specific replay

FORMAL-MATH-EVOLVING-DERIVATION-001
→ cross-domain Lineage of Change + independent Lean/OxiLean replay

MARKET-REGIME-LINEAGE-001
→ Decision Lineage + independent replay from Yoda-recovered decision evidence
```

The next strong falsification should be externally defined rather than another internal demonstration.

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

Yoda also does not claim that every transformation is legitimate simply because its derivation was preserved.

The goal is composition, not absorption.

---

## Principles

```text
Local first.
Evidence first.
History is preserved.
Change evidence is first-class.
Derived state is disposable.
Verification is explicit.
Composition over expansion.
Independent authorities stay independent.
Evidence before features.
```

> **Big vision. Small steps. Evidence always.**

---

## Collaborate

We are looking for researchers, engineers, scientific teams and early partners who have a result whose origin or evolution matters.

Good collaboration candidates include workflows where it is important to reconstruct:

- which data produced a result;
- what existed before the current state;
- which transformation created the new state;
- which tools and versions were involved;
- which evidence belongs to each state;
- which later decisions depended on it;
- whether the derivation can be independently replayed or checked.

The project is early. The claims are intentionally narrow. The ambition is not.

---

## Further reading

- [HISTORY.md](HISTORY.md)
- [REPOSITORY-POLICY.md](REPOSITORY-POLICY.md)
- [PROJECT-THESIS.md](PROJECT-THESIS.md)
- [ONE-PAGER.md](ONE-PAGER.md)
- [MISSION.md](MISSION.md)
- [GENESIS.md](GENESIS.md)
- [WHY-NOW.md](WHY-NOW.md)
- [EVIDENCE.md](EVIDENCE.md)
- [RESEARCH.md](RESEARCH.md)
- [PRODUCT-CONTRACT.md](PRODUCT-CONTRACT.md)
- [`properties/LINEAGE-OF-CHANGE.md`](properties/LINEAGE-OF-CHANGE.md)
- [`properties/DECISION-LINEAGE.md`](properties/DECISION-LINEAGE.md)
- [`cases/`](cases/)

---

## License

Apache License 2.0. See [LICENSE](LICENSE).