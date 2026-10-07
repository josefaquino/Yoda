# A2 Stability — Pre-lock Identity Correction

## Classification

STATUS=NOT_EVALUATED

The first safe-launch attempt stopped before the scientific execution gate because the launcher expected the wrong SHA256 for the A2 harness.

A2_EXECUTION_GATE_REACHED=NO
A2_EXECUTION_LOCK_CONSUMED=NO
SCIENTIFIC_EXECUTION=NO
MEASURED_SCENARIOS=0

## Cause

The harness contained a non-ASCII/mis-decoded dash in the warmup section title. The pre-publication hash calculation did not represent the exact raw GitHub bytes.

No scientific logic had executed.

## Correction

The harness was normalized to ASCII only.

SUPERSEDED_HARNESS_COMMIT=1e7a75dca976032f3ef08fb28ffeffe3eb6c885f
SUPERSEDED_EXPECTED_SHA256=f4c18cebf14d556d5a1206cf0aa9295d00c64eb7e58f33caff367753e6d801e1
OBSERVED_RAW_SHA256=fbc38cca6d3b0c1e6b320809352b1b7ba42ad812e54dc705ce76ea35fdee84b4

CORRECTED_HARNESS_COMMIT=61828c469706cf3719f6f977e6ec208a91291e11
CORRECTED_HARNESS_SHA256=530e6852e5d8b515f163255fae1327963f39944b1aa7ad663d2791e21467e5a1
CORRECTED_HARNESS_NON_ASCII=0

SCIENTIFIC_DESIGN_CHANGE=NO
ENGINEERING_CHANGE=NO
DATA_CHANGE=NO
AGENT_CHANGE=NO

The registered A2 design remains 32 repetitions per worker count, 128 measured scenarios, balanced order, and a 5 percent engineering-effect threshold.
