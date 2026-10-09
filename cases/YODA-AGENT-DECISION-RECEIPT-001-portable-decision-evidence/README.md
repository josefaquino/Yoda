# YODA-AGENT-DECISION-RECEIPT-001

## Portable Decision Evidence

**Status:** VALIDATED

Research question:

> Can Yoda turn preserved decision evidence into a portable Decision Receipt that an independent system can verify without access to Yoda, the original source or Yoda's internal evidence layout?

## Result

```text
YODA-AGENT-DECISION-RECEIPT-001=VALIDATED

PORTABLE_DECISION_EVIDENCE=PASS
THIRD_PARTY_VERIFICATION=PASS
RESEALED_TAMPER_DETECTION=PASS

TOTAL_PRODUCT_FAILURES=0

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## DR-001 — Receipt Contract Freeze

The contract froze:

- four decision IDs;
- a 19-field receipt schema;
- an 11-file portable bundle topology;
- verification rules;
- ALLOW and REFUSE examples;
- two tamper scenarios.

No Yoda execution occurred.

## DR-002-R2 — External Receipt Adapter

The external caller supplied only `decision_id`.

```text
AGENT_INPUT=DECISION_ID_ONLY
AGENT_ARGUMENTS_PER_REQUEST=1

INTERNAL_YODA_KEYS_REQUIRED_BY_AGENT=0
INTERNAL_YODA_RELATIONS_REQUIRED_BY_AGENT=0

ADAPTER_EXECUTION_COUNT=4
ADAPTER_YODA_ACCESS=READ_ONLY_GET
TOTAL_YODA_GETS=36

ALLOW_RECEIPTS_CREATED=2
REFUSE_RECEIPTS_CREATED=2
PORTABLE_BUNDLES=PASS

YODA_DATA_IDENTITY_UNCHANGED=PASS
```

The initial backend used the frozen validated decision registry. Horizontal backend discovery was not part of this CASE.

## DR-003 — Independent Bundle-Only Verification

The verifier received only each portable bundle.

```text
VERIFIER_YODA_ACCESS=NO
VERIFIER_CVM_ACCESS=NO
VERIFIER_ORIGINAL_CASE_ACCESS=NO
DECISION_REGISTRY_REQUIRED_BY_VERIFIER=NO

VERIFIED_RECEIPTS=4
ALLOW_RECEIPTS_VERIFIED=2
REFUSE_RECEIPTS_VERIFIED=2
VERIFICATION_FAILURES=0

INDEPENDENT_RECEIPT_VERIFICATION=PASS
```

All four receipts passed state, context, rule, evaluator and result checks.

## DR-004 — Resealed Tamper Detection

Two copies of a valid receipt were altered and then resealed by recalculating the outer manifest.

Result tamper:

```text
-0.057183
→ -0.050000

BUNDLE_INTEGRITY=PASS
RECEIPT_SCHEMA=PASS

DECISION_RECEIPT=INVALID
REASON=RESULT_EVIDENCE_MISMATCH
```

Rule-authority tamper:

```text
45fe6311...
→ 00000000...

BUNDLE_INTEGRITY=PASS
RECEIPT_SCHEMA=PASS

DECISION_RECEIPT=INVALID
REASON=RULE_AUTHORITY_MISMATCH
```

Final:

```text
TAMPERED_BUNDLES=2
INVALID_RECEIPTS=2
TAMPER_FAILURES=0
RESEALED_MANIFEST_BYPASS=NO
SOURCE_BUNDLE_UNCHANGED=PASS
TAMPER_DETECTION=PASS
```

## Safe claim

> **Yoda can package preserved decision evidence into a portable Decision Receipt that an independent verifier can validate without access to Yoda, the original source or Yoda's internal evidence layout. Tested alterations to the result and rule authority were rejected even after the bundle manifest was resealed.**

## Trust boundary

This CASE does not prove protection against an attacker who can simultaneously replace the receipt, all evidence, trusted authority identities, the verifier and its distribution channel.

See [Decision Receipt v1](../../products/decision-receipt-v1/README.md) for the frozen product contract and trust model.
