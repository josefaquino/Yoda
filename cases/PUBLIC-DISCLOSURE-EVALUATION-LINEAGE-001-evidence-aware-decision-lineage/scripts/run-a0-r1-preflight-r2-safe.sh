#!/usr/bin/env bash
set -u
set -o pipefail

CASE="PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"

SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-stage-a0-r1.sh"
CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a0-r1-preflight-r2-console.log"

ROOT="$HOME/cmu/$CASE"
LOCK="$ROOT/.stage-a0-r1-execution-started"
STAGE="$ROOT/stage-a0-r1"

EXPECTED_SCRIPT_SHA256="85b90c72684ce8b19392621de2d230a39259879768cae5344830d2d3a22ee35f"
SCRIPT_COMMIT="2cf725e6cccabbdb5256ad92ab0e345bd5465163"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage/scripts/01-a0-public-disclosure-authority.sh"

echo "============================================================"
echo " A0-R1 PRE-EXECUTION AUDIT R2"
echo " COMPILE + SYNTHETIC SELF-TEST ONLY"
echo " NO SCIENTIFIC SEC A0 FETCHES"
echo "============================================================"

if test -z "${SEC_USER_AGENT:-}"
then
    echo "SEC_USER_AGENT_PRESENT=NO"
    echo "AUDIT=ABORTED"
    exit 20
fi

if test -e "$LOCK"
then
    echo "A0_R1_EXECUTION_LOCK=EXISTS"
    echo "AUDIT=ABORTED"
    echo "REASON=scientific A0 gate already consumed"
    exit 21
fi

if test -e "$STAGE"
then
    echo "A0_R1_STAGE=EXISTS"
    echo "AUDIT=ABORTED"
    echo "REASON=scientific A0 stage already exists"
    exit 22
fi

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 23
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 24
fi

echo "BASH_PARSE=PASS"

ACTUAL="$(sha256sum "$SCRIPT" | awk '{print $1}')"

echo "EXPECTED_SCRIPT_SHA256=$EXPECTED_SCRIPT_SHA256"
echo "ACTUAL_SCRIPT_SHA256=$ACTUAL"

if test "$ACTUAL" != "$EXPECTED_SCRIPT_SHA256"
then
    echo "SCRIPT_IDENTITY=FAIL"
    exit 25
fi

echo "SCRIPT_IDENTITY=PASS"

A0_PREFLIGHT_ONLY=YES     bash "$SCRIPT" 2>&1 |
    tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " A0-R1 PRE-EXECUTION AUDIT R2 STATUS"
echo "============================================================"

echo "A0_R1_PREFLIGHT_R2_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

if test -e "$LOCK"
then
    echo "A0_R1_EXECUTION_LOCK=UNEXPECTEDLY_CONSUMED"
    exit 26
fi

echo "A0_R1_EXECUTION_LOCK=ABSENT"

if test -e "$STAGE"
then
    echo "A0_R1_STAGE=UNEXPECTEDLY_CREATED"
    exit 27
fi

echo "A0_R1_STAGE=ABSENT"

if test "$RUN_RC" -eq 0
then
    echo "A0_R1_PRE_EXECUTION_AUDIT_R2=PASS"
else
    echo "A0_R1_PRE_EXECUTION_AUDIT_R2=NOT_EVALUATED"
fi

echo "SCIENTIFIC_EXECUTION_STARTED=NO"
echo "A0_EXECUTION_LOCK_CONSUMED=NO"
echo "YODA_WRITES=ZERO"

exit "$RUN_RC"
