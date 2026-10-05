#!/usr/bin/env bash
set -eu
set -o pipefail

CASE="FORMAL-MATH-EVOLVING-DERIVATION-001"
ROOT="$HOME/cmu/$CASE"
EXTERNAL="$ROOT/external"
STAGE="$ROOT/stage-a0"
EVIDENCE="$STAGE/evidence"

YODA="/home/jose/YodaCore-015-FROZEN/product/yoda"
EXPECTED_YODA_SHA256="1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb"

MINIF2F_REPO="https://github.com/openai/miniF2F.git"
MINIF2F_COMMIT="4e433ff5cadff23f9911a2bb5bbab2d351ce5554"

LEAN_TOOLCHAIN="leanprover/lean4:v4.32.0-rc1"
LEAN_GITHASH="b4812ae53eea93439ad5dce5a5c26591c31cb697"

MATHLIB_REPO="https://github.com/leanprover-community/mathlib4.git"
MATHLIB_TAG="v4.32.0-rc1"
MATHLIB_COMMIT="360da6fa66c1273b76b6b2d8c5666fd5ac2e3b56"

LEAN4EXPORT_REPO="https://github.com/leanprover/lean4export.git"
LEAN4EXPORT_COMMIT="3de59f10bc4b4a0f2de698597aeb1246caa0df0a"

OXILEAN_REPO="https://github.com/cool-japan/oxilean.git"
OXILEAN_COMMIT="9077af778fe467cba61d9c8385fb2b7e6a8d385f"

fail()
{
    echo
    echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A0=NOT_EVALUATED"
    echo "REASON=$1"
    exit 1
}

