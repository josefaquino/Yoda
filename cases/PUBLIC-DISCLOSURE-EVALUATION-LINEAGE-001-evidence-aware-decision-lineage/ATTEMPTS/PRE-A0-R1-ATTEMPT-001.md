# PRE-A0-R1 — Attempt 001

## Observed result

```text
PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001_PRE_A0=NOT_EVALUATED
PRE_A0_REVISION=PRE-A0-R1
FAILURE_CLASS=SEC_USER_AGENT_FORMAT

CASE_ISSUER_SELECTED=NO
CASE_XBRL_CONCEPT_SELECTED=NO
CLASSIFICATION_EXECUTED=NO
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
A0_GATE_CONSUMED=NO
```

## Preflight authority

```text
LAUNCHER_IDENTITY=PASS
BASH_PARSE=PASS
SCRIPT_IDENTITY=PASS

PRE_A0_R1_SCRIPT_SHA256=
ed430dcb7d71c73b0147eaa5d5e89e3424f6b5ec70486c1c6de55ddc04a2b33e

PRE_A0_R1_CONSOLE_SHA256=
12ba2ba5d31e9a1637a9dc15a3cc666bf68e7ce41c3566fcad76ab37a8350e7b

PRE_A0_R1_RUN_RC=1
```

## Adjudication

The operator supplied a contact email without the descriptive tool/project token required by the preregistered local User-Agent format check.

The HTTP capability audit did not begin.

```text
SEC_NETWORK_REQUESTS_BY_HARNESS=ZERO
SEC_SOURCE_CAPABILITY=NOT_EVALUATED
HARNESS_DEFECT=NO
A0_GATE_CONSUMED=NO
YODA_WRITES=ZERO
```

PRE-A0 has no one-execution lock. A fresh PRE-A0 run is permitted after setting an identifiable User-Agent matching the frozen format, for example:

```text
YodaResearch contact@example.com
```

The real contact value must remain local and is not recorded in this repository.
