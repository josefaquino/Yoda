# Yoda Industrial Bearing Evidence Replay

Independent, experimental industrial signal analysis
using the public NASA IMS Bearings dataset.

## What was demonstrated

- C11 processing of historical vibration measurements.
- Chronological, deterministic observation replay.
- RMS, peak and crest-factor extraction.
- SHA-256 source evidence.
- Frozen-rule comparison across two IMS experiments.
- Detection of persistent RMS rises and common-mode
  low-energy observations.

## Results

| Dataset | Captures | First relevant alert |
|---|---:|---|
| IMS-2 | 984 | Channel 1, index 966 |
| IMS-3 | 6324 | Channel 3, index 6256 |

Two additional rise events occurred in channel 4
of IMS-3. Their physical significance is unresolved.

## Experimental rule

- Baseline: first 100 captures per channel.
- RMS rise threshold: 3.0 times baseline.
- Persistence: 3 consecutive captures.
- Common-mode low energy: all four channels at
  10% or less of their initial baselines.

The rule was explored on IMS-2 and then evaluated
without parameter changes on IMS-3.

## Source data

NASA IMS Bearings:
https://data.nasa.gov/dataset/ims-bearings

Official archive used:
https://phm-datasets.s3.amazonaws.com/NASA/4.+Bearings.zip

SHA-256 of downloaded ZIP:
21001ac266c465f5d345ec42d7b508c6a6328487fd9d4d7774422dd5ea10ad83

The raw NASA recordings are not redistributed.
Reproduction requires downloading and extracting
the source dataset separately.

Scripts contain paths relative to Yoda-Workspace
and are intended for execution in that workspace.

## Limitations

This is retrospective experimental evidence, not a
validated fault-prediction or remaining-useful-life
model. No production safety certification is claimed.

No live telemetry, industrial control, or access to
Tractian infrastructure is involved.

This independent project is not affiliated with,
sponsored by, or endorsed by NASA or Tractian.

See results/REPORT.md for detailed findings.

## Clean-checkout reproduction audit (016)

**PASS:** Published C11 code, pinned to the original
publication commit `e16ad1131427d08b9e29f9b9b03826e6b7c720bd`,
reproduced all three public TSV result files byte for
byte using the original locally stored NASA recordings.

See [CLEAN CLONE 016 audit](audits/CLEAN-CLONE-016.md)
and [published checker](scripts/yoda-nasa-clean-check-016.sh).
This is not a new-machine-from-scratch reproduction.
