# Evidence

Yoda is developed through narrow, reproducible CASEs.

A successful demo is not treated as proof of a broad product or market claim.

Each CASE should answer one question, freeze its evidence, preserve negative results and make the next question clearer.

---

## Research rule

```text
one question
one hypothesis
one controlled experiment
explicit PASS / FAIL gates
frozen evidence
independent authority where possible
no speculative engine change
```

> **Big vision. Small steps. Evidence always.**

Public claims should be traceable through:

```text
EVIDENCE
   ↓
FORMAL PROPERTY
   ↓
PROJECT THESIS
   ↓
PUBLIC LANGUAGE
```

---

# Cross-domain evidence map

| CASE | Domain | Property tested | Status |
|---|---|---|---|
| FIRMS-001 | Satellite observations | fact / decision equivalence | PASS |
| USGS-001 | Earthquake events | external identity + replay | PASS |
| BGP-RIPE-RIS-001 | Internet routing | mutation-state equivalence | PASS |
| YODA-GITHUB-WORK-QUEUE-001 | Agent workloads | real task identity preservation through concurrent local execution state | PASS |
| YODA-GITHUB-WORK-CONTEXT-001 | Agent workloads | exact task identity + minimal useful context preservation | PASS |
| YODA-EDGAR-FILING-CONTEXT-001-R1 | Public financial reporting | successive financial state + exact context + accession-level provenance | PASS |
| YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001 | Public financial reporting | same canonical value + distinct regulatory state + exact document provenance | PASS |
| YODA-CVM-AGENTIC-CONTEXT-001 | Context-governed deterministic evaluation | recoverable state + versioned context + rule + deterministic allow/refuse replay | PASS |
| AUDIT-FORENSICS-001 | Security events | exact ledger + tamper rejection | PASS |
| GENOME-KMER-001 | Genomics | exact indexed state | PASS |
| GENOME-REFERENCE-001 | Genomics | reference coordinate equivalence | PASS |
| GENOME-READ-001 | Genomics | paired-read state preservation | PASS |
| GENOME-ALIGNMENT-001 | Genomics | workflow-derived alignment state | PASS |
| GENOME-VARIANT-001 | Genomics | downstream workflow continuity | PASS |
| GENOME-LINEAGE-001 | Genomics | verifiable scientific lineage | PASS |
| AXIOM-YODA-PROOF-LINEAGE-001 | Formal verification | independent formal decision replay | PASS |
| SYNTHID-BIO-YODA-PROVENANCE-001 | Biological artifact provenance | composed provenance + independent measurement replay | PASS |
| SYNTHID-BIO-EVOLVING-PROVENANCE-001 | Controlled evolving artifact | Lineage of Change + state-specific authority replay | PASS |
| FORMAL-MATH-EVOLVING-DERIVATION-001 | Formal mathematics | cross-domain Lineage of Change + independent Lean/OxiLean replay | PASS |
| MARKET-REGIME-LINEAGE-001 | Deterministic public-data decisions | Decision Lineage + Yoda-only independent classification replay | PASS |

Negative experiments and invalid harness attempts remain evidence when they are classified honestly.


---

# Agent workloads — real GitHub work-identity preservation

`YODA-GITHUB-WORK-QUEUE-001` tested the frozen Yoda C23 execution path with 100 public GitHub issues from `kubernetes/kubernetes`.

The real workload path was:

```text
GitHub issues
    ↓
Frontier
    ↓
Agent Driver / Seeker
    ↓
Yoda Mesh
    ↓
Shield
    ↓
KyberDB WAL
    ↓
Lakehouse NDJSON
```

Runtime:

```text
TASKS=100
WORKERS=16
BATCH_SIZE=10
SYSTEM_RC=0
```

An independent read-only validator then reconciled the existing artifacts without rerunning the product:

```text
FRONTIER_INITIAL_LINES=100
FRONTIER_FINAL_PROCESSING=100
FRONTIER_FINAL_QUEUED=0

EXPECTED_KEYS=100

WAL_RECORDS=100
WAL_UNIQUE_KEYS=100
EXPECTED_EQUALS_WAL=1

LAKEHOUSE_RECORDS=100
LAKEHOUSE_UNIQUE_KEYS=100
EXPECTED_EQUALS_LAKEHOUSE=1

MISSING=0
DUPLICATE=0
EXTRA=0
```

The executed frozen binary identity was:

