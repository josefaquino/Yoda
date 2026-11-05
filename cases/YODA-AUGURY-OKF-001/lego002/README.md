# YODA-AUGURY-OKF-001 — LEGO 002: OKF Trust

Incremental, independent C11 CLI that reads the Augury OKF Industrial Profile example and verifies a **limited trust contract**: standalone Heuristic claim fields, source ID mapping to bundle-local Reference files, exact literal quote presence, recorded human review metadata, and the pending/rejected statuses in learned.md. It does not parse all YAML, certify the OKF standard, validate industrial diagnoses, authenticate a person's identity, or check live sensors.

It makes **no changes to LEGO 001 or existing Yoda/Kyber components**.

```sh
make -C lego002
./lego002/bin/yoda-okf-trust upstream/okf-industrial/bundles/northfield-plant
bash lego002/tests/test_trust.sh "$PWD"
```

All references in the upstream Northfield example are fictional. Verified quotes demonstrate textual agreement with local references, not independent factual correctness.
