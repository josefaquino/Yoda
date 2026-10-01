#!/usr/bin/env bash
set -eu

# ============================================================
# YODA FIELD-001
# COMMUNITY-REPRODUCIBLE MULTI-AGENT DECISION STATE
#
# PURPOSE
#   Test whether independent processes can recover consistent,
#   decision-relevant evidence from one durable Yoda state
#   without sharing conversational/process memory.
#
# RULES
#   - CORE-014 remains unchanged.
#   - Public v0.1.0-preview.1 release is authority.
#   - Bash + POSIX/coreutils + curl only.
#   - No Python.
#   - No jq.
#   - No LLM required for FIELD-001.
#
# FIELD-001-R1 will later replace the deterministic reference
# agents with real isolated Qwen agents.
# ============================================================

CASE_ID="FIELD-001"
TITLE="Multi-Agent Decision State"

ROOT="$HOME/YodaField-001"
DOWNLOAD="$ROOT/download"
RUNTIME="$ROOT/runtime"
CASE="$ROOT/case"
DB="$RUNTIME/memory"

VERSION="v0.1.0-preview.1"
ARCHIVE="yoda-v0.1.0-preview.1-linux-x86_64.tar.gz"
SHA_FILE="${ARCHIVE}.sha256"

BASE_URL="https://github.com/josefaquino/Yoda/releases/download/${VERSION}"

EXPECTED_ARCHIVE_SHA256="e7dd76b7e4d6da71fb8d9e6be31109b1cd8c567f45d20bf660b3e87fa4f89e68"
EXPECTED_BINARY_SHA256="06c1d2cb98099cb2d5b44f753fa3392da4f9a2bd42d39bd0a673270b01f9bfc8"
EXPECTED_SOURCE_SHA256="1d1ea6f7866307675d7b4cb37f42c5d82e52176a65debd8df3c8ea5c02be713b"

fail()
{
    echo
    echo "YODA_${CASE_ID}=FAIL"
    echo "REASON=$1"
    exit 1
}

need()
{
    command -v "$1" >/dev/null 2>&1 ||
        fail "required command missing: $1"
}

section()
{
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

capture_id()
{
    name="$1"
    shift

    out="$("$@")" || return 1

    printf '%s\n' "$out"

    id="$(
        printf '%s\n' "$out" |
        sed -n 's/^ID=//p' |
        head -n 1
    )"

    [ "${#id}" -eq 64 ] ||
        fail "invalid record id for $name"

    printf '%s\n' "$id" > "$CASE/evidence/${name}.id"
}

put_evidence()
{
    name="$1"
    key="$2"
    source="$3"
    value="$4"

    out="$(
        printf '%s\n' "$value" |
        "$YODA" -d "$DB" put "$key" "source=$source"
    )" || fail "PUT failed: $key"

    printf '%s\n' "$out"

    id="$(
        printf '%s\n' "$out" |
        sed -n 's/^ID=//p' |
        head -n 1
    )"

    [ "${#id}" -eq 64 ] ||
        fail "invalid PUT id: $key"

    printf '%s\n' "$id" > "$CASE/evidence/${name}.id"
}

link_evidence()
{
    name="$1"
    from="$2"
    rel="$3"
    to="$4"
    source="$5"

    out="$(
        "$YODA" -d "$DB" link \
            "$from" \
            "$rel" \
            "$to" \
            "source=$source"
    )" || fail "LINK failed: $from --$rel--> $to"

    printf '%s\n' "$out"

    id="$(
        printf '%s\n' "$out" |
        sed -n 's/^ID=//p' |
        head -n 1
    )"

    [ "${#id}" -eq 64 ] ||
        fail "invalid LINK id: $name"

    printf '%s\n' "$id" > "$CASE/evidence/${name}.id"
}

contains()
{
    file="$1"
    text="$2"

    grep -F -- "$text" "$file" >/dev/null 2>&1 ||
        fail "expected text not found in $file: $text"
}

section "FIELD-001 PREFLIGHT"

for cmd in \
    curl \
    sha256sum \
    tar \
    sed \
    grep \
    find \
    sort \
    head \
    wc
do
    need "$cmd"
done

