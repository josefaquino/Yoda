# Yoda

## Verifiable state for autonomous systems

Autonomous systems act on information that changes over time. Yoda preserves exactly what the software saw, where it came from, when it was observed, and the context that made it valid.

We have demonstrated this with real GitHub software tasks and public SEC EDGAR and CVM financial states, preserving identity, context, time, and provenance across local persistence and materialization.

> **Know what the system saw. Recover it exactly. Prove it.**

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

Nine evidence blocks now define the current research thesis.

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

### 7. YODA-EDGAR-FILING-CONTEXT-001 — Successive Financial State

Question:

> **Can Yoda preserve successive public financial states with their exact reporting context and filing provenance without destroying earlier observed states?**

The workload used public SEC EDGAR + XBRL facts for NVIDIA's `us-gaap:OtherAccruedLiabilitiesCurrent` at the same reporting date (`2022-01-30`) across five distinct filings:

```text
2022-03-18  10-K  accession 0001045810-22-000036  647000000
2022-05-27  10-Q  accession 0001045810-22-000079  515000000
2022-08-31  10-Q  accession 0001045810-22-000147  469000000
2022-11-18  10-Q  accession 0001045810-22-000166  469000000
2023-02-24  10-K  accession 0001045810-23-000017  371000000
```

The final R1 experiment reused the exact context-capable Yoda binary previously validated with real GitHub agent-task context:

```text
PRODUCT_BINARY_SHA256=
8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

YODA_CHANGE=NO
KYBER_CHANGE=NO
CROSS_DOMAIN_BINARY_REUSE=PASS
```

Five source states entered with five unique SEC accession identities and four distinct values. All five identities and contexts survived Frontier, KyberDB and Lakehouse exactly:

```text
FRONTIER_UNIQUE_IDENTITIES=5
KYBER_UNIQUE_IDENTITIES=5
LAKEHOUSE_UNIQUE_IDENTITIES=5

EXPECTED_CONTEXT_SHA256=
e9b8970f469a6a5e904a22d38a71849894789bc0e317f22217f2a234c47273b5

KYBER_CONTEXT_SHA256=
e9b8970f469a6a5e904a22d38a71849894789bc0e317f22217f2a234c47273b5

LAKEHOUSE_CONTEXT_SHA256=
e9b8970f469a6a5e904a22d38a71849894789bc0e317f22217f2a234c47273b5

TOTAL_FAILURES=0
YODA_EDGAR_FILING_CONTEXT_001_R1=PASS
```

A useful edge inside the case is that two filings carried the same observed value (`469000000`) while remaining distinct states because their accession numbers, filing dates and provenance differed:

```text
same value
!=
same state
```

The narrow demonstrated-property statement is:

> **Yoda preserved five successive public financial states with exact reporting context and accession-level filing provenance across Frontier, KyberDB and Lakehouse, without losing earlier observed states and without changing Yoda or Kyber.**

The initial `run-001` is preserved as `NOT_EVALUATED`: a preparation bug bound the accession field to fiscal year and collapsed five source states into two malformed identities. R1 corrected only the input/oracle binding, not the product, and then passed. The failed preparation remains part of the evidence trail.

This case does **not** establish restatement, correction or supersession semantics. It does not claim accounting interpretation, forecasting, trading alpha or investment advice.

See [`cases/YODA-EDGAR-FILING-CONTEXT-001-successive-financial-state/`](cases/YODA-EDGAR-FILING-CONTEXT-001-successive-financial-state/).


### 8. YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001 — Same Value, Distinct Regulatory State

Question:

> **Can Yoda preserve two distinct CVM regulatory presentations of the same accounting values without collapsing one state into the other?**

The source oracle used two real CVM DFP document presentations for the same company and reporting date:

```text
V1  ID_DOC=156154  DT_RECEB=2026-04-11
V2  ID_DOC=156163  DT_RECEB=2026-04-13
```

Within the consolidated balance-sheet scope, all 564 account codes existed in both primary XML documents. No canonical numeric value changed. Eighty-two non-zero accounts changed physical representation while retaining the same canonical value; the remaining 482 exact matches were zero-valued.

The frozen oracle selected ten non-zero accounts, producing 20 document-specific observed states:

```text
SELECTED_ACCOUNTS=10
DOCUMENT_PRESENTATIONS=2
ORACLE_STATES=20
UNIQUE_ORACLE_STATE_IDS=20
```

One example:

```text
Ativo Total

V1 raw        55.373.598
V2 raw        55373598,0000000000
canonical     55373598
```

The exact same frozen context-capable Yoda binary preserved all 20 states:

