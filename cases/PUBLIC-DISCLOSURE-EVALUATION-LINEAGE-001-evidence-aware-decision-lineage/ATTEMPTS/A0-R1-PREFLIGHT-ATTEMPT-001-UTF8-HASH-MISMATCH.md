# A0-R1 Pre-execution Audit — Attempt 001

## Observed result

```text
A0_R1_PRE_EXECUTION_AUDIT=NOT_EVALUATED
FAILURE_CLASS=A0_POLICY_IDENTITY_MISMATCH

A0_R1_PREFLIGHT_RC=1

A0_R1_EXECUTION_LOCK=ABSENT
A0_R1_STAGE=ABSENT

SCIENTIFIC_EXECUTION_STARTED=NO
A0_EXECUTION_LOCK_CONSUMED=NO
YODA_WRITES=ZERO
```

## Execution identities

```text
A0_R1_SCRIPT_SHA256=
50d39563841e32559355b97b0c6fb2659d43a7eb26ca03ee529849e35e7c86eb

A0_R1_PREFLIGHT_CONSOLE_SHA256=
ad93810cf12858e6d9d82a3048b5d6b7fe98dbc03a2a9214865a7153d414a351
```

## Read-only adjudication

The scientific A0 gate was never reached.

The policy file at the frozen authority commit and the policy file on the current branch are identical in content.

Root cause:

```text
ROOT_CAUSE=
PRE_REGISTERED_UTF8_SHA256_CALCULATION_ERROR
```

The policy contains one non-ASCII UTF-8 character.

The originally preregistered SHA-256 was produced by an internal helper that treated Unicode code points as single bytes. That helper is valid only for ASCII artifacts.

Incorrect preregistered identity:

```text
976e5b2ef7e4d345c128e83a37a6833174cd17db8e521a22136b38fcfda673d9
```

Correct SHA-256 over the actual UTF-8 bytes:

```text
390a46190a204d8c6eb2e3b249b5b875370728e8770f7c1cfdb6410a59575aff
```

No policy content is changed by this adjudication.

```text
POLICY_CONTENT_CHANGED=NO
SCIENTIFIC_SELECTION_CHANGED=NO
EVALUATION_CONTRACT_CHANGED=NO
ISSUER_SELECTED=NO
ACCESSION_PAIR_SELECTED=NO
XBRL_CONCEPT_SELECTED=NO
FACT_VALUES_REVEALED=NO
SEC_A0_REQUESTS=ZERO
A0_R1_RERUN=NOT_APPLICABLE
FRESH_FIRST_SCIENTIFIC_A0_EXECUTION_STILL_AUTHORIZED=YES
```