```text
7510fc055e1d53b0471077f4b8cb5a32c08828a0fb9f40c2e81a8859750b55c3
```

Final classification:

```text
YODA_GITHUB_WORK_QUEUE_001=PASS
VALIDATION_MODE=READ_ONLY
PRODUCT_RERUN=NO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The demonstrated property is intentionally narrow:

> **The frozen Yoda C23 stack preserved the identity of 100 real public development tasks through concurrent task admission, local persistence, materialization, and exact reconciliation.**

This case does not claim that Yoda solved, understood, prioritized, or modified the GitHub issues. It validates work-identity handling for a real agent-oriented workload.

See:

`cases/YODA-GITHUB-WORK-QUEUE-001-real-agent-work-queue/`

---

# Agent workloads — real GitHub task-context preservation

`YODA-GITHUB-WORK-CONTEXT-001` reused the exact 100 public GitHub issue identities from the preceding work-queue case and changed one product property:

```text
BEFORE
task identity

        ↓

AFTER
task identity
+
minimal useful task context
```

The preserved compact context contained:

```text
number
title
state
labels
created_at
updated_at
```

The candidate path was:

```text
GitHub source context
        ↓
Frontier
        ↓
Agent Driver / Seeker
        ↓
Yoda Mesh
        ↓
KyberDB WAL
        ↓
Lakehouse NDJSON
```

Runtime:

```text
TASKS=100
WORKERS=16
BATCH_SIZE=10
SYSTEM_RC=0
PRODUCT_EXECUTION_COUNT=1
PRODUCT_RERUN=NO
```

Independent read-only adjudication confirmed exact identity and context reconciliation:

```text
EXPECTED_IDENTITIES=100
EXPECTED_CONTEXTS=100

FRONTIER_FINAL_PROCESSING=100
FRONTIER_FINAL_QUEUED=0

KYBER_RECORDS=100
KYBER_TO_SOURCE_CONTEXT_MATCH=1
WAL_BYTE_EXACT_ORACLE=1

LAKEHOUSE_RECORDS=100
LAKEHOUSE_JSON_VALID=1
LAKEHOUSE_INNER_CONTEXT_JSON_VALID=1
LAKEHOUSE_TO_SOURCE_CONTEXT_MATCH=1

MISSING_IDENTITIES=0
DUPLICATE_IDENTITIES=0
EXTRA_IDENTITIES=0

MISSING_CONTEXTS=0
CONTEXT_MISMATCHES=0
EXTRA_CONTEXTS=0
```

The strongest byte-level evidence was:

```text
EXPECTED_CONTEXT_SHA256=
c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6

KYBER_WAL_SHA256=
c0cf7249996f0bf33602ef3e1ade9d9175279e81d38fb3f4b2b0c1fb1a02cee6
```

The complete Kyber WAL was therefore byte-for-byte identical to the independently expected key/context oracle for the tested workload.

The candidate required four localized source changes:

```text
yoda_agent_driver.h
yoda_agent_driver.c
yoda_mesh.c
yoda_lakehouse.c
```

KyberDB remained unchanged, and the frozen baseline remained untouched:

```text
KYBER_CHANGE=NO
BASELINE_CHANGED=NO
```

Final classification:

```text
YODA_GITHUB_WORK_CONTEXT_001=PASS
VALIDATION_MODE=READ_ONLY
PRODUCT_EXECUTION_COUNT=1
PRODUCT_RERUN=NO
TOTAL_FAILURES=0
```

The demonstrated property is intentionally narrow:

> **Yoda preserved both the identity and the minimal useful context of 100 real public agent tasks across concurrent execution, local persistence, and materialization, with zero missing, duplicate, extra, or mismatched records.**

This does not claim that Yoda solved, semantically understood, prioritized, or modified the GitHub issues. It demonstrates exact preservation of bounded useful task context.

See:

`cases/YODA-GITHUB-WORK-CONTEXT-001-real-agent-task-context/`

---

# Public financial reporting — successive state + exact provenance

`YODA-EDGAR-FILING-CONTEXT-001-R1` tested whether the same context-capable Yoda binary used for real GitHub task context could preserve successive public financial states without a finance-specific engine path.

The source chain used SEC EDGAR + XBRL facts for NVIDIA `us-gaap:OtherAccruedLiabilitiesCurrent`, unit `USD`, at reporting date `2022-01-30`:

```text
2022-03-18  10-K  0001045810-22-000036  647000000
2022-05-27  10-Q  0001045810-22-000079  515000000
2022-08-31  10-Q  0001045810-22-000147  469000000
2022-11-18  10-Q  0001045810-22-000166  469000000
2023-02-24  10-K  0001045810-23-000017  371000000
```

Frozen source property:

```text
SOURCE_STATES=5
UNIQUE_ACCESSIONS=5
DISTINCT_VALUES=4
VALUE_469M_DISTINCT_STATES=2
```

R1 reused:

```text
PRODUCT_BINARY_SHA256=
8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

