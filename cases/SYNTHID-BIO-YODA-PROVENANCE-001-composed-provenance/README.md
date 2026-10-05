# SYNTHID-BIO-YODA-PROVENANCE-001

## Composed provenance: intrinsic artifact signal + external derivation lineage

This CASE tests whether two different forms of provenance can coexist without either losing its identity:

- **SynthID Bio** as the independent intrinsic provenance-signal authority;
- **Yoda** as the external derivation-lineage and evidence layer.

The question is not whether Yoda can detect a SynthID watermark.

It cannot and does not claim to.

The question is:

> **Can Yoda preserve the biological artifacts and external workflow provenance byte-exactly such that the official SynthID Bio detector reproduces the same intrinsic provenance measurements after Yoda recovery?**

---

## Authority separation

```text
Google DeepMind SynthID Bio
→ intrinsic provenance measurement

Yoda
→ external derivation integrity
```

The authorities remain separate throughout the experiment.

SynthID Bio computes the measurement from the biological sequence using the frozen official detector and parameters.
Yoda stores and reconstructs the artifacts, measurement evidence, tool identity, parameters, relationships and history around those artifacts.

---

## Stage A0 — DeepMind oracle authority

The official public repository was frozen at:

```text
REPOSITORY=google-deepmind/synthidbio
COMMIT=acd75747b14c7f4c3c65ad1e6af1483aeba47614
```

The official DeepMind tests were reproduced in an isolated Python 3.9 environment.

Both arms passed:

```text
OFFICIAL_NON_WATERMARKED_TEST=PASS
OFFICIAL_WATERMARKED_TEST=PASS
OFFICIAL_G_VALUE_TEST=PASS
OFFICIAL_STANDALONE_DETECTOR=PASS
EXPECTED_G_VALUES=PASS
```

Frozen 5L33 measurements:

```text
CONTROL
sample 1 = 0.5037
sample 2 = 0.5130

WATERMARKED
sample 1 = 0.7961
sample 2 = 0.7184
```

No Yoda write occurred in A0.

```text
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## Stage A1 — Yoda composed-provenance ingest

A frozen Yoda binary was used:

```text
YODA_SHA256=1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
```

Yoda stored eight objects representing:

- control 5L33 artifact;
- watermarked 5L33 artifact;
- control measurement;
- watermarked measurement;
- SynthID Bio oracle identity;
- detector/generation parameters;
- frozen A0 summary;
- frozen A0 evidence authority.

Eleven explicit relations connected the artifacts, measurements, oracle, parameters and evidence.

Yoda verified the resulting state:

```text
VERIFY=PASS
RECORDS_SCANNED=19
RECORDS_VERIFIED=19
```

The relevant objects were recovered byte-exactly:

```text
CONTROL_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
WATERMARKED_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
ORACLE_PARAMETERS_BYTE_EXACT_RECOVERY=PASS
```

The recovered one-hop contexts included the expected measurement, oracle and evidence relationships for both arms:

```text
CONTROL_PROVENANCE_CONTEXT=PASS
WATERMARKED_PROVENANCE_CONTEXT=PASS
COMPOSED_PROVENANCE_CONTEXT=PASS
```

Important: the SynthID Bio detector was **not** rerun in A1.

```text
DETECTOR_RERUN=NO
```

### Invalid A1 attempt

The first A1 attempt stopped before any Yoda write because a harness literal for the expected watermarked SHA-256 was malformed.

The actual artifact SHA-256 still matched the value homologated in A0.

The attempt was classified as an invalid harness attempt, not a product or scientific failure.

The literal was repaired and validated at exactly 64 characters before A1 was rerun successfully.

---

## Stage B — independent detector equivalence

Stage B consumed the artifacts recovered from Yoda, not the original A0 files.

The same frozen DeepMind source commit and detector were used.

The official detector recalculated the g-values from the recovered biological sequences.

The before/after matrix was:

```text
ARM          SAMPLE   BEFORE   AFTER
CONTROL      1        0.5037   0.5037
CONTROL      2        0.5130   0.5130
WATERMARKED  1        0.7961   0.7961
WATERMARKED  2        0.7184   0.7184
```

All four comparisons passed exactly:

```text
CONTROL_DETECTOR_EQUIVALENCE=PASS
WATERMARKED_DETECTOR_EQUIVALENCE=PASS
G_VALUE_MATRIX_EQUIVALENCE=PASS
```

The control arm remained control-like under the same measurement protocol, while the watermarked arm reproduced the original measurements:

```text
CONTROL_SIGNAL_NOT_FABRICATED=PASS
WATERMARKED_SIGNAL_MEASUREMENT_PRESERVED=PASS
```

---

## What was demonstrated

The strongest narrow claim supported by this CASE is:

> **For one controlled SynthID Bio workflow, Yoda preserved external workflow provenance and recovered the biological artifacts byte-exactly, while the independent SynthID Bio detector reproduced the same intrinsic provenance measurements after recovery.**

This demonstrates a composition pattern:

```text
biological artifact
      │
      ├── intrinsic provenance measurement → SynthID Bio
      │
      └── external derivation lineage       → Yoda
```

Or more compactly:

> **SynthID Bio measures an intrinsic provenance signal. Yoda preserves the external derivation required to inspect and replay the surrounding evidence.**

---

## What was not demonstrated

This CASE does **not** establish that:

- Yoda detects SynthID Bio watermarks;
- Yoda proves biological origin;
- Yoda authenticates proteins;
- a g-value alone proves authorship or ownership;
- Yoda verifies biological function;
- Yoda replaces SynthID Bio;
- Yoda replaces ProteinMPNN;
- arbitrary watermarking systems are supported;
- the system is production-ready for biotechnology workflows;
- Google DeepMind participated in or endorsed this experiment;
- a partnership with Google DeepMind exists;
- product-market fit exists.

Google DeepMind remained an independent external software authority through its public code and tests.

---

## Frozen identities

```text
DEEPMIND_COMMIT=acd75747b14c7f4c3c65ad1e6af1483aeba47614

CONTROL_5L33_SHA256=77aaf2a4d2fa522f84280420d1605f28c78a1913bd39e9ac4b628d45e3681a4f
WATERMARKED_5L33_SHA256=16ce25bd9f444efcf3dd4adfd7b1732b5adc3f35289f6e498aa3ceabf0d0a1f4

A0_EVIDENCE_MANIFEST_SHA256=3114caf012ee41f3be15dae292f688299e872cef180dd3073750f05a4cee038e
A1_EVIDENCE_MANIFEST_SHA256=8a8a5482bcd2b691bef8fb155c310633d3cbddaf171fb5a11f98b386406c9272
B_EVIDENCE_MANIFEST_SHA256=e89730407d3d3ee6b76d76e4c0d9f8949a09ba90ccee585e1fc9113209693256

DATA_YODA_SHA256=3170d81272ae37a7d8ca4bddebf546ca9cced08a06c864f0f128a59da5facd60
DATA_YODA_BYTES=8318

A1_SCRIPT_SHA256=64c16aa0871c991b359782133f4d405957070d9b19345de3b275485d24766081
A1_CONSOLE_SHA256=0c94f5f82cd4ee086cfc6e96aed1e6ee2d4cf7014329e522cd447e2faca1d1ae

B_SCRIPT_SHA256=7a078e8432d3915c16e560ec41bcda39e03558346646ab8f4c4a6e18d115feea
B_CONSOLE_SHA256=7c24283e9782d9fb2275efbb78c21d8d05d53c283075fd71d9d7951df616dc8c
```

---

## Result

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
