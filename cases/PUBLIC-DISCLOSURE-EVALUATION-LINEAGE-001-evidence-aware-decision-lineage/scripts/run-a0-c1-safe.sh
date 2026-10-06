#!/usr/bin/env bash
set -u
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"

SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-stage-a0-c1.sh"
CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a0-c1-console.log"

ROOT="$HOME/cmu/$CASE"
A0R1_LOCK="$ROOT/.stage-a0-r1-execution-started"
A0R1_STAGE="$ROOT/stage-a0-r1"
LOCK="$ROOT/.stage-a0-c1-execution-started"
STAGE="$ROOT/stage-a0-c1"

EXPECTED_SCRIPT_SHA256="d9b6655c461bef8ede88c6f1e2ff605204c9405e03ed6828f141feb7d7e43f2e"
SCRIPT_COMMIT="6dcf4d59d3529291846ce13f8b9ac2a63358b3fd"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage/scripts/01-a0-c1-frozen-selection-completion.sh"

echo "============================================================"
echo " A0-C1 SAFE SCIENTIFIC CONTINUATION"
echo " FROZEN SELECTION COMPLETION"
echo " NO RESELECTION / ONE EXECUTION"
echo "============================================================"

if test -z "${SEC_USER_AGENT:-}"
then
    echo "SEC_USER_AGENT_PRESENT=NO"
    echo "EXECUTION=ABORTED"
    exit 20
fi

echo "SEC_USER_AGENT_PRESENT=YES"

if test ! -f "$A0R1_LOCK"
then
    echo "A0_R1_EXECUTION_LOCK=MISSING"
    echo "EXECUTION=ABORTED"
    exit 21
fi

if test ! -d "$A0R1_STAGE"
then
    echo "A0_R1_STAGE=MISSING"
    echo "EXECUTION=ABORTED"
    exit 22
fi

if test -e "$LOCK"
then
    echo "A0_C1_EXECUTION_LOCK=EXISTS"
    echo "EXECUTION=ABORTED"
    echo "REASON=one-execution continuation already consumed"
    exit 23
fi

if test -e "$STAGE"
then
    echo "A0_C1_STAGE=EXISTS"
    echo "EXECUTION=ABORTED"
    exit 24
fi

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 25
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 26
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
    exit 27
fi

echo "SCRIPT_IDENTITY=PASS"
echo "A0_C1_EXECUTION_LOCK=ABSENT"
echo "A0_C1_STAGE=ABSENT"

"$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A0-C1 POST-RUN"
echo "============================================================"

echo "A0_C1_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -f "$LOCK"
then
    echo "A0_C1_EXECUTION_LOCK=CONSUMED"
    sha256sum "$LOCK"
    cat "$LOCK"
else
    echo "A0_C1_EXECUTION_LOCK=NOT_CONSUMED"
fi

if test -f "$STAGE/evidence/SHA256SUMS"
then
    echo "A0_C1_MANIFEST=FOUND"
    sha256sum "$STAGE/evidence/SHA256SUMS"
else
    echo "A0_C1_MANIFEST=NOT_AVAILABLE"
fi

if test -f "$STAGE/selection/selection.tsv"
then
    echo
    echo "=== A0-C1 FROZEN SELECTION ==="
    cat "$STAGE/selection/selection.tsv"
fi

if test -f "$STAGE/canonical/canonical-facts.tsv"
then
    echo
    echo "=== A0-C1 CANONICAL FACTS ==="
    cat "$STAGE/canonical/canonical-facts.tsv"
fi

if test -f "$STAGE/evidence/summary.tsv"
then
    echo
    echo "=== A0-C1 SUMMARY ==="
    cat "$STAGE/evidence/summary.tsv"
fi

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
