#!/usr/bin/env bash
set -u
set -o pipefail

CASE="TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"

SCRIPT="$HOME/cmu/tau2-outcome-equivalent-derivations-001-stage-a0-r1.sh"
CONSOLE="$HOME/cmu/tau2-outcome-equivalent-derivations-001-a0-r1-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-a0-r1-freeze-started"
STAGE="$ROOT/stage-a0-r1"

EXPECTED_SCRIPT_SHA256="4c4cb4314fda7c5e843f516437647f7e144d23fec2b67dd63b1fb1657f52d06a"
SCRIPT_COMMIT="50f26efed0bc255cd057a101a541d2fed080e3ec"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001-outcome-equivalent-derivation-lineage/scripts/02-a0-experimental-freeze.sh"

echo "============================================================"
echo " TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001"
echo " A0-R1 EXPERIMENTAL FREEZE"
echo " NO TRAJECTORY / NO TAU2 RUNTIME / NO YODA"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A0_FREEZE_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    echo "REASON=freeze policy already consumed"
    exit 20
fi

if test -e "$STAGE"
then
    echo "A0_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
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
echo "A0_FREEZE_LOCK=ABSENT"
echo "A0_STAGE=ABSENT"

"$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A0-R1 POST-RUN"
echo "============================================================"

echo "A0_R1_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "A0_FREEZE_LOCK=CONSUMED"
    sha256sum "$LOCK"
    cat "$LOCK"
else
    echo "A0_FREEZE_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo "A0_MANIFEST=FOUND"
    sha256sum "$STAGE/evidence/SHA256SUMS"
else
    echo "A0_MANIFEST=NOT_AVAILABLE"
fi

if test -f "$STAGE/contracts/execution-contract.tsv"
then
    echo
    echo "=== A0 EXECUTION CONTRACT ==="
    cat "$STAGE/contracts/execution-contract.tsv"
fi

if test -f "$STAGE/contracts/outcome-equivalence-contract.tsv"
then
    echo
    echo "=== A0 OUTCOME EQUIVALENCE CONTRACT ==="
    cat "$STAGE/contracts/outcome-equivalence-contract.tsv"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== A0 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
