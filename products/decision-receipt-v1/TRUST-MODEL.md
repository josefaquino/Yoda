# Decision Receipt v1 — Trust Model

Decision Receipt v1 is portable across a trust boundary, but it is not a universal cryptographic root of trust.

## Trusted verification context

The validated model assumes a trusted verification context that includes:

- the verifier implementation or verifier identity;
- receipt-version semantics;
- hash-algorithm semantics;
- expected authority identities established independently when external authenticity is required.

## Untrusted transport

The following may arrive through an untrusted transport:

- `receipt.json`;
- `manifest.sha256`;
- evidence files;
- the bundle directory as a whole.

The verifier treats receipt assertions as claims to check, not truths.

## What was actually tested

Two tamper scenarios were executed against the same frozen verifier:

```text
result:
-0.057183
→ -0.050000

expected rejection:
RESULT_EVIDENCE_MISMATCH
```

and:

```text
rule authority SHA-256:
45fe6311...
→ 00000000...

expected rejection:
RULE_AUTHORITY_MISMATCH
```

In both cases the manifest was recalculated. The altered bundles still passed topology, bundle integrity and receipt schema before being rejected by deeper verification.

```text
RESEALED_MANIFEST_BYPASS=NO
TAMPER_DETECTION=PASS
```

## What this does not prove

Decision Receipt v1 does not by itself prove protection against an attacker who can replace all of the following together:

```text
receipt
evidence
trusted authorities
verifier
verifier distribution channel
```

It does not yet provide:

- digital signatures;
- a published public-key trust root;
- non-repudiation;
- a transparency log;
- protection against trusted-verifier replacement;
- protection against trusted-authority replacement.

Those are future properties, not implied by v1.