YODA_CHANGE=NO
KYBER_CHANGE=NO
CROSS_DOMAIN_BINARY_REUSE=PASS
```

Independent read-only adjudication confirmed:

```text
EXPECTED_IDENTITIES=5
EXPECTED_UNIQUE_IDENTITIES=5

FRONTIER_UNIQUE_IDENTITIES=5
FRONTIER_IDENTITY_EXACT_MATCH=PASS
FRONTIER_CONTEXT_EXACT_MATCH=PASS

KYBER_UNIQUE_IDENTITIES=5
KYBER_IDENTITY_EXACT_MATCH=PASS
KYBER_CONTEXT_EXACT_MATCH=PASS
KYBER_UNIQUE_ACCESSIONS=5

LAKEHOUSE_UNIQUE_IDENTITIES=5
LAKEHOUSE_IDENTITY_EXACT_MATCH=PASS
LAKEHOUSE_CONTEXT_EXACT_MATCH=PASS
LAKEHOUSE_UNIQUE_ACCESSIONS=5

TOTAL_FAILURES=0
```

Cross-layer context identity:

```text
EXPECTED_CONTEXT_SHA256=
e9b8970f469a6a5e904a22d38a71849894789bc0e317f22217f2a234c47273b5

KYBER_CONTEXT_SHA256=
e9b8970f469a6a5e904a22d38a71849894789bc0e317f22217f2a234c47273b5

LAKEHOUSE_CONTEXT_SHA256=
e9b8970f469a6a5e904a22d38a71849894789bc0e317f22217f2a234c47273b5
```

Final classification:

```text
YODA_EDGAR_FILING_CONTEXT_001_R1=PASS
VALIDATION_MODE=READ_ONLY
PRODUCT_EXECUTION_COUNT=1
PRODUCT_RERUN=NO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The initial `run-001` remains preserved as `NOT_EVALUATED` because a harness preparation bug bound accession identity to fiscal year and collapsed five real source states into two malformed identities. R1 corrected only the oracle/input binding. No Yoda or Kyber code changed.

The demonstrated property is intentionally narrow:

> **Yoda preserved five successive public financial states with exact reporting context and accession-level filing provenance across Frontier, KyberDB and Lakehouse, without losing earlier observed states and without changing Yoda or Kyber.**

The experiment makes no restatement, correction, supersession, accounting-judgment, forecasting, trading-alpha or investment-advice claim.

See:

`cases/YODA-EDGAR-FILING-CONTEXT-001-successive-financial-state/`

---


# Public financial reporting — same value, distinct regulatory state

`YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001` tested a complementary financial-state property using public Brazilian CVM DFP data and exact linked regulatory documents.

The selected reporting context was:

```text
CNPJ=08.827.501/0001-58
CD_CVM=023396
DT_REFER=2025-12-31
SCOPE=DfConsolidadas
STATEMENT=BalancoPatrimonialAtivo
```

Two distinct document presentations existed in the CVM master history:

```text
V1  ID_DOC=156154  DT_RECEB=2026-04-11
V2  ID_DOC=156163  DT_RECEB=2026-04-13
```

Their primary structured-content identities were distinct:

```text
V1_PRIMARY_XML_SHA256=
94ecc843369bed0dcf948189d925325dafe4b5f7f5c27cb6c3d8f7d9b0751936

V2_PRIMARY_XML_SHA256=
0cb9040499b1eac96a24a142495d2cb4fadc409d0b18858e29e6176e579a9684
```

The consolidated balance-sheet comparison showed:

```text
TOTAL_ACCOUNT_KEYS=564
VALUE_CHANGED=0
FORMAT_CHANGED_VALUE_SAME=82
EXACT_VALUE_SAME=482
UNPARSED_VALUE=0

EXACT_VALUE_SAME_ZERO=482
EXACT_VALUE_SAME_NONZERO=0
```

The frozen oracle therefore selected ten non-zero accounts from the 82 representation-changed/same-canonical-value accounts:

