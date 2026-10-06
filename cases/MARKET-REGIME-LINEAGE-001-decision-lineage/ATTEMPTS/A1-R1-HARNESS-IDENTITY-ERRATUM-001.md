# A1-R1 Harness Identity Erratum 001

## Status

```text
SCIENTIFIC_EXECUTION_STARTED=NO
A1_EXECUTION_LOCK_CONSUMED=NO
SCRIPT_CONTENT_CHANGED=NO
CLASSIFICATION_CONTRACT_CHANGED=NO
AUTHORITY_1_CHANGED=NO
AUTHORITY_2_CHANGED=NO
```

## Error

The A1-R1 harness identity was originally declared as:

```text
DECLARED_SHA256=
a9d04c9ceff162911a4a3606d68d747b82df0de69db686d47c4a6ef6115ca13c
```

That value was produced by an incorrect text-hashing procedure which treated JavaScript UTF-16 code units as if they were source bytes.

The script contains two Unicode em dash characters. SHA-256 authority must be computed over the exact UTF-8 file bytes.

## Correct byte identity

```text
UTF8_BYTE_SHA256=
0c891fb1565f42e01943c13def49473b9e515a66653b0f88a479ca065b89a440

CANONICAL_SCRIPT_COMMIT=
18acde5284ead728d0ed528730cbf5aecdead0a9
```

The corrected UTF-8 byte SHA matches the value independently observed by local `sha256sum` after fetching the canonical GitHub file.

## Scientific impact

```text
A1_R1_SCIENTIFIC_EXECUTION=NOT_STARTED
A1_R1_ONE_EXECUTION_GATE_CONSUMED=NO
HISTORICAL_CLASSIFICATION_EXECUTED=NO
SCIENTIFIC_ARTIFACT_BYTES_CHANGED=NO
```

Therefore this is a pre-execution identity-metadata correction, not a scientific rerun and not a change to the pre-registered classifier.

The prior incorrect identity remains preserved here as part of the audit trail.
