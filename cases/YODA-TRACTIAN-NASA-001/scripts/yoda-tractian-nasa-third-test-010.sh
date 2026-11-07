#!/usr/bin/env bash
set -eu
export LC_ALL=C

ROOT="$HOME/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001"
DATA="$ROOT/datasets"
EVIDENCE="$ROOT/evidence"

ZIP="$DATA/nasa-ims-bearings.zip"
INNER="$DATA/IMS.7z"
RAR="$DATA/3rd_test.rar"

STAGE="$DATA/.third-test-stage-010"
TARGET="$DATA/3rd_test"
OUT="$EVIDENCE/THIRD-TEST-010"

echo "============================================================"
echo " YODA-TRACTIAN-NASA-001"
echo " NASA THIRD TEST 010 — INDEPENDENT EXPERIMENT"
echo "============================================================"

test -f "$ZIP"
test -f "$INNER"
test -f "$EVIDENCE/nasa-ims-archive.sha256"
test ! -e "$STAGE"
test ! -e "$TARGET"
test ! -e "$OUT"

command -v 7z >/dev/null
command -v unar >/dev/null
command -v sha256sum >/dev/null

mkdir -p "$OUT"

echo
echo "=== 1. VERIFY NASA SOURCE ==="

sha256sum -c "$EVIDENCE/nasa-ims-archive.sha256"
echo "NASA_SOURCE=PASS"

echo
echo "=== 2. VERIFY THIRD TEST MEMBER ==="

7z l -slt "$INNER" > "$OUT/ims-inventory.txt"

COUNT="$(
    grep -Fxc 'Path = 3rd_test.rar' \
        "$OUT/ims-inventory.txt" || true
)"

test "$COUNT" -eq 1 || {
    echo "STOP=THIRD_TEST_MEMBER_NOT_UNIQUE"
    exit 1
}

echo "THIRD_TEST_MEMBER=PASS"

echo
echo "=== 3. EXTRACT THIRD TEST ARCHIVE ==="

if [ ! -f "$RAR" ]; then
    mkdir "$DATA/.third-rar-extract-010"

    7z e -y -bd \
        "-o$DATA/.third-rar-extract-010" \
        "$INNER" '3rd_test.rar' \
        > "$OUT/7z-extraction.log" 2>&1 || {
        tail -25 "$OUT/7z-extraction.log"
        exit 1
    }

    test -s "$DATA/.third-rar-extract-010/3rd_test.rar"

    mv "$DATA/.third-rar-extract-010/3rd_test.rar" \
       "$RAR"

    rmdir "$DATA/.third-rar-extract-010"
fi

sha256sum "$RAR" > "$OUT/third-test-rar.sha256"
echo "THIRD_TEST_RAR=PASS"

echo
echo "=== 4. INVENTORY RAR CONTENTS ==="

7z l -slt "$RAR" \
    > "$OUT/rar-inventory.txt"

awk '
/^Path = / {
    p=substr($0,8)
    if (p ~ /[0-9][0-9][0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]$/)
        print p
}
' "$OUT/rar-inventory.txt" |
    sort > "$OUT/snapshot-members.txt"

DECLARED="$(
    wc -l < "$OUT/snapshot-members.txt" |
    tr -d ' '
)"

echo "RAR_SNAPSHOT_MEMBERS=$DECLARED"

echo
echo "--- FIRST AND LAST MEMBER ---"
sed -n '1p;$p' "$OUT/snapshot-members.txt"

echo
echo "=== 5. EXTRACT WITH UNAR ==="

mkdir "$STAGE"

unar -q -D -o "$STAGE" "$RAR" \
    > "$OUT/unar-extraction.log" 2>&1 || {
    echo "THIRD_TEST_EXTRACTION=FAIL"
    tail -25 "$OUT/unar-extraction.log"
    echo "STAGE_PRESERVED=$STAGE"
    exit 1
}

echo "THIRD_TEST_EXTRACTION=PASS"

echo
echo "=== 6. VALIDATE EXTRACTED FILES ==="

FILES="$(
    find "$STAGE" -type f |
    wc -l | tr -d ' '
)"

LINKS="$(
    find "$STAGE" -type l |
    wc -l | tr -d ' '
)"

echo "EXTRACTED_FILES=$FILES"
echo "SYMLINKS=$LINKS"
echo "DOCUMENTED_DISTRIBUTION_COUNT=6324"

test "$FILES" -eq "$DECLARED"
test "$FILES" -eq 6324
test "$LINKS" -eq 0

echo "INVENTORY=PASS"

echo
echo "=== 7. VALIDATE FIRST AND LAST SIGNAL ==="

FIRST="$(find "$STAGE" -type f | sort | sed -n '1p')"
LAST="$(find "$STAGE" -type f | sort | tail -1)"

for file in "$FIRST" "$LAST"
do
    echo "CHECKING=$file"

    awk '
    {
        rows++
        if (NF != 4)
            bad++
    }
    END {
        printf "ROWS=%d CHANNELS=4 BAD_ROWS=%d\n",
            rows,bad

        if (rows != 20480 || bad != 0)
            exit 1
    }
    ' "$file" || {
        echo "SIGNAL_VALIDATION=FAIL"
        exit 1
    }
done

echo "SIGNAL_VALIDATION=PASS"

echo
echo "=== 8. PROMOTE DATASET ==="

mv "$STAGE" "$TARGET"

sha256sum \
    "$OUT/third-test-rar.sha256" \
    "$OUT/snapshot-members.txt" \
    > "$OUT/artifacts.sha256"

echo
echo "============================================================"
echo " NASA THIRD TEST 010 — COMPLETE"
echo "============================================================"

echo "THIRD_TEST_010=PASS"
echo "FILES=$FILES"
echo "CHANNELS=4"
echo "DATA=REAL_HISTORICAL"
echo "FAULT_LABELS=NOT_USED"
echo "EXISTING_COMPONENTS=UNCHANGED"
echo "DATASET_PATH=$TARGET"
echo "NEXT=FROZEN_RULE_CROSS_TEST_REPLAY"
