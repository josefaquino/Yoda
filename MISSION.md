# Mission

## Build the verifiable derivation layer

Yoda exists to make the origin and evolution of important results inspectable.

Modern results rarely come from a single source. They emerge from chains of data, software, models, tools, transformations, human judgment and machine decisions.

The final artifact is often easy to store.
The chain that produced and changed it is not.

Yoda is built around two connected questions:

> **Where did this result come from?**
>
> **How did it become what it is now?**

The long-term mission is to make those answers reconstructible from durable evidence rather than memory, screenshots, transient prompts or undocumented pipeline state.

---

## The thesis

> **Information behaves less like inventory and more like lineage.**

Important information has ancestry.
It has identity.
It changes.
It conflicts.
It is superseded.
It is transformed by tools.
It becomes evidence for later decisions.

A system that preserves only the latest value loses much of what makes a result explainable.

Yoda therefore treats identity, provenance, relationships, history, transformations and evidence as first-class concerns.

The project thesis is:

> **Yoda preserves not only where a result came from, but how it became what it is now.**

A second principle remains equally important:

> **Yoda does not need to be the authority that decides whether something is true. Yoda preserves the derivation required for independent authorities to decide again.**

Yoda should preserve the chain.
The appropriate external authority should evaluate the result.

---

## What Yoda wants to make possible

Given an important result, a developer, scientist or agent should eventually be able to ask:

```text
What is this?
Where did it come from?
What existed before it?
What changed?
Which transformation created the current state?
Which source data contributed to it?
Which tools and versions were used?
What evidence belongs to each state?
What became obsolete or superseded?
Which later decisions depended on it?
Can the derivation be reconstructed independently?
Can the appropriate authority evaluate each recovered state again?
```

The purpose is not to replace reasoning, scientific judgment or domain validation.

The purpose is to make the derivation behind those judgments reconstructible.

---

## Architecture

```text
Sputnik
observation
     ↓
KyberDB
state integrity
     ↓
Yoda
derivation integrity
     ↓
Independent Authorities / Agents / Humans
evaluation + decision
```

### Sputnik

Observe a changing external world.

### KyberDB

Preserve exact state durably and verify that it survived.

### Yoda

Preserve meaning around state: identity, provenance, relationships, history, transformation evidence and recoverable context.

### Independent authorities, agents and humans

Evaluate results and make decisions from evidence that survives.

Yoda should not absorb the responsibilities of the other layers.

---

## Lineage of Change

A validated CASE exposed a property that extends lineage across a state transition.

```text
State A
  ↓
Transformation T
  ↓
State B
```

The demonstrated property is:

```text
Lineage of Change
=
derivation integrity across state transitions
```

In the validating experiment:

- A remained recoverable;
- B remained recoverable;
- A and B retained distinct identities;
- `B --derived-from--> A` remained recoverable;
- transformation evidence remained recoverable;
- state-specific measurements remained attached to the correct state;
- an independent authority reproduced the original evaluation of each recovered state.

This does not create a new engine mode.

It emerges from the same primitives already used for identity, evidence, relations, history, verification and bounded context.

See [`properties/LINEAGE-OF-CHANGE.md`](properties/LINEAGE-OF-CHANGE.md).

---

## Independent Authority Replay

AXLE and SynthID Bio exposed the same architectural pattern in different domains:

```text
independent authority
        ↓
measurement / decision
        ↓
       Yoda
        ↓
recovery + lineage
        ↓
same independent authority
        ↓
same measurement / decision
```

The evolving-provenance CASE extended this pattern across two distinct states of the same artifact.

Yoda did not become the prover, detector or scientific authority.

That is the point.

---

## Evidence ladder

The current evidence sequence can be read as a progression:

```text
LINEAGE OF STATE
Where did this result come from?
        ↓
INDEPENDENT AUTHORITY REPLAY
Can the right authority evaluate it again?
        ↓
COMPOSED PROVENANCE
Can independent forms of provenance coexist?
        ↓
LINEAGE OF CHANGE
How did this become what it is now?
```

These are related observations of one derivation architecture, not separate product modes.

---

## What success would look like

Yoda succeeds if important results become easier to explain and re-evaluate without forcing every domain to adopt a giant platform.

The ideal integration remains small:

```text
existing workflow
      ↓
evidence + relations + transformations
      ↓
Yoda
      ↓
verifiable derivation
      ↓
appropriate authority
```

A scientist should keep using scientific tools.
An agent should keep using its preferred runtime.
A formal verifier should remain the formal verifier.
A provenance detector should remain the provenance detector.

Yoda should compose.

---

## Why verification matters

As AI increases the rate at which software, hypotheses, proofs, biological artifacts and decisions are produced, generation alone becomes less differentiating.

The harder questions become:

```text
Can we trace it?
Can we reproduce the chain?
Can we recover what existed before?
Can we see exactly what changed?
Can we keep evidence attached to the correct state?
Can an independent authority evaluate the recovered states again?
```

Yoda is an attempt to build infrastructure for those questions.

---

## Boundary

Yoda does not claim to prove scientific truth.

A correct derivation can still begin from bad assumptions, biased data or an inadequate experiment.

Yoda targets a narrower property:

> **Derivation integrity: the ability to reconstruct the verifiable chain that produced a result.**

`Lineage of Change` extends that property across a demonstrated state transition; it does not prove that every transition is legitimate.

The emerging category thesis is:

> **Verifiable Derivation Infrastructure**

---

## Research discipline

Yoda is developed through falsifiable CASEs.

```text
one question
one controlled experiment
explicit PASS / FAIL gates
frozen evidence
independent authority where possible
no speculative engine change
```

A successful CASE does not prove a market.
A failed CASE does not automatically earn a feature.

The architecture should change only when repeated evidence forces it to.

Public claims should flow through:

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

## Long-term direction

The project is exploring whether verifiable derivation is a cross-domain infrastructure property.

Validated proving grounds now include network state, security events, scientific observations, genomics, formal proof workflows, biological artifact provenance and one controlled evolving-artifact transition.

The next strong falsification should be externally defined rather than another experiment designed around Yoda.

If the same small architecture continues to survive qualitatively different domains and longer change histories without special modes, the result may be more important than any one vertical.

---

## Mission statement

> **Make important results traceable to the evidence and transformations that produced and changed them — so the right authority can evaluate them again.**

Or, more simply:

> **Preserve the derivation.**
