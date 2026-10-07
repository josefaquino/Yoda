#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"
REVISION="A4-R0-SOURCE-AUTHORITY-001"

PROJECT="$HOME/cmu/yoda_agent_c23"
ROOT="$HOME/cmu/$CASE"
STAGE="$ROOT/a4-r0-source-authority"
EVIDENCE="$STAGE/evidence"
REBUILD="$STAGE/rebuild"

AGENT="$PROJECT/yoda_seeker_agent"

EXPECTED_AGENT_SHA256="dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"
EXPECTED_A3_MANIFEST_SHA256="fef59c315bc2bef4f45f47bc15e214667c6b97ae7ed4548bc4cad542233e3c29"

A3_MANIFEST="$ROOT/a3-lock-instrumentation/evidence/SHA256SUMS"

fail()
{
    echo
    echo "A4_R0_SOURCE_AUTHORITY=NOT_ESTABLISHED"
    echo "FAILURE_CLASS=$1"
    echo "PROJECT_SOURCE_MUTATED=NO"
    echo "SEEKER_EXECUTED=NO"
    exit 1
}

sha()
{
    sha256sum "$1" | awk '{print $1}'
}

for cmd in sha256sum awk cp rm mkdir make gcc file wc cat find sort xargs cmp
do
    command -v "$cmd" >/dev/null 2>&1 ||
        fail "MISSING_COMMAND_$cmd"
done

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A4-R0 SOURCE AUTHORITY"
echo " ISOLATED REBUILD / NO SEEKER EXECUTION"
echo "============================================================"

test -d "$PROJECT" ||
    fail "PROJECT_MISSING"

test -x "$AGENT" ||
    fail "CONTROL_AGENT_MISSING"

test ! -e "$STAGE" ||
    fail "A4_R0_STAGE_ALREADY_EXISTS"

test -f "$A3_MANIFEST" ||
    fail "A3_MANIFEST_MISSING"

for f in main.c yoda_agent_driver.c yoda_agent_driver.h Makefile
do
    test -f "$PROJECT/$f" ||
        fail "SOURCE_MISSING_$f"
done

ACTUAL_AGENT_SHA256="$(sha "$AGENT")"
ACTUAL_FRONTIER_SHA256="$(sha "$PROJECT/frontier.tsv")"
ACTUAL_A3_MANIFEST_SHA256="$(sha "$A3_MANIFEST")"

echo "EXPECTED_AGENT_SHA256=$EXPECTED_AGENT_SHA256"
echo "ACTUAL_AGENT_SHA256=$ACTUAL_AGENT_SHA256"
echo "EXPECTED_FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256"
echo "ACTUAL_FRONTIER_SHA256=$ACTUAL_FRONTIER_SHA256"
echo "EXPECTED_A3_MANIFEST_SHA256=$EXPECTED_A3_MANIFEST_SHA256"
echo "ACTUAL_A3_MANIFEST_SHA256=$ACTUAL_A3_MANIFEST_SHA256"

test "$ACTUAL_AGENT_SHA256" = "$EXPECTED_AGENT_SHA256" ||
    fail "CONTROL_AGENT_IDENTITY_MISMATCH"

test "$ACTUAL_FRONTIER_SHA256" = "$EXPECTED_FRONTIER_SHA256" ||
    fail "FRONTIER_IDENTITY_MISMATCH"

test "$ACTUAL_A3_MANIFEST_SHA256" = "$EXPECTED_A3_MANIFEST_SHA256" ||
    fail "A3_MANIFEST_IDENTITY_MISMATCH"

mkdir -p "$EVIDENCE" "$REBUILD" ||
    fail "STAGE_CREATION_FAILURE"

echo
echo "============================================================"
echo " 1. TOOLCHAIN"
echo "============================================================"

gcc --version | head -n 1
make --version | head -n 1

echo
echo "============================================================"
echo " 2. SOURCE IDENTITIES"
echo "============================================================"

: > "$EVIDENCE/source-identities.tsv"

for f in main.c yoda_agent_driver.c yoda_agent_driver.h Makefile
do
    s="$(sha "$PROJECT/$f")"
    b="$(wc -c < "$PROJECT/$f" | awk '{print $1}')"
    l="$(wc -l < "$PROJECT/$f" | awk '{print $1}')"

    printf '%s\t%s\t%s\t%s\n' "$f" "$s" "$b" "$l" |
        tee -a "$EVIDENCE/source-identities.tsv"

    cp "$PROJECT/$f" "$EVIDENCE/$f" ||
        fail "SOURCE_FREEZE_FAILURE_$f"

    cp "$PROJECT/$f" "$REBUILD/$f" ||
        fail "REBUILD_COPY_FAILURE_$f"
done

echo
echo "============================================================"
echo " 3. ISOLATED REBUILD"
echo "============================================================"

