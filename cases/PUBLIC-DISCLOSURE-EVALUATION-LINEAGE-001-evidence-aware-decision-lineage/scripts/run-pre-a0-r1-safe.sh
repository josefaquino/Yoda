#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-pre-a0-r1.sh"
CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-pre-a0-r1-console.log"

EXPECTED_SCRIPT_SHA256="ed430dcb7d71c73b0147eaa5d5e89e3424f6b5ec70486c1c6de55ddc04a2b33e"
SCRIPT_COMMIT="45fbd7b33d17ba7606b08b288435bc9997e88fa5"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage/scripts/00-pre-a0-sec-source-capability-audit.sh"

echo "============================================================"
echo " PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001"
echo " PRE-A0-R1 - SEC SOURCE CAPABILITY AUDIT"
echo " READ-ONLY / NO YODA WRITES"
echo "============================================================"

if test -z "${SEC_USER_AGENT:-}"
then
    echo "SEC_USER_AGENT_PRESENT=NO"
    echo "EXECUTION=ABORTED"
    exit 20
fi

echo "SEC_USER_AGENT_PRESENT=YES"

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 21
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 22
fi

echo "BASH_PARSE=PASS"

ACTUAL="$(sha256sum "$SCRIPT" | awk '{print $1}')"

echo "EXPECTED_SCRIPT_SHA256=$EXPECTED_SCRIPT_SHA256"
echo "ACTUAL_SCRIPT_SHA256=$ACTUAL"

if test "$ACTUAL" != "$EXPECTED_SCRIPT_SHA256"
then
    echo "SCRIPT_IDENTITY=FAIL"
    exit 23
fi

echo "SCRIPT_IDENTITY=PASS"

"$SCRIPT" 2>&1 | tee "$CONSOLE"
RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " PRE-A0-R1 POST-RUN"
echo "============================================================"

echo "PRE_A0_R1_RUN_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

echo
echo "SAFE_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
