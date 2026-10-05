# Why We Built This

Yoda emerged from a sequence of increasingly demanding experiments about identity, state, workflow continuity and lineage.

Genomics demonstrated one form of verifiable derivation:

```text
Reference
↓
ReadSet
↓
Alignment
↓
Variant
↓
Lineage
```

But that workflow was still empirical science.

We wanted to know whether the same small Yoda architecture could survive a qualitatively different authority model without adding a Math Mode or theorem-proving subsystem.

Formal mathematics is useful because it gives us something biology cannot provide: an independent formal authority capable of saying whether a candidate proof satisfies a precise statement.

That made AXLE a strong adversary for the next experiment.

The research question became:

> **Can Yoda preserve the origin of a result while another system remains the authority for whether that result is formally valid?**

This separation matters.

A lineage system that quietly becomes its own semantic authority is difficult to trust.

The experiment therefore assigned distinct responsibilities:

```text
AXLE
→ prove whether the candidate satisfies the formal statement

Yoda
→ preserve what statement, proof, environment and verification evidence produced that result
```

The negative arm was designed to avoid a weak test.

We did not give AXLE broken Lean syntax.

We gave it a valid Lean theorem proving a different proposition.

That candidate compiled successfully, but AXLE rejected it against the original statement.

This exposed the distinction we care about:

```text
artifact validity
!=
derivation validity against a specification
```

Stage A1 then made Yoda part of the loop.

The statement, proof, controlled mutation, environment and external verification evidence were stored with explicit relations. Yoda recovered the proof artifacts byte-for-byte. Those recovered artifacts were sent back to AXLE.

AXLE reproduced both decisions:

```text
valid proof     → ACCEPT → Yoda → recover → ACCEPT
mutated proof   → REJECT → Yoda → recover → REJECT
```

This does not make Yoda a prover.

It demonstrates a complementary property:

> **The authority that verifies a result and the infrastructure that preserves its derivation do not need to be the same system.**

That is strategically important for the broader Yoda thesis.

If AI-era systems produce more scientific, mathematical and operational results, the scarce resource may not only be generation. It may be the ability to reconstruct which artifacts, tools, environments, evidence and decisions produced a result — and then submit those artifacts back to the appropriate authority for independent verification.

This CASE is one small controlled demonstration of that architecture.

It is not proof of a general platform or a market.

It is evidence that verifiable derivation survived its first move from empirical genomics into formal proof verification without a Yoda or Kyber engine change.
