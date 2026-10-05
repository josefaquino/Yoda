# Project Thesis

## Verifiable derivation for evolving state

Yoda is exploring a simple idea:

> **Information behaves less like inventory and more like lineage.**

Important information does not merely exist. It is observed, transformed, evaluated, related to other evidence, superseded, challenged and reused.

A final result is therefore only one point in a larger derivation.

The project thesis is:

> **Yoda preserves not only where a result came from, but how it became what it is now.**

This extends the original research question without replacing it.

```text
Where did this result come from?
            +
How did it become what it is now?
```

---

## From state to derivation

Conventional state storage primarily answers:

```text
What is the state now?
```

Version history can additionally answer:

```text
What were earlier states?
```

Yoda is investigating a stronger reconstruction problem:

```text
What is the state now?
What was it before?
What changed?
What evidence describes that change?
Which authority evaluated each state?
Can the states, transition and evaluations be reconstructed later?
```

This is the difference between preserving versions and preserving derivation.

---

## Architectural thesis

The current architecture separates responsibilities:

```text
Sputnik
=
observation

Kyber
=
durable state integrity

Yoda
=
derivation integrity

Independent Authorities / Humans / Agents
=
evaluation + decision
```

`Lineage of Change` does not add another subsystem.

It is a demonstrated property of the derivation layer:

```text
Lineage of Change
=
derivation integrity across state transitions
```

The validating CASE showed that a new state identity can be created while the prior state, resulting state, transition evidence and state-specific external evaluations remain recoverable.

---

## Evidence ladder

The thesis did not begin as a slogan. It emerged from sequential CASEs.

### Lineage of State

Question:

> **Where did this result come from?**

Evidence:

`GENOME-LINEAGE-001`

Observed property:

```text
prior scientific states
+
tools
+
evidence
+
relations
→ recoverable lineage
```

### Independent Authority Replay

Question:

> **Can Yoda preserve enough derivation for an external authority to evaluate a recovered result again?**

Evidence:

`AXIOM-YODA-PROOF-LINEAGE-001`

Observed pattern:

```text
external authority
→ decision
→ Yoda preservation
→ recovery
→ same external authority
→ same decision
```

### Composed Provenance

Question:

> **Can provenance inside an artifact coexist with provenance around the artifact?**

Evidence:

`SYNTHID-BIO-YODA-PROVENANCE-001`

Observed property:

```text
intrinsic provenance measurement
+
external workflow derivation
→ coexistence + independent replay
```

### Lineage of Change

Question:

> **How did this become what it is now?**

Evidence:

`SYNTHID-BIO-EVOLVING-PROVENANCE-001`

Observed property:

```text
State A
  ↓
Transformation T
  ↓
State B

identity(A) != identity(B)

while:
A remains recoverable
B remains recoverable
A → B remains recoverable
T remains recoverable
state-specific evidence remains recoverable
independent authority replay remains reproducible
```

This was formalized in [`properties/LINEAGE-OF-CHANGE.md`](properties/LINEAGE-OF-CHANGE.md).

---

## The working category

The emerging category thesis remains:

> **Verifiable Derivation Infrastructure**

The category is broader than provenance storage and narrower than a truth engine.

Yoda does not claim to determine whether an arbitrary result is scientifically, formally or operationally true.

It aims to preserve the derivation required for the appropriate authority to inspect or evaluate that result again.

The current thesis can be summarized as:

```text
State integrity
        ↓
Derivation integrity
        ↓
Derivation integrity across change
        ↓
Independent re-evaluation
```

---

## Public language

Two sentences currently express the thesis without exceeding the evidence.

Product-level language:

> **Yoda preserves not only where a result came from, but how it became what it is now.**

Demonstrated-property language:

> **A valid change can create a new identity without destroying the verifiable lineage of what came before.**

The second sentence is supported only within the scope of the validating CASE and must not be presented as a universal guarantee.

---

## What the thesis does not mean

The project does not currently claim that:

- Yoda determines whether every transformation is legitimate;
- every state transition can be represented without additional domain adapters;
- arbitrary long change histories have been validated at production scale;
- Yoda replaces scientific, formal or operational authorities;
- Yoda proves authorship, origin, biological function or scientific truth;
- Yoda natively performs arbitrary multi-hop graph reasoning;
- the demonstrated properties establish product-market fit.

The evidence remains narrower than the ambition.

---

## Research discipline

The thesis should continue to evolve only through evidence.

```text
EVIDENCE
   ↓
FORMAL PROPERTY
   ↓
PROJECT THESIS
   ↓
PUBLIC LANGUAGE
```

A public claim should be traceable backward through that chain.

The operating rule remains:

> **Big vision. Small steps. Evidence always.**
