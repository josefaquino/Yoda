# Lineage of Change

**Status:** DEMONSTRATED  
**Property class:** Architectural research property  
**Evidence authorities:** `SYNTHID-BIO-EVOLVING-PROVENANCE-001`, `FORMAL-MATH-EVOLVING-DERIVATION-001`  
**Scope:** Demonstrated in one controlled biological-artifact transition and one formal-proof transition, each with independent authority replay

---

## 1. Purpose

This document formalizes **Lineage of Change** as a property observed in Yoda without turning the experimental domain into the product definition.

The property is not about proteins, watermarking or SynthID Bio.

Those were the experimental environment used to create a falsifiable state transition with an independent measurement authority.

The general question is:

> **Can a legitimate change create a new identity without destroying the verifiable lineage of what came before?**

Within the scope of `SYNTHID-BIO-EVOLVING-PROVENANCE-001`, the observed answer was yes.

A second CASE, `FORMAL-MATH-EVOLVING-DERIVATION-001`, later reproduced the same architectural property in formal mathematics without changing Yoda or Kyber.

---

## 2. Architectural placement

Lineage of Change is **not** a new Yoda subsystem and does not introduce a new engine mode.

The architectural relationship is:

```text
Kyber
=
durable state integrity

Yoda
=
derivation integrity

Lineage of Change
=
derivation integrity across state transitions
```

The demonstrated property emerged from the existing Yoda primitives:

```text
identity
+
evidence
+
relations
+
history
+
verification
+
bounded context
```

No Yoda or Kyber change was required for the validating CASE.

---

## 3. State-transition model

Let:

```text
A = prior state
T = transformation evidence
B = resulting state
```

The experiment used the topology:

```text
A
│
│ transformation T
▼
B
```

with:

```text
identity(A) != identity(B)
```

The existence of B did not require deletion of A.

The state model therefore remained:

```text
A exists
B exists
B --derived-from--> A exists
T exists
```

Yoda did not decide whether the biological transformation was scientifically valid.

It preserved the state identities, derivation relation and evidence describing the transition.

---

## 4. Formal property

For a recorded transition from state `A` to state `B` with transformation evidence `T`, **Lineage of Change** is preserved when all of the following hold within the evidence system:

### 4.1 Prior-state identity preservation

The prior state remains independently identifiable and recoverable.

```text
recover(A) = A
identity(recover(A)) = identity(A)
```

### 4.2 Result-state identity preservation

The resulting state remains independently identifiable and recoverable.

```text
recover(B) = B
identity(recover(B)) = identity(B)
```

### 4.3 State distinction

When the transition creates a new state identity, the distinction is preserved rather than collapsed.

```text
identity(A) != identity(B)
```

### 4.4 Derivation preservation

The relationship between the two states remains recoverable.

```text
B --derived-from--> A
```

### 4.5 Transformation-evidence preservation

Evidence describing the transition remains recoverable separately from the state objects.

Conceptually:

```text
B --transformed-by--> T

T
├── transformation record
├── mutation/change evidence
├── authority reference
└── experimental evidence
```

### 4.6 State-specific evidence preservation

Evidence associated with A and B remains attributable to the correct state rather than being merged into a single current-state record.

```text
A --has-evidence--> evidence(A)
B --has-evidence--> evidence(B)
```

### 4.7 Recoverable lineage context

The evidence neighborhoods can be composed into a bounded reconstruction containing the prior state, resulting state, transition and relevant authorities.

This does not require arbitrary graph traversal inside Yoda.

The validating CASE used the frozen Yoda context semantics:

```text
lexical retrieval
+
direct 1-hop relational expansion
```

and composed multiple bounded neighborhoods externally.

---

## 5. Independent authority replay

The validating CASE included a stronger condition beyond the minimal structural definition.

An external authority evaluated state A and state B before Yoda recovery, then evaluated the Yoda-recovered states again.

Let `E` be an external state-specific evaluation function.

The CASE demonstrated:

