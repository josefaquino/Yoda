# A1-R1 — Scientific Execution Preregistration

## Status

```text
STATUS=READY_FOR_SINGLE_EXECUTION
A1_R1_EXECUTED=NO
A1_R1_EXECUTION_LOCK_CONSUMED=NO
```

## Scientific question

Can two independent deterministic implementations reproduce the same evaluation from the frozen A0 public-disclosure facts under the frozen evaluation contract?

## Frozen input authority

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

## Pre-execution authority

```text
A1_R1_PRE_EXECUTION_AUDIT=PASS

A1_R1_PREFLIGHT_CONSOLE_SHA256=
a584144d3a6555ba62cf01d3ab27df98ad1c806ea1fa1692f7f245e5e3c4f544

C11_PREFLIGHT_BINARY_SHA256=
cda6c18ee6ecfadca2feabda93debfd5b61a680d0dc0de9d3030f6516acf179b
```

## Independent implementations

```text
C11_SOURCE_SHA256=
9f41bda1c4e5a082cb739362f36030be047e00edef727518e7f74c161098fad0

AWK_SOURCE_SHA256=
8b88216d22e6435319c73ec91dd3968cb453539c1a9effa1460bd9930fe0da91

SHARED_CLASSIFICATION_CODE=NO
```

## Contract-derived expected result

```text
VALUE_A_RAW=3314177
VALUE_B_RAW=3314177
REQUIRED_CONTEXT_MATCH=YES
IF_DELTA_EQ_0=UNCHANGED

EXPECTED_CLASSIFICATION_BY_FROZEN_CONTRACT=UNCHANGED
```

## Scientific harness identity

```text
A1_R1_SCRIPT_SHA256=
21d337571abfe2546afc2364f899bcc7e73fa52a265904d336f21c1420526560

A1_R1_SCRIPT_COMMIT=
5bca0cf2d3c74ca8e28ad169ab51ce23d11915f0

SCRIPT_LINES=410
NON_ASCII=0
SEC_URLS=0
YODA_COMMANDS=0

LOCK_LINE=245
C11_SCIENTIFIC_RUN_LINE=281
AWK_SCIENTIFIC_RUN_LINE=299
LOCK_BEFORE_BOTH_AUTHORITIES=YES
```

## Safe launcher identity

```text
A1_R1_SAFE_LAUNCHER_SHA256=
21504c3a87569c0d3ac2872f9e8add9b6f63c216556710688fc0d2c9bece0a32

A1_R1_SAFE_LAUNCHER_COMMIT=
6be09664ba719cf343e101893b8bf7fd8f08b31b
```

## One-execution rule

Before lock creation, toolchain or authority identity drift is `NOT_EVALUATED`.

After:

```text
A1_EXECUTION_GATE=PASS
```

the gate is consumed.

Any runtime failure, authority divergence, output-shape mismatch, or mismatch with the already frozen contract expectation is a scientific `FAIL` and must not be repaired by rerunning A1-R1.

## PASS criteria

```text
C11_AUTHORITY=PASS
AWK_AUTHORITY=PASS

STATE_A_B_AUTHORITY_EQUIVALENCE=PASS
AUTHORITY_EQUIVALENCE=PASS

EXPECTED_CLASSIFICATION_BY_FROZEN_CONTRACT=UNCHANGED
OBSERVED_CLASSIFICATION=UNCHANGED
CONTRACT_EXPECTATION_MATCH=PASS

A1_EVIDENCE_INTEGRITY=PASS

SEC_FETCHES=ZERO
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO

PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_STAGE_A1=PASS
NEXT_GATE=A2_YODA_EVALUATION_LINEAGE
```


## Pre-execution hardening note

Before any A1-R1 scientific execution, the harness was hardened so that post-lock stage/evidence materialization failures map to explicit scientific failure classes instead of relying on implicit `set -e` termination.

```text
SCIENTIFIC_INPUT_CHANGED=NO
EVALUATION_CONTRACT_CHANGED=NO
AUTHORITY_SOURCE_CHANGED=NO
EXPECTED_CLASSIFICATION_CHANGED=NO
A1_R1_EXECUTED_BEFORE_HARDENING=NO
```

Final frozen harness and launcher identities are the values above.