```text
SELECTED_ACCOUNTS=10
DOCUMENT_PRESENTATIONS=2
ORACLE_STATES=20
UNIQUE_ORACLE_STATE_IDS=20

EVERY_ACCOUNT_HAS_TWO_PRESENTATIONS=PASS
EVERY_ACCOUNT_CANONICAL_VALUE_EQUAL=PASS
EVERY_ACCOUNT_RAW_VALUE_DIFFERENT=PASS
```

The exact same context-capable product binary was reused:

```text
PRODUCT_BINARY_SHA256=
8e99fdb4289c47dc1d03ecd59abd85d48c34204ffa23e1e9c6ac863445c1b001

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The one-shot execution produced:

```text
PRODUCT_RC=0

FRONTIER_FINAL_ROWS=20
FRONTIER_PROCESSING_ROWS=20
FRONTIER_QUEUED_ROWS=0
FRONTIER_STATE_MATCH=PASS

KYBER_ROWS=20
KYBER_UNIQUE_KEYS=20
KYBER_EXACT_MATCH=PASS

LAKEHOUSE_ROWS=20
LAKEHOUSE_EXACT_MATCH=PASS

TOTAL_FAILURES=0
PRODUCT_EXECUTION_COUNT=1
PRODUCT_RERUN=NO
```

Cross-layer key identity was exact:

```text
EXPECTED_KEY_SHA256=
d1d54f580f2f73baf7e675d71a6dc2c36f2f4b6ef2fb570788cfd83911d92dfd

KYBER_KEY_SHA256=
d1d54f580f2f73baf7e675d71a6dc2c36f2f4b6ef2fb570788cfd83911d92dfd

CROSS_LAYER_KEY_IDENTITY=PASS
```

Final classification:

```text
YODA_CVM_REAPRESENTED_FINANCIAL_STATE_001=PASS
TEST_PROPERTY=SAME_VALUE_DISTINCT_REGULATORY_STATE
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The demonstrated property is intentionally narrow:

> **Yoda preserved 20 real public financial states representing two distinct CVM document presentations across Frontier, KyberDB and Lakehouse, with exact identity and context recovery, zero mismatches, and no changes to Yoda or Kyber.**

The useful observation is:

> **Same value does not mean same state.**

The experiment makes no correction, restatement, supersession, accounting-judgment, forecasting, trading-alpha or investment-advice claim.

The rejected oracle assumption and two `mawk`-incompatible preparation attempts remain preserved as `NOT_EVALUATED`; none executed the product.

See:

`cases/YODA-CVM-REAPRESENTED-FINANCIAL-STATE-001-same-value-distinct-regulatory-state/`

---

# Context-governed deterministic evaluation

`YODA-CVM-AGENTIC-CONTEXT-001` tested whether preserved operational context could govern a deterministic operation strongly enough to reproduce both valid calculations and controlled refusals after Yoda-only recovery.

The data authority froze eight real CVM DFP facts across two document presentations, two scopes and two source accounts.

```text
FACTS_SHA256=
5f25cb44580cfd7b515aedeef1e767021982cf619aad956d36b9c47704157900

DOCUMENT_METADATA_SHA256=
51653999ae44445dc471af2b31ac99171afc0b5e490906f366cb39c3fdace877
```

The project-defined Context Authority v1 froze semantic mappings, one metric contract and an ordered refusal policy:

```text
net_margin = net_income / net_revenue

SAME_COMPANY
SAME_PERIOD
SAME_SCOPE
SAME_PRESENTATION
SAME_CURRENCY
SAME_SCALE
NONZERO_DENOMINATOR
```

```text
CONTEXT_AUTHORITY_SHA256=
7f77a89514f9751116a8b9622ca6c35f63eb98a07e76dcefff02f750496534c0

METRIC_CONTRACT_SHA256=
45fe6311e89b866a475c1050e8490a89e47790b48545de118809563586f2f1f2
```

A deterministic C11 evaluator established the external baseline before Yoda preservation:

```text
POSITIVE_V1_CONSOLIDATED  ALLOW   -0.057183
POSITIVE_V2_CONSOLIDATED  ALLOW    0.068161
NEGATIVE_SCOPE            REFUSE   INCOMPATIBLE_SCOPE
NEGATIVE_PRESENTATION     REFUSE   INCOMPATIBLE_PRESENTATION

OUTCOME_ORACLE_EXACT_MATCH=PASS
OUTCOMES_SHA256=
e40e9d222320fe94324bc73225d5e69d59a89943986b57ada377534930a66324
```

