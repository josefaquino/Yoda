# CASE — AXIOM-YODA-PROOF-LINEAGE-001

## Question

Can Yoda preserve and reconstruct the complete derivation lineage of a formally verified proof such that artifacts recovered from Yoda can be submitted again to AXLE and reproduce the original formal verification outcome?

## External authority

AXLE is the formal-verification authority.
Yoda is not allowed to substitute for AXLE's logical judgment.

Frozen AXLE environment:

```text
lean-4.34.0
leanprover/lean4:v4.34.0
```

## Positive arm

```text
formal statement
+
valid candidate proof
↓
AXLE accepts
↓
Yoda stores artifacts + evidence + relations
↓
Yoda verify
↓
Yoda exact recovery
↓
AXLE replay
↓
accept again
```

PASS requires:

```text
AXLE_POSITIVE_VERIFICATION=PASS
YODA_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
AXLE_POSITIVE_REPLAY_FROM_YODA=PASS
AXLE_POSITIVE_DECISION_REPRODUCED=PASS
```

## Negative arm

The negative candidate must be valid Lean, but prove a different statement.

```text
controlled mutation
↓
Lean check succeeds
↓
AXLE rejects against frozen formal statement
↓
Yoda stores mutation + evidence + relations
↓
Yoda exact recovery
↓
Lean check still succeeds
↓
AXLE replay rejects again
```

PASS requires:

```text
CONTROLLED_MUTATION_VALID_LEAN=PASS
AXLE_CONTROLLED_REJECTION=PASS
CONTROLLED_MUTATION_VALID_LEAN_AFTER_YODA=PASS
AXLE_NEGATIVE_REPLAY_FROM_YODA=PASS
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS
```

## Lineage requirement

Yoda must recover bounded context for both derivations with explicit relations among:

- formal statement;
- candidate proof;
- AXLE environment;
- verification-before evidence;
- verification-after evidence;
- frozen experiment manifest.

PASS requires:

```text
POSITIVE_DERIVATION_LINEAGE_RECOVERY=PASS
NEGATIVE_DERIVATION_LINEAGE_RECOVERY=PASS
```

## Integrity requirement

```text
YODA_VERIFY_BEFORE_RECOVERY=PASS
YODA_VERIFY_AFTER_REPLAY=PASS
A0_EVIDENCE_REVERIFY=PASS
A1_EVIDENCE_INTEGRITY=PASS
```

## Forbidden shortcuts

The CASE must not:

- add a Math Mode to Yoda;
- add theorem-proving logic to Yoda;
- modify AXLE results;
- infer validity from Yoda metadata;
- accept a negative candidate that merely fails to compile;
- treat request-specific AXLE response bytes as deterministic semantic authority.

## Success claim

If all gates pass, the permitted claim is:

> Yoda preserved and reconstructed the derivation of a formally verified result such that AXLE reproduced the original accept/reject outcome from Yoda-recovered artifacts.

## Non-claims

The CASE does not prove mathematical capability, theorem-proving capability, general formal-methods support, production readiness or product-market fit.
