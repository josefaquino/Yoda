#!/usr/bin/env bash
set -u
set -o pipefail

CASE="SEEKER-C23-SWARM-SCALING-002"

PROJECT="$HOME/cmu/yoda_agent_c23"
AGENT="$PROJECT/yoda_seeker_agent"
FRONTIER="$PROJECT/frontier.tsv"

ROOT="$HOME/cmu/$CASE"
PREFLIGHT="$ROOT/a3-lock-instrumentation-preflight"
EVIDENCE="$PREFLIGHT/evidence"
SMOKE="$PREFLIGHT/smoke"

EXPECTED_AGENT_SHA256="dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a"
EXPECTED_FRONTIER_SHA256="c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5"
EXPECTED_A2_MANIFEST_SHA256="01fa3de643602a08033e18aa60ce1e3c0207909990f227205e35f86a2d6b8621"

A2_MANIFEST="$ROOT/a2-stability/evidence/SHA256SUMS"
A3_LOCK="$ROOT/.a3-lock-instrumentation-execution-started"
A3_STAGE="$ROOT/a3-lock-instrumentation"

sha()
{
    sha256sum "$1" | awk '{print $1}'
}

fail()
{
    echo
    echo "A3_PREFLIGHT=NOT_READY"
    echo "FAILURE_CLASS=$1"
    echo "SEEKER_EXECUTED=NO"
    echo "A3_EXECUTION_LOCK=ABSENT"
    echo "A3_SCIENTIFIC_EXECUTION=NO"
    exit 1
}

require_cmd()
{
    command -v "$1" >/dev/null 2>&1 ||
        fail "MISSING_COMMAND_$1"

    echo "$2=PASS"
}

echo "============================================================"
echo " SEEKER-C23-SWARM-SCALING-002"
echo " A3 LOCK INSTRUMENTATION PREFLIGHT"
echo " STRACE FORMAT AUDIT ONLY"
echo " NO SEEKER EXECUTION"
echo "============================================================"

test ! -e "$A3_LOCK" ||
    fail "A3_EXECUTION_LOCK_ALREADY_EXISTS"

test ! -e "$A3_STAGE" ||
    fail "A3_STAGE_ALREADY_EXISTS"

require_cmd strace STRACE
require_cmd flock FLOCK
require_cmd sha256sum SHA256SUM
require_cmd awk AWK
require_cmd grep GREP
require_cmd sort SORT
require_cmd find FIND
require_cmd xargs XARGS
require_cmd mkdir MKDIR
require_cmd rm RM
require_cmd cmp CMP
require_cmd wc WC

echo
echo "============================================================"
echo " 1. FROZEN AUTHORITIES"
echo "============================================================"

test -x "$AGENT" ||
    fail "AGENT_MISSING"

test -f "$FRONTIER" ||
    fail "FRONTIER_MISSING"

test -f "$A2_MANIFEST" ||
    fail "A2_MANIFEST_MISSING"

ACTUAL_AGENT_SHA256="$(sha "$AGENT")"
ACTUAL_FRONTIER_SHA256="$(sha "$FRONTIER")"
ACTUAL_A2_MANIFEST_SHA256="$(sha "$A2_MANIFEST")"

echo "EXPECTED_AGENT_SHA256=$EXPECTED_AGENT_SHA256"
echo "ACTUAL_AGENT_SHA256=$ACTUAL_AGENT_SHA256"

echo "EXPECTED_FRONTIER_SHA256=$EXPECTED_FRONTIER_SHA256"
echo "ACTUAL_FRONTIER_SHA256=$ACTUAL_FRONTIER_SHA256"

echo "EXPECTED_A2_MANIFEST_SHA256=$EXPECTED_A2_MANIFEST_SHA256"
echo "ACTUAL_A2_MANIFEST_SHA256=$ACTUAL_A2_MANIFEST_SHA256"

test "$ACTUAL_AGENT_SHA256" = "$EXPECTED_AGENT_SHA256" ||
    fail "AGENT_IDENTITY_MISMATCH"

test "$ACTUAL_FRONTIER_SHA256" = "$EXPECTED_FRONTIER_SHA256" ||
    fail "FRONTIER_IDENTITY_MISMATCH"

test "$ACTUAL_A2_MANIFEST_SHA256" = "$EXPECTED_A2_MANIFEST_SHA256" ||
    fail "A2_MANIFEST_IDENTITY_MISMATCH"

echo "FROZEN_AUTHORITIES=PASS"

echo
echo "============================================================"
echo " 2. STRACE AUTHORITY"
echo "============================================================"

STRACE_VERSION="$(strace -V 2>&1 | head -n 1)"

echo "STRACE_VERSION=$STRACE_VERSION"

rm -rf "$PREFLIGHT"
mkdir -p "$EVIDENCE" "$SMOKE"

TRACE_PREFIX="$SMOKE/trace"
LOCKFILE="$SMOKE/test.lock"
TMPFILE="$SMOKE/a"
FINALFILE="$SMOKE/b"

set +e
strace     -ff     -qq     -ttt     -T     -e trace=flock,rename,renameat,renameat2     -o "$TRACE_PREFIX"     sh -c '
        exec 9>"$1"
        flock -x 9
        printf x > "$2"
        mv "$2" "$3"
        flock -u 9
    ' sh "$LOCKFILE" "$TMPFILE" "$FINALFILE"
