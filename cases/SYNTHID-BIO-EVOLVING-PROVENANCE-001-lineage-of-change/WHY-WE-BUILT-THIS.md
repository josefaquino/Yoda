# Why We Built This

Yoda's earlier CASEs established two important ideas.

First, a result can remain connected to the states and tools that produced it.

```text
GENOME-LINEAGE-001
→ Where did this result come from?
→ LINEAGE OF STATE
```

Second, Yoda does not need to become the authority that decides whether a result is valid. It can preserve the derivation required for an independent authority to evaluate the result again.

```text
SYNTHID-BIO-YODA-PROVENANCE-001
→ Can intrinsic and external provenance coexist?
→ COMPOSED PROVENANCE
```

That left a deeper question unanswered.

Real systems do not remain in one state.

They change.

Artifacts are revised. Models are updated. Experiments evolve. Policies change. Knowledge is corrected. Data is replaced or superseded. New states emerge from old ones.

So the next question was not simply:

> Where did this come from?

It was:

> **How did this become what it is now?**

---

## The experimental environment

We needed an environment with four properties:

1. a concrete initial state;
2. a controlled legitimate transformation;
3. a distinct resulting state;
4. an independent authority capable of evaluating both states.

The public Google DeepMind SynthID Bio implementation provided a useful experimental instrument.

A previously frozen watermarked biological sequence supplied Artifact A.

The public SynthID Bio Supplementary Information supplied authority for a random residue substitution mechanism and included evaluation at a 5% substitution target.

The CASE then used a deterministic case-controlled implementation of that mechanism to create Artifact B.

The purpose was not to test protein function, watermark robustness or watermark removal.

The purpose was to create a legitimate, observable state transition:

```text
A
↓
controlled transformation
↓
B
```

with:

```text
identity(A) != identity(B)
```

and ask whether the history of that transition could remain verifiable.

---

## What happened

Artifact A had:

```text
SHA-256=da6b1b6b239fc3c870f9750f7b29c816f4d700462a160fc8ced7922dbecbfad0
g=0.7961
```

Six of 106 residues were deterministically substituted.

Artifact B had:

```text
SHA-256=defc97981f115f1c1792e53946dcf81f5cce28fafdcccf917c80470fa3cfaa00
g=0.6990
```

A new state existed.

The important point is that the CASE did not require Artifact B to erase Artifact A.

Instead, Yoda preserved both states and the evidence that connected them:

```text
A continues to exist
B continues to exist
B --derived-from--> A remains explicit
transformation evidence remains explicit
```

That distinction is central.

Many systems can tell us the current state.

Versioning systems can often tell us previous states.

The research question here is stronger:

> **Can the system preserve why the current state is different from the prior state, and preserve enough evidence for independent authorities to evaluate both states again?**

---

## Why the external replay matters

The final replay was the decisive gate.

The CASE did not end with:

```text
Yoda says A and B are valid.
```

Yoda is not the measurement authority.

Instead the pattern was:

```text
independent authority
↓
evaluates A

controlled transformation
↓

independent authority
↓
evaluates B

Yoda preserves A, B and A → B derivation
↓

Yoda recovers A and B byte-exactly
↓

same independent authority
↓
re-evaluates A
re-evaluates B
```

The state-specific measurements reproduced exactly:

```text
A: 0.7961 → 0.7961
B: 0.6990 → 0.6990
```

This matters because the claim does not depend on Yoda interpreting the biological meaning of either state.

The authority stayed external.

Yoda preserved the derivation required to return each recovered state to that authority.

---

## The architectural property that emerged

The experiment supports a new property name:

```text
LINEAGE OF CHANGE
```

Within this CASE, Lineage of Change means that a state transition can create a new identity while preserving:

- the prior state;
- the new state;
- the derivation between them;
- the transformation evidence;
- the state-specific evaluation evidence;
- the ability to return recovered states to an independent authority.

A compact formulation is:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

This should not be interpreted as a new engine component.

A better architectural reading is:

```text
Kyber
=
durable state integrity

Yoda
=
derivation integrity

Lineage of Change
=
derivation integrity across state transitions
```

The property emerged without changing Yoda or Kyber.

That is significant because the CASE tested an existing architecture rather than adding a feature specifically to satisfy the experiment.

---

## From state lineage to change lineage

The research program now has a progression:

```text
GENOME-LINEAGE-001
Where did this result come from?
↓
LINEAGE OF STATE

SYNTHID-BIO-YODA-PROVENANCE-001
Can independent provenance layers coexist?
↓
COMPOSED PROVENANCE

SYNTHID-BIO-EVOLVING-PROVENANCE-001
How did this become what it is now?
↓
LINEAGE OF CHANGE
```

That progression matters because the real world is not a collection of frozen snapshots.

It is a sequence of state transitions.

Companies change.

Models change.

Experiments change.

Policies change.

Scientific artifacts change.

Knowledge changes.

If derivation integrity can survive those transitions, Yoda may be useful for a broader problem than preserving provenance around a static result.

That broader possibility is a research thesis, not a universal claim established by this one CASE.

---

## Why this matters to the Yoda thesis

A conventional database primarily answers:

> What is the state now?

A versioning system may also answer:

> What were the previous states?

The direction suggested by this CASE is richer:

```text
What is the state now?

What was it before?

What changed?

What caused the change?

What evidence describes that change?

Which authority evaluated each state?

Can those states and evaluations be independently reconstructed?
```

This is why the most useful product-level sentence emerging from the experiment is:

> **Yoda preserves not only where a result came from, but how it became what it is now.**

The evidence does not yet justify claiming that Yoda solves this problem universally.

It does justify recording `LINEAGE_OF_CHANGE=DEMONSTRATED` for one controlled transformation with independent state replay.

---

## What this CASE does not mean

The biological environment should not be confused with the architectural claim.

This CASE does not establish that:

- Yoda detects SynthID Bio watermarks;
- Yoda proves authorship or biological origin;
- Yoda proves biological function;
- Yoda validates watermark robustness;
- Yoda measures watermark-removal efficacy;
- every state transition should preserve every prior state;
- Lineage of Change is universally demonstrated;
- Google DeepMind participated in, endorsed or partnered on the experiment.

Google DeepMind remained an independent public-code and publication authority.

The biological experiment is one controlled piece of evidence for a broader architectural idea:

> **Verifiable derivation should survive legitimate change.**
