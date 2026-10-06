#!/usr/bin/env bash
set -u
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"

SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-a1-r1-preflight.sh"
CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a1-r1-preflight-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-a1-r1-execution-started"
STAGE="$ROOT/stage-a1-r1"

EXPECTED_SCRIPT_SHA256="23d96dbdd86e87c3dfdf59f445b4ba5bd988cc86b060e879c4f4374d06f50117"
SCRIPT_COMMIT="97f28c9b156da47cdaec289999cc9b38ed723183"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage/scripts/02-a1-r1-preflight.sh"

echo "============================================================"
echo " A1-R1 PRE-EXECUTION AUDIT"
echo " DUAL AUTHORITY / SYNTHETIC ONLY"
echo " NO SCIENTIFIC CLASSIFICATION"
echo "============================================================"

if test -e "$LOCK"
then
    echo "A1_R1_EXECUTION_LOCK=EXISTS"
    echo "AUDIT=ABORTED"
    exit 20
fi

if test -e "$STAGE"
then
    echo "A1_R1_STAGE=EXISTS"
    echo "AUDIT=ABORTED"
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

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A1-R1 PRE-EXECUTION AUDIT STATUS"
echo "============================================================"

echo "A1_R1_PREFLIGHT_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -e "$LOCK"
then
    echo "A1_R1_EXECUTION_LOCK=UNEXPECTEDLY_CONSUMED"
    exit 25
fi

echo "A1_R1_EXECUTION_LOCK=ABSENT"

if test -e "$STAGE"
then
    echo "A1_R1_STAGE=UNEXPECTEDLY_CREATED"
    exit 26
fi

echo "A1_R1_STAGE=ABSENT"

if test "$RUN_RC" -eq 0
then
    echo "A1_R1_PRE_EXECUTION_AUDIT_WRAPPER=PASS"
else
    echo "A1_R1_PRE_EXECUTION_AUDIT_WRAPPER=NOT_EVALUATED"
fi

echo "SCIENTIFIC_EXECUTION_STARTED=NO"
echo "A1_EXECUTION_LOCK_CONSUMED=NO"
echo "SEC_FETCHES=ZERO"
echo "YODA_WRITES=ZERO"

exit "$RUN_RC"
