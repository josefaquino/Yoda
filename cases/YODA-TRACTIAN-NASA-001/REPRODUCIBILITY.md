# Reproducibility and provenance

## Source

NASA IMS Bearings:
https://phm-datasets.s3.amazonaws.com/NASA/4.+Bearings.zip

Source ZIP SHA-256:
21001ac266c465f5d345ec42d7b508c6a6328487fd9d4d7774422dd5ea10ad83

The package does not redistribute raw NASA measurements.

## Experimental scope

- IMS-2: 984 captures, 4 channels
- IMS-3: 6324 captures, 4 channels
- 20480 vibration samples per channel per capture
- Chronological order enforced
- Reference: first 100 captures per channel
- RMS rise: 3.0x
- Persistence: 3 captures
- Common-mode low energy: <=0.10x on all channels

## Historical execution stages

- 005: C11 signal extraction
- 007: C11 chronological replay
- 008: sensitivity analysis
- 009: channel contrast
- 010: third experiment extraction
- 011: frozen-rule cross-test
- 012: consolidated technical report

The scripts are stage-specific, use the
Yoda-Workspace directory layout and may refuse
to overwrite existing evidence or source files.

The original NASA archive must be downloaded
and extracted independently. Historical input
manifests can contain absolute local paths.

This release preserves the experimental sources
and reported results. **CLEAN CLONE 016 passed** on
2026-11-06: published C11 code at commit
`e16ad1131427d08b9e29f9b9b03826e6b7c720bd`
was recompiled and run with existing local NASA
recordings; all three published TSV result files
matched byte for byte.

See [CLEAN CLONE 016 audit](audits/CLEAN-CLONE-016.md)
and [verification script](scripts/yoda-nasa-clean-check-016.sh).
This is not a clean-machine-from-scratch reproduction.

## Interpretation

Observed alerts are not validated predictions
of mechanical failure or remaining useful life.

Additional channel 4 alerts occurred in IMS-3
and must not be discarded.

SHA-256 provides integrity checks, not a
cryptographic signature or independent
attestation of experimental execution.

## License

Yoda-authored code is distributed under the
Apache-2.0 license of the parent Yoda repository,
subject to applicable third-party rights.

This project is independent of Tractian and NASA.
