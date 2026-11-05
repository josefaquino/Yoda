# LEGO 003 — OKF Decision Gate (Northfield Profile)

Independent C11 executable that consumes the **fictitious** Augury Northfield OKF example and a small TSV of explicitly *simulated* sensor-age scenarios. It reads the `trust_window_minutes` from the P-101A asset and `review_status` from standalone heuristics and the two proposed claims in `learned.md`.

It **never recommends or executes control actions**. An assumed fresh sensor reading does not prove runtime liveness. The gate does not perform cryptographic verification, independently authenticate human reviewers, validate diagnostic truth, or contact endpoints. It uses the narrow schema of this case, **not a general YAML parser**. For upstream documentary trust checks, run LEGO 002 first. No code or data from LEGO 001/002 or from the core Yoda/Kyber components is modified.

Run:

```sh
make -C lego003
./lego002/bin/yoda-okf-trust upstream/okf-industrial/bundles/northfield-plant
./lego003/bin/yoda-okf-gate upstream/okf-industrial/bundles/northfield-plant lego003/fixtures/scenarios.tsv
bash lego003/tests/test_gate.sh "$PWD"
```

The TSV has three tab-separated fields: `scenario_id`, `claim` (`cold-start`, `settle`, `pending`, `rejected`), and assumed sensor age in minutes (non-negative integer). These cases are constructed test scenarios, not real observations. The OKF Northfield documents and asset tags are fictional; `opc.tcp://...` endpoints are not accessed.

Licence: original code in this LEGO is offered under MIT for evaluation; the upstream Augury OKF Industrial Profile is separately distributed under its Apache-2.0 licence. Preserve upstream licence and attribution when distributing.