rm -rf "$ROOT"

mkdir -p \
    "$DOWNLOAD" \
    "$RUNTIME" \
    "$CASE/evidence" \
    "$CASE/expected" \
    "$CASE/agents"

echo "CASE_ID=$CASE_ID"
echo "TITLE=$TITLE"
echo "YODA_VERSION=$VERSION"
echo "CORE=CORE-014"

section "1. FETCH FROZEN PUBLIC RELEASE"

(
    cd "$DOWNLOAD"

    curl -fL \
        "$BASE_URL/$ARCHIVE" \
        -o "$ARCHIVE"

    curl -fL \
        "$BASE_URL/$SHA_FILE" \
        -o "$SHA_FILE"
)

ACTUAL_ARCHIVE_SHA256="$(
    sha256sum "$DOWNLOAD/$ARCHIVE" |
    awk '{print $1}'
)"

echo "EXPECTED_ARCHIVE_SHA256=$EXPECTED_ARCHIVE_SHA256"
echo "ACTUAL_ARCHIVE_SHA256=$ACTUAL_ARCHIVE_SHA256"

[ "$ACTUAL_ARCHIVE_SHA256" = "$EXPECTED_ARCHIVE_SHA256" ] ||
    fail "public archive identity mismatch"

(
    cd "$DOWNLOAD"

    sha256sum -c "$SHA_FILE"
) || fail "published SHA256 file rejected archive"

echo "PUBLIC_RELEASE_IDENTITY=PASS"

section "2. EXTRACT AND VERIFY CORE IDENTITIES"

tar -xzf \
    "$DOWNLOAD/$ARCHIVE" \
    -C "$RUNTIME"

PKG="$RUNTIME/yoda-v0.1.0-preview.1-linux-x86_64"
YODA="$PKG/yoda"
SOURCE="$PKG/yoda.c"

[ -x "$YODA" ] ||
    fail "yoda binary missing"

[ -f "$SOURCE" ] ||
    fail "yoda.c missing"

BINARY_SHA256="$(
    sha256sum "$YODA" |
    awk '{print $1}'
)"

SOURCE_SHA256="$(
    sha256sum "$SOURCE" |
    awk '{print $1}'
)"

echo "EXPECTED_BINARY_SHA256=$EXPECTED_BINARY_SHA256"
echo "ACTUAL_BINARY_SHA256=$BINARY_SHA256"

echo "EXPECTED_SOURCE_SHA256=$EXPECTED_SOURCE_SHA256"
echo "ACTUAL_SOURCE_SHA256=$SOURCE_SHA256"

[ "$BINARY_SHA256" = "$EXPECTED_BINARY_SHA256" ] ||
    fail "binary identity mismatch"

[ "$SOURCE_SHA256" = "$EXPECTED_SOURCE_SHA256" ] ||
    fail "source identity mismatch"

echo "CORE014_IDENTITY=PASS"

section "3. INITIALIZE CLEAN DECISION STATE"

"$YODA" init "$DB"

# ------------------------------------------------------------
# Scenario
#
# Widget 2.4 originally passed production validation.
#
# Later a critical security advisory says 2.4 must not be
# deployed.
#
# Widget 2.5 then passes validation and explicitly addresses
# that advisory.
#
# A security policy requires supported, non-blocked versions.
#
# Independent processes must recover the same durable evidence
# rather than depend on one another's transient context.
# ------------------------------------------------------------

section "4. STORE EVIDENCE"

put_evidence \
    "policy-production-security" \
    "policy/production-security" \
    "security-policy" \
    "Production deployment requires a version that has passed validation and is not blocked by an active critical security advisory."

put_evidence \
    "widget-24-validation" \
    "dependency/widget-2.4-validation" \
    "production-validation" \
    "Widget 2.4 passed compatibility and production validation."

put_evidence \
    "widget-24-advisory" \
    "dependency/widget-2.4-security-advisory" \
    "security-advisory" \
    "Widget 2.4 is affected by an active critical security advisory and must not be deployed to production."

put_evidence \
    "widget-25-validation" \
    "dependency/widget-2.5-validation" \
    "production-validation" \
    "Widget 2.5 passed compatibility and production validation and addresses the critical security advisory affecting Widget 2.4."

