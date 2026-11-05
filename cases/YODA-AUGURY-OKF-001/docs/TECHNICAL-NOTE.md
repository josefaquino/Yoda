# Technical note — independent OKF evidence guard

## Problem

Industrial AI agents may cite real text from a document while ignoring claim lifecycle or sensor freshness restrictions. A valid quote alone does not make a claim actionable.

## Approach

- Read Augury's public **fictional** Northfield Plant OKF bundle at a pinned commit.
- Validate local references and verify that targeted quotes correspond to the target claim.
- Distinguish confirmed knowledge, pending hypotheses, and rejected claims.
- Apply deterministic authority decisions from C11, separate from the local LLM output.
- Generate machine-readable and human-readable reports with SHA-256 manifests.

## Scenario matrix

| Scenario | Expected host decision | Control action |
| --- | --- | --- |
| Fresh + confirmed | CONTEXT_ELIGIBLE_FOR_HUMAN_REVIEW | FORBIDDEN |
| Stale + confirmed | ADVISORY_ONLY | FORBIDDEN |
| Pending | HYPOTHESIS_ONLY | FORBIDDEN |
| Rejected | IGNORE_CLAIM | FORBIDDEN |

Reading age is **simulated**; the example's 30-minute trust policy is sourced to the OKF bundle. No sensor liveness call is made.

## Measured performance

Observed on one 4-CPU, 11-GiB-RAM Debian-family desktop using local Ollama `qwen2.5:3b`. One initial run: 18.24 s; two subsequent runs: 4.11 s and 4.43 s (mean 4.27 s). Each finished with `AI_GUARD=PASS`. Timings measure end-to-end execution including model invocation. `/usr/bin/time` RSS observations relate to the measured wrapper process, **not** the full Ollama server memory.

This is a product-engineering demonstrator, not a scientific comparison or production benchmark.

## Proposed partnership discussion

We would welcome technical feedback from the OKF maintainers on interoperability and the independent decision-boundary layer. A future authorized, read-only pilot could assess broader knowledge bundles, real review workflows and integration contracts. We do not claim any present integration with Augury's private systems.

## Known limitations

The reader is intentionally scoped to known YAML frontmatter shapes in the provided sample. Citation matching checks text presence, not semantic or mechanical correctness. Human review information is not independently authenticated. Reports have integrity checksums but no signing/key management. No KyberDB/KyberProof/Kyber Learn integration, live telemetry, industrial diagnosis, hardware control, or safety certification.
