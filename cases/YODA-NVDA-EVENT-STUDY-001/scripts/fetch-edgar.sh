#!/bin/sh
# Read-only SEC download of NVIDIA revenue concept + accession submissions.
# Requires SEC_USER_AGENT='Your Name your-contact@example.com'
set -eu
: "${SEC_USER_AGENT:?Set SEC_USER_AGENT='Full Name real-email@example.com' locally; do not commit it}"
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT="$ROOT/data/raw/edgar"
mkdir -p "$OUT"
umask 077
command -v curl >/dev/null 2>&1 || exit 2
command -v sha256sum >/dev/null 2>&1 || exit 2

download() {
  url=$1
  name=$2
  tmp="$OUT/$name.part"
  rm -f "$tmp"
  if ! curl -fLsS --retry 2 --retry-delay 3 --max-time 90 \
    -A "$SEC_USER_AGENT" -H 'Accept: application/json' \
    -o "$tmp" "$url"; then
      rm -f "$tmp"
      echo "SEC_DOWNLOAD_FAILED=$name" >&2
      exit 2
  fi
  if ! grep -Eq '"cik"[[:space:]]*:[[:space:]]*"?0*1045810"?' "$tmp"; then
    rm -f "$tmp"
    echo "SEC_IDENTITY_FAILED=$name" >&2
    exit 2
  fi
  if [ "$name" = "revenue-concept.json" ] &&
      ! grep -q 'RevenueFromContractWithCustomerExcludingAssessedTax' "$tmp"; then
    rm -f "$tmp"
    echo "SEC_CONCEPT_FAILED=$name" >&2
    exit 2
  fi
  mv "$tmp" "$OUT/$name"
  sha256sum "$OUT/$name"
  echo "SEC_RAW_OK=$name"
}
download 'https://data.sec.gov/api/xbrl/companyconcept/CIK0001045810/us-gaap/RevenueFromContractWithCustomerExcludingAssessedTax.json' 'revenue-concept.json'
sleep 1
download 'https://data.sec.gov/submissions/CIK0001045810.json' 'submissions.json'
printf "SOURCE_EDGAR=PASS\nRAW_JSON_WRITTEN=%s\n" "$OUT"
