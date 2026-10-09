# Decision Receipt v1 — Error and Exit Codes

The CLI contract freezes distinct outcomes for machine callers.

| Exit code | Meaning | Validated status |
|---:|---|---|
| 0 | successful operation / VALID receipt | PASS |
| 1 | receipt verified as INVALID | PASS |
| 64 | command usage error | PASS |
| 65 | malformed or unsupported receipt input | PASS for unsupported version |
| 66 | decision or input bundle not found | PASS |
| 70 | internal implementation failure | implemented statically |
| 74 | I/O failure | PASS |

Stable public error identifiers include:

```text
OK
UNKNOWN_DECISION_ID
BUNDLE_NOT_FOUND
UNSUPPORTED_RECEIPT_VERSION
RECEIPT_SCHEMA_INVALID
BUNDLE_TOPOLOGY_MISMATCH
BUNDLE_INTEGRITY_MISMATCH
STATE_EVIDENCE_MISMATCH
CONTEXT_AUTHORITY_MISMATCH
RULE_AUTHORITY_MISMATCH
EVALUATOR_AUTHORITY_MISMATCH
EVALUATION_REPLAY_FAILURE
DECISION_EVIDENCE_MISMATCH
REASON_EVIDENCE_MISMATCH
RESULT_EVIDENCE_MISMATCH
INTERNAL_ERROR
```

Frozen error-code contract identity:

```text
ERROR_CODES_V1_SHA256=
964365bff50259f1e4724a41c4a99fedb7f3a198914c25e019791f6d3bfed805
```
