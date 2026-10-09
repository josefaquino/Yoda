# Decision Receipt v1 — Examples

## ALLOW

```bash
yoda decision get \
  decision:cvm:net-margin:doc-156154:consolidated \
  --output receipt-v1
```

Validated decision:

```text
DECISION=ALLOW
REASON=COMPATIBLE_CONTEXT
RESULT=-0.057183
RECEIPT_VERSION=1
EVIDENCE_COMPLETE=YES
DECISION_RECEIPT_CREATED=PASS
```

Verify:

```bash
yoda decision verify receipt-v1
```

Expected successful verdict:

```text
DECISION_RECEIPT=VALID
```

## REFUSE

A REFUSE outcome is a first-class decision receipt, not a receipt-generation error.

Validated example:

```text
DECISION_ID=
decision:cvm:net-margin:presentation-mismatch:156154-156163

DECISION=REFUSE
REASON=INCOMPATIBLE_PRESENTATION
RESULT=null
```

The resulting bundle also verified successfully.

## Tampered but resealed

The validated negative test changed:

```text
-0.057183
→ -0.050000
```

and recalculated the bundle manifest.

Verification returned:

```text
DECISION_RECEIPT=INVALID
REASON=RESULT_EVIDENCE_MISMATCH
```

This demonstrates that resealing the outer manifest was not sufficient to make contradictory decision evidence valid.