The frozen CORE-014 product then preserved 11 objects and 8 relations:

```text
YODA_BINARY_SHA256=
06c1d2cb98099cb2d5b44f753fa3392da4f9a2bd42d39bd0a673270b01f9bfc8

PUT_COUNT=11
LINK_COUNT=8
RECORDS_VERIFIED=19
GET_EXACT_MATCHES=11

DATA_YODA_SHA256=
3f1ffbe56a41f71ab305a3a50cf3d18a4e5d2bb63a77d4b6efc5d04ae049fa34

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The final R1 replay used only Yoda `get` as the source of executable evidence:

```text
REPLAY_INPUT_SOURCE=YODA_GET_ONLY
ORIGINAL_AUTHORITY_DIRECT_PATH_REFERENCES=ZERO

STATE_USED_RECOVERABLE=PASS
CONTEXT_USED_RECOVERABLE=PASS
RULE_USED_RECOVERABLE=PASS
EVALUATOR_RECOVERABLE=PASS
RESULT_PRODUCED_RECOVERABLE=PASS

V1_VALID_RESULT_REPRODUCED=PASS
V2_VALID_RESULT_REPRODUCED=PASS
INCOMPATIBLE_SCOPE_REFUSAL_REPRODUCED=PASS
INCOMPATIBLE_PRESENTATION_REFUSAL_REPRODUCED=PASS

REPLAY_VS_ORIGINAL_EXACT_MATCH=PASS
DATA_YODA_IDENTITY_UNCHANGED=PASS

CONTEXT_GOVERNED_REPRODUCIBLE_EVALUATION=PASS
```

The demonstrated property is intentionally narrow:

> **Yoda preserved the exact observed state, versioned context, operational rule and evaluator required to reproduce two valid calculations and deterministically refuse two incompatible calculations using only Yoda-recovered evidence, without changing Yoda or Kyber.**

The first `REPLAY-008` attempt is preserved as `NOT_EXECUTED`: its forbidden-path preflight matched its own audit regex before lock acquisition. R1 changed harness mechanics only.

This is an infrastructure/reproducibility result. It is not accounting interpretation, financial forecasting, investment advice or a claim that Yoda is a general rules engine.

See:

- `cases/YODA-CVM-AGENTIC-CONTEXT-001-context-governed-reproducible-evaluation/`
- `properties/CONTEXT-GOVERNED-REPRODUCIBLE-EVALUATION.md`

---

# Genomics — Lineage of State

The genomics ladder moved from exact state to derivation:

```text
identity
   ↓
state
   ↓
workflow
   ↓
derived state
   ↓
workflow continuity
   ↓
verifiable lineage
```

`GENOME-LINEAGE-001` recovered the bounded lineage behind a controlled genomic result without a Genome Mode.

```text
GENOME_LINEAGE_001_STAGE_A=PASS
EXACT_EVIDENCE_RECOVERY=PASS
VARIANT_CONTEXT_1HOP=PASS
ALIGNMENT_CONTEXT_1HOP=PASS
EXTERNAL_TWO_NEIGHBORHOOD_COMPOSITION=PASS
FULL_GENOMIC_LINEAGE_RECOVERY=PASS
YODA_VERIFY=PASS
PRODUCT_CHANGE=NO
KYBER_CHANGE=NO
```

Frozen lineage bundle:

```text
99a4b9380e48ae703410c2bc54554c151b02475bc2f1d1e5ce64743802ed747b
```

Question answered inside the CASE scope:

> **Where did this result come from?**

See:

`cases/GENOME-LINEAGE-001-verifiable-scientific-lineage/`

---

# AXLE — independent formal authority replay

`AXIOM-YODA-PROOF-LINEAGE-001` moved Yoda into a different authority model.

```text
AXLE
→ formal validity

Yoda
→ derivation integrity
```

A valid proof was accepted by AXLE. A controlled mutation was valid Lean but proved a different theorem and was rejected against the frozen formal statement.

Yoda stored the statement, proof artifacts, environment, verification evidence and explicit relations, then recovered the proof artifacts byte-for-byte.

AXLE reproduced both decisions from Yoda-recovered artifacts:

```text
A0_POSITIVE_OKAY=true
A1_POSITIVE_OKAY=true
AXLE_POSITIVE_DECISION_REPRODUCED=PASS

