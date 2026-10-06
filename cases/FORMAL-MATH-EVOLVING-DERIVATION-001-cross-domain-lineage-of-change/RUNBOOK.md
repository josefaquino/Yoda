# Runbook — FORMAL-MATH-EVOLVING-DERIVATION-001

## Execution order

The CASE is intentionally gated.

```text
A0 external authority freeze
PASS
        |
        v
A1.0 original Complex-dependent workload
NOT_EVALUATED
CAPABILITY BOUNDARY DISCOVERED
        |
        v
A1-R1 authority-compatible workload
one pre-registered execution
        |
        v only if PASS
A2 Yoda versioned derivation
        |
        v only if PASS
B independent formal replay
        |
        v only if PASS
final homologation
```

Do not skip stages.

Do not modify Yoda or Kyber to rescue an external compatibility failure.

---

## Local case root

All scripts use:

```text
$HOME/cmu/FORMAL-MATH-EVOLVING-DERIVATION-001
```

Frozen Yoda authority:

```text
/home/jose/YodaCore-015-FROZEN/product/yoda
SHA256=1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
```

---

## Stage A0

A0 is complete and homologated as PASS.

Required preserved authority:

```text
A0_EVIDENCE_MANIFEST_SHA256=
80cb8e086c70015dd6f5e259a354a75c24e3b69809e71cb0c04666634771a408
```

Do not rerun A0 unless the experiment is explicitly restarted under a new authority freeze.

---

## Stage A1.0 — historical attempt

Script:

```text
scripts/01-controlled-proof-evolution.sh
```

A1.0 is preserved for evidence and should not be rerun in an attempt to obtain PASS.

Official result:

```text
STAGE_A1.0=NOT_EVALUATED
INTERPRETATION=CAPABILITY_BOUNDARY_DISCOVERED
FAILURE_CLASS=SECONDARY_AUTHORITY_CAPABILITY_BOUNDARY

PROOF_A_LEAN=PASS
PROOF_B_LEAN=PASS

PROOF_A_OXILEAN=UNSUPPORTED
PROOF_B_OXILEAN=UNSUPPORTED

MATHEMATICAL_REJECTION=NO
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

See `ATTEMPTS/A1.0-CAPABILITY-BOUNDARY.md`.

---

## Stage A1-R1 — current next gate

A1-R1 is the only permitted continuation of Stage A1.

Pre-registered workload:

```text
CORPUS=openai/miniF2F
COMMIT=4e433ff5cadff23f9911a2bb5bbab2d351ce5554
THEOREM=mathd_numbertheory_188
TARGET=Nat.gcd 180 168 = 12
```

The exact A1-R1 script and proof-state pair are committed before the first execution.

Frozen proof-state pair:

```text
Proof A
rfl
-> direct kernel computation

Proof B
Nat.gcd_rec + rfl reduction steps + Nat.gcd_zero_left
-> explicit Euclidean GCD derivation
```

Transformation:

```text
kernel_computation_to_explicit_euclidean_derivation
```

Script path:

```text
scripts/01-r1-authority-compatible-evolution.sh
```

The harness enforces a local one-execution lock before formal validation so the revision cannot be silently rerun after its result is known. A consumed lock is checked at startup before `stage-a1-r1` can be removed or rebuilt, preserving the first execution evidence.

Execution policy:

```text
ONE_EXECUTION
NO_CANDIDATE_SEARCH_AFTER_EXECUTION
YODA_WRITES=ZERO
```

Required end state:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A1_R1=PASS
STATEMENT_PORT=PASS
PROOF_IDENTITIES_DISTINCT=PASS
MATHEMATICAL_TARGET_IDENTICAL=PASS
PROOF_A_LEAN=PASS
PROOF_B_LEAN=PASS
PROOF_A_OXILEAN=VERIFIED
PROOF_B_OXILEAN=VERIFIED
TRANSFORMATION_RECORD=PASS
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

If either target is `unsupported`, classify A1-R1 as `NOT_EVALUATED` and stop.

Do not choose another theorem inside this revision.

---

## Stage A2 — completed by read-only adjudication

A1-R1 is complete and homologated as PASS.

Research question:

```text
Can Yoda preserve a versioned derivation
between two independently verified
formal proof states without changing
Yoda or Kyber?
```

A2 revision:

```text
A2-R1
```

Script:

```text
scripts/02-r1-yoda-versioned-derivation.sh
```

Input authority:

```text
A1_R1_EVIDENCE_MANIFEST_SHA256=
fad7416a7528d9d6ec885836668668d20c3cb942bc04b4f509949f92227c8bca
```

Inputs are only existing A1-R1 artifacts:

```text
Statement
Proof A
Proof B
Transformation A -> B
Lean Evidence A
Lean Evidence B
OxiLean Evidence A
OxiLean Evidence B
A1-R1 Evidence Authority
```

No new formal artifact is introduced.

```text
NEW_WORKLOAD=NO
NEW_CORPUS=NO
NEW_AUTHORITY=NO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

A2 validates Yoda preservation, byte-exact recovery, relation recovery, bounded context reconstruction and durable-store integrity.

A2 does **not** rerun Lean or OxiLean. Stage B remains the independent replay gate.

A2 used a one-execution lock immediately before the first Yoda write.

The one-shot execution is permanently classified:

```text
A2_R1_ONE_SHOT=NOT_EVALUATED
FAILURE_CLASS=HARNESS_QUERY_TOKENIZATION_MISMATCH
A2_R1_RERUN=NO
```

The same immutable Yoda state was then adjudicated read-only.

Final adjudication:

```text
A2_RESEARCH_QUESTION=PASS_BY_READ_ONLY_ADJUDICATION
DATA_YODA_SHA256=
5e9c916794b7c94ec01bf822ae31705b08140449bf085fbfff327724224a06ba

FINAL_ADJUDICATION_EVIDENCE_MANIFEST_SHA256=
e603b0ac3fe1b477a2dd6b3db71c46c7a07e3a098843067fc68c23711775accb

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

Do not rerun A2-R1 and do not delete its execution lock.

---

## Stage B — B-R1 complete

```text
REVISION=B-R1
EXECUTION_COUNT=1
STATUS=PASS
RUN_RC=0
```

Do not rerun B-R1 and do not delete its execution lock.

```text
B_R1_EXECUTION_LOCK_SHA256=
741ccae2c834234dba01a0c5750c90c494bc8302765b3d147d79db3904413a32

STAGE_B_EVIDENCE_MANIFEST_SHA256=
040cfbb629e6262ed8b75e95859e7ca99362e85aed3df8f79d24a378f2ffd6d5
```

Lean, lean4export and OxiLean replay all reproduced the frozen A1-R1 outcomes from Yoda-recovered proof states.

---

## Final homologation

Final homologation is now authorized and recorded:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001=VALIDATED
CROSS_DOMAIN_LINEAGE_OF_CHANGE=DEMONSTRATED
```

Negative and non-evaluable attempts remain part of the final research record.
