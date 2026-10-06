# A1 — Deterministic Evaluation Authority

## Status

```text
CASE=PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001
STAGE=A1
STATUS=PRE_REGISTERED
EXECUTED=NO
```

## Input authority

A1 consumes only the completed frozen A0 authority.

```text
A0_R1=NOT_EVALUATED
A0_C1=PASS
A0_AUTHORITY=PASS_BY_FROZEN_SELECTION_COMPLETION

A0_C1_EXECUTION_LOCK_SHA256=
7bc7ed24b7e4468c618f72e8c61c02f5689df865deea32d8cc3c36eee993bde2

A0_C1_EVIDENCE_MANIFEST_SHA256=
40499e4c4545974f3ed106d72cc5da356bdbadc8a4478f0a152e6d4f454c84cb

CANONICAL_FACTS_SHA256=
0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d

EVALUATION_CONTRACT_SHA256=
ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd
```

A1 performs no SEC fetch, no candidate selection and no Yoda write.

## Frozen scientific input

```text
state A:
accession=0001213900-24-083458
form=10-K
concept=Assets
unit=USD
start=-
end=2024-06-30
value_raw=3314177

state B:
accession=0001213900-25-000438
form=10-K/A
concept=Assets
unit=USD
start=-
end=2024-06-30
value_raw=3314177
```

## Contract-derived expectation

The evaluation contract was frozen before the values were revealed.

It states:

```text
IF_DELTA_EQ_0=UNCHANGED
```

The frozen A0 facts satisfy:

```text
VALUE_A_RAW=3314177
VALUE_B_RAW=3314177
VALUE_A_EQUALS_VALUE_B=YES
UNIT_MATCH=YES
REQUIRED_CONTEXT_MATCH=YES
```

Therefore, before either A1 authority is executed:

```text
EXPECTED_CLASSIFICATION_BY_FROZEN_CONTRACT=UNCHANGED
```

This expectation is a deterministic consequence of the already frozen contract and A0 evidence. The threshold is not tuned and the workload is not reselected.

## Authority 1

```text
LANGUAGE=C11
ROLE=INDEPENDENT_DETERMINISTIC_EVALUATOR
BINARY_FLOATING_POINT_FOR_FACT_VALUES=NO
```

Authority 1 parses decimal values as sign + decimal digit string + scale and performs value arithmetic using decimal digit-string operations.

## Authority 2

```text
LANGUAGE=POSIX_AWK
ROLE=INDEPENDENT_DETERMINISTIC_EVALUATOR
BINARY_FLOATING_POINT_FOR_FACT_VALUES=NO
```

Authority 2 independently implements decimal-string normalization, comparison, addition/subtraction and small-integer multiplication.

It must not share classification code with Authority 1.

## Canonical evaluation output

Both authorities must emit exactly:

```text
contract	concept	unit	start	end	value_a_raw	value_b_raw	common_scale	delta_coefficient	base_coefficient	threshold_basis_points	classification
```

followed by one evaluation row.

## Required equivalence

```text
AUTHORITY_1=PASS
AUTHORITY_2=PASS

AUTHORITY_1_VS_AUTHORITY_2=BYTE_IDENTICAL
AUTHORITY_EQUIVALENCE=PASS

EXPECTED_CLASSIFICATION_BY_FROZEN_CONTRACT=UNCHANGED
OBSERVED_CLASSIFICATION=UNCHANGED
CONTRACT_EXPECTATION_MATCH=PASS
```

## Synthetic preflight

Before the scientific one-execution lock, both authorities must independently pass a synthetic suite covering:

```text
UNCHANGED
CHANGED_WITHIN_THRESHOLD
CHANGED_ABOVE_THRESHOLD
NOT_COMPARABLE
NOT_EVALUABLE
decimal-scale alignment
negative values
opposite signs
```

The synthetic suite is not scientific evidence; it is a harness/toolchain gate.

## One-execution boundary

The A1 lock is created only after:

```text
A0_AUTHORITY=PASS
AUTHORITY_SOURCE_IDENTITIES=PASS
C11_COMPILE=PASS
SYNTHETIC_AUTHORITY_1=PASS
SYNTHETIC_AUTHORITY_2=PASS
SYNTHETIC_AUTHORITY_EQUIVALENCE=PASS
```

After lock creation, any scientific authority divergence is a true A1 failure and must not be repaired by rerunning the consumed gate.

## PASS

```text
PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A1=PASS

C11_AUTHORITY=PASS
AWK_AUTHORITY=PASS

STATE_A_B_AUTHORITY_EQUIVALENCE=PASS
CONTRACT_EXPECTATION_MATCH=PASS

CLASSIFICATION=UNCHANGED

SEC_FETCHES=ZERO
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO

NEXT_GATE=A2_YODA_EVALUATION_LINEAGE
```

## Non-claims

```text
FRAUD_CLASSIFICATION=NO
MARKET_MANIPULATION_CLASSIFICATION=NO
FILING_CORRECTNESS_JUDGMENT=NO
COMPANY_QUALITY_ASSESSMENT=NO
PRICE_PREDICTION=NO
INVESTMENT_SIGNAL=NO
```
