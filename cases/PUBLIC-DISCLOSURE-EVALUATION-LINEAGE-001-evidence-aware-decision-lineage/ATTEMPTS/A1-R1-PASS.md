# A1-R1 — Deterministic Evaluation Authority — PASS

## Verdict

```text
PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A1=PASS
A1_REVISION=A1-R1

C11_AUTHORITY=PASS
AWK_AUTHORITY=PASS

STATE_A_B_AUTHORITY_EQUIVALENCE=PASS
AUTHORITY_EQUIVALENCE=PASS

EXPECTED_CLASSIFICATION_BY_FROZEN_CONTRACT=UNCHANGED
OBSERVED_CLASSIFICATION=UNCHANGED
CONTRACT_EXPECTATION_MATCH=PASS

SEC_FETCHES=ZERO
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO

NEXT_GATE=A2_YODA_EVALUATION_LINEAGE
```

## Execution identities

```text
A1_R1_SCRIPT_SHA256=
21d337571abfe2546afc2364f899bcc7e73fa52a265904d336f21c1420526560

A1_R1_CONSOLE_SHA256=
60f2e8fc9b38d4a7ffd0fb1e5c9fe15d61337cbe6c3b5846d9413b64c5d1dd34

A1_R1_EXECUTION_LOCK_SHA256=
85e493177e75aad351a45fcf9c5fb4aa2bf731dae483350aa10dc7a61cb31c0e

A1_EVIDENCE_MANIFEST_SHA256=
6b5f0093426dac4b8a4603fbaf12f1859e0fb60e2eb09386a63ba8a49d425cc7
```

A1-R1 is a consumed one-shot and must not be rerun.

## A0 input authority

```text
A0_AUTHORITY=PASS_BY_FROZEN_SELECTION_COMPLETION

A0_C1_LOCK_SHA256=
7bc7ed24b7e4468c618f72e8c61c02f5689df865deea32d8cc3c36eee993bde2

A0_C1_MANIFEST_SHA256=
40499e4c4545974f3ed106d72cc5da356bdbadc8a4478f0a152e6d4f454c84cb

CANONICAL_FACTS_SHA256=
0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d

EVALUATION_CONTRACT_SHA256=
ad99c69bba58ccc862d5d9b1700a784bcc9f5124320a30f69d5faeeb2721abfd
```

## Independent implementations

```text
C11_SOURCE_SHA256=
9f41bda1c4e5a082cb739362f36030be047e00edef727518e7f74c161098fad0

AWK_SOURCE_SHA256=
8b88216d22e6435319c73ec91dd3968cb453539c1a9effa1460bd9930fe0da91

C11_BINARY_SHA256=
cda6c18ee6ecfadca2feabda93debfd5b61a680d0dc0de9d3030f6516acf179b
```

## Result identity

Both independent authorities produced byte-identical output:

```text
AUTHORITY_1_RESULTS_SHA256=
906cb399db9bd91730506ec6f89242f5f88c921e543f09a5ffdc54e05a956bcb

AUTHORITY_2_RESULTS_SHA256=
906cb399db9bd91730506ec6f89242f5f88c921e543f09a5ffdc54e05a956bcb

CANONICAL_EVALUATION_SHA256=
906cb399db9bd91730506ec6f89242f5f88c921e543f09a5ffdc54e05a956bcb
```

Canonical evaluation:

```text
contract	concept	unit	start	end	value_a_raw	value_b_raw	common_scale	delta_coefficient	base_coefficient	threshold_basis_points	classification
PUBLIC-DISCLOSURE-EVALUATION-V1	Assets	USD	-	2024-06-30	3314177	3314177	0	0	3314177	100	UNCHANGED
```

## Scientific interpretation

The later public filing has a distinct filing identity, but the selected structured fact remained equal under the frozen context and the frozen deterministic evaluation remained `UNCHANGED`.

This is not evidence that the filings are globally identical. It is evidence that the selected deterministic evaluation is stable across the two frozen disclosure states.

## Non-claims

```text
FRAUD_CLASSIFICATION=NO
MARKET_MANIPULATION_CLASSIFICATION=NO
FILING_CORRECTNESS_JUDGMENT=NO
COMPANY_QUALITY_ASSESSMENT=NO
PRICE_PREDICTION=NO
INVESTMENT_SIGNAL=NO
```