```text
E(recover(A)) = E(A)
E(recover(B)) = E(B)
```

while also preserving:

```text
identity(A) != identity(B)
E(A) != E(B)
```

For the validating experiment:

```text
E(A) = 0.7961
E(recover(A)) = 0.7961

E(B) = 0.6990
E(recover(B)) = 0.6990
```

This is evidence that Yoda preserved distinct state identities and derivation without substituting its own interpretation for the external authority.

Independent authority replay strengthens the evidence for Lineage of Change, but Yoda itself does not become the domain authority.

---

## 6. Demonstrated instance

Evidence authority:

```text
CASE=SYNTHID-BIO-EVOLVING-PROVENANCE-001
STATUS=VALIDATED
LINEAGE_OF_CHANGE=DEMONSTRATED
```

Observed transition:

```text
Artifact A
SHA256=da6b1b6b239fc3c870f9750f7b29c816f4d700462a160fc8ced7922dbecbfad0
measurement=0.7961

        │
        │ controlled random-residue substitution
        │ 6 changed residues
        ▼

Artifact B
SHA256=defc97981f115f1c1792e53946dcf81f5cce28fafdcccf917c80470fa3cfaa00
measurement=0.6990
```

Yoda stored nine objects and eleven explicit relations.

The validating gates included:

```text
ARTIFACT_A_BYTE_EXACT_RECOVERY=PASS
ARTIFACT_B_BYTE_EXACT_RECOVERY=PASS
TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS
MUTATION_TABLE_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
LINEAGE_OF_CHANGE_CONTEXT=PASS
VERSIONED_DERIVATION_RECOVERY=PASS
STATE_SPECIFIC_MEASUREMENT_REPLAY=PASS
INDEPENDENT_STATE_REPLAY=PASS
LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Final evidence authority:

```text
FINAL_EVIDENCE_MANIFEST_SHA256=e46bcb223be3264f97390abac792a889b5a79033d9ff55eb8f400c818ebcc17a
```

See:

`cases/SYNTHID-BIO-EVOLVING-PROVENANCE-001-lineage-of-change/`

---

## 6.1 Cross-domain demonstrated instance — formal mathematics

A second evidence authority tested the same property in a qualitatively different domain:

```text
CASE=FORMAL-MATH-EVOLVING-DERIVATION-001
STATUS=VALIDATED
CROSS_DOMAIN_LINEAGE_OF_CHANGE=DEMONSTRATED
```

The formal transition preserved two distinct proof artifacts for the same proposition:

```text
Nat.gcd 180 168 = 12

Proof A
kernel computation / rfl

        |
        | semantics-preserving proof refactor
        v

Proof B
explicit Euclidean GCD derivation
```

Before Yoda preservation:

```text
Lean A=PASS
Lean B=PASS

OxiLean A=VERIFIED
OxiLean B=VERIFIED
```

After recovery from the frozen Yoda store:

```text
LEAN_AUTHORITY_REPLAY=PASS

LEAN4EXPORT_A_IDENTITY_REPRODUCED=PASS
LEAN4EXPORT_B_IDENTITY_REPRODUCED=PASS

OXILEAN_AUTHORITY_REPLAY=PASS

INDEPENDENT_FORMAL_REPLAY=PASS
FORMAL_LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS

DATA_YODA_IDENTITY_UNCHANGED=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Final Stage B evidence authority:

```text
STAGE_B_EVIDENCE_MANIFEST_SHA256=
040cfbb629e6262ed8b75e95859e7ca99362e85aed3df8f79d24a378f2ffd6d5
```

The experiment also preserved two non-evaluable measurements rather than rewriting them:

- A1.0 — secondary-authority capability boundary;
- A2-R1 one-shot — harness query-tokenization mismatch.

The formal-mathematics CASE therefore strengthens the claim from a single-domain observation to a cross-domain demonstrated property within the two tested scopes.

It does not establish universal generality.

---
## 7. Invariants observed in the CASE