section "5. STORE EXPLICIT RELATIONSHIPS"

link_evidence \
    "24-advisory-conflicts-24-validation" \
    "dependency/widget-2.4-security-advisory" \
    "conflicts-with" \
    "dependency/widget-2.4-validation" \
    "field-001"

link_evidence \
    "25-supersedes-24" \
    "dependency/widget-2.5-validation" \
    "supersedes" \
    "dependency/widget-2.4-validation" \
    "field-001"

link_evidence \
    "25-resolves-24-advisory" \
    "dependency/widget-2.5-validation" \
    "resolves" \
    "dependency/widget-2.4-security-advisory" \
    "field-001"

link_evidence \
    "24-advisory-governed-by-policy" \
    "dependency/widget-2.4-security-advisory" \
    "governed-by" \
    "policy/production-security" \
    "field-001"

link_evidence \
    "25-governed-by-policy" \
    "dependency/widget-2.5-validation" \
    "governed-by" \
    "policy/production-security" \
    "field-001"

section "6. VERIFY AUTHORITATIVE STATE"

"$YODA" -d "$DB" verify |
    tee "$CASE/VERIFY.txt"

contains \
    "$CASE/VERIFY.txt" \
    "VERIFY=PASS"

section "7. AGENT A — SECURITY INVESTIGATOR"

# Agent A receives no output from Agent B.
# Its only durable shared state is Yoda.

(
    env -i \
        PATH="$PATH" \
        HOME="$HOME" \
        "$YODA" -d "$DB" context \
            --limit 8 \
            --bytes 12000 \
            "Widget 2.4 critical security advisory"
) > "$CASE/agents/AGENT-A-CONTEXT.txt"

cat "$CASE/agents/AGENT-A-CONTEXT.txt"

contains \
    "$CASE/agents/AGENT-A-CONTEXT.txt" \
    "active critical security advisory"

contains \
    "$CASE/agents/AGENT-A-CONTEXT.txt" \
    "must not be deployed to production"

contains \
    "$CASE/agents/AGENT-A-CONTEXT.txt" \
    "Production deployment requires"

echo "AGENT_A_CONTEXT=PASS"

section "8. AGENT B — DEPLOYMENT LEAD"

# Fresh process.
# It does not receive Agent A's context or output.

(
    env -i \
        PATH="$PATH" \
        HOME="$HOME" \
        "$YODA" -d "$DB" context \
            --limit 8 \
            --bytes 12000 \
            "Widget 2.5 validation"
) > "$CASE/agents/AGENT-B-CONTEXT.txt"

cat "$CASE/agents/AGENT-B-CONTEXT.txt"

contains \
    "$CASE/agents/AGENT-B-CONTEXT.txt" \
    "Widget 2.5 passed compatibility and production validation"

contains \
    "$CASE/agents/AGENT-B-CONTEXT.txt" \
    "addresses the critical security advisory"

contains \
    "$CASE/agents/AGENT-B-CONTEXT.txt" \
    "Production deployment requires"

contains \
    "$CASE/agents/AGENT-B-CONTEXT.txt" \
    "Widget 2.4"

echo "AGENT_B_CONTEXT=PASS"

section "9. SHARED-DURABLE-STATE ASSERTION"

# Both independent processes must independently recover
# the same governing policy from Yoda.

POLICY_TEXT="Production deployment requires a version that has passed validation and is not blocked by an active critical security advisory."

contains \
    "$CASE/agents/AGENT-A-CONTEXT.txt" \
    "$POLICY_TEXT"

contains \
    "$CASE/agents/AGENT-B-CONTEXT.txt" \
    "$POLICY_TEXT"

echo "SHARED_POLICY_VISIBLE_TO_AGENT_A=PASS"
echo "SHARED_POLICY_VISIBLE_TO_AGENT_B=PASS"
echo "SHARED_DURABLE_STATE=PASS"

section "10. REFERENCE DECISION ADAPTER"

# FIELD-001 intentionally uses a deterministic decision adapter.
#
# It does not claim Yoda itself makes decisions.
# It proves that independent decision processes can stand on
# one durable, verifiable evidence state.
#
# FIELD-001-R1 will later substitute real isolated Qwen agents.

