# Why We Built This

Yoda began by asking whether state and lineage could be reconstructed exactly.

Genomics showed that a scientific result could be traced backward through prior states and tools.

AXLE then showed something stronger: Yoda did not need to become the authority that decides whether a result is valid. It could preserve the derivation and let an independent authority decide again.

That suggested a deeper architectural pattern:

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

SynthID Bio gave us a qualitatively different way to test that pattern.

Instead of an external proof artifact evaluated by a formal verifier, SynthID Bio carries a provenance signal inside an AI-generated biological artifact and provides an independent detector for measuring that signal.

Yoda operates outside the artifact.

It preserves the surrounding derivation:

- which artifact was produced;
- which authority and code version were used;
- which parameters were active;
- which measurement was observed;
- which evidence supports that measurement;
- which relationships connect the artifact to its history.

That created a new research question:

> **Can intrinsic provenance inside an artifact and external workflow provenance around that artifact coexist without either losing its identity?**

The experiment deliberately used two arms.

```text
control
→ no watermark flag
→ lower measured g-values

watermarked
→ SynthID Bio enabled
→ higher measured g-values
```

This matters because preserving only the positive arm would be a weak test.

A useful trust layer must not only avoid destroying a signal that exists. It must also avoid creating the appearance of a signal where the control did not have one.

The CASE therefore tested both:

```text
Yoda does not destroy the measured signal.
Yoda does not fabricate the measured signal.
```

Stage A0 established the external authority before Yoda was allowed to write anything.

Stage A1 stored the artifacts, measurements, detector identity, parameters and evidence in a fresh Yoda store. Yoda recovered the biological artifacts byte-for-byte and reconstructed their provenance context.

Stage B then took only the artifacts recovered from Yoda and sent them back to the frozen SynthID Bio detector.

The detector reproduced all four measurements exactly:

```text
CONTROL      0.5037 → 0.5037
CONTROL      0.5130 → 0.5130
WATERMARKED  0.7961 → 0.7961
WATERMARKED  0.7184 → 0.7184
```

The important result is not that Yoda learned to detect a watermark.

It did not.

The important result is that the authority stayed independent while Yoda preserved the derivation required to replay the measurement.

That leads to the strongest formulation we have found so far:

> **Yoda does not need to be the authority that decides whether something is true. Yoda preserves the derivation required for independent authorities to decide again.**

The SynthID Bio CASE also introduced a useful concept for the broader research program:

## Composed provenance

```text
inside the artifact
→ intrinsic provenance signal
→ SynthID Bio

outside the artifact
→ workflow provenance / derivation
→ Yoda
```

Those two layers were demonstrated together in one controlled workflow without a Yoda or Kyber engine change.

This does not prove a universal provenance architecture.

It does not prove biological origin, authorship, function or scientific truth.

It does not imply Google DeepMind endorsement or partnership.

But it does strengthen the thesis that Yoda may belong in a different category from databases, workflow engines and domain-specific scientific tools:

> **Verifiable Derivation Infrastructure**

The broader bet is that as AI makes generation abundant, trust increasingly depends on the ability to reconstruct how a result came to exist and to return that result to the right independent authority for evaluation.

This CASE is one controlled piece of evidence for that architecture.