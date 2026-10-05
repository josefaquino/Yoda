# CASE — SYNTHID-BIO-YODA-PROVENANCE-001

## Question

Can an intrinsic provenance signal measured by an independent authority coexist with Yoda's external workflow provenance such that, after byte-exact recovery from Yoda, the same authority reproduces the same measurement?

## Authority separation

The CASE deliberately separates responsibilities:

```text
Google DeepMind SynthID Bio
→ intrinsic provenance measurement

Yoda
→ external derivation integrity

Kyber
→ underlying durable state
```

Yoda is not allowed to detect, infer or substitute for the SynthID Bio signal.
SynthID Bio is not asked to reconstruct workflow lineage.

## Frozen external authority

```text
repository=google-deepmind/synthidbio
commit=acd75747b14c7f4c3c65ad1e6af1483aeba47614
```

The official SynthID Bio tests and detector were executed in an isolated Python 3.9 environment, following the frozen public implementation.

## Stage A0 — Oracle authority

A0 contains no Yoda write.

It must reproduce the official control and watermarked behavior before Yoda enters the experiment.

PASS requires:

```text
OFFICIAL_REPO_CLONE=PASS
FROZEN_COMMIT=PASS
TEST_DATASET_IDENTITY=PASS
OFFICIAL_NON_WATERMARKED_TEST=PASS
OFFICIAL_WATERMARKED_TEST=PASS
OFFICIAL_G_VALUE_TEST=PASS
OFFICIAL_STANDALONE_DETECTOR=PASS
EXPECTED_G_VALUES=PASS
ORACLE_EVIDENCE_FREEZE=PASS
YODA_WRITES=ZERO
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

## Stage A1 — Composed provenance ingest

Yoda must store and relate:

- control artifact;
- watermarked artifact;
- control measurement;
- watermarked measurement;
- SynthID Bio authority identity;
- detector/generation parameters;
- A0 evidence summary;
- A0 evidence authority.

PASS requires:

```text
YODA_AUTHORITY=PASS
A0_EVIDENCE_AUTHORITY=PASS
YODA_OBJECT_INGEST=PASS
COMPOSED_PROVENANCE_RELATIONS=PASS
CONTROL_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
WATERMARKED_ARTIFACT_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
ORACLE_PARAMETERS_BYTE_EXACT_RECOVERY=PASS
CONTROL_PROVENANCE_CONTEXT=PASS
WATERMARKED_PROVENANCE_CONTEXT=PASS
COMPOSED_PROVENANCE_CONTEXT=PASS
FINAL_YODA_VERIFY=PASS
```

The detector must not be rerun in A1.

```text
DETECTOR_RERUN=NO
```

## Stage B — Independent detector replay

Stage B must consume the artifacts recovered from Yoda, not the original A0 files.

The frozen SynthID Bio detector must recompute the g-values from those recovered sequences using the correct parameters for each arm.

PASS requires exact measurement equivalence:

```text
CONTROL
0.5037 == 0.5037
0.5130 == 0.5130

WATERMARKED
0.7961 == 0.7961
0.7184 == 0.7184
```

And:

```text
CONTROL_DETECTOR_EQUIVALENCE=PASS
WATERMARKED_DETECTOR_EQUIVALENCE=PASS
G_VALUE_MATRIX_EQUIVALENCE=PASS
INTRINSIC_PROVENANCE_MEASUREMENT_EQUIVALENCE=PASS
EXTERNAL_WORKFLOW_PROVENANCE_RECOVERY=PASS
COMPOSED_PROVENANCE=PASS
```

## Control requirement

The non-watermarked arm is mandatory.

The CASE must demonstrate both:

```text
Yoda does not destroy the measured signal that exists.
Yoda does not fabricate the measured signal in the control arm.
```

## Forbidden shortcuts

The CASE must not:

- add SynthID-specific logic to Yoda;
- modify Yoda or Kyber to make the CASE pass;
- infer watermark presence from Yoda metadata;
- substitute a Yoda-computed metric for the official detector;
- compare only the positive arm;
- claim that a g-value alone proves authorship or biological origin;
- imply Google DeepMind participation, endorsement or partnership.

## Invalid harness attempt

The first A1 attempt stopped before any Yoda write because the expected watermarked SHA-256 literal in the harness was malformed.

The actual artifact identity still matched A0. The attempt was classified as an invalid harness attempt, repaired, and rerun successfully.

## Success claim

If all stages pass, the permitted claim is:

> For one controlled SynthID Bio workflow, Yoda preserved external workflow provenance and recovered the biological artifacts byte-exactly, while the independent SynthID Bio detector reproduced the same intrinsic provenance measurements after recovery.

## Non-claims

The CASE does not establish biological truth, protein authentication, proof of authorship, general watermark support, biotechnology-scale readiness, Google DeepMind endorsement, or product-market fit.