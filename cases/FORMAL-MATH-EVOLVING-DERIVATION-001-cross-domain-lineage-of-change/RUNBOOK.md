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

## Stage A2

A2 remains blocked until A1-R1 passes.

The existing A2 design remains conceptually valid, but its implementation must consume the A1-R1 artifacts and A1-R1 evidence authority rather than the historical A1.0 artifacts.

Do not execute A2 before that adaptation is explicitly reviewed.

---

## Stage B

B remains blocked until A2 passes.

The replay stage must use only artifacts recovered from Yoda and must rerun the same frozen Lean and OxiLean authorities against the recovered A1-R1 proof states.

---

## Final homologation

Do not write final homologation constants before real A1-R1, A2, and B evidence hashes exist.

Only after Stage B passes may the CASE evaluate:

```text
FORMAL_MATH_EVOLVING_DERIVATION_001=VALIDATED
CROSS_DOMAIN_LINEAGE_OF_CHANGE=DEMONSTRATED
```

Negative and non-evaluable attempts remain part of the final research record.
