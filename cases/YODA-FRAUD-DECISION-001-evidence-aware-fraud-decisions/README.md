# YODA-FRAUD-DECISION-001 — Evidence-Aware Fraud Decisions

Status: **STAGE1=PASS · STAGE2=PASS · STAGE3=PASS** (reported terminal execution; independent CI reproduction not performed).

This case tests Yoda as a local, persistent evidence reference for an externally produced NeoSpace Cortex fraud prediction. It is **not** a fraud-detection model, a direct Cortex competitor, or a claim of performance superiority.

## Observed results

- Stage 1: a public Cortex prediction was selected from a locally held Parquet shard; Yoda stored three evidence objects (source, protocol, result) and two relations. `verify` reported `VERIFY=PASS`, `RECORDS_SCANNED=5`, `RECORDS_VERIFIED=5`. `context` recovered all three objects and both relations.
- Stage 2: an extra newline was appended to the selected prediction CSV. A self-declared-hash baseline accepted the modified file; an adapter comparing against the hash recovered from Yoda rejected it. The original file was accepted. `STAGE2=PASS`.
- Stage 3: a structured TSV manifest represented the same three objects and two relations. Manifest and Yoda references agreed on the original prediction hash. `STAGE3=PASS`.

## Interpretation

The Yoda-backed decision was made by an **external Bash adapter**; Yoda supplied a previously persisted reference. The stage-2 baseline deliberately trusted a self-declared hash, and is not a security-equivalent baseline. Stage 3 established small-scale **functional parity** with a structured manifest, not superiority. Yoda's `verify` verifies **internal Yoda records**, not the external Parquet or CSV automatically.

No Yoda core modifications were made. No real financial transactions were processed; the source benchmark contains synthetic transactions.

See [CASE.md](CASE.md), [RESULTS.md](RESULTS.md), and [REPRODUCE.md](REPRODUCE.md). Original upstream: [NeoLDMBenchmark](https://github.com/neospace-ai/NeoLDMBenchmark). Related evaluation case: [PR #1](https://github.com/josefaquino/Yoda/pull/1).
