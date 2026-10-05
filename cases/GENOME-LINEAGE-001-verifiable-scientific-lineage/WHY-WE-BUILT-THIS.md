# Why We Built This

The earlier genomics CASEs answered progressively stronger questions.

First:

```text
Can we preserve exact state?
```

Then:

```text
Can reconstructed state participate in the next real workflow step?
```

GENOME-LINEAGE-001 asks a different question:

> **Can we explain where the final result came from?**

That change matters because users rarely care about isolated records.

They care about questions such as:

```text
Which reference was used?
Which reads contributed?
Which alignment produced this state?
Which tool produced it?
Which evidence was frozen?
Which identities prove we are talking about the same artifacts?
```

A storage engine can preserve a Variant State perfectly while losing the explanation around it.

Yoda exists to test whether that explanation can become durable evidence too.

---

## From record reconstruction to workflow reconstruction

Earlier work demonstrated exact post-reopen reconstruction.

GENOME-VARIANT-001 went further: Alignment State reconstructed from Kyber was rehydrated into BAM and consumed by `bcftools` to create the Variant State.

That demonstrated workflow continuity.

GENOME-LINEAGE-001 then represented the explicit scientific relationships around that result.

The transition is:

```text
record reconstruction
        ↓
workflow reconstruction
        ↓
lineage reconstruction
```

This is the first genomics CASE whose central value belongs more clearly to Yoda than to KyberDB.

---

## The deeper product hypothesis

A result becomes more useful when its origin remains recoverable.

That suggests a product thesis broader than genomic storage:

> **Information behaves less like inventory and more like lineage.**

The same pattern may exist in formal reasoning, biological R&D, autonomous software and other high-value workflows.

That is now an external research question.

It is not yet a product claim.

---

## What this CASE changed

Before:

```text
Kyber:
Can the state survive?
```

After:

```text
Yoda:
Can the derivation be reconstructed?
```

That is why this CASE marks the end of the planned genomics technical ladder and the beginning of the external derivation-validation program.
