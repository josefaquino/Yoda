# Results — terminal evidence supplied by experiment operator

| Check | Observed outcome |
|---|---|
| Stage 1 | PASS |
| Real Cortex prediction selected | YES |
| Yoda internal verification | PASS; 5 scanned, 5 verified |
| Yoda context | 3 objects and 2 relations visible |
| Stage 1 Bash policy | VALID=ALLOW, MISSING=REVIEW, CONFLICT=DENY |
| Stage 2 reference recovered | YES |
| Stage 2 modified file | YES (one newline appended) |
| Stage 2 self-declared-hash baseline | ALLOW |
| Stage 2 Yoda-backed adapter | DENY |
| Stage 2 original control | ALLOW |
| Stage 2 | PASS |
| Stage 3 manifest recovery | 3 objects, 2 links |
| Stage 3 Yoda recovery | 3 objects, 2 links |
| Stage 3 hash parity | PASS |
| Stage 3 | PASS |
| Core changes | NO |

### Observed identities

Source Parquet shard `000.parquet` SHA-256:
`7629ec7aaea9ba7f58abb872013dfdbd1b891064fa6f384093300a7ea18ecc22`

Original selected prediction CSV SHA-256:
`3a6f2f761b3805b83cee7239459eb3fa5715deb82b6b60aa5ecd6e0706965dc6`

The hashes above were printed in Yoda context by the operator. The exact CSV row is not published in this case.

### Verdict

**FUNCTIONAL_EXECUTION=PASS**

**INDEPENDENT_EVIDENCE_ANCHOR_UTILITY=DEMONSTRATED_IN_STAGE2**

**STRUCTURED_MANIFEST_FUNCTIONAL_PARITY=PASS_IN_STAGE3**

**YODA_SUPERIORITY_OVER_MANIFEST=NOT_DEMONSTRATED**

**SUPERIORITY_OVER_NEOSPACE_CORTEX=NOT_EVALUATED**

**FRAUD_DETECTION_IMPROVEMENT=NOT_EVALUATED**

These are observations from user-provided terminal logs, not a separately verified GitHub Actions execution.
