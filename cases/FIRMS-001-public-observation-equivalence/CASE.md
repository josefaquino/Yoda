# FIRMS-001 — Experiment Contract

## Status

Validated on 2026-10-02.

## Research question

Can Yoda persist a real public observation snapshot and reproduce exactly the facts and deterministic classification obtained directly from the original public source?

## External authority

NASA FIRMS public VIIRS S-NPP sample dataset:

https://firms.modaps.eosdis.nasa.gov/content/notebooks/sample_viirs_snpp_071223.csv

NASA FIRMS data-ingest tutorial:

https://firms.modaps.eosdis.nasa.gov/content/academy/data_ingest/firms_data_ingest.html

The NASA tutorial reports:

- 74,605 rows;
- 14 columns;
- for the USA (Conterminous) + Hawaii bounding box `[-160.5, 17.5, -63.8, 50]`, 900 detections;
- 324 records with `version == 2.0URT`.

These published values are used as external reference gates, not derived from Yoda.

## Frozen source observed in the validated run

```text
SOURCE_SHA256=edf79f62b35ba4485d7c85e01be5f6f61d30ab7b4addcf2eea00e2581982c30f
SOURCE_BYTES=6077404
SOURCE_ROWS=74605
```

CSV contract:

```text
latitude
longitude
bright_ti4
scan
track
acq_date
acq_time
satellite
instrument
confidence
version
bright_ti5
frp
daynight
```

Every source row in the selected subset had exactly 14 fields.

## Core authority

The experiment used Yoda CORE-015:

```text
CORE015_SHA256=1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb
```

No product or storage-engine change was introduced for FIRMS-001.

## Experimental architecture

```text
NASA FIRMS CSV
      |
      +--------------------------> RAW ORACLE
      |                              |
      |                              | canonical facts
      |                              | deterministic class
      v                              |
canonicalizer                        |
      |                              |
      v                              |
Yoda CORE-015                        |
      |                              |
      v                              |
verify                               |
      |                              |
      v                              |
900 exact get operations             |
      |                              |
      v                              |
Yoda replay facts -------------------+
              exact comparison
```

The source oracle and Yoda replay are intentionally separate paths.

## Source subset

The case applies the NASA tutorial bounding box:

```text
west  = -160.5
south = 17.5
east  = -63.8
north = 50
```

Required raw-source gates:

```text
RAW_SUBSET_ROWS=900
RAW_URT_ROWS=324
RAW_OTHER_ROWS=576
```

## Canonical observation identity

Each selected CSV row is hashed independently with SHA-256.

The Yoda key is:

```text
firms/obs/<source-row-sha256>
```

The validated run required:

```text
MANIFEST_ROWS=900
UNIQUE_KEYS=900
```

This makes observation identity independent of row order inside the subset.

## Stored observation facts

Each Yoda record preserves the source observation values used by the case:

```text
latitude
longitude
bright_ti4
scan
track
acq_date
acq_time
satellite
instrument
confidence
version
bright_ti5
frp
daynight
source_row_sha256
```

The source label was:

```text
source=nasa-firms-public-sample
```

## Deterministic classification

FIRMS-001 deliberately avoids an interpretive or predictive fire model.

The classification is only a deterministic projection of the source `version` field:

```text
version == 2.0URT  -> ULTRA_REAL_TIME
otherwise          -> OTHER
```

This rule exists to test decision equivalence after persistence and replay. It is not a NASA hazard classification and is not presented as an operational fire decision.

## Yoda replay path

After ingest, Yoda must pass authoritative verification.

Then each of the 900 canonical keys is retrieved through `get`. The replay path reconstructs the same canonical fields from Yoda output and independently reapplies the deterministic classification.

The replay comparison does not read classification results from the original oracle.

## Required gates

A run passes only when all of the following hold:

```text
PUBLIC_SOURCE_AUTHORITY=PASS
NASA_REFERENCE_COUNTS=PASS
CORE015_AUTHORITY=PASS
DATABASE_VERIFY=PASS
OBSERVATIONS_INGESTED=900
OBSERVATIONS_REPLAYED=900
FACT_EQUIVALENCE=PASS
DECISION_EQUIVALENCE=PASS
DURABLE_HISTORY=PASS
EVIDENCE_INTEGRITY=PASS
```

## Exact equivalence

`FACT_EQUIVALENCE=PASS` requires the canonical fact manifest reconstructed through Yoda to compare exactly with the canonical fact manifest derived directly from the NASA CSV.

`DECISION_EQUIVALENCE=PASS` requires the deterministic classification manifest reconstructed through Yoda to compare exactly with the raw-source classification manifest.

This is intentionally stricter than comparing only aggregate counts.

## Out of scope

FIRMS-001 does **not** test or claim:

- fire detection by Yoda;
- fire prediction;
- hazard severity assessment;
- geospatial ranking quality;
- database performance superiority;
- scalability beyond this workload;
- NRT/RT/URT-to-standard supersession;
- comparison against another database;
- LLM or agent reasoning quality.

## Earned next question

The next experiment should introduce temporal evolution without changing the fundamental kernel question:

> Given observations that are later replaced or superseded, can Yoda preserve prior state, represent the explicit supersession relation, recover the current state, and replay what was authoritative at an earlier point in time?

That is a separate experiment and is not implied by the FIRMS-001 PASS.
