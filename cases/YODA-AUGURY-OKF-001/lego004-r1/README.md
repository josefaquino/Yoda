# Yoda Augury OKF — LEGO 004 R1

Independent **evidence-only** adapter for local Ollama. It does **not** modify LEGO 001/002/003/004, Yoda Core, KyberDB or KyberProof.

## Correction

The original LEGO004 asked a 3B LLM to echo an exact claim id, scenario id and host authority decision; the live matrix showed 3/4 mismatches. The R1 removes these free-text outputs from the model contract. A pre-existing C11 `yoda-okf-gate` still computes authority; the LLM returns only a verbatim excerpt from the **specific source quote** associated with the case. The host verifies the excerpt belongs to that claim and to its cited document. A failed check returns nonzero, with no control action authorized.

This is a grounded quote extraction test, not physical truth verification, authentication of reviewers, diagnosis, or live telemetry validation.

## Run

`bash lego004-r1/tests/test_evidence.sh "$CASE"`

`lego004-r1/bin/yoda-ai-evidence "$CASE" stale-confirmed --model qwen2.5:3b`

`lego004-r1/bin/yoda-ai-evidence "$CASE" pending-observation --model qwen2.5:3b`

Only the fictional Northfield public OKF bundle is used. The model receives a scoped canonical quote, not source documents containing unrelated claims.
