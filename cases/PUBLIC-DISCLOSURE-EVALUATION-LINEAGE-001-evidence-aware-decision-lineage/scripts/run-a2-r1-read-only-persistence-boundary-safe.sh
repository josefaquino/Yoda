#!/usr/bin/env bash
set -u
set -o pipefail

SCRIPT="$HOME/cmu/public-disclosure-evaluation-lineage-001-a2-r1-readonly-adjudication.sh"
CONSOLE="$HOME/cmu/public-disclosure-evaluation-lineage-001-a2-r1-readonly-adjudication-console.log"

EXPECTED_SCRIPT_SHA256="3cffbe3044974f458361af0ac4fd78e42850e4cb26af4825b9273d286a5ac67f"
SCRIPT_COMMIT="1f8c3bfc4a42cc50450cfdc969585a05804d6df1"

URL="https://raw.githubusercontent.com/josefaquino/Yoda/$SCRIPT_COMMIT/cases/PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001-evidence-aware-decision-lineage/scripts/03-a2-r1-read-only-persistence-boundary.sh"

echo "============================================================"
echo " A2-R1 READ-ONLY PERSISTENCE BOUNDARY ADJUDICATION"
echo " NO INIT / NO PUT / NO LINK / NO RERUN"
echo "============================================================"

rm -f "$SCRIPT"

if ! curl -fsSL "$URL" -o "$SCRIPT"
then
    echo "FETCH=FAIL"
    exit 20
fi

chmod +x "$SCRIPT"

if ! bash -n "$SCRIPT"
then
    echo "BASH_PARSE=FAIL"
    exit 21
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
    exit 22
fi

echo "SCRIPT_IDENTITY=PASS"

bash "$SCRIPT" 2>&1 |
tee "$CONSOLE"

RUN_RC="${PIPESTATUS[0]}"

echo
echo "============================================================"
echo " READ-ONLY ADJUDICATION POST-RUN"
echo "============================================================"

echo "READ_ONLY_ADJUDICATION_RC=$RUN_RC"

sha256sum "$SCRIPT" "$CONSOLE"

echo "SAFE_READ_ONLY_LAUNCHER_COMPLETE=YES"

exit "$RUN_RC"