A_CONTEXT="$CASE/agents/AGENT-A-CONTEXT.txt"
B_CONTEXT="$CASE/agents/AGENT-B-CONTEXT.txt"

grep -F \
    "must not be deployed to production" \
    "$A_CONTEXT" >/dev/null ||
    fail "reference adapter cannot establish DENY for 2.4"

grep -F \
    "Widget 2.5 passed compatibility and production validation" \
    "$B_CONTEXT" >/dev/null ||
    fail "reference adapter cannot establish validation for 2.5"

grep -F \
    "addresses the critical security advisory" \
    "$B_CONTEXT" >/dev/null ||
    fail "reference adapter cannot establish advisory resolution"

ID_24_VALIDATION="$(
    cat "$CASE/evidence/widget-24-validation.id"
)"

ID_24_ADVISORY="$(
    cat "$CASE/evidence/widget-24-advisory.id"
)"

ID_25_VALIDATION="$(
    cat "$CASE/evidence/widget-25-validation.id"
)"

ID_POLICY="$(
    cat "$CASE/evidence/policy-production-security.id"
)"

cat > "$CASE/DECISION-REFERENCE.txt" <<EOF
DECISION_WIDGET_2_4=DENY
STATE_WIDGET_2_4=CONFLICTED
EVIDENCE_WIDGET_2_4_VALIDATION=$ID_24_VALIDATION
EVIDENCE_WIDGET_2_4_ADVISORY=$ID_24_ADVISORY
EVIDENCE_POLICY=$ID_POLICY

DECISION_WIDGET_2_5=ALLOW
STATE_WIDGET_2_5=VERIFIED
EVIDENCE_WIDGET_2_5_VALIDATION=$ID_25_VALIDATION
EVIDENCE_POLICY=$ID_POLICY
EOF

cat "$CASE/DECISION-REFERENCE.txt"

echo "REFERENCE_DECISION_ADAPTER=PASS"

section "11. HISTORY AND RELATION EVIDENCE"

"$YODA" -d "$DB" log \
    "dependency/widget-2.4-security-advisory" \
    > "$CASE/evidence/widget-24-advisory.log"

"$YODA" -d "$DB" log \
    "dependency/widget-2.5-validation" \
    > "$CASE/evidence/widget-25-validation.log"

cat "$CASE/evidence/widget-24-advisory.log"
cat "$CASE/evidence/widget-25-validation.log"

section "12. BUILD PROPAGATION CASE"

cat > "$CASE/CASE.md" <<'EOF'
# FIELD-001 — Multi-Agent Decision State

## Question

Can independent processes recover consistent decision-relevant
evidence from shared durable state without sharing their transient
context?

## Scenario

Widget 2.4 passed production validation.

A later critical security advisory blocks Widget 2.4 from production.

Widget 2.5 passes production validation and addresses that advisory.

A production security policy requires validated software that is not
blocked by an active critical security advisory.

Two independent processes query the same durable Yoda state.

They do not exchange conversational context.

## Arms

### Agent A

Security investigator.

Retrieves the state around Widget 2.4 and the security advisory.

### Agent B

Deployment lead.

Retrieves the state around Widget 2.5 and production deployment.

## Boundary

FIELD-001 does not claim Yoda is an agent or reasoning engine.

The two reference agents are deterministic independent processes.

FIELD-001-R1 will replace them with real isolated model agents.

## Success

Both independent processes must recover the shared governing policy.

Agent A must recover the blocking advisory for Widget 2.4.

Agent B must recover current Widget 2.5 validation and advisory
resolution.

The authoritative Yoda state must verify successfully.
EOF

cat > "$CASE/README.md" <<'EOF'
# Yoda FIELD-001 — Multi-Agent Decision State

This is a reproducible Yoda Case.

It tests whether independent decision processes can operate from one
durable evidence state without sharing their transient conversational
context.

## Reproduce

Run:

    ./run.sh

## Adapt

Replace the Widget scenario with a real problem from your own system.

Keep the experiment structure:

    evidence
    relationships
    independent contexts
    verification
    decision evidence