(
    cd "$REBUILD" || exit 1

    make clean >/dev/null 2>&1 || true
    make
) > "$EVIDENCE/rebuild.log" 2>&1

REBUILD_RC=$?

cat "$EVIDENCE/rebuild.log"

test "$REBUILD_RC" -eq 0 ||
    fail "ISOLATED_REBUILD_FAILED"

test -x "$REBUILD/yoda_seeker_agent" ||
    fail "REBUILT_BINARY_MISSING"

REBUILT_SHA256="$(sha "$REBUILD/yoda_seeker_agent")"

echo
echo "CONTROL_AGENT_SHA256=$ACTUAL_AGENT_SHA256"
echo "REBUILT_AGENT_SHA256=$REBUILT_SHA256"

file "$AGENT"
file "$REBUILD/yoda_seeker_agent"

if test "$REBUILT_SHA256" != "$ACTUAL_AGENT_SHA256"
then
    echo "BYTE_IDENTICAL_REBUILD=NO"
    fail "SOURCE_DOES_NOT_REPRODUCE_FROZEN_BINARY"
fi

echo "BYTE_IDENTICAL_REBUILD=YES"

echo
echo "============================================================"
echo " 4. SOURCE BUNDLE"
echo "============================================================"

BUNDLE="$EVIDENCE/source-bundle.txt"

: > "$BUNDLE"

for f in main.c yoda_agent_driver.c yoda_agent_driver.h Makefile
do
    {
        echo "===== BEGIN FILE: $f ====="
        cat "$PROJECT/$f"
        echo
        echo "===== END FILE: $f ====="
        echo
    } >> "$BUNDLE"
done

echo "SOURCE_BUNDLE=$BUNDLE"
echo "SOURCE_BUNDLE_SHA256=$(sha "$BUNDLE")"
echo "SOURCE_BUNDLE_BYTES=$(wc -c < "$BUNDLE" | awk '{print $1}')"
echo "SOURCE_BUNDLE_LINES=$(wc -l < "$BUNDLE" | awk '{print $1}')"

echo
echo "============================================================"
echo " 5. PROJECT IMMUTABILITY"
echo "============================================================"

for f in main.c yoda_agent_driver.c yoda_agent_driver.h Makefile
do
    cmp -s "$PROJECT/$f" "$EVIDENCE/$f" ||
        fail "PROJECT_SOURCE_MUTATED_$f"
done

test "$(sha "$AGENT")" = "$EXPECTED_AGENT_SHA256" ||
    fail "CONTROL_AGENT_MUTATED"

test "$(sha "$PROJECT/frontier.tsv")" = "$EXPECTED_FRONTIER_SHA256" ||
    fail "FRONTIER_MUTATED"

echo "PROJECT_SOURCE_MUTATED=NO"
echo "CONTROL_AGENT_MUTATED=NO"
echo "FRONTIER_MUTATED=NO"
echo "SEEKER_EXECUTED=NO"

echo
echo "============================================================"
echo " 6. EVIDENCE MANIFEST"
echo "============================================================"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	$REVISION
VERDICT	PASS
CONTROL_AGENT_SHA256	$EXPECTED_AGENT_SHA256
FRONTIER_SHA256	$EXPECTED_FRONTIER_SHA256
A3_MANIFEST_SHA256	$EXPECTED_A3_MANIFEST_SHA256
REBUILT_AGENT_SHA256	$REBUILT_SHA256
BYTE_IDENTICAL_REBUILD	YES
PROJECT_SOURCE_MUTATED	NO
CONTROL_AGENT_MUTATED	NO
FRONTIER_MUTATED	NO
SEEKER_EXECUTED	NO
NEXT_GATE	A4_R1_CANDIDATE_BUILD
EOF

(
    cd "$STAGE" || exit 1

    find .         -type f         ! -path './evidence/SHA256SUMS'         ! -path './evidence/SHA256SUMS.check'         -print |
    LC_ALL=C sort |
    sed 's#^\./##' |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS         > evidence/SHA256SUMS.check
) || fail "EVIDENCE_INTEGRITY_FAILURE"

MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A4_R0_EVIDENCE_INTEGRITY=PASS"
echo "A4_R0_EVIDENCE_MANIFEST_SHA256=$MANIFEST_SHA256"

echo
echo "============================================================"
echo " 7. SOURCE AUTHORITY VERDICT"
echo "============================================================"

echo "A4_R0_SOURCE_AUTHORITY=PASS"
echo "BYTE_IDENTICAL_REBUILD=YES"
echo "PROJECT_SOURCE_MUTATED=NO"
echo "SEEKER_EXECUTED=NO"
echo "NEXT_GATE=A4_R1_CANDIDATE_BUILD"

echo
echo "============================================================"
echo " 8. EXACT SOURCE TEXT"
echo "============================================================"

cat "$BUNDLE"

exit 0
