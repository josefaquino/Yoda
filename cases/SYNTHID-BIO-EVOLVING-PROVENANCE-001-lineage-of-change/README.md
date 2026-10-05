# SYNTHID-BIO-EVOLVING-PROVENANCE-001

## Lineage of Change

This CASE asks a broader question than its biological test environment might suggest:

> **Can a legitimate change create a new identity without destroying the verifiable lineage of what existed before?**

The experiment uses a biological artifact and the public Google DeepMind SynthID Bio implementation because they provide a useful combination of:

- a concrete artifact state;
- a controlled transformation;
- an external measurement authority;
- a reproducible before/after evaluation.

The CASE is therefore not fundamentally about proteins, watermarking or SynthID Bio.

Those are the experimental instruments.

The property under test is **Lineage of Change**.

---

## The experiment in one diagram

```text
Artifact A
SHA=da6b1b6b...
g=0.7961
     │
     │ controlled random residue substitution
     │ 6 / 106 residues changed
     │ 5.660377% actual change
     ▼
Artifact B
SHA=defc9798...
g=0.6990
```

The new state has a new cryptographic identity and a different state-specific external measurement.

```text
identity(A) != identity(B)
g(A) != g(B)
```

That distinction is important.

The CASE does not require the external measurement to survive the transformation unchanged. It requires each state to remain independently identifiable, recoverable and independently evaluable.

---

## What Yoda preserved

A fresh Yoda store contained nine objects and eleven relations representing:

```text
Artifact A
Artifact B
Measurement A
Measurement B
Transformation A → B
Mutation table
SynthID Bio detector authority
SynthID Bio Supplementary authority
A1 experimental evidence
```

The central relationship was explicit:

```text
B --derived-from--> A
```

Other relations connected each state to its measurement authority and the transformation to its mutation evidence and public mechanism authority.

Yoda then recovered byte-exactly:

```text
Artifact A
Artifact B
Transformation record
Mutation table
Measurement A
Measurement B
```

Both artifact identities survived exactly:

```text
A recovered SHA = A original SHA
B recovered SHA = B original SHA
```

The Yoda store verified successfully before and after recovery.

No Yoda or Kyber engine change was made for the CASE.

---

## Context reconstruction without changing the product boundary

Yoda's frozen context semantics remain:

```text
lexical retrieval
+
direct 1-hop relational expansion
```

The CASE did not add arbitrary graph traversal.

Instead, the external harness composed five bounded evidence neighborhoods:

```text
artifact-B
artifact-A
random-residue-substitution
pre-transformation
post-transformation
```

That composition recovered the complete evidence set needed for this experiment:

```text
ARTIFACT_A_CONTEXT=PASS
ARTIFACT_B_CONTEXT=PASS
TRANSFORMATION_CONTEXT=PASS
MEASUREMENT_A_CONTEXT=PASS
MEASUREMENT_B_CONTEXT=PASS
FIVE_NEIGHBORHOOD_COMPOSITION=PASS
LINEAGE_OF_CHANGE_CONTEXT=PASS
VERSIONED_DERIVATION_RECOVERY=PASS
```

This boundary is intentional: Yoda preserved the graph and 1-hop evidence neighborhoods; the harness composed the bounded lineage required by the CASE.

---

## The decisive gate: independent state replay

The final stage did not trust Yoda to assert that the recovered states were still equivalent to their originals.

Instead, the artifacts recovered from Yoda were returned to the same frozen external measurement authority: the public SynthID Bio detector.

The original A1 artifacts were not used for this replay.

Observed matrix:

```text
STATE        BEFORE    AFTER YODA RECOVERY
Artifact A   0.7961    0.7961
Artifact B   0.6990    0.6990
```

Result:

```text
ARTIFACT_A_MEASUREMENT_REPLAY=PASS
ARTIFACT_B_MEASUREMENT_REPLAY=PASS
STATE_SPECIFIC_MEASUREMENT_REPLAY=PASS
INDEPENDENT_STATE_REPLAY=PASS
LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS
```

The key pattern is:

```text
independent authority
        ↓
evaluates A
        ↓
controlled transformation
        ↓
evaluates B
        ↓
       Yoda
        ↓
byte-exact recovery of A and B
        ↓
same independent authority
        ↓
re-evaluates A and B
        ↓
same state-specific measurements
```

---

## What changed relative to previous CASEs

### GENOME-LINEAGE-001

Question:

> **Where did this result come from?**

Observed property:

```text
LINEAGE OF STATE
```

### SYNTHID-BIO-YODA-PROVENANCE-001

Question:

> **Can intrinsic provenance and external derivation provenance coexist?**

Observed property:

```text
COMPOSED PROVENANCE
```

### SYNTHID-BIO-EVOLVING-PROVENANCE-001

Question:

> **How did this become what it is now?**

