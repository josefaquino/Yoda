# Dataset contract — market prices + SEC EDGAR point-in-time fundamentals

## Purpose

Reconstruct what a market participant could have known at each market date and
compare a price-only model with an otherwise identical model with financial features.
Both comparisons must use walk-forward historical validation, never a random split.

## Data authorities

- Market prices: Nasdaq public website historical JSON endpoint (subject to terms of use and availability) for NVDA, QQQ, SOXX;
  a fixed policy for split adjustments, dividend treatment and the trading calendar.
  Stooq and Yahoo direct endpoints were unavailable from the test host (HTML
  JavaScript challenge and HTTP 429). Nasdaq raw responses and splits still need
  verification on the user's Debian host. Treat this as a public web endpoint,
  not a contractual exchange-grade data feed.
- SEC concept: `https://data.sec.gov/api/xbrl/companyconcept/CIK0001045810/us-gaap/RevenueFromContractWithCustomerExcludingAssessedTax.json`.
- SEC submission history: `https://data.sec.gov/submissions/CIK0001045810.json`.
- An initial earnings news release may make a figure public before the 10-Q/10-K;
  when available, capture its public timestamp and authority separately.

## Canonical relation

Preserve the raw JSON bytes, SHA-256 digest, collection time, source URL and
the collection policy before any transformation.

market_prices.tsv:
date, ticker, close, split_adjusted_close, volume, source_id, raw_sha256

fundamentals_observations.tsv:
cik, concept, unit, fiscal_start, fiscal_end, fiscal_period, form,
accession, filed_date, acceptance_timestamp, first_public_timestamp,
first_public_source_id, reported_value, observation_sha256

daily_point_in_time.tsv:
trade_date, nvda_close, qqq_close, soxx_close,
latest_known_revenue_fiscal_end, latest_known_revenue,
latest_known_revenue_public_at, latest_known_revenue_accession,
nvda_close_source_id, revenue_source_id

Each `trade_date` must be associated with the latest data known strictly before
the corresponding forecast origin cutoff. Apply US market hours and Eastern
time-zone conversion. After-hours disclosures become available for the next
trading-session open by default; a daily close-to-close model may include
a same-day pre-close disclosure, but it must explicitly fix its information
cutoff at that close. Keep provenance for both versions.

SEC `companyconcept` supplies the `filed` date and `accn`, but does not
itself supply an authoritative real-time intraday acceptance timestamp per
observation. Use the matching SEC submissions accession to obtain
`acceptanceDateTime`; preserve the separate news-release publication time
when it preceded the formal filing. Do not assume fiscal period end equals
publication. A filing in 2027 must never rewrite what was known in 2026.

Select genuine 3-month revenue observations with `start` and `end`,
suitable duration and filing context. Do not mix annual, YTD, quarterly
values, or retrospectively restated prior periods without labeling them.
Do not silently deduplicate distinct accessions even if numeric values match.

## Statistical model contract

Model A: price-only, fixed information set and fixed forecast horizon.
Model B: identical walk-forward test origins and output horizon, plus a
revenue feature available at the origin (e.g. last-known YoY revenue growth).

A `revenue surprise` is actual revenue less an analyst consensus forecast
**recorded before** the public announcement; SEC values alone cannot
reconstruct a genuine consensus surprise. Without pre-announcement forecast
snapshots, name the feature `revenue_growth` or `revenue_growth_delta`,
never `revenue_surprise`.

Evaluate point errors, probabilistic coverage/calibration and comparison
against a naive persistence model. Document thin event counts, changing
regimes and the uncertainty of extrapolating to February 2027. No financial
forecasting ability or trading alpha is established by successful ingestion.

## Admission gates

- PRICE_SOURCE_AUTHORIZED=PASS
- RAW_PRICES_FROZEN=PASS
- SEC_RAW_COMPANYCONCEPT=PASS
- SEC_RAW_SUBMISSIONS=PASS
- SEC_ACCESSION_ALIGNMENT=PASS
- FIRST_PUBLIC_AT_VALIDATED=PASS
- NO_FUTURE_INFORMATION=PASS
- QUARTERLY_REVENUE_DEFINITION=PASS
- FEATURE_AVAILABILITY=PASS
- WALK_FORWARD_BASELINE=PASS
- YODA_KYBER_CHANGE=NO

The previous EDGAR case is a frozen product precedent. These standalone
source files do **not** establish Yoda ingest until integration is run and
audited against the previously validated interface.
