# A0-R1 — Read-only Partial-State Adjudication

## Result

```text
READ_ONLY_ADJUDICATION=COMPLETE
DIAGNOSTIC_RC=0

A0_R1_EXECUTION_LOCK=CONSUMED
A0_R1_LOCK_IDENTITY=PASS

SELECTION_IDENTITY=PASS

ROOT_CAUSE_SIGNAL=
REVEAL_MODE_DIAGNOSTIC_PREAMBLE_VIOLATES_CANONICAL_OUTPUT_SHAPE

CANONICAL_PAYLOAD_RECOVERABLE_WITHOUT_RESELECTION=YES

SELECTED_TUPLE_RESELECTION=FORBIDDEN
A0_R1_RERUN=NO
```

## Diagnostic identity

```text
DIAGNOSTIC_SCRIPT_SHA256=
2fef9b111f73ad448bafe140888326480d456175fa938288829b599c7d7b498b

A0_R1_EXECUTION_LOCK_SHA256=
95143c814b061a68e0857eb508f7b0324bf3eabe755d872c72bc4c257f404b0f
```

## Frozen selection

```text
SELECTION_SHA256=
3bff9ec5b957231543e1c9c6d45dc0d026cf2bd1113660a39056d7ffc25dc85f

ordinal=1
cik=0001807166
issuer=Amesite Inc.
original_filing_date=2024-09-30
amendment_filing_date=2025-01-02
report_date=2024-06-30
original_accession=0001213900-24-083458
amendment_accession=0001213900-25-000438
concept=Assets
kind=instant
unit=USD
context_start=-
context_end=2024-06-30
```

No reselection is permitted after value reveal.

## Partial canonical artifact

```text
CANONICAL_PARTIAL_SHA256=
67de9dc83bf2223a84b3541de26ab87e8a72c4916c2fe87609baee45a755b7b3

CANONICAL_PARTIAL_LINES=4

line 1 = PARSER_STATUS=PASS
line 2 = canonical header
line 3 = State A
line 4 = State B

CANONICAL_PAYLOAD_LINES_AFTER_PREAMBLE=3

CANONICAL_PAYLOAD_SHA256=
0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d
```

Observed payload:

```text
state	accession	form	concept	unit	start	end	value_raw
A	0001213900-24-083458	10-K	Assets	USD	-	2024-06-30	3314177
B	0001213900-25-000438	10-K/A	Assets	USD	-	2024-06-30	3314177
```

No classification was executed.

## Existing selected raw artifacts

```text
submissions-current.json
SHA256=ec0c168cb1f8bbec6d9ffe676219679aad0cc4d05f8427f3078eedf48f37e027
BYTES=59561

history-files.txt
SHA256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
BYTES=0

submissions-all-filings.tsv
SHA256=94dedbdbdbbeed6d6df7e9d06baa959423c51e4a81c6b52f5dc2e3282c8f657e
BYTES=16068

companyfacts.json
SHA256=a012fe95a36f2d1277fd31dad59e09003d0ced5bdff279dcbdc145ee1ca228c2
BYTES=794628

original-index.htm
SHA256=4a6c0db737a1bd01f4fbba4e46d8c09a75eac2050161e8c336eec624fd2fe5a0
BYTES=13756

amendment-index.htm
SHA256=7b1d5a6d9846baa478c599a304b16c1f7e75ef3bc6170fe845449cfb8f97c4df
BYTES=11955

history/ file count=0
concept-checks/ file count=1
```

## Missing raw artifacts

```text
original-submission.txt=MISSING
amendment-submission.txt=MISSING
```

These were scheduled after the failed canonical line-count gate and therefore were never fetched.

## Partial evidence state

```text
candidate-scan.tsv
SHA256=e7e6648419715b1402e5a25b3ff2c2e1348e4e2e90637710c481aeb556fdaba2
LINES=2

summary.tsv=MISSING
SHA256SUMS=MISSING
SHA256SUMS.check=MISSING
```

## Continuation authorization

A new continuation stage may complete A0 only if it preserves all frozen selection identities.

Permitted actions:

```text
1. verify A0-R1 lock identity
2. verify frozen selection identity
3. verify partial canonical identity
4. derive canonical payload by removing exactly line 1
5. verify derived payload SHA256
6. fetch only the two missing frozen submission artifacts
7. freeze a continuation evidence manifest
```

Forbidden:

```text
candidate rescan
issuer reselection
accession reselection
concept reselection
parser execution
classification
evaluation
Yoda writes
mutation of A0-R1 files
```

The original A0-R1 remains permanently `NOT_EVALUATED`.
