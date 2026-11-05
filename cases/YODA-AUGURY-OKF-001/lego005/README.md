# LEGO 005 — Yoda Industrial Evidence Report

Additive module for `YODA-AUGURY-OKF-001`. No modifications to earlier LEGOs or the protected Yoda/Kyber components. Uses Bash, jq, SHA-256 utilities and the **existing** LEGO 004 R1 and C11 Decision Gate.

## Functions

- Produces `report.json`, `report.md`, `guard.log` and `manifest.sha256` in a **new output directory**.
- Pins the Augury snapshot commit to `72bbcc40aa729d4b929314c2e20c0961ad04843c` and delegates source checks to LEGO004-R1.
- Marks the Northfield setting fictional and reading age simulated.
- Distinguishes confirmed source-document quotations from quotes in `learned.md` staging claims.
- Keeps C11 as the only decision authority and records `CONTROL_ACTION=FORBIDDEN`.
- Checks that report files have not changed via SHA-256; **not** a KyberProof signature or identity attestation.

## Commands

```bash
bash "$CASE/lego005/tests/test_report.sh" "$CASE"

"$CASE/lego005/bin/yoda-evidence-report" "$CASE" stale-confirmed \
  --model qwen2.5:3b --out "$CASE/evidence/lego005-live-stale"

"$CASE/lego005/bin/yoda-verify-report" "$CASE/evidence/lego005-live-stale"
```

The `--out` directory must not already exist. A guard rejection exits with nonzero and leaves no completed report.

## Limits

- The `guard.log` records the accepted verdict of LEGO004-R1, **not** the exact verbatim excerpt output by the LLM, because R1 does not persist that excerpt.
- The canonical quote displayed in the report is copied from OKF, not presented as the verbatim text emitted by the LLM.
- The `report.json` has source-file and snapshot-manifest SHA-256, but this is neither signed nor independently authenticated.
- No live telemetry, hazard forecasting, industrial control, or customer data.
