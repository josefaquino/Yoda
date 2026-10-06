# Decision Lineage

**Status:** DEMONSTRATED  
**Property class:** Architectural research property  
**Evidence authority:** `MARKET-REGIME-LINEAGE-001`  
**Scope:** Demonstrated in one controlled deterministic public-data decision workflow with independent dual-authority replay from Yoda-recovered artifacts

---

## 1. Purpose

This document formalizes **Decision Lineage** as a property observed in Yoda without turning the validating market-data workflow into the product definition.

The property is not about trading, market prediction or financial advice.

The experimental question was:

> **Can Yoda preserve successive deterministic decision states and the evidence behind them such that independent implementations reproduce the original decisions after recovery?**

Within the scope of `MARKET-REGIME-LINEAGE-001`, the observed answer was yes.

---

## 2. Architectural placement

Decision Lineage is not a new Yoda subsystem and does not introduce a market-specific engine mode.

Conceptually:

```text
Observation
    ↓
State
    ↓
Deterministic evaluation
    ↓
Decision
    ↓
New observation
    ↓
New state
    ↓
Same evaluation contract
    ↓
Later decision
```

Yoda's role is to preserve enough derivation to answer:

```text
what data was available?
which contract was applied?
which authority implementation evaluated it?
which decision resulted?
what changed between decisions?
what stayed the same?
can the decision be replayed later from recovered evidence?
```

---

## 3. Formal model

Let:

```text
S_t = source state available at evaluation time t
C   = frozen deterministic classification contract
A   = independent implementation of C
D_t = deterministic decision produced from S_t under C
E_t = evaluation evidence for D_t
```

Decision Lineage is preserved when the evidence system can recover:

```text
S_t
C
A
D_t
E_t
```

and the relations among successive decision states.

For two times `t1 < t2`:

```text
D_t2 --supersedes--> D_t1
D_t1 --derived-from--> S_t1
D_t2 --derived-from--> S_t2
D_t1 --classified-by--> C
D_t2 --classified-by--> C
```

The property does not require that:

```text
D_t1 != D_t2
```

A later decision may remain identical while the underlying evidence changes.

That distinction is part of the demonstrated property.

---

## 4. Required sub-properties

### 4.1 Source-state preservation

The source state used for each decision remains independently recoverable.

```text
recover(S_t) = S_t
identity(recover(S_t)) = identity(S_t)
```

### 4.2 Decision-state preservation

The deterministic decision state remains recoverable with its original evaluation date, score, features and label.

### 4.3 Contract preservation

The exact deterministic contract that maps source state to decision remains recoverable.

### 4.4 Authority preservation

The independent implementation artifacts used to evaluate the contract remain recoverable.

### 4.5 Evaluation-evidence preservation

Original authority outputs remain recoverable separately from the decision-state objects.

### 4.6 Successive-decision preservation

The relationship between later and earlier decisions remains recoverable.

```text
D_t2 --supersedes--> D_t1
```

### 4.7 Transition-evidence preservation

Evidence describing what changed between successive decision states remains recoverable separately from the endpoint decisions.

### 4.8 Stable-label / changed-evidence distinction

The evidence model must preserve the case where:

```text
label(D_t1) = label(D_t2)
```

while:

```text
identity(S_t1) != identity(S_t2)
```

This prevents a stable label from collapsing distinct underlying decision contexts.

---

## 5. Independent replay condition

The validating CASE added a stronger condition.

After Yoda preservation, the replay stage recovered from Yoda only:

```text
source snapshots
classification contract
Authority 1 source
Authority 2 source
original Authority 1 output
original Authority 2 output
original canonical output
```

The two recovered authorities then independently replayed all three states.

The required relation was:

```text
Replay_A1
=
Replay_A2
=
Original_A1
=
Original_A2
=
Original_Canonical
```

The CASE demonstrated this byte-for-byte.

Independent replay strengthens the evidence for Decision Lineage because Yoda did not merely preserve descriptive labels; it preserved enough information for the original deterministic decisions to be recomputed.

---

## 6. Demonstrated instance

Evidence authority:

```text
CASE=MARKET-REGIME-LINEAGE-001
STATUS=VALIDATED
DECISION_LINEAGE=DEMONSTRATED
```

Frozen observed sequence:

```text
A
evaluation_date=2025-04-25
score=2
classification=STRESSED

B
evaluation_date=2025-08-29
score=1
classification=FRAGILE

C
evaluation_date=2025-12-26
score=1
classification=FRAGILE
```

Observed transitions:

```text
A -> B
STRESSED -> FRAGILE
CLASSIFICATION_CHANGED=YES

B -> C
FRAGILE -> FRAGILE
CLASSIFICATION_CHANGED=NO
UNDERLYING_EVIDENCE_CHANGED=YES
```

Yoda preserved:

```text
OBJECT_COUNT=18
LINK_COUNT=31

BYTE_EXACT_RECOVERY=PASS
DECISION_LINEAGE_RELATION_RECOVERY=PASS
DECISION_LINEAGE_SEMANTICS=PASS
FINAL_YODA_VERIFY=PASS
```