A0_NEGATIVE_OKAY=false
A1_NEGATIVE_OKAY=false
AXLE_NEGATIVE_DECISION_REPRODUCED=PASS

PROOF_DERIVATION_REPLAY=PASS
```

Frozen evidence:

```text
FORMAL_STATEMENT_SHA256=24bea18925bf1a4b9e1dddc4ea6b34bd0cba323d57de42bfdcfd79c1756d2ee9
VALID_PROOF_SHA256=0082af12ce4e8b8c249f90706c3c9b0264e1e0ebcf05e3d3ece25fdf76f79a29
CONTROLLED_MUTATION_SHA256=a74af4eb7a514a97163f7d86dd8216298e478763eade920f91e08b52e12fd392
A0_EVIDENCE_MANIFEST_SHA256=f6c1b0a71c4d4b706628ee42008ac2f1dd495f2861fa39899217d0f0e0c567b3
A1_EVIDENCE_MANIFEST_SHA256=94a0801e2a554a80c32228c1eb6edf4334d4ce59c27b75cb876e2171c0196c90
DATA_YODA_SHA256=b3cd12a421fe84b2728a65ddf474db0aa3ec0f9da7bc292c4f7608d9ff36ff8c
```

Important nuance: AXLE response bytes are request-specific. The validated property is semantic accept/reject replay using byte-exact recovered proof artifacts.

See:

`cases/AXIOM-YODA-PROOF-LINEAGE-001-verifiable-proof-derivation/`

---

# SynthID Bio — Composed Provenance

`SYNTHID-BIO-YODA-PROVENANCE-001` tested whether intrinsic provenance inside an artifact and external workflow provenance around it could coexist and remain independently measurable after Yoda persistence and recovery.

Authority separation:

```text
Google DeepMind SynthID Bio
→ intrinsic provenance measurement

Yoda
→ external derivation integrity
```

The public implementation was frozen at:

```text
DEEPMIND_COMMIT=acd75747b14c7f4c3c65ad1e6af1483aeba47614
```

The official external detector behavior was reproduced before Yoda entered the experiment.

Yoda then stored the control and watermarked artifacts, measurements, authority identity, parameters and evidence.

Only Yoda-recovered artifacts were submitted to the frozen detector in the replay stage.

```text
ARM          SAMPLE   BEFORE   AFTER
CONTROL      1        0.5037   0.5037
CONTROL      2        0.5130   0.5130
WATERMARKED  1        0.7961   0.7961
WATERMARKED  2        0.7184   0.7184
```

```text
CONTROL_DETECTOR_EQUIVALENCE=PASS
WATERMARKED_DETECTOR_EQUIVALENCE=PASS
G_VALUE_MATRIX_EQUIVALENCE=PASS
INTRINSIC_PROVENANCE_MEASUREMENT_EQUIVALENCE=PASS
EXTERNAL_WORKFLOW_PROVENANCE_RECOVERY=PASS
COMPOSED_PROVENANCE=PASS
```

Frozen evidence:

```text
CONTROL_5L33_SHA256=77aaf2a4d2fa522f84280420d1605f28c78a1913bd39e9ac4b628d45e3681a4f
WATERMARKED_5L33_SHA256=16ce25bd9f444efcf3dd4adfd7b1732b5adc3f35289f6e498aa3ceabf0d0a1f4
A0_EVIDENCE_MANIFEST_SHA256=3114caf012ee41f3be15dae292f688299e872cef180dd3073750f05a4cee038e
A1_EVIDENCE_MANIFEST_SHA256=8a8a5482bcd2b691bef8fb155c310633d3cbddaf171fb5a11f98b386406c9272
B_EVIDENCE_MANIFEST_SHA256=e89730407d3d3ee6b76d76e4c0d9f8949a09ba90ccee585e1fc9113209693256
DATA_YODA_SHA256=3170d81272ae37a7d8ca4bddebf546ca9cced08a06c864f0f128a59da5facd60
```

See:

`cases/SYNTHID-BIO-YODA-PROVENANCE-001-composed-provenance/`

---

# Evolving provenance — Lineage of Change

`SYNTHID-BIO-EVOLVING-PROVENANCE-001` asked a different question:

> **Can a legitimate change create a new identity without destroying the verifiable lineage of what came before?**

The biological domain and SynthID Bio were the experimental environment, not the property definition.

The controlled transition was:

```text
Artifact A
SHA256=da6b1b6b239fc3c870f9750f7b29c816f4d700462a160fc8ced7922dbecbfad0
measurement=0.7961

        │
        │ random-residue substitution
        │ 6 changed residues
        │ 5.660377% actual change
        ▼

