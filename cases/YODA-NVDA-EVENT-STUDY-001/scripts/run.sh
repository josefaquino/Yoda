#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
for c in awk sort sha256sum;do command -v "$c" >/dev/null 2>&1 || {echo "MISSING_COMMAND=$c" >&2;exit 1;};done
mkdir -p data/normalized results evidence
: > data/normalized/prices-long.tsv
for symbol in NVDA QQQ SOXX;do
 raw="data/raw/$symbol.csv"
 [ -s "$raw" ] || {echo "MISSING_DATA=$raw" >&2;exit 1;}
 awk -F, -v name="$symbol" '
 BEGIN{OFS="\t"}
 NR==1{gsub(/\r/,"",$0);if($1!="Date"||$5!="Close")exit 2;next}
 {gsub(/\r/,"",$0);if($1 !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/||($5+0)<=0){print "INVALID_RECORD " name " " NR > "/dev/stderr";exit 2}print $1,name,$5}
 ' "$raw" >> data/normalized/prices-long.tsv
done
LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2,2 data/normalized/prices-long.tsv > data/normalized/prices-long.sorted.tsv
awk -F '\t' '{k=$1 SUBSEP $2;if(seen[k]++){print "DUPLICATE_PRICE " $1 " " $2 > "/dev/stderr";bad=1}}END{exit bad}' data/normalized/prices-long.sorted.tsv
printf 'date\tNVDA\tQQQ\tSOXX\n' > data/normalized/prices-wide.tsv
awk -F '\t' '
function flush(){if(day!=""&&have_n&&have_q&&have_s)printf "%s\t%.10f\t%.10f\t%.10f\n",day,n,q,s}
{if($1!=day){flush();day=$1;have_n=have_q=have_s=0}
if($2=="NVDA"){n=$3;have_n=1}if($2=="QQQ"){q=$3;have_q=1}if($2=="SOXX"){s=$3;have_s=1}}
END{flush()}
' data/normalized/prices-long.sorted.tsv >> data/normalized/prices-wide.tsv
awk -f scripts/returns.awk data/normalized/prices-wide.tsv > data/normalized/daily-returns.tsv
awk -v model_file=results/model.tsv -v abnormal_file=results/abnormal-returns.tsv -f scripts/model.awk data/normalized/daily-returns.tsv
sha256sum data/raw/NVDA.csv data/raw/QQQ.csv data/raw/SOXX.csv scripts/*.awk scripts/*.sh > evidence/MANIFEST.sha256
printf 'RUN_COMPLETE=YES\nWINDOW_START=2026-06-24\nWINDOW_END=2026-11-20\n'
