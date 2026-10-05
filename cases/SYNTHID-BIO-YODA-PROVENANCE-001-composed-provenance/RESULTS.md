# Results — SYNTHID-BIO-YODA-PROVENANCE-001

## Final classification

```text
SYNTHID_BIO_YODA_PROVENANCE_001=VALIDATED
STAGE_A0=PASS
STAGE_A1=PASS
STAGE_B=PASS
DEEPMIND_ORACLE_REPRODUCED=PASS
CONTROL_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
WATERMARKED_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
CONTROL_DETECTOR_EQUIVALENCE=PASS
WATERMARKED_DETECTOR_EQUIVALENCE=PASS
G_VALUE_MATRIX_EQUIVALENCE=PASS
INTRINSIC_PROVENANCE_MEASUREMENT_EQUIVALENCE=PASS
EXTERNAL_WORKFLOW_PROVENANCE_RECOVERY=PASS
COMPOSED_PROVENANCE=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Stage A0 — Google DeepMind oracle authority

Frozen public authority:

```text
DEEPMIND_REPOSITORY_COMMIT=acd75747b14c7f4c3c65ad1e6af1483aeba47614
```

Official tests reproduced:

```text
OFFICIAL_NON_WATERMARKED_TEST=PASS
OFFICIAL_WATERMARKED_TEST=PASS
OFFICIAL_G_VALUE_TEST=PASS
OFFICIAL_STANDALONE_DETECTOR=PASS
EXPECTED_G_VALUES=PASS
```

Frozen artifacts:

```text
CONTROL_5L33_SHA256=77aaf2a4d2fa522f84280420d1605f28c78a1913bd39e9ac4b628d45e3681a4f
WATERMARKED_5L33_SHA256=16ce25bd9f444efcf3dd4adfd7b1732b5adc3f35289f6e498aa3ceabf0d0a1f4
```

Frozen measurements:

```text
CONTROL_SAMPLE1_G=0.5037
CONTROL_SAMPLE2_G=0.5130
WATERMARKED_SAMPLE1_G=0.7961
WATERMARKED_SAMPLE2_G=0.7184
```

Evidence:

```text
A0_EVIDENCE_MANIFEST_SHA256=3114caf012ee41f3be15dae292f688299e872cef180dd3073750f05a4cee038e
A0_SCRIPT_SHA256=7d13c193a257f5350a1dcc15fa15fdd9087b6bccb27577987e3f3be46c68a9e5
A0_CONSOLE_SHA256=448d0335179a596bfb5dc17ac2d8ccc73872761db93bbc002827f5c4372d5a00
```

The first A0 execution used Python 3.13 and stopped during dependency installation before any oracle test ran. The environment was corrected to Python 3.9 as recommended by the frozen SynthID Bio implementation. No scientific gate was changed.

## Stage A1 — Yoda composed provenance

Frozen Yoda authority:

```text
YODA_SHA256=1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
```

Yoda stored eight objects and eleven relations.

```text
YODA_OBJECTS_STORED=8
YODA_RELATIONS_CREATED=11
VERIFY=PASS
RECORDS_SCANNED=19
RECORDS_VERIFIED=19
```

Byte-exact recovery:

```text
CONTROL_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
WATERMARKED_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
ORACLE_PARAMETERS_BYTE_EXACT_RECOVERY=PASS
```

Recovered identities:

```text
RECOVERED_CONTROL_SHA256=77aaf2a4d2fa522f84280420d1605f28c78a1913bd39e9ac4b628d45e3681a4f
RECOVERED_WATERMARKED_SHA256=16ce25bd9f444efcf3dd4adfd7b1732b5adc3f35289f6e498aa3ceabf0d0a1f4
```

Context recovery:

```text
CONTROL_PROVENANCE_CONTEXT=PASS
WATERMARKED_PROVENANCE_CONTEXT=PASS
COMPOSED_PROVENANCE_CONTEXT=PASS
```

Authoritative Yoda state:

```text
DATA_YODA_SHA256=3170d81272ae37a7d8ca4bddebf546ca9cced08a06c864f0f128a59da5facd60
DATA_YODA_BYTES=8318
```

Evidence:

```text
A1_EVIDENCE_MANIFEST_SHA256=8a8a5482bcd2b691bef8fb155c310633d3cbddaf171fb5a11f98b386406c9272
A1_SCRIPT_SHA256=64c16aa0871c991b359782133f4d405957070d9b19345de3b275485d24766081
A1_CONSOLE_SHA256=0c94f5f82cd4ee086cfc6e96aed1e6ee2d4cf7014329e522cd447e2faca1d1ae
```

The first A1 attempt was invalidated before Yoda writes because a harness literal for the expected watermarked SHA-256 was malformed. The actual artifact SHA-256 matched A0. The literal was repaired and validated at 64 characters before the successful rerun.

## Stage B — independent detector replay

Stage B used the artifacts recovered from Yoda.

The frozen SynthID Bio detector recalculated the measurements from those recovered sequences.

```text
ARM          SAMPLE   G_BEFORE   G_AFTER   RESULT
CONTROL      1        0.5037     0.5037    PASS
CONTROL      2        0.5130     0.5130    PASS
WATERMARKED  1        0.7961     0.7961    PASS
WATERMARKED  2        0.7184     0.7184    PASS
```

Equivalence gates:

```text
CONTROL_DETECTOR_EQUIVALENCE=PASS
WATERMARKED_DETECTOR_EQUIVALENCE=PASS
G_VALUE_MATRIX_EQUIVALENCE=PASS
CONTROL_SIGNAL_NOT_FABRICATED=PASS
WATERMARKED_SIGNAL_MEASUREMENT_PRESERVED=PASS
INTRINSIC_PROVENANCE_MEASUREMENT_EQUIVALENCE=PASS
EXTERNAL_WORKFLOW_PROVENANCE_RECOVERY=PASS
COMPOSED_PROVENANCE=PASS
```

Detector outputs:

```text
CONTROL_REDETECTED_OUTPUT_SHA256=3703c8e4fa018e0937349de8035cdee4227dd1c0f2580f9ce8065eb5e042f7cb
WATERMARKED_REDETECTED_OUTPUT_SHA256=be66095efec0a190bb6916d3d5ea5c1f0db60bca81ba93739d51200c3c9554a5
```

Evidence:

```text
B_EVIDENCE_MANIFEST_SHA256=e89730407d3d3ee6b76d76e4c0d9f8949a09ba90ccee585e1fc9113209693256
B_SCRIPT_SHA256=7a078e8432d3915c16e560ec41bcda39e03558346646ab8f4c4a6e18d115feea
B_CONSOLE_SHA256=7c24283e9782d9fb2275efbb78c21d8d05d53c283075fd71d9d7951df616dc8c
```

## Authority model

```text
SynthID Bio
→ intrinsic provenance measurement

Yoda
→ derivation integrity

Kyber
→ durable underlying state
```

The external authority remained external.

Yoda did not compute the g-values used to validate the CASE.

## Validated property

```text
independent authority
        ↓
measurement
        ↓
Yoda preservation + lineage
        ↓
byte-exact recovery
        ↓
same independent authority
        ↓
same measurement
```

This is evidence for an **independent authority replay** pattern and for **composed provenance** in one controlled SynthID Bio workflow.

It is not proof that the property holds for arbitrary authorities, arbitrary watermark systems or production biotechnology workloads.