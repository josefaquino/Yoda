# PRE-A0 — SEC Source Capability Audit

## Status

```text
CASE=PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001
STAGE=PRE-A0
STATUS=PRE-REGISTERED
EXECUTED=NO
```

This is a source-capability audit only.

It does **not** select the issuer, filing pair, XBRL concept, reporting period, evaluation contract or classification labels for the scientific CASE.

## Safety boundary

```text
FRAUD_CLASSIFICATION=NO
MARKET_MANIPULATION_CLASSIFICATION=NO
INVESTMENT_RECOMMENDATION=NO
SECURITY_MERIT_EVALUATION=NO
PRICE_PREDICTION=NO
```

The intended experiment is provenance, auditability and reproducibility infrastructure.

## Public source authorities

PRE-A0 checks access to:

```text
SUBMISSIONS_AUTHORITY=https://data.sec.gov/submissions/
COMPANYFACTS_AUTHORITY=https://data.sec.gov/api/xbrl/companyfacts/
FILING_ARCHIVE_AUTHORITY=https://www.sec.gov/Archives/edgar/data/
```

No API key or authentication token is used.

## SEC access policy

The operator must supply an identifiable SEC request User-Agent.

Example shape:

```text
YodaResearch contact@example.com
```

The User-Agent is used only in HTTP request headers.

The audit intentionally runs far below the SEC maximum automated request rate:

```text
HARNESS_REQUEST_SPACING_SECONDS=0.40
THEORETICAL_MAX_REQUESTS_PER_SECOND=2.5
SEC_PUBLIC_MAX_REQUESTS_PER_SECOND=10
```

## Probe-only issuer

PRE-A0 needs one known public filing pair to verify that submissions history and filing archives expose enough structure to recognize an original filing and a later amendment.

The probe is:

```text
PROBE_ONLY=YES
PROBE_CIK=0001652044
PROBE_ORIGINAL_ACCESSION=0001652044-19-000004
PROBE_ORIGINAL_FORM=10-K
PROBE_AMENDMENT_ACCESSION=0001193125-19-028757
PROBE_AMENDMENT_FORM=10-K/A
PROBE_REPORT_PERIOD=2018-12-31
```

This probe is **not** the issuer selection for the CASE.

```text
CASE_ISSUER_SELECTED=NO
CASE_CIK_FROZEN=NO
CASE_ACCESSION_PAIR_FROZEN=NO
CASE_XBRL_CONCEPT_SELECTED=NO
```

A later stage must use an objective selection policy frozen before evaluation.

## PRE-A0 objectives

Required capability checks:

```text
SEC_API_CONNECTIVITY=PASS
USER_AGENT_POLICY=PASS

SUBMISSIONS_ENDPOINT=PASS
SUBMISSIONS_HISTORY_ENDPOINT=PASS
COMPANYFACTS_ENDPOINT=PASS
FILING_ARCHIVE_ACCESS=PASS

ORIGINAL_AMENDMENT_PAIR_DISCOVERABILITY=PASS

ARTIFACT_SIZE_ESTIMATE=PASS

CASE_ISSUER_SELECTED=NO
CASE_XBRL_CONCEPT_SELECTED=NO

CLASSIFICATION_EXECUTED=NO
YODA_WRITES=ZERO
```

## Artifact policy

All HTTP bodies are stored only in a temporary directory and deleted on exit.

They are not frozen as scientific CASE evidence.

```text
PRE_A0_RESPONSES_FROZEN_AS_CASE_EVIDENCE=NO
RAW_PUBLIC_DATA_FROZEN=NO
A0_GATE_CONSUMED=NO
```

PRE-A0 may emit response byte counts and SHA-256 identities for diagnostic purposes only.

## PASS

Only a complete PRE-A0 PASS authorizes design/freeze of A0.

```text
PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_PRE_A0=PASS
NEXT_GATE=A0_DESIGN_AND_SELECTION_POLICY
```

PRE-A0 PASS does not itself authorize historical evaluation or Yoda writes.
