# CLEAN CLONE 016 - Reproduction audit

**Status:** `CLEAN_CLONE_016=PASS` (reported by the operator from their Debian terminal on 2026-11-06).

**Code under test:** [original published commit `e16ad1131427d08b9e29f9b9b03826e6b7c720bd`](https://github.com/josefaquino/Yoda/commit/e16ad1131427d08b9e29f9b9b03826e6b7c720bd). The verification script **pins this commit** rather than using a moving main branch.

**Verification script:** [`scripts/yoda-nasa-clean-check-016.sh`](../scripts/yoda-nasa-clean-check-016.sh); SHA-256 `7fe9f26a8ff8a70e5deeacface83e886b6b2c94dfb3c8c3b89d1af93561c67fc`.

## Scope and results

The script cloned the public Yoda repository, checked out the exact original publication commit, verified public SHA-256 manifests, compiled three **published C11 source files** and reprocessed the existing local NASA IMS vibration recordings without changing the experimental rules.

| Check | Operator-reported result |
|---|---|
| Public pinned commit, manifests | PASS |
| NASA source ZIP SHA-256 | PASS |
| IMS-2 inventory | 984 captures, 4 channels |
| IMS-3 inventory | 6,324 captures, 4 channels |
| C11 compiled from GitHub sources | 3/3 PASS |
| IMS-2 feature rows | 3,936 |
| IMS-3 feature rows | 25,296 |
| C11 causal replay of IMS-2 | PASS: one rise transition, two common-mode low-energy captures |
| Frozen rule on IMS-2 | PASS: 1 rise event, 2 common-mode low-energy captures |
| Frozen rule on IMS-3 | PASS: 3 rise events, 1 common-mode low-energy capture |
| `alerts.tsv` versus original published results | **Byte-for-byte PASS** |
| `channel-comparison.tsv` versus original published results | **Byte-for-byte PASS** |
| `counts.tsv` versus original published results | **Byte-for-byte PASS** |
| C11 versus published IMS-2 event identity | PASS |
| Source recordings rehashed after processing | PASS |

Total: **7,308 captures** across two historical trials. Fixed rule: RMS baseline from the first 100 captures of each channel, rise at 3.0x for 3 consecutive captures, common-mode low energy at or below 0.10x on all four channels.

## Decisive terminal transcript

Excerpt from the successful operator-provided terminal output:

```text
PUBLIC_COMMIT=PASS SHA=e16ad1131427d08b9e29f9b9b03826e6b7c720bd
PUBLIC_MANIFESTS=PASS
RAW_INVENTORY=PASS TRIAL=IMS2 CAPTURES=984
RAW_INVENTORY=PASS TRIAL=IMS3 CAPTURES=6324
PUBLISHED_C11_BUILD=PASS BINARIES=3
IMS_READER=PASS FILES=984 CHANNEL_ROWS=3936 SAMPLES_PER_FILE=20480 ORDER=STRICT_CHRONOLOGICAL
IMS_READER=PASS FILES=6324 CHANNEL_ROWS=25296 SAMPLES_PER_FILE=20480 ORDER=STRICT_CHRONOLOGICAL
CAUSAL_REPLAY=PASS SNAPSHOTS=984 BASELINE=100 RISE_RATIO=3.0 PERSISTENCE=3 LOW_RATIO=0.10
RISE_TRANSITIONS=1 LOW_ENERGY_SNAPSHOTS=2
FROZEN_RULE=PASS trial=IMS2 CAPTURES=984 RISE_EVENTS=1 LOW_COMMON=2
FROZEN_RULE=PASS trial=IMS3 CAPTURES=6324 RISE_EVENTS=3 LOW_COMMON=1
BYTE_COMPARISON=PASS FILE=alerts.tsv
BYTE_COMPARISON=PASS FILE=channel-comparison.tsv
BYTE_COMPARISON=PASS FILE=counts.tsv
C11_VS_PUBLIC_EVENT=PASS TRIAL=IMS2
NASA_SIGNALS_UNCHANGED=PASS
CLEAN_CLONE_016=PASS
PUBLISHED_COMMIT=VERIFIED
SOURCE=GITHUB_PINNED_C11
NASA_DATA=EXISTING_LOCAL_READ_ONLY
PUBLIC_RESULTS_EXACTLY_REPRODUCED=YES
CLEAN_MACHINE_FROM_SCRATCH=NOT_TESTED
CASE_SOURCE_UNCHANGED=YES
```

## How to rerun

The original NASA archive and extracted `2nd_test` and `3rd_test/4th_test/txt` data must already exist below `~/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001/datasets/`. Run from this case checkout:

```bash
bash scripts/yoda-nasa-clean-check-016.sh
```

Requires `git`, `cc`, `sha256sum`, `find`, `sort`, `xargs`, `awk`, `wc`, `cmp`, and `tr`. The script refuses an existing output directory `~/Yoda-Workspace/releases/YODA-NASA-CLEAN-CHECK-016`: use a fresh isolated workspace if rerunning. It checks out the original commit deliberately, even when the repository main branch advances.

## Provenance and limitations

- The audit result and terminal transcript were **supplied by the operator**. The local audit directory (`~/Yoda-Workspace/releases/YODA-NASA-CLEAN-CHECK-016/evidence`) and raw NASA files are **not included** in the repository. The exact checker script is included and its SHA-256 is recorded.
- This is **clean-checkout reproduction with existing locally acquired NASA recordings**, **not** a fully clean-machine reproduction from a newly provisioned environment and independent download.
- SHA-256 does not constitute an independent digital attestation of runtime behavior.
- Retrospective replay does not validate prospective failure prediction, remaining useful life, industrial safety or physical actuation. Two additional CH4 rise events in IMS-3 remain unexplained.
- This independent project is not sponsored by or affiliated with NASA or Tractian.

The original report and experiment parameters remain unchanged.
