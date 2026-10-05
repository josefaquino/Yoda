# Evidence Index — FORMAL-MATH-EVOLVING-DERIVATION-001

This directory indexes evidence identities recorded during the CASE.

Large local execution artifacts are not silently reconstructed here. The authoritative local files remain those produced by the frozen harnesses and identified by SHA-256.

## A0 authority

```text
A0_EVIDENCE_MANIFEST_SHA256=
80cb8e086c70015dd6f5e259a354a75c24e3b69809e71cb0c04666634771a408

A0_ATTEMPT_002_CONSOLE_SHA256=
ab8dfd3000ce58b76010ed7712371c28fd6584732b9ce15d1f859abbde9e8f67
```

## A1.0 proof artifacts

```text
STATEMENT_SHA256=
a42746b4bd36a6f891480e35d739ce7a717bc3bb6cb2a5359594bdf12700116c

PROOF_A_SHA256=
e99b7543a53df23812d95fce7437c2f11902f119ca938befdd74a1503907ce61

PROOF_B_SHA256=
8bb29a89770ba5c58a26c8dda3e8335dcfa645c498516929572c417060276c11

PROOF_A_EXPORT_SHA256=
786b4d2a4796929d4e0e38b520e0f1c2d1a4bca0d8488d7398868e47914155bb

PROOF_B_EXPORT_SHA256=
f748d0746ba864fefe7382cfb26a4a378695ac0385acea2719a302fb7238dda4
```

## A1.0 Attempt 003 OxiLean artifacts

```text
OXILEAN_A_JSON_SHA256=
c1b0dd0ea9ab812fdb52b12380cdffbc8ce137b289e38ac9ea08e697024c98eb

OXILEAN_A_LOG_SHA256=
d0e0c1bfd1eea915626c7d5f59b898ca1e05fdce3edf122a26c3d70d29c08831

OXILEAN_B_JSON_SHA256=
f2c33226851e7209c09ce04f14c3410c027f48d40478b0a544d5532ddbf66fc0

OXILEAN_B_LOG_SHA256=
b2acbc59eeb9e12a9b3cea24e7564840b25563433aa287b46c212bfb76a9d434
```

Observed target verdicts:

```text
FormalEvolution.ProofA.proof
unsupported
dependency on an unsupported declaration

FormalEvolution.ProofB.proof
unsupported
dependency on an unsupported declaration
```

## Preservation rule

Do not overwrite A1.0 evidence with A1-R1 evidence.

Each revision must retain separate artifact identities and manifests.
