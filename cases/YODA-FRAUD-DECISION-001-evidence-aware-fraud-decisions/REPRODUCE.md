# Reproduction notes

Prerequisites: local Linux shell, DuckDB CLI, `sha256sum`, and a compatible Yoda binary with `init`, `put`, `link`, `get`, `context`, `verify`.

The source data was the publicly accessible NeoSpace Cortex prediction Parquet shard `000.parquet` from `https://embeddings.neospace.ai/cortex_score/`, acquired in the preceding evaluation case. Large Parquet files and the local Yoda store are intentionally **not** committed.

1. Select one record from `read_parquet('000.parquet')` where `YEAR(timestamp__orig)>=2018`, extracting `is_fraud` and the two `is_fraud_logits` elements into a CSV.
2. Hash the original CSV and Parquet shard using SHA-256. Initialize a new Yoda store; create source, protocol and result records, and the two links documented in CASE.md.
3. Verify Yoda and recover context. Confirm three objects, two links, and five internally verified records.
4. Retrieve `fraud/result-001` with `yoda get`; extract `prediction_sha256`.
5. Append a newline to a **copy** of the CSV. Compare its hash both to its own supplied hash (self-declared baseline) and to the earlier Yoda reference (anchored comparison). The former matches itself; the latter should differ.
6. Build a tab-delimited manifest with source, protocol, result and two links. Compare manifest counts, Yoda context and SHA-256 references for the original CSV.

**Reproduction caveat:** the original interactive shell transcripts are the evidence for the PASS status. This publication documents their procedure and outcomes; it does not claim that a new packaged script or CI job was run. `LIMIT 1` without `ORDER BY` is not guaranteed to select an identical row in all environments, so use the locally selected CSV or re-anchor a fresh row for an independent run.

Do not treat Yoda's internal `verify` as verification of the external prediction bytes. Always hash the external artifact separately.