Artifact B
SHA256=defc97981f115f1c1792e53946dcf81f5cce28fafdcccf917c80470fa3cfaa00
measurement=0.6990
```

The two states had distinct identities and distinct independent measurements.

## Yoda preservation

Yoda stored nine objects and eleven explicit relations covering:

```text
Artifact A
Artifact B
Measurement A
Measurement B
Transformation
Mutation table
Detector authority
Supplementary authority
Experimental evidence
```

The relation set included:

```text
B --derived-from--> A
B --transformed-by--> Transformation
A --has-measurement--> Measurement A
B --has-measurement--> Measurement B
Measurement A --measured-by--> Detector
Measurement B --measured-by--> Detector
```

Recovery gates:

```text
ARTIFACT_A_BYTE_EXACT_RECOVERY=PASS
ARTIFACT_B_BYTE_EXACT_RECOVERY=PASS
TRANSFORMATION_BYTE_EXACT_RECOVERY=PASS
MUTATION_TABLE_BYTE_EXACT_RECOVERY=PASS
MEASUREMENT_BYTE_EXACT_RECOVERY=PASS
LINEAGE_OF_CHANGE_CONTEXT=PASS
VERSIONED_DERIVATION_RECOVERY=PASS
FINAL_YODA_VERIFY=PASS
```

The validating Yoda state was:

```text
DATA_YODA_SHA256=0aac02391eec12c2caa2a0bca725af6ddcdab4530c2153002b6673a7e7729954
DATA_YODA_BYTES=9971
```

## Independent state-specific replay

Only the Yoda-recovered A and B states were sent back to the frozen SynthID Bio detector.

```text
G_A_BEFORE=0.7961
G_A_AFTER_RECOVERY=0.7961

G_B_BEFORE=0.6990
G_B_AFTER_RECOVERY=0.6990
```

```text
STATE_A_MEASUREMENT_EQUIVALENCE=PASS
STATE_B_MEASUREMENT_EQUIVALENCE=PASS
STATE_SPECIFIC_MEASUREMENT_REPLAY=PASS
INDEPENDENT_STATE_REPLAY=PASS
LINEAGE_OF_CHANGE_EXTERNAL_AUTHORITY_REPLAY=PASS
```

Final homologation:

```text
SYNTHID_BIO_EVOLVING_PROVENANCE_001=VALIDATED
STAGE_A0=PASS
STAGE_A0_1=PASS
STAGE_A1=PASS
STAGE_A2=PASS
STAGE_B=PASS
LINEAGE_OF_CHANGE=DEMONSTRATED
INDEPENDENT_AUTHORITY_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
FINAL_EVIDENCE_INTEGRITY=PASS
```

Frozen authorities:

```text
A2_EVIDENCE_MANIFEST_SHA256=ab4e996f28d5d70995620f5d14d2e50886eec1d493955b31b419624fab735728
STAGE_B_EVIDENCE_MANIFEST_SHA256=6eba74b9b659db8950c3fd7d0e5b39b0c7fcae49fa2682023c3a528c7f87b8a7
REPLAY_CONTRACT_SHA256=ccdd19b43094b883f682e235a50fd21e06d1c4cfa08531560c9549768548d2c9
FINAL_EVIDENCE_MANIFEST_SHA256=e46bcb223be3264f97390abac792a889b5a79033d9ff55eb8f400c818ebcc17a
```

Formal property:

```text
Lineage of Change
=
derivation integrity across state transitions
```

See:

- `cases/SYNTHID-BIO-EVOLVING-PROVENANCE-001-lineage-of-change/`
- `properties/LINEAGE-OF-CHANGE.md`

---

# Evidence ladder

The demonstrated sequence is now:

```text
LINEAGE OF STATE
Where did this result come from?
        ↓
INDEPENDENT AUTHORITY REPLAY
Can the right authority evaluate it again?
        ↓
COMPOSED PROVENANCE
Can independent provenance layers coexist?
        ↓
LINEAGE OF CHANGE
How did this become what it is now?
        ↓
SUCCESSIVE STATE PRESERVATION
Can distinct observed states retain exact context and provenance over time?
        ↓
VALUE-INDEPENDENT STATE IDENTITY
Can equal canonical values remain distinct when provenance differs?
        ↓
