# A1-R1 — Authority-Compatible Workload

## Status

```text
STATUS=PRE-REGISTERED
EXECUTED=NO
```

This revision is registered before execution.

---

## Rationale

Why a revision?

```text
Not because the hypothesis failed.

Not because Yoda failed.

Not because Kyber failed.

Not because Lean rejected the theorem.

The A1.0 workload exceeded the
current evaluation capacity of
the secondary authority.
```

The hypothesis remains unchanged.

The instrument is adjusted by choosing a workload that is compatible with the known capabilities of both frozen formal authorities.

---

## New workload

```text
CORPUS=openai/miniF2F
COMMIT=4e433ff5cadff23f9911a2bb5bbab2d351ce5554
THEOREM=mathd_numbertheory_188
TARGET=Nat.gcd 180 168 = 12
```

The theorem exists in the same frozen MiniF2F corpus used by A1.0.

---

## Pre-registered selection reasoning

```text
Same formal domain
Same public corpus
Same frozen commit
Same Lean authority
Same OxiLean authority
Same Yoda
Same Kyber

Smaller dependency surface
No Complex hierarchy
Concrete Nat computation
No workload search after execution begins
```

The candidate is chosen for architectural reasons before execution.

This is not a search over multiple theorems until one passes.

---

## Controlled proof evolution

The proposition must remain byte-identical between state A and state B.

The exact proof-state pair must be frozen in the A1-R1 harness before first execution.

Required invariant:

```text
statement(A) = statement(B)
identity(A) != identity(B)
```

---

## Expected gates

```text
STATEMENT_SOURCE=MINIF2F
STATEMENT_PORT=PASS

PROOF_IDENTITIES_DISTINCT=PASS
MATHEMATICAL_TARGET_IDENTICAL=PASS

Lean(A)=PASS
Lean(B)=PASS

OxiLean(A)=VERIFIED
OxiLean(B)=VERIFIED

TRANSFORMATION_RECORD=PASS

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## Stop rule

If either target declaration is `unsupported`:

```text
A1-R1=NOT_EVALUATED
```

No additional workload may be selected within this revision.

If either formal authority rejects the mathematical target, record the exact rejection and stop.

A2 remains blocked until A1-R1 passes.

---

## Governance

```text
PREDECESSOR_STAGE=A1.0
PREDECESSOR_STATUS=NOT_EVALUATED
PREDECESSOR_CLASS=SECONDARY_AUTHORITY_CAPABILITY_BOUNDARY

REROUTE_REASON=authority-compatible workload

HYPOTHESIS_CHANGED=NO
DOMAIN_CHANGED=NO
CORPUS_CHANGED=NO
CORPUS_COMMIT_CHANGED=NO
AUTHORITIES_CHANGED=NO
YODA_CHANGED=NO
KYBER_CHANGED=NO
WORKLOAD_CHANGED=YES

SELECTION_BEFORE_EXECUTION=YES
CANDIDATE_SEARCH_AFTER_EXECUTION=NO
```