section()
{
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

sha()
{
    sha256sum "$1" | awk '{print $1}'
}

clone_exact()
{
    repo="$1"
    commit="$2"
    dest="$3"

    rm -rf "$dest"
    git clone --filter=blob:none --no-checkout "$repo" "$dest" >/dev/null 2>&1 ||
        fail "clone failed: $repo"

    (
        cd "$dest"
        git fetch --depth 1 origin "$commit" >/dev/null 2>&1 ||
            fail "fetch failed: $repo@$commit"
        git checkout --detach "$commit" >/dev/null 2>&1 ||
            fail "checkout failed: $repo@$commit"
        actual="$(git rev-parse HEAD)"
        test "$actual" = "$commit" ||
            fail "commit mismatch for $repo"
    )
}

rm -rf "$STAGE"
mkdir -p "$EXTERNAL" "$EVIDENCE"

section "0. PREFLIGHT"

for cmd in \
    git \
    cargo \
    rustc \
    elan \
    lake \
    sha256sum \
    awk \
    sed \
    grep \
    find \
    xargs \
    wc
 do
    command -v "$cmd" >/dev/null 2>&1 ||
        fail "$cmd missing"
done


test -x "$YODA" ||
    fail "frozen Yoda binary missing"

ACTUAL_YODA_SHA256="$(sha "$YODA")"

echo "EXPECTED_YODA_SHA256=$EXPECTED_YODA_SHA256"
echo "ACTUAL_YODA_SHA256=$ACTUAL_YODA_SHA256"

test "$ACTUAL_YODA_SHA256" = "$EXPECTED_YODA_SHA256" ||
    fail "Yoda identity mismatch"

echo "YODA_AUTHORITY=PASS"
echo "YODA_WRITES=ZERO"

section "1. FREEZE MINIF2F SOURCE AUTHORITY"

MINIF2F="$EXTERNAL/miniF2F"
clone_exact "$MINIF2F_REPO" "$MINIF2F_COMMIT" "$MINIF2F"

SOURCE_FILE="$MINIF2F/lean/src/valid.lean"
test -f "$SOURCE_FILE" ||
    fail "MiniF2F Lean source missing"

awk '
/^theorem mathd_algebra_182$/ { capture=1 }
capture { print }
capture && /^end$/ { exit }
' "$SOURCE_FILE" > "$EVIDENCE/minif2f-mathd_algebra_182.txt"

grep -F "theorem mathd_algebra_182" "$EVIDENCE/minif2f-mathd_algebra_182.txt" >/dev/null ||
    fail "MiniF2F theorem name missing"

grep -F "7 * (3 * y + 2) = 21 * y + 14 :=" "$EVIDENCE/minif2f-mathd_algebra_182.txt" >/dev/null ||
    fail "MiniF2F theorem statement mismatch"

grep -F "ring_nf," "$EVIDENCE/minif2f-mathd_algebra_182.txt" >/dev/null ||
    fail "MiniF2F reference proof tactic missing"

MINIF2F_SOURCE_SHA256="$(sha "$EVIDENCE/minif2f-mathd_algebra_182.txt")"

echo "MINIF2F_COMMIT=$MINIF2F_COMMIT"
echo "MINIF2F_THEOREM=mathd_algebra_182"
echo "MINIF2F_SOURCE_SHA256=$MINIF2F_SOURCE_SHA256"
echo "MINIF2F_SOURCE_AUTHORITY=PASS"

section "2. FREEZE LEAN TOOLCHAIN"

elan toolchain install "$LEAN_TOOLCHAIN" >/dev/null 2>&1 ||
    fail "Lean toolchain install failed"

elan run "$LEAN_TOOLCHAIN" lean --version |
    tee "$EVIDENCE/lean-version.txt"

grep -F "4.32.0-rc1" "$EVIDENCE/lean-version.txt" >/dev/null ||
    fail "Lean version mismatch"

cat > "$EVIDENCE/lean-authority.txt" <<EOF
LEAN_TOOLCHAIN=$LEAN_TOOLCHAIN
LEAN_GITHASH=$LEAN_GITHASH
EOF

echo "LEAN_TOOLCHAIN=$LEAN_TOOLCHAIN"
echo "LEAN_GITHASH=$LEAN_GITHASH"
echo "LEAN_AUTHORITY=PASS"

section "3. FREEZE MATHLIB"

MATHLIB="$EXTERNAL/mathlib4"
rm -rf "$MATHLIB"
git clone --depth 1 --branch "$MATHLIB_TAG" "$MATHLIB_REPO" "$MATHLIB" >/dev/null 2>&1 ||
    fail "Mathlib clone failed"

ACTUAL_MATHLIB_COMMIT="$(cd "$MATHLIB" && git rev-parse HEAD)"

echo "EXPECTED_MATHLIB_COMMIT=$MATHLIB_COMMIT"
echo "ACTUAL_MATHLIB_COMMIT=$ACTUAL_MATHLIB_COMMIT"

test "$ACTUAL_MATHLIB_COMMIT" = "$MATHLIB_COMMIT" ||
    fail "Mathlib commit mismatch"

grep -F "$LEAN_TOOLCHAIN" "$MATHLIB/lean-toolchain" >/dev/null ||
    fail "Mathlib Lean toolchain mismatch"

echo "MATHLIB_AUTHORITY=PASS"

section "4. FREEZE LEAN4EXPORT"

LEAN4EXPORT="$EXTERNAL/lean4export"
clone_exact "$LEAN4EXPORT_REPO" "$LEAN4EXPORT_COMMIT" "$LEAN4EXPORT"

(
    cd "$LEAN4EXPORT"
    lake build lean4export
) > "$EVIDENCE/lean4export-build.log" 2>&1 ||
    fail "lean4export build failed"

LEAN4EXPORT_BIN="$LEAN4EXPORT/.lake/build/bin/lean4export"
test -x "$LEAN4EXPORT_BIN" ||
    fail "lean4export binary missing after build"

echo "LEAN4EXPORT_COMMIT=$LEAN4EXPORT_COMMIT"
echo "LEAN4EXPORT_BIN_SHA256=$(sha "$LEAN4EXPORT_BIN")"
echo "LEAN4EXPORT_AUTHORITY=PASS"

section "5. FREEZE OXILEAN"

OXILEAN="$EXTERNAL/oxilean"
clone_exact "$OXILEAN_REPO" "$OXILEAN_COMMIT" "$OXILEAN"

(
    cd "$OXILEAN"
    cargo build --release -p oxilean-verify
) > "$EVIDENCE/oxilean-build.log" 2>&1 ||
    fail "OxiLean build failed"

OXILEAN_BIN="$OXILEAN/target/release/oxilean-verify"
test -x "$OXILEAN_BIN" ||
    fail "oxilean-verify binary missing"

"$OXILEAN_BIN" --version |
    tee "$EVIDENCE/oxilean-version.txt"

grep -F "v4.32.0-rc1" "$EVIDENCE/oxilean-version.txt" >/dev/null ||
    fail "OxiLean Lean-toolchain pin mismatch"

grep -F "3de59f10" "$EVIDENCE/oxilean-version.txt" >/dev/null ||
    fail "OxiLean lean4export pin mismatch"

echo "OXILEAN_COMMIT=$OXILEAN_COMMIT"
echo "OXILEAN_BIN_SHA256=$(sha "$OXILEAN_BIN")"
echo "OXILEAN_AUTHORITY=PASS"

section "6. AUTHORITY RECORD"

cat > "$EVIDENCE/authority-record.tsv" <<EOF
CASE	$CASE
MINIF2F_REPOSITORY	$MINIF2F_REPO
MINIF2F_COMMIT	$MINIF2F_COMMIT
MINIF2F_THEOREM	mathd_algebra_182
MINIF2F_SOURCE_SHA256	$MINIF2F_SOURCE_SHA256
LEAN_TOOLCHAIN	$LEAN_TOOLCHAIN
LEAN_GITHASH	$LEAN_GITHASH
MATHLIB_TAG	$MATHLIB_TAG
MATHLIB_COMMIT	$MATHLIB_COMMIT
LEAN4EXPORT_COMMIT	$LEAN4EXPORT_COMMIT
LEAN4EXPORT_BIN_SHA256	$(sha "$LEAN4EXPORT_BIN")
OXILEAN_COMMIT	$OXILEAN_COMMIT
OXILEAN_BIN_SHA256	$(sha "$OXILEAN_BIN")
YODA_SHA256	$ACTUAL_YODA_SHA256
YODA_WRITES	ZERO
YODA_CHANGE	NO
KYBER_CHANGE	NO
EOF

section "7. FREEZE A0 EVIDENCE"

cp "$0" "$EVIDENCE/stage-a0-script.sh"

(
    cd "$STAGE"
    find evidence \
        -type f \
        ! -name SHA256SUMS \
        ! -name SHA256SUMS.check \
        -print |
    LC_ALL=C sort |
    xargs sha256sum > evidence/SHA256SUMS

    sha256sum -c evidence/SHA256SUMS > evidence/SHA256SUMS.check
) || fail "A0 evidence integrity failed"

A0_MANIFEST_SHA256="$(sha "$EVIDENCE/SHA256SUMS")"

echo "A0_EVIDENCE_INTEGRITY=PASS"
echo "A0_EVIDENCE_MANIFEST_SHA256=$A0_MANIFEST_SHA256"

section "8. HOMOLOGATION"

echo "FORMAL_MATH_EVOLVING_DERIVATION_001_STAGE_A0=PASS"
echo "MINIF2F_SOURCE_AUTHORITY=PASS"
echo "LEAN_AUTHORITY=PASS"
echo "MATHLIB_AUTHORITY=PASS"
echo "LEAN4EXPORT_AUTHORITY=PASS"
echo "OXILEAN_AUTHORITY=PASS"
echo "YODA_AUTHORITY=PASS"
echo "YODA_WRITES=ZERO"
echo "YODA_CHANGE=NO"
echo "KYBER_CHANGE=NO"
echo "NEXT_GATE=STAGE_A1_CONTROLLED_PROOF_EVOLUTION"
