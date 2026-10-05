# Genesis

## The Internet is a living organism

Yoda did not begin as a database project.

It began with a worldview:

> **The Internet is a living organism. Data is born, changes, forms relationships, conflicts, ages, and is replaced.**

If that is true, then data should not be understood only as rows, files or objects sitting still.

It has ancestry.
It mutates.
It accumulates evidence.
It can be superseded.
It can conflict with neighboring information.
It can produce descendants.

That idea became the seed of everything that followed.

---

## Sputnik — observation

The first problem was observation.

How do you watch a changing information ecosystem without pretending it is static?

Sputnik emerged as the observation layer: discover, collect and classify signals from a living external world.

Its job was not to own the Internet.
Its job was to observe it.

```text
world
  ↓
observation
  ↓
Sputnik
```

The early work around feeds, discovery and changing web ecosystems taught an important lesson:

> The interesting part of data is often not the record itself, but where it came from and how it relates to other records.

---

## KyberDB — state

Observation immediately creates a second problem.

If something matters, can we preserve it exactly?

KyberDB emerged as the state engine: a local C11 embedded database focused on exact persistence, durability, verification and reconstruction.

The question became:

> **Can this state survive?**

Kyber was deliberately kept domain-agnostic.

It should not need to understand biology, routing, security or AI.

It should understand state.

```text
observation
    ↓
state
    ↓
KyberDB
```

---

## Yoda — derivation

Once state could survive, a harder question appeared.

A result can be perfectly preserved and still be impossible to explain.

The next question became:

> **Where did this result come from?**

Yoda emerged as the layer above exact state: evidence, identity, relationships, history, provenance and bounded context.

The object under test changed.

```text
Kyber:
Can I preserve this state?

Yoda:
Can I reconstruct why this state exists?
```

That is the transition from storage to derivation.

---

## Genomics changed the project

Genomics became the first serious product-discovery lab because it forced the architecture through a chain of increasingly difficult questions.

```text
Reference
   +
ReadSet
   ↓
Alignment
   ↓
Variant
   ↓
Lineage
```

No special Genome Mode was added.
No biology-specific storage engine was invented.

Instead, each CASE asked a narrower question of the existing core.

The most important result was not that genomic objects could be stored.

It was that a final scientific result could be connected back to the tools, evidence and prior states that produced it.

That suggested a more general thesis:

> **Information behaves less like inventory and more like lineage.**

---

## The architecture that emerged

Looking backward, the project now has a surprisingly coherent shape:

```text
Sputnik observes the living world of data.
Kyber preserves its state.
Yoda reconstructs its lineage.
Agents decide from the evidence that survives.
```

Or:

```text
Sputnik
OBSERVATION
     ↓
KyberDB
STATE
     ↓
Yoda
DERIVATION
     ↓
Agents / Humans
DECISION
```

This architecture was not designed in one meeting.
It emerged from successive experiments.

---

## From Internet lineage to scientific lineage

The Internet was the first organism we observed.

It does not need to be the last.

The same concepts appeared again in scientific workflows:

```text
identity
history
relationships
mutation
origin
evidence
verification
```

That is why Yoda is not being positioned as an Internet crawler, a genomic database or an AI framework.

Those were proving grounds.

The deeper problem is the lineage of information itself.

---

## The next chapter

AI systems are increasing the rate at which artifacts and decisions are produced.

That creates a new question:

> What evidence survives after the generation process is over?

Yoda's next research phase moves into external workflows:

```text
formal proof verification
biological design-build-test-learn
agent decision evidence
```

The hypothesis is that the same small primitives — identity, relation, history, provenance, evidence and verification — may remain useful across all of them.

That hypothesis is not yet proven.

That is what the next CASEs are for.

---

## The founding idea

The original sentence remains the beginning of the project:

> **The Internet is a living organism. Data is born, changes, forms relationships, conflicts, ages, and is replaced.**

Today we would add one more line:

> **And information worth trusting should carry a recoverable lineage.**
