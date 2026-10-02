# Yoda FIRMS-001 — Public Observation Equivalence

FIRMS-001 is a Yoda research case using public NASA FIRMS satellite-observation data with no LLM in the experiment.

It asks a narrow question:

> Can Yoda persist a real public observation snapshot and reproduce exactly the decision-relevant facts and deterministic classification derived directly from the original source?

The case uses the NASA FIRMS VIIRS S-NPP sample dataset from July 12, 2023.

Official NASA FIRMS tutorial:

https://firms.modaps.eosdis.nasa.gov/content/academy/data_ingest/firms_data_ingest.html

Public sample CSV:

https://firms.modaps.eosdis.nasa.gov/content/notebooks/sample_viirs_snpp_071223.csv

## Result

**PASS**

The tested run produced:

- 74,605 source observations;
- 900 observations in the NASA tutorial bounding box for USA (Conterminous) and Hawaii;
- 324 `2.0URT` observations;
- 900 observations written to Yoda CORE-015;
- 900 observations replayed through Yoda;
- `VERIFY=PASS` for all 900 records;
- exact fact equivalence between the raw-source oracle and Yoda replay;
- exact deterministic classification equivalence;
- durable history for a sampled observation;
- frozen evidence with SHA-256 verification.

No LLM, Python, or SQL was used in the tested path.

## Why this matters

FIRMS-001 is intentionally modest.

It does not claim that Yoda detects fires, predicts fires, outperforms another database, or improves NASA data.

It demonstrates something more foundational: the same Yoda kernel previously exercised on decision-state cases can ingest an external scientific observation domain, preserve the observations as durable state, verify them, replay them, and reproduce the independently computed source facts exactly.

The storage engine was not changed for this case.

## Files

- `CASE.md` — hypothesis, data contract, method, and gates.
- `RESULTS.md` — measured result and evidence identities.

## Next earned experiment

FIRMS-001 validates preservation and equivalence for one frozen public snapshot.

The next earned question is temporal:

> Can Yoda represent observation supersession while preserving both the previous state and the current authoritative state?

That future experiment is intentionally separate from FIRMS-001.
