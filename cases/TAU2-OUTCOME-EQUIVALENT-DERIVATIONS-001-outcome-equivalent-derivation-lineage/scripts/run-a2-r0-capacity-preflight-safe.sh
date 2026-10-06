#!/usr/bin/env bash
set -u
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"

SCRIPT="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a2-r0-capacity-preflight.sh"
CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a2-r0-capacity-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
A2_LOCK="$ROOT/.stage-a2-r1-execution-started"
A2_STAGE="$ROOT/stage-a2-r1"
PREFLIGHT="$ROOT/a2-r0-capacity-preflight"

EXPECTED_SCRIPT_SHA256="1dc4306ec00e25f4759aedd25ca9ceadede3d56e52db694ec0cf44036dd4535e"
SCRIPT_COMMIT="7f2999da05de06ba607821c26ad43660e09bc146"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/scripts/05-a2-r0-capacity-preflight.sh"

echo "============================================================"
echo " TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
echo " A2-R0 YODA CAPACITY PREFLIGHT"
echo " READ ONLY WITH RESPECT TO YODA"
echo "============================================================"

if test -e "$A2_LOCK"
then
    echo "A2_EXECUTION_LOCK=EXISTS"
    echo "PREFLIGHT=ABORTED"
    exit 20
fi

if test -e "$A2_STAGE"
then
    echo "A2_STAGE=EXISTS"
    echo "PREFLIGHT=ABORTED"
    exit 21
fi

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 22
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 23
fi

echo "BASH_PARSE=PASS"

ACTUAL="$(
    sha256sum "$SCRIPT" |
    awk '{print $1}'
)"

echo "EXPECTED_SCRIPT_SHA256=$EXPECTED_SCRIPT_SHA256"
echo "ACTUAL_SCRIPT_SHA256=$ACTUAL"

if test "$ACTUAL" != "$EXPECTED_SCRIPT_SHA256"
then
    echo "SCRIPT_IDENTITY=FAIL"
    exit 24
fi

echo "SCRIPT_IDENTITY=PASS"
echo "A2_EXECUTION_LOCK=ABSENT"
echo "A2_STAGE=ABSENT"

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A2-R0 PREFLIGHT POST-RUN"
echo "============================================================"

echo "A2_R0_PREFLIGHT_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -e "$A2_LOCK"
then
    echo "A2_EXECUTION_LOCK=UNEXPECTEDLY_CONSUMED"
    exit 25
fi

echo "A2_EXECUTION_LOCK=ABSENT"

if test -e "$A2_STAGE"
then
    echo "A2_STAGE=UNEXPECTEDLY_CREATED"
    exit 26
fi

echo "A2_STAGE=ABSENT"

if test -f "$PREFLIGHT/candidate/SHA256SUMS"
then
    echo "A2_CANDIDATE_MANIFEST=FOUND"
    sha256sum "$PREFLIGHT/candidate/SHA256SUMS"
fi

if test -f "$PREFLIGHT/evidence/PRECHECK-SHA256SUMS"
then
    echo "A2_R0_EVIDENCE_MANIFEST=FOUND"
    sha256sum "$PREFLIGHT/evidence/PRECHECK-SHA256SUMS"
fi

if test -f "$PREFLIGHT/evidence/summary.tsv"
then
    echo
    echo "=== A2-R0 SUMMARY ==="
    cat "$PREFLIGHT/evidence/summary.tsv"
fi

if test "$RUN_RC" -eq 0
then
    echo "A2_R0_PREFLIGHT_WRAPPER=PASS"
else
    echo "A2_R0_PREFLIGHT_WRAPPER=NOT_READY_OR_NOT_EVALUATED"
fi

echo "YODA_STORE_CREATED=NO"
echo "YODA_WRITES=ZERO"

echo
echo "SAFE_PREFLIGHT_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