```text
PRODUCT_BINARY_SHA256=
8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

FRONTIER_FINAL_ROWS=20
FRONTIER_STATE_MATCH=PASS

KYBER_ROWS=20
KYBER_UNIQUE_KEYS=20
KYBER_EXACT_MATCH=PASS

LAKEHOUSE_ROWS=20
LAKEHOUSE_EXACT_MATCH=PASS

CROSS_LAYER_KEY_IDENTITY=PASS

TOTAL_FAILURES=0
PRODUCT_EXECUTION_COUNT=1
PRODUCT_RERUN=NO

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The narrow demonstrated-property statement is:

> **Yoda preserved 20 real public financial states representing two distinct CVM document presentations across Frontier, KyberDB and Lakehouse, with exact identity and context recovery, zero mismatches, and no changes to Yoda or Kyber.**

The useful product observation is:

```text
same canonical value
!=
same observed state
```

This case does not establish correction, restatement, supersession or accounting semantics.

See [`cases/YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001-same-value-distinct-regulatory-state/`](cases/YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001-same-value-distinct-regulatory-state/).

### 9. YODA-CVM-AGENTIC-CONTEXT-001 — Context-Governed Reproducible Evaluation

Question:

> **Can preserved context govern a deterministic operation over preserved state — reproducing a valid calculation and refusing an incompatible one?**

The CASE froze eight real CVM DFP facts, a versioned semantic/metric contract and a deterministic C11 evaluator before Yoda entered the experiment.

The contract required compatible company, period, scope, presentation, currency and scale.

Four scenarios were frozen:

```text
V1 consolidated
→ ALLOW
→ -0.057183

V2 consolidated
→ ALLOW
→ 0.068161

scope mismatch
→ REFUSE
→ INCOMPATIBLE_SCOPE

presentation mismatch
→ REFUSE
→ INCOMPATIBLE_PRESENTATION
```

Yoda Simple Core CORE-014 then preserved 11 evidence objects and 8 explicit relations without a finance-specific engine mode.

The final replay recovered all executable inputs only through Yoda `get`, recompiled the recovered evaluator and reproduced all four original outcomes byte-exactly:

```text
YODA_CVM_AGENTIC_CONTEXT_REPLAY_008_R1=PASS

REPLAY_INPUT_SOURCE=YODA_GET_ONLY
YODA_GET_EXACT_MATCHES=11

STATE_USED_RECOVERABLE=PASS
CONTEXT_USED_RECOVERABLE=PASS
RULE_USED_RECOVERABLE=PASS
EVALUATOR_RECOVERABLE=PASS
RESULT_PRODUCED_RECOVERABLE=PASS

REPLAY_VS_EXPECTED_EXACT_MATCH=PASS
REPLAY_VS_ORIGINAL_EXACT_MATCH=PASS

CONTEXT_GOVERNED_REPRODUCIBLE_EVALUATION=PASS

DATA_YODA_IDENTITY_UNCHANGED=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The narrow demonstrated-property statement is:

> **Yoda preserved the exact observed state, versioned context, operational rule and evaluator required to reproduce two valid calculations and deterministically refuse two incompatible calculations using only Yoda-recovered evidence, without changing Yoda or Kyber.**

Yoda did not interpret accounting, select the metric or become a rules engine. The external deterministic evaluator remained responsible for applying the frozen contract.

See [`cases/YODA-CVM-AGENTIC-CONTEXT-001-context-governed-reproducible-evaluation/`](cases/YODA-CVM-AGENTIC-CONTEXT-001-context-governed-reproducible-evaluation/) and [`properties/CONTEXT-GOVERNED-REPRODUCIBLE-EVALUATION.md`](properties/CONTEXT-GOVERNED-REPRODUCIBLE-EVALUATION.md).

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
SUCCESSIVE STATE PRESERVATION
Can distinct observed states keep exact context and provenance over time?
        ↓
VALUE-INDEPENDENT STATE IDENTITY
Can equal canonical values remain distinct when provenance differs?
        ↓
DECISION LINEAGE
Why did a deterministic system make this decision then,
and can that decision be reproduced from recovered evidence?
        ↓
CONTEXT-GOVERNED REPRODUCIBLE EVALUATION
Can preserved context and rules reproduce both an allowed operation
and the deterministic refusal of incompatible operations?
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

YODA-EDGAR-FILING-CONTEXT-001-R1
→ successive public financial state + exact context + filing provenance

YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001
→ same canonical value + distinct regulatory document state + exact provenance

YODA-CVM-AGENTIC-CONTEXT-001
→ context-governed reproducible evaluation + Yoda-get-only replay
```

Across the financial CASEs, Yoda's existing small surfaces were reused without a finance-specific engine mode. The agentic-context CASE used the frozen Yoda Simple Core CORE-014 and preserved data, context, rule, evaluator and outcomes as ordinary evidence objects and relations.

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
- a trading system;
- an accounting interpretation engine;
- an investment-advice system;
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