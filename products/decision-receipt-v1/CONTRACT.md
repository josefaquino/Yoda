# Decision Receipt v1 — Contract

**Status:** frozen product contract.

A Decision Receipt is a portable evidence package for a previously produced decision.

## Required receipt fields

Version 1 requires 19 schema paths:

```text
receipt_version
decision_id
decision.status
decision.reason
decision.result
operation.metric
operation.period_start
operation.period_end
state_used
state_used[].fact_id
state_used[].sha256
authorities.context.version
authorities.context.sha256
authorities.rule.version
authorities.rule.sha256
authorities.evaluator.version
authorities.evaluator.sha256
evidence.data_yoda_sha256
evidence.original_outcomes_sha256
```

Frozen schema identity:

```text
RECEIPT_SCHEMA_V1_SHA256=
73333e4b9a092541607e3e5fe48b1e65c4715bbd02b7bb1e85ee06c2ff0fd3bd
```

## Bundle topology

A v1 bundle contains 11 required files:

```text
receipt.json
manifest.sha256
evidence/state.tsv
evidence/document-metadata.tsv
evidence/semantic-mappings.tsv
evidence/metric-contract.tsv
evidence/refusal-policy.tsv
evidence/context-authority.tsv
evidence/evaluator.c
evidence/scenario.tsv
evidence/original-outcome.tsv
```

Frozen topology identity:

```text
BUNDLE_TOPOLOGY_V1_SHA256=
973c019522afbb0e6ae70fbf674f5d7a3291c45d2a798461c7cdb2dd0b7c2a0d
```

## Canonicalization

Decision Receipt v1 uses:

- UTF-8 text;
- LF line endings;
- canonical JSON key ordering equivalent to `jq -S`;
- SHA-256 rendered as 64 lowercase hexadecimal characters;
- lexical ordering of manifest paths;
- no inclusion of `manifest.sha256` in its own digest set;
- string representation for ALLOW results;
- JSON `null` for REFUSE results.

Frozen canonicalization identity:

```text
CANONICALIZATION_V1_SHA256=
967ff5a61eadf4e98ec55b8c0b594c4185db3d2a1a2ca15b39959e3b567890c3
```

## Verification principle

A receipt is not accepted because its self-declared hashes look well formed.

Verification combines topology, manifest integrity, schema validation, authority identity checks and operational replay/consistency checks.

A recalculated manifest proves only byte consistency of that transported bundle. It does not establish external authorship or authenticity.

## Compatibility

Unknown receipt semantics require a new `receipt_version`. A v1 verifier must not silently interpret an unknown version as v1.

Decision Receipt v1 is domain-independent. The CVM workload was the validating authority, not part of the public envelope semantics.
