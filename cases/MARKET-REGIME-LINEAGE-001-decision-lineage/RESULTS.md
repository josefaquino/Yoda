# RESULTS — MARKET-REGIME-LINEAGE-001

## Status

| Stage | Status | Meaning |
|---|---|---|
| Design | FROZEN | Research question, dates, classifier and authorities pre-registered |
| PRE-A0-R1 | NOT_EVALUATED | Harness transport composition mismatch; no A0 gate consumed |
| PRE-A0-R2 | PASS | FRED metadata/observations and point-in-time parameters reachable; zero Yoda writes |
| A0-R1 | PASS | Three point-in-time snapshots frozen; evidence manifest valid; classification not executed |
| A1-R1 | NOT_EVALUATED | One-shot consumed; C11 authority stopped at first classification with HARNESS_FAILURE; rerun forbidden |
| A2 | BLOCKED | Requires A1 PASS |
| B | BLOCKED | Requires A2 PASS |

No market classifications have been observed or recorded in this CASE at preregistration time.


## A1-R1 harness identity erratum

Before A1 scientific execution, the declared script hash was corrected from a non-byte text hash to the exact UTF-8 byte SHA-256:

```text
CORRECT_A1_R1_SCRIPT_SHA256=
0c891fb1565f42e01943c13def49473b9e515a66653b0f88a479ca065b89a440

A1_EXECUTION_LOCK_CONSUMED=NO
SCRIPT_CONTENT_CHANGED=NO
```
