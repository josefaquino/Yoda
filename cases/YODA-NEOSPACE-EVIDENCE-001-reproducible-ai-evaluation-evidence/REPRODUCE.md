# Reproduce the independent metrics

## Prerequisites

Linux shell, `curl`, `sha256sum`, and a DuckDB command-line executable. The four remotely hosted score files total approximately 423 MB. These are model prediction artifacts, **not** model training data.

## Run

From this case directory:

```bash
./scripts/run-reproduction.sh
```

The shell script downloads `000.parquet` through `003.parquet` from `https://embeddings.neospace.ai/cortex_score/` with User-Agent `neoldm-benchmark`, verifies hashes against `evidence/scores.sha256`, then executes `scripts/reproduce.sql`.

The data download may be subject to third-party hosting terms; the input files are not redistributed in the Yoda repository. The case directory's `scores/` is ignored by Git.

## Algorithm

1. Set DuckDB session timezone to UTC.
2. Select transactions where `YEAR(timestamp__orig) >= 2018`.
3. Calculate `score = sigmoid(float32(logit1 - logit0))` using the SQL's cast operations.
4. Aggregate by prediction score to handle tied scores.
5. Rank descending, calculate cumulative true positives and predicted positives.
6. Compute average precision as the sum of precision-weighted positive counts divided by all positives.
7. Report the maximum possible F1 across observed score thresholds.

This independently reproduces the **UTC 2018+ cohort evaluation only**. It does not reproduce the exact cohort represented by NeoSpace's `results/fulltest_score.json`, nor model training.

## Expected output

```text
test_rows         3782053
test_fraud        4578
auprc             0.9894027718933324
best_threshold_f1 0.962490375096249
```

Cross-DuckDB-version last-digit differences are possible. Best-F1 is a **retrospective** selection and is not an independently validated deployment threshold.

For observed data identities and environment, see `evidence/scores.sha256`, `evidence/upstream-commit.txt`, and `evidence/public-reproduction.txt`.

## Yoda evidence

The independent metrics can be stored in the existing Yoda CLI as separate source, protocol, and result records with explicit links. Yoda's `verify` operation checks the stored Yoda records, **not the downloaded Parquet data**. The independent file hash checks and metrics are handled externally.
