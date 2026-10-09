# Context-Governed Reproducible Evaluation

## Status

Validated in:

`YODA-CVM-AGENTIC-CONTEXT-001`

This document names a bounded infrastructure property demonstrated by that CASE.

It is not a claim that Yoda understands domain semantics or should become a general rules engine.

---

## Definition

A context-governed deterministic operation has at least five recoverable elements:

```text
STATE_USED
CONTEXT_USED
RULE_USED
EVALUATOR_USED
RESULT_PRODUCED
```

The property is demonstrated when an evidence system can preserve those elements such that:

1. a valid operation can be reproduced from recovered state and recovered context;
2. an operation that violates the preserved context can be refused deterministically for the same reason;
3. the evaluator and rule used in replay are recoverable and identifiable;
4. replay does not require consulting the original external source state;
5. the authoritative Yoda state remains unchanged through replay.

Conceptually:

```text
observed state
     +
versioned context
     +
versioned rule
     +
deterministic evaluator
        ↓
ALLOW + result
or
REFUSE + reason
        ↓
       Yoda
        ↓
exact recovery
        ↓
same governed evaluation
```

---

## Authority separation

The property requires separating domain facts from operational meaning and execution.

```text
DATA AUTHORITY
→ what was observed

CONTEXT AUTHORITY
→ how preserved facts may be interpreted or combined for this operation

EVALUATION AUTHORITY
→ mechanically applies the frozen rule

YODA
→ preserves identities, relationships, evidence and recoverable derivation
```

Yoda does not need to become any of the first three authorities.

---

## Validated instance

The validating CASE used real public CVM financial-reporting states and one project-defined metric contract.

The valid calculations were:

```text
V1 consolidated net margin
→ ALLOW
→ -0.057183

V2 consolidated net margin
→ ALLOW
→ 0.068161
```

The controlled incompatibilities were:

```text
scope mismatch
→ REFUSE
→ INCOMPATIBLE_SCOPE

presentation mismatch
→ REFUSE
→ INCOMPATIBLE_PRESENTATION
```

After Yoda preservation, the replay used only Yoda `get` to recover the facts, metadata, semantic mappings, metric contract, refusal policy, evaluator source, scenarios and original outcomes.

The recovered evaluator was recompiled.

All four outcomes reproduced byte-exactly.

```text
CONTEXT_GOVERNED_REPRODUCIBLE_EVALUATION=PASS
REPLAY_INPUT_SOURCE=YODA_GET_ONLY
REPLAY_VS_ORIGINAL_EXACT_MATCH=PASS
DATA_YODA_IDENTITY_UNCHANGED=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## What the property means

The validated observation is:

> **Operational context can be preserved as versioned evidence strongly enough to reproduce both an allowed deterministic operation and the refusal of incompatible operations.**

This extends prior state and Decision Lineage evidence.

```text
state identity
      ↓
decision lineage
      ↓
context-governed reproducible evaluation
```

A decision is no longer recoverable only as an output.

The evidence can include the context and rule that constrained the operation.

---

## What the property does not mean

The validating CASE does not establish:

```text
semantic understanding by Yoda
domain truth determination by Yoda
general policy-engine behavior
arbitrary rule-language support
arbitrary agent correctness
universal context compatibility
automatic rule selection
automatic metric selection
accounting correctness
financial prediction
```

The property is about preservation and deterministic replay of a bounded, explicit operational contract.

---

## Product implication

No new Yoda engine mode was required.

The demonstrated composition was:

```text
Yoda objects
+
explicit relations
+
versioned contracts
+
external deterministic evaluator
```

This supports the product principle:

> **Composition over expansion.**

And it motivates a stronger product question:

> **Can an autonomous system recover not only what it saw, but the exact context and rule that governed what it was allowed to do with that state?**