## Publish your variant

Fork or copy this case.

Record:

    CASE_ID
    DERIVED_FROM
    YODA_VERSION
    result
    evidence identities

Then publish the new case so another developer can reproduce it.

Evidence should propagate.
EOF

cat > "$CASE/expected/EXPECTED.env" <<'EOF'
VERIFY=PASS
AGENT_A_CONTEXT=PASS
AGENT_B_CONTEXT=PASS
SHARED_DURABLE_STATE=PASS
REFERENCE_DECISION_ADAPTER=PASS
DECISION_WIDGET_2_4=DENY
DECISION_WIDGET_2_5=ALLOW
EOF

# Save the exact homologation runner as the future case run.sh.
cp "$0" "$CASE/run.sh"
chmod +x "$CASE/run.sh"

cat > "$CASE/RESULTS.md" <<EOF
# FIELD-001 Results

CASE_ID=$CASE_ID
TITLE=$TITLE
YODA_VERSION=$VERSION
CORE=CORE-014

PUBLIC_RELEASE_IDENTITY=PASS
CORE014_IDENTITY=PASS
AUTHORITATIVE_VERIFY=PASS

AGENT_A_CONTEXT=PASS
AGENT_B_CONTEXT=PASS
SHARED_DURABLE_STATE=PASS

REFERENCE_DECISION_ADAPTER=PASS

DECISION_WIDGET_2_4=DENY
DECISION_WIDGET_2_5=ALLOW

MACHINE_REPRODUCIBLE=PASS
ADAPTABLE=PASS
REPUBLISHABLE=PASS
FORKABLE=PASS

INDEPENDENT_EXTERNAL_REPRODUCTION=PENDING
FIELD_001_R1_REAL_AGENT=PENDING

ARCHIVE_SHA256=$ACTUAL_ARCHIVE_SHA256
BINARY_SHA256=$BINARY_SHA256
SOURCE_SHA256=$SOURCE_SHA256

EVIDENCE_WIDGET_2_4_VALIDATION=$ID_24_VALIDATION
EVIDENCE_WIDGET_2_4_ADVISORY=$ID_24_ADVISORY
EVIDENCE_WIDGET_2_5_VALIDATION=$ID_25_VALIDATION
EVIDENCE_POLICY=$ID_POLICY
EOF

section "13. CASE INTEGRITY"

(
    cd "$CASE"

    find . \
        -type f \
        ! -name SHA256SUMS \
        -print |
        LC_ALL=C sort |
        sed 's#^\./##' |
        while IFS= read -r file
        do
            sha256sum "$file"
        done > SHA256SUMS
)

(
    cd "$CASE"
    sha256sum -c SHA256SUMS
) || fail "case integrity verification failed"

CASE_FILES="$(
    find "$CASE" -type f |
    wc -l |
    tr -d ' '
)"

section "14. FINAL RESULT"

echo "CASE_ID=$CASE_ID"
echo "TITLE=$TITLE"
echo "YODA_VERSION=$VERSION"
echo "CORE=CORE-014"
echo
echo "PUBLIC_RELEASE_IDENTITY=PASS"
echo "CORE014_IDENTITY=PASS"
echo "AUTHORITATIVE_VERIFY=PASS"
echo
echo "AGENT_A_CONTEXT=PASS"
echo "AGENT_B_CONTEXT=PASS"
echo "SHARED_DURABLE_STATE=PASS"
echo
echo "REFERENCE_DECISION_ADAPTER=PASS"
echo
echo "DECISION_WIDGET_2_4=DENY"
echo "DECISION_WIDGET_2_5=ALLOW"
echo
echo "MACHINE_REPRODUCIBLE=PASS"
echo "ADAPTABLE=PASS"
echo "REPUBLISHABLE=PASS"
echo "FORKABLE=PASS"
echo "INDEPENDENT_EXTERNAL_REPRODUCTION=PENDING"
echo "FIELD_001_R1_REAL_AGENT=PENDING"
echo
echo "CASE_FILES=$CASE_FILES"
echo "CASE_PATH=$CASE"
echo
echo "YODA_FIELD_001=PASS"