### Identity is not history

A new identity does not need to erase the identity that preceded it.

### Current state is not sufficient lineage

Knowing B alone is weaker than recovering:

```text
A
+
T
+
B
+
A → B
+
evidence(A)
+
evidence(B)
```

### Change evidence is first-class evidence

The transition itself can be represented separately from both endpoint states.

### State-specific evidence must remain state-specific

Measurements or evaluations associated with A must not silently become measurements of B, or vice versa.

### Authority remains external

Yoda preserves derivation and evidence. It does not inherit the authority that evaluates the scientific, formal or domain-specific meaning of a state.

### Bounded context does not imply hidden multi-hop semantics

Lineage reconstruction may be produced by explicit composition of bounded one-hop evidence neighborhoods.

---

## 8. Relationship to earlier demonstrated properties

The research sequence can be separated conceptually as follows.

### Lineage of State

Question:

> **Where did this result come from?**

Evidence:

`GENOME-LINEAGE-001`

### Composed Provenance

Question:

> **Can independent forms of provenance coexist without losing their identities?**

Evidence:

`SYNTHID-BIO-YODA-PROVENANCE-001`

### Lineage of Change

Question:

> **How did this become what it is now?**

Evidence:

`SYNTHID-BIO-EVOLVING-PROVENANCE-001`

These are related observations of the same underlying derivation architecture, not separate engine modes.

---

## 9. Claim boundary

The demonstrated property supports this narrow statement:

> **Across one controlled biological-artifact transformation and one formal-proof transformation, Yoda preserved distinct states, their derivation and transformation evidence, and enabled the relevant independent authorities to reproduce the original state-specific evaluations after recovery, without Yoda or Kyber changes.**

A concise interpretation is:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

The CASE does **not** establish that:

- every type of state transition can be represented this way;
- Yoda proves that a transformation is legitimate;
- Yoda proves scientific truth;
- Yoda validates biological function;
- Yoda detects SynthID Bio watermarks;
- Yoda proves authorship or biological origin;
- Yoda validates watermark robustness;
- all independent authorities can be replayed;
- arbitrary multi-hop lineage is computed natively by Yoda;
- production-scale change lineage has been validated;
- Google DeepMind participated in, endorsed or partnered on the experiment.

---

## 10. Falsification and extension

The property should be narrowed or revised if future evidence shows that:

- prior states cannot remain independently recoverable under realistic update workloads;
- derivation relationships become ambiguous or unrecoverable as transitions accumulate;
- transformation evidence cannot be preserved without domain-specific engine changes;
- state-specific evidence becomes incorrectly attached across versions;
- bounded-context composition becomes impractical for longer change histories;
- independent replay requires special-case changes inside the Yoda core;
- identity preservation alone proves insufficient for meaningful transition reconstruction.

Stronger evidence would come from demonstrating the same property across qualitatively different transition domains without changing the core architecture.

---

## 11. Property record

```text
PROPERTY=LINEAGE_OF_CHANGE
STATUS=DEMONSTRATED

DEFINITION=DERIVATION_INTEGRITY_ACROSS_STATE_TRANSITIONS

EVIDENCE_CASE=SYNTHID-BIO-EVOLVING-PROVENANCE-001
EVIDENCE_CASE_STATUS=VALIDATED

PRIOR_STATE_RECOVERY=PASS
RESULT_STATE_RECOVERY=PASS
DISTINCT_STATE_IDENTITIES=PASS
DERIVATION_RELATION_RECOVERY=PASS
TRANSFORMATION_EVIDENCE_RECOVERY=PASS
STATE_SPECIFIC_EVIDENCE_RECOVERY=PASS
INDEPENDENT_AUTHORITY_REPLAY=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO

CROSS_DOMAIN_SUPPORT=BIOLOGY_PLUS_FORMAL_MATHEMATICS
UNIVERSAL_GENERALITY=NOT_ESTABLISHED
PRODUCTION_SCALE=NOT_ESTABLISHED
```
