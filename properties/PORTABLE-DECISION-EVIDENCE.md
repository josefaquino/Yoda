# Portable Decision Evidence

## Property

> **A preserved decision can be packaged as a portable evidence bundle that an independent verifier can evaluate without access to the originating Yoda store, source system or internal evidence layout.**

## Demonstrated by

`YODA-AGENT-DECISION-RECEIPT-001`.

The CASE demonstrated:

```text
PORTABLE_DECISION_EVIDENCE=PASS
THIRD_PARTY_VERIFICATION=PASS
RESEALED_TAMPER_DETECTION=PASS
```

The independent verifier required:

```text
YODA_ACCESS=NO
CVM_ACCESS=NO
ORIGINAL_CASE_ACCESS=NO
DECISION_REGISTRY_ACCESS=NO
```

The external agent used only:

```text
decision_id
```

and did not need internal Yoda keys or relations.

## Negative evidence

Two transported receipts were modified and their manifests recalculated.

The same frozen verifier rejected:

- an altered result with `RESULT_EVIDENCE_MISMATCH`;
- an altered rule-authority hash with `RULE_AUTHORITY_MISMATCH`.

This establishes that outer-manifest resealing alone was insufficient to make contradictory evidence pass the tested verifier.

## Boundary

This property is not equivalent to universal tamper-proofing, cryptographic authorship or non-repudiation.

The demonstrated trust model assumes trusted verifier semantics and trusted authority identities outside the adversary capabilities exercised in the CASE.

## Product expression

Decision Receipt v1 exposes the property through the frozen interface:

```bash
yoda decision get <decision_id> --output <bundle-dir>
yoda decision verify <bundle-dir>
```

The initial backend is the validated four-decision registry. Horizontal discovery remains future product work.