Observed property:

```text
LINEAGE OF CHANGE
```

---

## The important distinction

Artifact B did not need Artifact A to be destroyed.

The experiment preserved:

```text
A continues to exist
B continues to exist
A → B remains explainable
```

That is different from preserving only the current version.

The demonstrated property is not merely that two versions can be stored. It is that the evidence of the transition between them remains recoverable and can be returned to an independent authority for state-specific evaluation.

A compact formulation is:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

For Yoda, the product-level interpretation is:

> **Yoda preserves not only where a result came from, but how it became what it is now.**

---

## Authority model

```text
SynthID Bio detector
→ independent state-specific measurement authority

SynthID Bio Supplementary Information
→ public transformation-mechanism authority

Yoda
→ derivation integrity

Kyber
→ durable state integrity
```

One architectural interpretation is:

```text
Lineage of Change
=
derivation integrity across state transitions
```

This CASE does not introduce a new engine subsystem called Lineage of Change. It demonstrates a property that emerges from the existing evidence, relation, recovery and authority-separation model.

---

## What was demonstrated

The strongest narrow claim supported by this CASE is:

> **For one controlled biological-artifact transformation, Yoda preserved two distinct artifact states, the verifiable derivation between them, and the associated transformation and measurement evidence such that the independent SynthID Bio detector reproduced each state's original measurement after byte-exact recovery.**

Final classification:

```text
SYNTHID_BIO_EVOLVING_PROVENANCE_001=VALIDATED
LINEAGE_OF_CHANGE=DEMONSTRATED
INDEPENDENT_AUTHORITY_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
FINAL_EVIDENCE_INTEGRITY=PASS
```

Final evidence authority:

```text
FINAL_EVIDENCE_MANIFEST_SHA256=e46bcb223be3264f97390abac792a889b5a79033d9ff55eb8f400c818ebcc17a
```

---

## What was not demonstrated

This CASE does **not** establish that:

- Yoda detects SynthID Bio watermarks;
- Yoda proves authorship;
- Yoda proves biological origin;
- Yoda proves biological function;
- Yoda validates watermark robustness;
- Yoda measures watermark-removal efficacy;
- Yoda proves scientific truth;
- every transformation should preserve prior states;
- Lineage of Change holds universally across arbitrary domains or transformations;
- arbitrary multi-hop graph traversal exists in Yoda `context`;
- Google DeepMind participated in, endorsed or partnered on this CASE;
- production biotechnology readiness or product-market fit has been established.

Google DeepMind remained an independent external public-code and publication authority.

---

## Frozen identities

```text
DEEPMIND_COMMIT=acd75747b14c7f4c3c65ad1e6af1483aeba47614
DETECTOR_SHA256=dfabbf49f555152808272639a6ce1acf09bdc11920f71559481955df7f857727
SUPPLEMENTARY_SHA256=6b9cadfdbc70e54eb711fc670139a1f7f61c4a79cafd965b6e0c2ba651887b04

ARTIFACT_A_SHA256=da6b1b6b239fc3c870f9750f7b29c816f4d700462a160fc8ced7922dbecbfad0
ARTIFACT_B_SHA256=defc97981f115f1c1792e53946dcf81f5cce28fafdcccf917c80470fa3cfaa00

A0_EVIDENCE_MANIFEST_SHA256=ed41b4238e92ea174d8a8cc6a0b285ca4a7fa3a781dfd545478d5d07eab9c610
A0_1_EVIDENCE_MANIFEST_SHA256=30b1a85695f28f6ccc60b26f252b517a1633fec862ac725fdb04909da07585c2
A1_EVIDENCE_MANIFEST_SHA256=2dd1298ec9e91ef03c332f1cac00c08bb1fe79d3478fbd45f89801efe1ef449f
A2_EVIDENCE_MANIFEST_SHA256=ab4e996f28d5d70995620f5d14d2e50886eec1d493955b31b419624fab735728
STAGE_B_EVIDENCE_MANIFEST_SHA256=6eba74b9b659db8950c3fd7d0e5b39b0c7fcae49fa2682023c3a528c7f87b8a7

DATA_YODA_SHA256=0aac02391eec12c2caa2a0bca725af6ddcdab4530c2153002b6673a7e7729954
REPLAY_CONTRACT_SHA256=ccdd19b43094b883f682e235a50fd21e06d1c4cfa08531560c9549768548d2c9
FINAL_EVIDENCE_MANIFEST_SHA256=e46bcb223be3264f97390abac792a889b5a79033d9ff55eb8f400c818ebcc17a
```

For the experiment contract, detailed results and motivation, see:

- [CASE.md](CASE.md)
- [RESULTS.md](RESULTS.md)
- [WHY-WE-BUILT-THIS.md](WHY-WE-BUILT-THIS.md)
