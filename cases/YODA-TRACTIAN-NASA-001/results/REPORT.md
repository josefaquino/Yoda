# Yoda Industrial Bearing Evidence Replay

**Independent engineering case — NASA IMS Bearings**

## Objective

Evaluate whether a deterministic chronological replay
can identify and preserve evidence of vibration changes
in independent industrial bearing experiments.

Implementation: C11, Bash and Unix CLI.

## Frozen experimental rule

- Baseline: first 100 captures, independently per channel.
- RMS increase threshold: 3.0 times baseline.
- Persistence: three consecutive captures.
- Common-mode low energy: all four channels at
  10% or less of their respective baselines.
- No future observations used in replay decisions.

## Results

| Trial | Captures | Documented faulty bearing | First relevant alert |
|---|---:|---|---|
| IMS-2 | 984 | Bearing 1, outer race | CH1, index 966 |
| IMS-3 | 6,324 | Bearing 3, outer race | CH3, index 6256 |

### IMS-2

CH1: 2004-02-19 03:22:39.

One persistent RMS-rise episode.

No persistent RMS-rise episode in CH2, CH3 or CH4.

Two common-mode low-energy captures at the end.

### IMS-3

CH3: 2004-04-17 15:22:55.

One persistent RMS-rise episode in CH3.

CH4 also presented two persistent RMS-rise episodes,
at indices 6304 and 6309.

CH1 and CH2 had no persistent alerts.

One common-mode low-energy capture at the end.

## Interpretation

The frozen rule produced alerts in the channels
associated with the documented end-of-test faults
in both experiments.

This is a retrospective observation, not a
validated prospective fault-prediction capability.

The significance of the additional CH4 alerts
in IMS-3 remains unresolved.

Low-energy events are not interpreted as mechanical
recovery, shutdown or sensor failure.

## Limitations

- Only two independent historical experiments.
- The rule was explored on IMS-2 before application
  to IMS-3.
- No externally validated fault-onset timestamps.
- No validated sensitivity, specificity or RUL.
- No industrial control or live telemetry.
- No commercial benchmarking.
- SHA-256 checksums, not digital signatures.
- No affiliation with NASA or Tractian.

The distributed third experiment contains 6,324
captures under the directory 3rd_test/4th_test/txt.
Historical descriptions of this experiment may
refer to a shorter recording.

## Source

NASA IMS Bearings:

https://data.nasa.gov/dataset/ims-bearings

The raw dataset is not redistributed in this report.

See channel-comparison.tsv, alerts.tsv, counts.tsv
and artifacts.sha256 for the supporting results.
