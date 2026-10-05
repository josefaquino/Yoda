# Public Note — FORMAL-MATH-EVOLVING-DERIVATION-001 / A2

Today we reached a useful milestone in the Yoda research program.

The question was deliberately narrow:

> Can Yoda preserve a versioned derivation between two independently verified formal proof states without changing Yoda or Kyber?

The formal workload came from a frozen MiniF2F commit. We constructed two different proofs of the same theorem:

```text
Nat.gcd 180 168 = 12
```

Proof A used direct kernel computation.

Proof B made the Euclidean derivation explicit.

Both proof states passed Lean and were independently VERIFIED by OxiLean.

Then we moved to Yoda.

Yoda stored the statement, both proof states, the A→B transformation, Lean evidence, OxiLean evidence and the frozen A1-R1 evidence authority.

The one-shot A2 harness did not complete: it hit a query-tokenization mismatch in a context assertion.

We did not rerun it.

Instead, we preserved the exact durable state and adjudicated it read-only.

The result:

```text
YODA_VERIFY=PASS

byte-exact recovery=PASS

Proof B --derived-from--> Proof A
recoverable

Proof B --transformed-by--> Transformation
recoverable

bounded derivation context=PASS

data.yoda unchanged during adjudication=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

So the careful conclusion is:

```text
A2-R1 one-shot:
NOT_EVALUATED

A2 research question:
PASS_BY_READ_ONLY_ADJUDICATION
```

I think the methodological part matters as much as the result.

When an instrument or harness fails, preserve the failed measurement.

Do not relabel it.

Do not silently rerun until it passes.

Use the immutable evidence you already have to determine what actually happened.

Earlier in this CASE we preserved an OxiLean capability boundary instead of calling it a mathematical failure.

Here we preserved a harness failure instead of calling it a Yoda failure.

The full cross-domain claim is not complete yet.

Stage B still has to recover the proof states from Yoda and independently replay Lean and OxiLean.

That is the next gate — not today's gate.

One hypothesis.
One experiment.
One conclusion at a time.
