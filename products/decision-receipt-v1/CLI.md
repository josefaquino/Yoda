# Decision Receipt v1 — CLI

The frozen interface is:

```bash
yoda decision get <decision_id> --output <bundle-dir>
yoda decision verify <bundle-dir>
```

## Generate a receipt

```bash
yoda decision get \
  decision:cvm:net-margin:doc-156154:consolidated \
  --output receipt-v1
```

Successful human-readable output includes:

```text
DECISION_ID=<id>
DECISION=<ALLOW|REFUSE>
REASON=<reason>
RESULT=<value|NO_RESULT>
RECEIPT_VERSION=1
EVIDENCE_COMPLETE=YES
DECISION_RECEIPT_CREATED=PASS
```

Machine-readable creation is frozen as:

```bash
yoda decision get \
  <decision_id> \
  --output <bundle-dir> \
  --format json
```

The caller is not required to supply internal Yoda keys, relations, evidence paths or evaluator invocation details.

## Verify a receipt

```bash
yoda decision verify receipt-v1
```

A valid receipt includes:

```text
DECISION_RECEIPT=VALID
```

An invalid receipt includes:

```text
DECISION_RECEIPT=INVALID
REASON=<stable error code>
```

## Validated behavior

The product-layer implementation passed:

```text
DECISION_GET_ALLOW_TEXT=PASS
DECISION_GET_REFUSE_JSON=PASS

DECISION_VERIFY_ALLOW=PASS
DECISION_VERIFY_REFUSE=PASS

UNKNOWN_DECISION_ID_BEHAVIOR=PASS
PUBLIC_TAMPER_REJECTION=PASS
CORE_014_PASSTHROUGH=PASS
```

## Current scope boundary

```text
INITIAL_BACKEND=VALIDATED_CASE_REGISTRY
REGISTERED_DECISIONS=4
HORIZONTAL_BACKEND_DISCOVERY=NOT_IMPLEMENTED
```

The public syntax is frozen; the backend is not yet horizontal.
