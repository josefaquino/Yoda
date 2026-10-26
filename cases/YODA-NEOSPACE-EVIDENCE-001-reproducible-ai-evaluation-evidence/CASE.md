# Case contract — YODA-NEOSPACE-EVIDENCE-001

## Question

Can the existing public Yoda CLI retain and recover a connected chain of source identity, evaluation method and independently computed AI-model results?

## Inputs

- NeoSpace [NeoLDMBenchmark](https://github.com/neospace-ai/NeoLDMBenchmark) at `32154368d5634408a0914f0a7b8c71112b2c3543`
- Four public published Cortex score Parquet shards; identities listed in `evidence/scores.sha256`
- Synthetic IBM TabFormer transaction setting; **no claim to reproduce model training**

## Independent evaluation

The DuckDB calculation uses the subset `YEAR(timestamp__orig) >= 2018` with UTC timezone. It converts a two-element logits array into a fraud score through a sigmoid of the logit difference. It groups tied scores, computes cumulative true positives and predicted positives in descending score order, sums average-precision contributions, and takes the maximum F1 across observed score thresholds.

Float conversions and library implementations can differ; this is **not** a bit-identical replay of the notebook's NumPy/scikit-learn execution. The selected best-F1 threshold is retrospective on the test population, not an independently chosen deployment threshold.

## Yoda operations observed

- `init`
- Three `put` records (source, protocol, result)
- Two `link` records: `result evaluated_under protocol` and `protocol uses source`
- `verify` returning `PASS`, five records scanned and verified
- `context` returning evidence objects, with the protocol→source link rendered

The result→protocol link was created and counted among stored records but was **not separately shown** in the captured `context` output. Do not claim full visual traversal was independently demonstrated.

## Boundary

Yoda verifies **internal record integrity**. External Parquet file identities are checked by `sha256sum`; DuckDB computes metrics. The case does not show automatic external-file checking, automatic invalidation of dependencies, detection of statistically erroneous protocols, training, or causal performance improvement.
