#!/bin/sh
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/../.." && pwd)

YODA="$ROOT/yoda"
DB="$HERE/memory"

fail()
{
    echo "CASE_EXTERNAL_001=FAIL"
    echo "REASON=$1"
    exit 1
}

test -x "$YODA" ||
    fail "yoda binary not executable"

rm -rf "$DB"

echo "============================================================"
echo " YODA CASE-EXTERNAL-001"
echo " DECISION-STATE / TEMPORAL EVIDENCE"
echo "============================================================"

echo
echo "=== INIT ==="

"$YODA" init "$DB"

echo
echo "=== OLD EVIDENCE ==="

printf '%s\n' \
    'Orion production database: PostgreSQL 15.4 approved.' |
    "$YODA" -d "$DB" put \
        evidence/orion-db-compat-20260929 \
        source=production-validation

echo
echo "=== NEW EVIDENCE ==="

printf '%s\n' \
    'Orion production database: PostgreSQL 16 approved after successful validation.' |
    "$YODA" -d "$DB" put \
        evidence/orion-db-compat-20260930 \
        source=production-validation

echo
echo "=== TEMPORAL RELATION ==="

"$YODA" -d "$DB" link \
    evidence/orion-db-compat-20260930 \
    supersedes \
    evidence/orion-db-compat-20260929 \
    source=production-validation

echo
echo "=== GET OLD ==="

"$YODA" -d "$DB" get \
    evidence/orion-db-compat-20260929

echo
echo "=== GET NEW ==="

"$YODA" -d "$DB" get \
    evidence/orion-db-compat-20260930

echo
echo "=== FIND ORION ==="

"$YODA" -d "$DB" find Orion

echo
echo "=== CONTEXT ==="

"$YODA" -d "$DB" context \
    "Orion production database"

echo
echo "=== VERIFY ==="

"$YODA" -d "$DB" verify

echo
echo "CASE_COMMANDS=PASS"
echo "CASE_EXTERNAL_001=READY_FOR_HUMAN_EVALUATION"
