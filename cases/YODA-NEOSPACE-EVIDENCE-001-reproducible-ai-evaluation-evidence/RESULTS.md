# Results — YODA-NEOSPACE-EVIDENCE-001

**Local independent evaluation:** PASS  
**Public reproduction script:** PASS  
**Yoda internal evidence verification:** PASS

| Check | Observed |
| --- | --- |
| Public Parquet SHA-256 | 4/4 OK |
| Independent UTC 2018+ rows | 3,782,053 |
| Fraud count | 4,578 |
| Average precision | 0.9894027718933324 |
| Maximum (retrospective) F1 | 0.962490375096249 |
| Yoda evidence objects | 3 |
| Yoda relation records | 2 |
| Yoda `verify` | `PASS RECORDS_SCANNED=5 RECORDS_VERIFIED=5` |
| Yoda source change | NONE |

The two metric report files from independent invocations had the same SHA-256, `f6f6537115c3b1d5945d484519aad3ef2b19b2e2d6f3467c94e68c2dd5b59d5f`; the public script also reproduced the numeric values. This confirms repeatable output **in the observed local environment**, not universal cross-version bitwise reproducibility.

## Published reference — different cohort

NeoSpace's committed `results/fulltest_score.json` reports 2,412,326 transactions, 2,698 fraud cases, AUPRC `0.988520247682862`, and F1 `0.959279414524301`. Its cohort/protocol differs from the UTC-year-filtered sample above. **Do not treat the metrics as a like-for-like comparison.**

## Scope of evidence

The published results establish local data identity checks, independent metric evaluation and Yoda evidence storage/recovery. They do **not** establish Yoda verifying Parquet files, detecting an incorrect model report automatically, nor matching the official published split.