Independent replay from Yoda-recovered artifacts demonstrated:

```text
REPLAY_INPUT_SOURCE=YODA_GET_ONLY

REPLAY_AUTHORITY_1=PASS
REPLAY_AUTHORITY_2=PASS

REPLAY_AUTHORITY_EQUIVALENCE=PASS
REPLAY_VS_ORIGINAL_CANONICAL=PASS

STATE_A_INDEPENDENT_REPLAY=PASS
STATE_B_INDEPENDENT_REPLAY=PASS
STATE_C_INDEPENDENT_REPLAY=PASS

INDEPENDENT_CLASSIFICATION_REPLAY=PASS
```

Canonical evaluation identity:

```text
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba
```

The frozen Yoda state remained unchanged through replay:

```text
DATA_YODA_SHA256_BEFORE=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_SHA256_AFTER=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_IDENTITY_UNCHANGED=PASS
```

---

## 7. Relationship to Lineage of Change

Lineage of Change asks:

> **How did this state become what it is now?**

Decision Lineage asks:

> **Why did a deterministic system make this decision at that point in time, and can that decision be reproduced later from the preserved evidence?**

They are related but not identical.

Lineage of Change centers on state transition and transformation evidence.

Decision Lineage centers on:

```text
source state
+
decision contract
+
decision state
+
evaluation evidence
+
successive decision relationships
+
independent decision replay
```

Decision Lineage therefore extends the verifiable-derivation thesis from artifact evolution to deterministic evaluation history.

---

## 8. Invariants observed in the CASE

### Decision is not source state

The same decision label can arise from different source-state evidence.

### Stable output is not stable evidence

```text
B=FRAGILE
C=FRAGILE
```

did not imply identical supporting data.

### Contract identity matters

Reproducibility requires preservation of the exact deterministic decision contract, not merely the resulting label.

### Authority remains independent

Yoda preserved the authority implementations and their results; it did not become the classifier.

### Replay must be evidence-driven

The strongest validating replay did not read local A0 or A1 source files as replay input.

It recovered the required artifacts from the frozen Yoda store.

### History is part of decision meaning

A current label alone is weaker than recovering:

```text
prior source state
prior decision
new source state
later decision
contract
authority evidence
transition record
decision relationship
```

---

## 9. Claim boundary

The demonstrated property supports this narrow statement:

> **For one controlled deterministic public-data market-regime workflow, Yoda preserved successive evaluation states, their point-in-time public-data inputs, classification contract, transition history and evidence such that two independent implementations reproduced each original classification after recovery.**

A concise interpretation is:

> **Yoda preserved not only the classification, but why the deterministic system produced that classification at that point in time.**

The CASE does not establish that Yoda:

- predicts financial markets;
- generates alpha;
- recommends investments;
- identifies a true market regime;
- proves that the classifier is economically correct;
- proves arbitrary decision systems correct;
- guarantees Decision Lineage across all domains;
- replaces domain authorities;
- validates causal claims merely because decision history was preserved.

---

## 10. Falsification and extension

Decision Lineage should be narrowed or revised if future evidence shows that:

- source states cannot remain recoverable as decision history grows;
- decision-to-source relationships become ambiguous;
- stable labels incorrectly collapse distinct underlying evidence states;
- deterministic contracts cannot be preserved without domain-specific engine changes;
- authority implementations cannot be recovered and replayed;
- replay requires hidden dependencies outside the preserved derivation;
- Yoda mutation is required merely to represent a new decision domain;
- longer decision chains make relation recovery ambiguous or impractical.

Stronger evidence would come from qualitatively different deterministic decision domains using independently defined rules or external authorities, again without changing the Yoda core.

---

## 11. Property record

```text
PROPERTY=DECISION_LINEAGE
STATUS=DEMONSTRATED

DEFINITION=
VERIFIABLE_DERIVATION_OF_SUCCESSIVE_DETERMINISTIC_DECISIONS

EVIDENCE_CASE=MARKET-REGIME-LINEAGE-001
EVIDENCE_CASE_STATUS=VALIDATED

SOURCE_STATE_RECOVERY=PASS
DECISION_STATE_RECOVERY=PASS
CLASSIFICATION_CONTRACT_RECOVERY=PASS
AUTHORITY_SOURCE_RECOVERY=PASS
EVALUATION_EVIDENCE_RECOVERY=PASS
SUCCESSIVE_DECISION_RELATION_RECOVERY=PASS
TRANSITION_EVIDENCE_RECOVERY=PASS
STABLE_LABEL_CHANGED_EVIDENCE_RECOVERY=PASS
INDEPENDENT_CLASSIFICATION_REPLAY=PASS
DATA_YODA_IDENTITY_UNCHANGED=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO

UNIVERSAL_GENERALITY=NOT_ESTABLISHED
PRODUCTION_SCALE=NOT_ESTABLISHED
```
