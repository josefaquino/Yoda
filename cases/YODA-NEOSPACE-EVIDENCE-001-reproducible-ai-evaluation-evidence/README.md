# Yoda × NeoSpace Cortex — Reproducible Evidence for AI Evaluations

**Case ID:** YODA-NEOSPACE-EVIDENCE-001  
**Outcome:** Local evidence experiment PASS; independent evaluation reproduced.  
**Scope:** Public Cortex prediction files, independent DuckDB metrics, and evidence stored in Yoda.

## Why this matters

A model score is not self-explanatory. To review an AI evaluation, a developer needs to recover the identities of the data used, the evaluation protocol, and the result together.

This case demonstrates a small evidence chain preserved by the existing Yoda CLI:

```text
result-001 --evaluated_under--> protocol-001 --uses--> source-001
```

DuckDB computes the metrics. Yoda stores the evidence records, explicit links, and local context; it does **not** compute the metrics, train Cortex, automatically validate the external score files, or certify the correctness of the evaluation.

## Results

| Measurement | Independent UTC year ≥ 2018 cohort |
| --- | ---: |
| Transactions | 3,782,053 |
| Fraud transactions | 4,578 |
| Average precision (AUPRC) | 0.9894027718933324 |
| Retrospective best-threshold F1 | 0.962490375096249 |

Four public Parquet prediction shards were verified by SHA-256, and two independent DuckDB invocations plus the public script produced the same metrics. Yoda internal verification returned `VERIFY=PASS` for 5 stored records (3 objects and 2 links).

**Important:** The NeoSpace committed summary reports a **different** test cohort (2,412,326 transactions, 2,698 frauds). These numbers are **not** an exact reproduction of that official summary. Do not infer a source error, comparable split, or model improvement from this difference.

## Reproduce

Requires Linux, `curl`, `sha256sum`, and the DuckDB CLI. The download is approximately 423 MB; the four Parquet files are **not** committed here.

```bash
./scripts/run-reproduction.sh
```

The script fetches the public predictions with the upstream notebook's User-Agent, checks the pinned SHA-256 hashes, and runs `scripts/reproduce.sql` using UTC timestamps. No Python is needed for this independent evaluation.

See [REPRODUCE.md](REPRODUCE.md), [CASE.md](CASE.md), [RESULTS.md](RESULTS.md), and [evidence/](evidence/).

## Attribution and limits

The source benchmark is [NeoLDMBenchmark](https://github.com/neospace-ai/NeoLDMBenchmark), pinned to commit `32154368d5634408a0914f0a7b8c71112b2c3543`. Its repository declares Apache-2.0; rights to associated third-party data and externally hosted prediction artifacts must be considered separately. This repository publishes scripts, hashes, and factual output, **not** the Parquet binaries or IBM source dataset.

This is an independent Yoda case and is **not** an endorsement or official validation by NeoSpace.
