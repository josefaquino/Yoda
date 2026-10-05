# Transformation Contract 002 — Direct C-terminal Artifact Evolution

## Status

```text
CONTRACT_VERSION=002
CONTRACT_STATUS=FROZEN_FOR_EXECUTION_DESIGN
SUPERSEDES_EXECUTION_PATH=TRANSFORMATION-CONTRACT.md
CODE_WRITING=NO
EXECUTION_STATUS=NOT_STARTED
```

The first transformation contract explored ProteinMPNN resequencing because the SynthID Bio paper explicitly studies that attack.

A deeper public-artifact audit showed a limitation for exact reproduction: the paper’s attack starts from a watermarked binder in complex with its cognate target, but the frozen public repository does not expose the study’s AlphaProteo binder-target complex structures as a directly replayable A→B input set.

The original resequencing contract is preserved as research history. It is not deleted.

This v2 contract chooses a better transformation for the Yoda research question: a **direct, legitimate post-design sequence modification explicitly recognized by the SynthID Bio paper**.

---

## Scientific authority

Primary publication:

**Stutz, D. et al. Function-preserving watermarking of AI-generated proteins. Nature (2026).**

DOI:

`10.1038/s41586-026-10965-y`

The paper states that manual modification after sequence design, including addition of a C-terminal expression tag, changes the effective watermark signal in proportion to the modification’s relative size.

The Methods section publishes the exact C-terminal tags used for SC2RBD and VEGF-A binders:

```text
GFP11
RDHMVLHEYVNAAGIT

Twin-Strep
WSHPQFEKGGGSGGGSGGSAWSHPQFEK
```

This provides a public, direct and deterministic transformation class that does not depend on unavailable binder-target structure files.

---

## Transformation semantics

```text
SOURCE_STATE=A
SOURCE_CLASS=published watermarked VEGF-A binder sequence

TRANSFORMATION_CLASS=C_TERMINAL_TAG_ADDITION
TRANSFORMATION_OPERATION=append
TRANSFORMATION_ORDER=GFP11_then_Twin-Strep

GFP11=RDHMVLHEYVNAAGIT
TWIN_STREP=WSHPQFEKGGGSGGGSGGSAWSHPQFEK

TARGET_STATE=B
TARGET_CLASS=tagged derivative of A
```

Canonical sequence transformation:

```text
B = A || GFP11 || TWIN_STREP
```

No residue in A is removed, substituted or reordered.

---

## Why this transformation is preferred for this CASE

The CASE asks whether Yoda can preserve **lineage through legitimate change**.

For that question, direct tag addition is superior to the resequencing attack because:

1. B is literally and deterministically derived from A.
2. the exact transformation is public;
3. the exact tag sequences are public;
4. no unpublished AlphaProteo complex structure is needed;
5. the transformation corresponds to a real experimental workflow operation described in the paper;
6. any change in g-value is an external measurement result, not a Yoda success criterion.

---

## Authority separation

```text
Nature / SynthID Bio paper
→ recognizes post-design C-terminal modification
→ publishes exact tag sequences

SynthID Bio detector
→ evaluates intrinsic provenance measurement of A and B

Yoda
→ preserves A, B, the transformation evidence and B derived-from A
```

Yoda does not decide whether the modified artifact remains watermarked.

---

## Required equivalence

Before Yoda:

```text
A → detector → g(A)
B → detector → g(B)
```

After Yoda recovery:

```text
A' → detector → g(A')
B' → detector → g(B')
```

PASS requires:

```text
SHA256(A') = SHA256(A)
SHA256(B') = SHA256(B)

g(A') = g(A)
g(B') = g(B)

B derived-from A = recoverable
transformation evidence = recoverable
```

It does not require:

```text
g(A) = g(B)
```

---

## Biological-boundary rule

The experiment does not claim that applying these tags to the selected public sequence reproduces the complete wet-lab construct or proves function.

The tags are used as a controlled sequence transformation whose class and exact amino-acid strings are published by the same external scientific authority.

The CASE tests derivation integrity, not biological validity.

---

## Anti-cherry-picking rule

Artifact A must be selected before g(B) is computed.

Selection must depend only on public metadata and deterministic ordering, never on the post-transformation measurement.

The concrete selection rule is frozen separately in `INSTANCE-CONTRACT.md`.

---

## Contract gates

```text
POST_DESIGN_MODIFICATION_AUTHORITY=PASS
C_TERMINAL_TAG_OPERATION_DOCUMENTED=PASS
GFP11_SEQUENCE_AUTHORITY=PASS
TWIN_STREP_SEQUENCE_AUTHORITY=PASS
DIRECT_A_TO_B_TRANSFORMATION=PASS
TRANSFORMATION_CONTRACT_002=FROZEN

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## Next gate

```text
NEXT_GATE=EXECUTE_A0_INSTANCE_AUTHORITY
```

No Yoda write is permitted until A and B identities and their independent pre-Yoda measurements are frozen.
