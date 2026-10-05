# CASE — SYNTHID-BIO-EVOLVING-PROVENANCE-001

## Research question

Can Yoda preserve a versioned derivation across a controlled biological-artifact transformation while an independent authority continues evaluating each state independently?

The broader question is:

> **Can a legitimate change create a new identity without destroying the verifiable lineage of what existed before?**

This CASE uses a biological artifact, Google DeepMind's public SynthID Bio implementation and a controlled residue-substitution transformation as the experimental environment. The property under test is not specific to proteins or watermarking.

---

## Authority separation

The experiment separates four responsibilities:

```text
Google DeepMind SynthID Bio detector
→ independent state-specific measurement authority

Google DeepMind SynthID Bio Supplementary Information
→ public transformation-mechanism authority

Yoda
→ derivation / lineage-of-change integrity

Kyber
→ underlying durable state integrity
```

Yoda is not allowed to compute, infer or substitute for the SynthID Bio measurement.

The external detector is not asked to reconstruct derivation lineage.

---

## Frozen public authority

```text
repository=google-deepmind/synthidbio
commit=acd75747b14c7f4c3c65ad1e6af1483aeba47614

detector_sha256=dfabbf49f555152808272639a6ce1acf09bdc11920f71559481955df7f857727
supplementary_sha256=6b9cadfdbc70e54eb711fc670139a1f7f61c4a79cafd965b6e0c2ba651887b04
```

The public Nature paper and Supplementary Information describe random residue substitution as a transformation mechanism and evaluate substitution percentages including 5%.

The CASE adopts that public mechanism but uses its own deterministic, case-controlled selection and replacement algorithm. It does not claim to reproduce DeepMind's exact random implementation or a specific published biological result.

---

## Stage A0 — transformation authority

A0 establishes the public scientific/software authority before the selected transformation is performed.

It freezes:

- the public SynthID Bio repository and commit;
- the official detector identity;
- the Supplementary Information identity;
- relevant transformation mechanisms;
- ProteinMPNN defaults originally considered for resequencing;
- the boundary between public authority and case-controlled execution.

No Yoda write is allowed.

Frozen evidence:

```text
A0_EVIDENCE_MANIFEST_SHA256=ed41b4238e92ea174d8a8cc6a0b285ca4a7fa3a781dfd545478d5d07eab9c610
YODA_WRITES=ZERO
```

---

## Stage A0.1 — transformation topology authority

The CASE selects `RANDOM_RESIDUE_SUBSTITUTION` instead of resequencing because it provides a cleaner direct sequence-to-sequence causal topology for the property under test.

Frozen topology:

```text
TRANSFORMATION_TOPOLOGY=DIRECT_A_TO_B
TARGET_PERCENT=5
CASE_SEED=SYNTHID-BIO-EVOLVING-PROVENANCE-001-A1-RANDOM-SUBSTITUTION-V1
```

The public mechanism authority and the case implementation are deliberately separated:

```text
DEEPMIND_TRANSFORMATION_MECHANISM_AUTHORITY=YES
CASE_RANDOMIZATION_IMPLEMENTATION=YODA_CASE_CONTROLLED
```

Frozen evidence:

```text
A0_1_EVIDENCE_MANIFEST_SHA256=30b1a85695f28f6ccc60b26f252b517a1633fec862ac725fdb04909da07585c2
TRANSFORMATION_TOPOLOGY_CONTRACT_SHA256=6c4e0d9e9455b9437768f020aaa13262ce4ef3bf709d9da7a37dee2bba0c9488
```

---

## Stage A1 — controlled transformation

A1 starts from the previously frozen watermarked 5L33 sample 1.

Artifact A:

```text
ARTIFACT_A_SEQUENCE_LENGTH=106
ARTIFACT_A_SHA256=da6b1b6b239fc3c870f9750f7b29c816f4d700462a160fc8ced7922dbecbfad0
G_A=0.7961
```

The CASE applies a deterministic 5% target substitution transformation.

For a 106-residue sequence, the mutation-count contract uses `ceil(106 × 0.05) = 6`.

Observed transformation:

```text
MUTATION_COUNT=6
ACTUAL_CHANGED_PERCENT=5.660377
CONTROLLED_TRANSFORMATION=PASS
```

Artifact B:

```text
ARTIFACT_B_SHA256=defc97981f115f1c1792e53946dcf81f5cce28fafdcccf917c80470fa3cfaa00
G_B=0.6990
NEW_IDENTITY_CREATED=PASS
```

The CASE explicitly does not require the two measurements to be equal:

```text
G_A_EQUALS_G_B=NO
G_A_EQUALS_G_B_REQUIRED=NO
```

The selected positions, replacements and deterministic hashes are frozen in the mutation table.

Frozen evidence:

```text
TRANSFORMATION_RECORD_SHA256=293b22a4c0d6db799850dc8d73e1c043353f44224960b08a7fda7374d5c31b47
A1_EVIDENCE_MANIFEST_SHA256=2dd1298ec9e91ef03c332f1cac00c08bb1fe79d3478fbd45f89801efe1ef449f
```

No Yoda write occurs in A1.

---

## Stage A2 — versioned derivation in Yoda

A fresh Yoda store must preserve both states and the evidence connecting them.

The frozen Yoda authority is:

