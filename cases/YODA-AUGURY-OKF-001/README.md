# Yoda Industrial AI Evidence Guard

**Independent, local-first evidence verification and decision-boundary enforcement for industrial AI agents.**

This repository is a small **C11 + Bash** consumer of Augury's public [OKF Industrial Profile](https://github.com/augurysys/okf-industrial). It demonstrates evidence lookup, claim-review states, a deterministic authority gate, optional local LLM quotation extraction, and checksum-verifiable reports.

**Independent project; not affiliated with, endorsed or certified by Augury or Google.** The Northfield Plant showcase and sensor-age values are **fictional/simulated**. No real IoT data, industrial control, fault prediction, or model training is performed. No safety certification is claimed.

## What it does

1. `LEGO 001` (C11) inventories OKF Markdown files, inspects an asset and checks local references.
2. `LEGO 002` (C11) verifies textual citations and review states (`confirmed`, `pending`, `rejected`) in the pinned showcase.
3. `LEGO 003` (C11) applies deterministic evidence/authority constraints; never authorizes industrial control.
4. `LEGO 004 R1` (Bash + jq + local Ollama) extracts textual excerpts, validates against the target claim, and delegates authority to the C11 gate.
5. `LEGO 005` (Bash + jq + sha256sum) produces JSON/Markdown evidence reports with SHA-256 integrity manifests.

These tools are **scoped to the pinned showcase**, not full YAML or OKF validators. There is no KyberDB, KyberProof, or Kyber Learn integration in this release.

## Requirements

Linux, GCC (C11), Make, Bash, Git, awk/sed/grep, jq, curl, `sha256sum`. Ollama + `qwen2.5:3b` are **optional**, needed only for live local inference. No Python, cloud services, or new database is required.

## Reproduce

```sh
bash scripts/setup-upstream.sh  # fetch exact Augury commit; generate and verify upstream manifest
bash scripts/test-all.sh        # compile 3 C11 binaries, execute all offline tests
bash scripts/demo-local.sh qwen2.5:3b  # requires running local Ollama and the model installed
```

To generate a report (requires Ollama):

```sh
./lego005/bin/yoda-evidence-report "$PWD" stale-confirmed \
  --model qwen2.5:3b --out "$PWD/evidence/stale-demo"
./lego005/bin/yoda-verify-report "$PWD/evidence/stale-demo"
cat evidence/stale-demo/report.md
```

`--out` must identify a **new** directory. Reports are protected by checksums, **not digitally signed** or authenticated by KyberProof. `report.md` quotes canonical OKF source text; the exact text returned by the LLM is not preserved by LEGO 004 R1.

## Demonstrated results (developer's Debian, 2026-11-05)

- `LEGO_001`, `LEGO_002`, `LEGO_003`, `LEGO_004_R1_OFFLINE`, and `LEGO_005`: PASS.
- Four live LLM scenarios (`fresh-confirmed`, `stale-confirmed`, `pending-observation`, `rejected-observation`): 4/4 PASS with local `qwen2.5:3b`.
- Four SHA-256 report verifications: 4/4 PASS.
- End-to-end times for `stale-confirmed`, local Qwen 3B: **18.24 s** initial; **4.11 s**, **4.43 s** subsequent. Three measured executions only; no comparison against third-party systems.
- The benchmark process reported approximately 32–34 MB maximum RSS; **this excludes the separately running Ollama server/model**.

Read [docs/TECHNICAL-NOTE.md](docs/TECHNICAL-NOTE.md) for scope and proposed collaboration.

## Licensing and attribution

Project code: Apache-2.0. The **external** OKF Industrial Profile source is fetched at commit `72bbcc40aa729d4b929314c2e20c0961ad04843c`; see its own Apache-2.0 `LICENSE`, `NOTICE`, and disclaimer. We do not vendor the original sample to this repository.

## Security and scope

No telemetry endpoints are contacted. No process controls, recommendations for physical actuation, or automatic intervention. Checksummed files are not proof of external origin or correctness. Model excerpts are not proof of physical truth. Nothing here is a production safety system.
