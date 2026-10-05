# Instance Contract — SYNTHID-BIO-EVOLVING-PROVENANCE-001

## Status

```text
INSTANCE_CONTRACT_VERSION=001
INSTANCE_STATUS=FROZEN_BEFORE_G_B
POST_TRANSFORMATION_MEASUREMENT_OBSERVED=NO
CODE_WRITING=NO
```

This file freezes the concrete A→B instance **before the transformed artifact is measured**.

The purpose is to prevent outcome-driven selection.

---

## Public source dataset

Repository:

`google-deepmind/synthidbio`

Frozen commit:

```text
acd75747b14c7f4c3c65ad1e6af1483aeba47614
```

Source file:

```text
synthidbio_sequence/data/VEGF-A/vegfa_data.csv
```

Measurement index:

```text
synthidbio_sequence/data/all_g_values.csv
```

---

## Deterministic selection rule for Artifact A

Select the first unique design in file order satisfying all of:

```text
Plate Target ID = VEGFA
Subset_Name = watermark_0.1
binding = TRUE
```

Replicate rows for the same design are treated as one artifact.

This rule selects:

```text
ARTIFACT_A_ID=PDW_0903
BACKBONE_ID=Backbone 0
TARGET=VEGFA
WATERMARK_SETTING=watermark_0.1
BINDING=TRUE
```

The choice is based only on dataset ordering and public metadata.
It is not based on the g-value magnitude.

---

## Artifact A sequence

Published sequence:

```text
IEERRAALLNGLHEALKVIKEALKGKEKELDELEGPLAEALYALTKAGISRTEAALDEAEAAVRAFLDRAREVLEKQGQEEAVEKLRELEARYL
```

The source CSV contains the same sequence for both experimental replicate rows of `PDW_0903`.

The public `all_g_values.csv` associates `PDW_0903` with the distortionary watermark measurement for the same target/backbone/design setting.

The exact detector measurement used by the CASE will be independently recomputed in A0 rather than trusted solely from the CSV.

---

## Artifact B construction

Frozen tags from the paper Methods:

```text
GFP11=RDHMVLHEYVNAAGIT
TWIN_STREP=WSHPQFEKGGGSGGGSGGSAWSHPQFEK
```

Canonical operation:

```text
B = A || GFP11 || TWIN_STREP
```

Therefore the complete frozen sequence for B is:

```text
IEERRAALLNGLHEALKVIKEALKGKEKELDELEGPLAEALYALTKAGISRTEAALDEAEAAVRAFLDRAREVLEKQGQEEAVEKLRELEARYLRDHMVLHEYVNAAGITWSHPQFEKGGGSGGGSGGSAWSHPQFEK
```

No separator character is inserted in the amino-acid sequence.

---

## Transformation identity

```text
TRANSFORMATION_ID=append-c-terminal-gfp11-twinstrep-001
TRANSFORMATION_CLASS=C_TERMINAL_TAG_ADDITION
PARENT=PDW_0903
CHILD=PDW_0903+c-terminal-tags
RELATION=derived-from
```

Expected derivation:

```text
Artifact A
PDW_0903
      ↓
append GFP11
      ↓
append Twin-Strep
      ↓
Artifact B
PDW_0903+c-terminal-tags
```

---

## Measurement policy

A0 must compute both measurements with the same frozen official SynthID Bio detector authority used in the validated prior CASE.

```text
A → official detector → g(A)
B → official detector → g(B)
```

The value of `g(B)` is deliberately absent from this contract.

No PASS criterion depends on whether it rises, falls or crosses a threshold.

---

## Identity policy

The executable A0 will create canonical FASTA artifacts with one sequence per file and freeze SHA-256 identities before any Yoda write.

Expected identity gates:

```text
A_SEQUENCE_SOURCE_AUTHORITY=PASS
B_TRANSFORMATION_DETERMINISTIC=PASS
A_SHA256_FROZEN=PASS
B_SHA256_FROZEN=PASS
A_NE_B=PASS
```

---

## Anti-cherry-picking proof

At contract freeze:

```text
ARTIFACT_A_SELECTED=PDW_0903
ARTIFACT_B_DEFINITION=DETERMINISTIC
G_B_USED_FOR_SELECTION=NO
YODA_WRITES=ZERO
```

If the detector later returns an unexpected value for B, the instance is not replaced.

Unexpected measurement is evidence.

---

## Scope boundary

This contract does not claim:

- the tagged sequence was experimentally tested as a binder;
- the exact tagged construct reproduces the wet-lab construct architecture beyond the published amino-acid tag strings;
- biological function is preserved;
- watermark detectability is preserved;
- tag addition is a watermark robustness benchmark for Yoda.

It creates a public, deterministic and scientifically motivated **artifact evolution** instance for testing derivation integrity.

---

## Next gate

```text
NEXT_GATE=A0_INSTANCE_AUTHORITY_AND_PRE_YODA_MEASUREMENT
```