```text
YODA_SHA256=1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
```

A2 stores nine objects:

- Artifact A;
- Artifact B;
- Measurement A;
- Measurement B;
- Transformation A → B;
- Mutation table;
- SynthID Bio detector authority;
- SynthID Bio Supplementary authority;
- A1 evidence summary.

It creates eleven explicit relations, including:

```text
B --derived-from--> A
B --transformed-by--> Transformation

A --has-measurement--> Measurement A
B --has-measurement--> Measurement B

Measurement A --measured-by--> SynthID Bio detector
Measurement B --measured-by--> SynthID Bio detector

Transformation --has-mutation-table--> Mutation table
Transformation --defined-by--> Supplementary authority
Transformation --has-evidence--> A1 evidence
```

PASS requires byte-exact recovery of both artifacts, the transformation record, mutation table and measurements.

The CASE respects the frozen Yoda context boundary:

```text
context = lexical retrieval + direct 1-hop relational expansion
```

Arbitrary multi-hop graph traversal is not claimed. The harness may compose bounded 1-hop neighborhoods externally.

A2 therefore composes five neighborhoods:

```text
artifact-B
artifact-A
random-residue-substitution
pre-transformation
post-transformation
```

PASS requires:

```text
YODA_OBJECT_INGEST=PASS
VERSIONED_DERIVATION_RELATIONS=PASS
ARTIFACT_A_BYTE_EXACT_RECOVERY=PASS
ARTIFACT_B_BYTE_EXACT_RECOVERY=PASS
TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS
MUTATION_TABLE_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
FIVE_NEIGHBORHOOD_COMPOSITION=PASS
LINEAGE_OF_CHANGE_CONTEXT=PASS
VERSIONED_DERIVATION_RECOVERY=PASS
FINAL_YODA_VERIFY=PASS
```

Frozen A2 authority:

```text
DATA_YODA_SHA256=0aac02391eec12c2caa2a0bca725af6ddcdab4530c2153002b6673a7e7729954
DATA_YODA_BYTES=9971
A2_EVIDENCE_MANIFEST_SHA256=ab4e996f28d5d70995620f5d14d2e50886eec1d493955b31b419624fab735728
```

---

## Stage B — independent state replay

Stage B may consume only the artifacts recovered from Yoda, not the original A1 artifacts.

The same frozen SynthID Bio detector must evaluate each recovered state independently.

PASS requires exact state-specific measurement replay:

```text
Artifact A
0.7961 == 0.7961

Artifact B
0.6990 == 0.6990
```

And:

```text
STATE_A_MEASUREMENT_EQUIVALENCE=PASS
STATE_B_MEASUREMENT_EQUIVALENCE=PASS
STATE_SPECIFIC_MEASUREMENT_REPLAY=PASS
INDEPENDENT_STATE_REPLAY=PASS
LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS
```

Frozen Stage B authority:

```text
REPLAY_CONTRACT_SHA256=ccdd19b43094b883f682e235a50fd21e06d1c4cfa08531560c9549768548d2c9
STAGE_B_EVIDENCE_MANIFEST_SHA256=6eba74b9b659db8950c3fd7d0e5b39b0c7fcae49fa2682023c3a528c7f87b8a7
```

Stage B performs no Yoda write.

---

## Harness-attempt discipline

Several executions were intentionally classified as invalid harness attempts rather than scientific or product failures:

- A1 Attempt 001: malformed Bash parameter expansion during Artifact B generation;
- A1 Attempt 002: a second malformed parameter expansion during Hamming verification;
- A2 Attempt 001: exact Yoda keys were incorrectly supplied as lexical `context` queries;
- A2 Attempt 002: the harness incorrectly expected complete multi-hop closure from three 1-hop contexts.

Each failure was isolated, preserved as evidence, repaired without changing the scientific hypothesis or the Yoda/Kyber engines, and rerun.

The successful runs used the same frozen authorities and claim boundaries.

---

## Forbidden shortcuts

The CASE must not:

- add SynthID-specific logic to Yoda;
- change Yoda or Kyber to make the CASE pass;
- treat Yoda as the detector authority;
- require `g(A) == g(B)`;
- claim watermark-removal efficacy;
- claim watermark robustness;
- claim biological-function preservation;
- claim that a g-value proves authorship or biological origin;
- imply Google DeepMind participation, endorsement or partnership;
- claim arbitrary multi-hop graph traversal from Yoda `context`;
- generalize one controlled transformation into a universal property.

---

## Success claim

If all stages pass, the permitted narrow claim is:

> **For one controlled biological-artifact transformation, Yoda preserved two distinct artifact states, the verifiable derivation between them, and the associated transformation and measurement evidence such that the independent SynthID Bio detector reproduced each state's original measurement after byte-exact recovery.**

The architectural property name is:

```text
LINEAGE_OF_CHANGE
```

Within the defined scope, successful final homologation permits:

```text
LINEAGE_OF_CHANGE=DEMONSTRATED
```

A compact interpretation is:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

---

## Non-claims

The CASE does not establish biological truth, biological function, protein authentication, proof of authorship, proof of biological origin, watermark robustness, watermark-removal performance, production biotechnology readiness, universal lineage-of-change support, Google DeepMind endorsement, or product-market fit.
