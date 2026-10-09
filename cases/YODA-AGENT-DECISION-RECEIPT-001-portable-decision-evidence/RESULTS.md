# RESULTS — YODA-AGENT-DECISION-RECEIPT-001

```text
CASE=YODA-AGENT-DECISION-RECEIPT-001
STATUS=VALIDATED

PORTABLE_DECISION_EVIDENCE=PASS
THIRD_PARTY_VERIFICATION=PASS
RESEALED_TAMPER_DETECTION=PASS

DR-001=PASS
DR-002=NOT_EXECUTED
DR-002-R1=NOT_EXECUTED
DR-002-R2=PASS
DR-003=PASS
DR-004-PREFLIGHT=PASS
DR-004=PASS

TOTAL_PRODUCT_FAILURES=0

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The NOT_EXECUTED stages were harness/preparation failures before product execution. They are preserved as part of the evidence trail and are not product failures.

## Product follow-through

The validated CASE produced a frozen Decision Receipt v1 product contract and a validated product-layer implementation of:

```bash
yoda decision get <decision_id> --output <bundle-dir>
yoda decision verify <bundle-dir>
```

The implementation preserved CORE-014 and `data.yoda` identities and passed public tamper rejection.

The current initial backend remains limited to four decisions from the validated registry.