DECISION LINEAGE
Why did the deterministic system decide this then,
and can that decision be replayed from recovered evidence?
        ↓
CONTEXT-GOVERNED REPRODUCIBLE EVALUATION
Can recovered context and rules reproduce both an allowed operation
and the refusal of incompatible operations?
```

These are not separate engine modes.

They are increasingly strong observations of the same small derivation architecture.

---

# Emerging architectural pattern

Across AXLE and the two SynthID Bio CASEs, the authority remained external.

```text
independent authority
        ↓
measurement / decision
        ↓
       Yoda
        ↓
exact recovery + lineage
        ↓
same independent authority
        ↓
same measurement / decision
```

The evidence supports a narrow architectural thesis:

> **Yoda does not need to be the authority that decides whether something is true. Yoda can preserve the derivation required for independent authorities to decide again.**

The evolving-provenance CASE adds another demonstrated observation:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

That sentence is scoped to the validating CASE and is not a universal guarantee.

---

# What is not proven

The evidence does not establish:

```text
general-purpose truth engine
general-purpose provenance platform
proof of authorship or ownership
biological truth or clinical validity
arbitrary theorem-proving workflow support
arbitrary watermark support
arbitrary state-transition support
native arbitrary multi-hop graph reasoning
production-scale long change histories
biotech-scale operation
product-market fit
Google DeepMind or Axiom endorsement
```

Domain authorities remain responsible for domain validity.

---

# Next external falsification

The strongest next test should be externally defined rather than another internal format or biology demonstration.

A useful target remains a real Design-Build-Test-Learn or other iterative workflow selected by an external team.

The stronger question is now not merely whether Yoda can recover a final candidate's ancestry, but whether it can preserve a longer sequence of meaningful state transitions without domain-specific engine changes.

That experiment should be defined by the external problem before Yoda code or schema is added.


---

# Decision Lineage — deterministic decision replay

`MARKET-REGIME-LINEAGE-001` extended the evidence program from artifact/proof state transitions to successive deterministic evaluations.

Three point-in-time source states produced:

```text
A=STRESSED
B=FRAGILE
C=FRAGILE
```

The transition record preserved both a label change and a stable-label/new-evidence transition:

```text
A -> B
STRESSED -> FRAGILE
CLASSIFICATION_CHANGED=YES

B -> C
FRAGILE -> FRAGILE
CLASSIFICATION_CHANGED=NO
UNDERLYING_EVIDENCE_CHANGED=YES
```

Yoda preserved 18 objects and 31 explicit relations, including source snapshots, decision states, the classification contract, two independent authority implementations, original evaluation evidence and transition evidence.

A2 demonstrated:

```text
BYTE_EXACT_RECOVERY=PASS
DECISION_LINEAGE_RELATION_RECOVERY=PASS
DECISION_LINEAGE_SEMANTICS=PASS
FINAL_YODA_VERIFY=PASS
```

B-R1 then recovered replay inputs only from the frozen Yoda store:

```text
REPLAY_INPUT_SOURCE=YODA_GET_ONLY

REPLAY_AUTHORITY_1=PASS
REPLAY_AUTHORITY_2=PASS
REPLAY_AUTHORITY_EQUIVALENCE=PASS
REPLAY_VS_ORIGINAL_CANONICAL=PASS

STATE_A_INDEPENDENT_REPLAY=PASS
STATE_B_INDEPENDENT_REPLAY=PASS
STATE_C_INDEPENDENT_REPLAY=PASS

INDEPENDENT_CLASSIFICATION_REPLAY=PASS
```

All replayed result bytes matched:

```text
bea0f2e397f9e00b217c6f3fccd036ef346f9d555a04941369707792927b11ba
```

The Yoda store remained byte-identical through replay:

```text
DATA_YODA_SHA256_BEFORE=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_SHA256_AFTER=
fbe0800522d44ec54a71cd26c0fe3cde0bb1cf8475ac859af0c045d054cfe84e

DATA_YODA_IDENTITY_UNCHANGED=PASS
```

Final homologation:

```text
MARKET_REGIME_LINEAGE_001=VALIDATED
DECISION_LINEAGE=DEMONSTRATED
INDEPENDENT_CLASSIFICATION_REPLAY=PASS
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Formal property:

`properties/DECISION-LINEAGE.md`

This is an infrastructure/reproducibility result, not a market forecast or investment claim.