STRACE_RC=$?
set -e

echo "STRACE_SMOKE_RC=$STRACE_RC"

test "$STRACE_RC" -eq 0 ||
    fail "STRACE_SMOKE_EXECUTION_FAILURE"

TRACE_FILES="$(
    find "$SMOKE" -type f -name 'trace*' | wc -l | awk '{print $1}'
)"

LOCK_EX_COUNT="$(
    grep -h 'flock(.*LOCK_EX' "$SMOKE"/trace* 2>/dev/null |
    wc -l |
    awk '{print $1}'
)"

LOCK_UN_COUNT="$(
    grep -h 'flock(.*LOCK_UN' "$SMOKE"/trace* 2>/dev/null |
    wc -l |
    awk '{print $1}'
)"

RENAME_COUNT="$(
    grep -hE 'rename(at2|at)?\(' "$SMOKE"/trace* 2>/dev/null |
    wc -l |
    awk '{print $1}'
)"

DURATION_COUNT="$(
    grep -hE '<[0-9]+\.[0-9]+>$' "$SMOKE"/trace* 2>/dev/null |
    wc -l |
    awk '{print $1}'
)"

echo "TRACE_FILES=$TRACE_FILES"
echo "LOCK_EX_COUNT=$LOCK_EX_COUNT"
echo "LOCK_UN_COUNT=$LOCK_UN_COUNT"
echo "RENAME_COUNT=$RENAME_COUNT"
echo "SYSCALL_DURATION_LINES=$DURATION_COUNT"

test "$TRACE_FILES" -ge 1 ||
    fail "STRACE_TRACE_FILE_MISSING"

test "$LOCK_EX_COUNT" -ge 1 ||
    fail "STRACE_LOCK_EX_NOT_OBSERVED"

test "$LOCK_UN_COUNT" -ge 1 ||
    fail "STRACE_LOCK_UN_NOT_OBSERVED"

test "$RENAME_COUNT" -ge 1 ||
    fail "STRACE_RENAME_NOT_OBSERVED"

test "$DURATION_COUNT" -ge 3 ||
    fail "STRACE_DURATION_FORMAT_NOT_OBSERVED"

echo "STRACE_FORMAT_AUTHORITY=PASS"

echo
echo "============================================================"
echo " 3. SAMPLE TRACE"
echo "============================================================"

grep -hE 'flock\(|rename(at2|at)?\(' "$SMOKE"/trace* |
head -n 20 |
tee "$EVIDENCE/sample-trace.txt"

echo
echo "============================================================"
echo " 4. PROVE SEEKER AND FRONTIER UNCHANGED"
echo "============================================================"

test "$(sha "$AGENT")" = "$EXPECTED_AGENT_SHA256" ||
    fail "AGENT_MUTATED_DURING_PREFLIGHT"

test "$(sha "$FRONTIER")" = "$EXPECTED_FRONTIER_SHA256" ||
    fail "FRONTIER_MUTATED_DURING_PREFLIGHT"

echo "AGENT_MUTATED=NO"
echo "FRONTIER_MUTATED=NO"
echo "SEEKER_EXECUTED=NO"

echo
echo "============================================================"
echo " 5. FREEZE PREFLIGHT EVIDENCE"
echo "============================================================"

cat > "$EVIDENCE/summary.tsv" <<EOF
CASE	$CASE
REVISION	A3-LOCK-INSTRUMENTATION-PREFLIGHT
VERDICT	PASS
AGENT_SHA256	$EXPECTED_AGENT_SHA256
FRONTIER_SHA256	$EXPECTED_FRONTIER_SHA256
A2_MANIFEST_SHA256	$EXPECTED_A2_MANIFEST_SHA256
STRACE_VERSION	$STRACE_VERSION
TRACE_FILES	$TRACE_FILES
LOCK_EX_COUNT	$LOCK_EX_COUNT
LOCK_UN_COUNT	$LOCK_UN_COUNT
RENAME_COUNT	$RENAME_COUNT
SYSCALL_DURATION_LINES	$DURATION_COUNT
SEEKER_EXECUTED	NO
FRONTIER_MUTATED	NO
A3_EXECUTION_LOCK	ABSENT
A3_SCIENTIFIC_EXECUTION	NO
EOF

(
    cd "$PREFLIGHT"

    find .         -type f         ! -path './evidence/SHA256SUMS'         ! -path './evidence/SHA256SUMS.check'         -print |
    LC_ALL=C sort |
    sed 's#^\./##' |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS         > evidence/SHA256SUMS.check
) || fail "PREFLIGHT_EVIDENCE_INTEGRITY_FAILURE"

MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A3_PREFLIGHT_EVIDENCE_INTEGRITY=PASS"
echo "A3_PREFLIGHT_MANIFEST_SHA256=$MANIFEST_SHA256"

echo
echo "============================================================"
echo " 6. PREFLIGHT VERDICT"
echo "============================================================"

echo "A3_LOCK_INSTRUMENTATION_PREFLIGHT=PASS"
echo "SEEKER_EXECUTED=NO"
echo "FRONTIER_MUTATED=NO"
echo "A3_EXECUTION_LOCK=ABSENT"
echo "A3_SCIENTIFIC_EXECUTION=NO"
echo "NEXT_GATE=A3_LOCK_INSTRUMENTATION_ONE_SHOT"
