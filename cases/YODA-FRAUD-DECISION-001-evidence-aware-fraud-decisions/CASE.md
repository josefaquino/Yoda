# Experiment contract and observations

**Question:** Can a previously persisted Yoda evidence reference influence a decision about whether an externally produced prediction file should be admitted, and how does this compare with a structured manifest?

**Environment:** Bash/POSIX utilities, DuckDB CLI, frozen Yoda preview binary, locally downloaded Cortex prediction Parquet shard. Execution reported on a Linux workstation.

**Yoda database:** `$HOME/Yoda-Workspace/cases/YODA-FRAUD-DECISION-001/fixtures/yoda-store`

**Records:** `fraud/source-001`, `fraud/protocol-001`, `fraud/result-001`.

**Relations:** `fraud/result-001 --evaluated_under--> fraud/protocol-001`; `fraud/protocol-001 --uses--> fraud/source-001`.

## Stages

1. Select one prediction with `YEAR(timestamp__orig)>=2018` from the public Cortex Parquet, write a local CSV, compute SHA-256, store evidence and relations in Yoda, and inspect `verify` and `context`. Three hard-coded adapter decisions illustrate allow/review/deny conditions; they **do not** read Yoda in stage 1.
2. Retrieve `fraud/result-001` with `yoda get`, extract the persisted `prediction_sha256`, append a newline to a copy of the CSV, and compare the modified file hash with the recovered reference. A self-declared hash baseline accepts the modified file, whereas the Yoda-backed adapter denies it.
3. Construct a TSV manifest containing source, protocol, result and two links. Check that manifest and Yoda context recover the same object/link counts, and compare the original file SHA-256 against both the manifest and `yoda get` reference.

## Boundaries

The newline modification is byte-level tampering, not semantic fraud or an adversarially secured attack. A protected manifest can provide the same independent hash anchor. Stage 3's manifest was generated from the current local file and was not tested for tamper resistance or independent historical anchoring. The experiment did not measure latency, scale, availability, authorization, fraud classification accuracy, or actual agent autonomy.
