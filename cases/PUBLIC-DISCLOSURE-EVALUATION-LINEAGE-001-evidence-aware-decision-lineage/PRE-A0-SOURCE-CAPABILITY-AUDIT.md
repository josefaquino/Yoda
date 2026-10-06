# PRE-A0 — SEC Source Capability Audit

## Status

```text
CASE=PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001
STAGE=PRE-A0
STATUS=PASS
EXECUTED=YES
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


## Frozen harness identities

```text
PRE_A0_R1_SCRIPT_SHA256=
ed430dcb7d71c73b0147eaa5d5e89e3424f6b5ec70486c1c6de55ddc04a2b33e

PRE_A0_R1_SCRIPT_COMMIT=
45fbd7b33d17ba7606b08b288435bc9997e88fa5

SAFE_LAUNCHER_SHA256=
57aea17a390d2c6f969091fd9ee67b9a5682f17cf8fb778fbff57cd077f493a5

SAFE_LAUNCHER_COMMIT=
2d2ca27368adc3cfa268fe98a0bcab09e9077e1d
```

The launcher executes the PRE-A0 harness in a child shell.

No scientific one-execution lock exists in PRE-A0.


## Observed PRE-A0 result

```text
PUBLIC_DISCLOSURE_EVALUATION_LINEAGE_001_PRE_A0=PASS
PRE_A0_REVISION=PRE-A0-R1
PRE_A0_R1_RUN_RC=0

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
A0_GATE_CONSUMED=NO

PRE_A0_R1_CONSOLE_SHA256=
0298fcbbbb776fa14cf29b296dfd963d4c837f77008b2281aa32ef09f2f1d53e

NEXT_GATE=A0_DESIGN_AND_SELECTION_POLICY
```
