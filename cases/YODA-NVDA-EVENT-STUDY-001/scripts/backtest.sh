#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
input=data/normalized/prices-wide.tsv
[ -s "$input" ] || { echo "MISSING_INPUT=$input" >&2; exit 2; }
mkdir -p results/forecast
out=results/forecast/backtest.tsv
origins=results/forecast/.origins.tsv
awk -F '\t' 'NR>1{n++;d[n]=$1;p[n]=$2} END{for(i=180;i+60<=n;i+=20) if(d[i]>="2026-01-01" && d[i]<="2026-08-31") printf "%s\t%s\t%.8f\t%.8f\n",d[i],d[i+60],p[i],p[i+60]}' "$input" > "$origins"
[ -s "$origins" ] || { echo "NO_BACKTEST_ORIGINS" >&2; exit 2; }
printf 'origin\ttarget\tspot\tactual\tp10\tp50\tp90\tcovered80\tmodel_abs_pct_error\tnaive_abs_pct_error\n' > "$out"
while IFS="$(printf '\t')" read -r origin target spot actual; do
 awk -v asof="$origin" -v horizon=60 -v sims=2000 -v seed=20261120 -v lookback=100 -f scripts/forecast.awk "$input" | awk 'NR>1{print $2}' | LC_ALL=C sort -n > results/forecast/.backtest-samples.txt
 awk -v spot="$spot" -f scripts/quantiles.awk results/forecast/.backtest-samples.txt > results/forecast/.backtest-quantiles.tsv
 awk -F '\t' -v O="$origin" -v T="$target" -v S="$spot" -v A="$actual" '
 $1=="p10"{q10=$2} $1=="p50"{q50=$2} $1=="p90"{q90=$2}
 END{m=q50-A;if(m<0)m=-m;n=S-A;if(n<0)n=-n;printf "%s\t%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%d\t%.6f\t%.6f\n",O,T,S,A,q10,q50,q90,(A>=q10&&A<=q90),m/A,n/A}' results/forecast/.backtest-quantiles.tsv >> "$out"
done < "$origins"
rm -f "$origins" results/forecast/.backtest-samples.txt results/forecast/.backtest-quantiles.tsv
awk -F '\t' 'NR>1{n++;cov+=$8;mod+=$9;naive+=$10}END{if(!n)exit 2;printf "BACKTEST=PASS\nORIGINS=%d\nCOVERAGE_80=%.4f\nMODEL_MAPE=%.4f\nNAIVE_MAPE=%.4f\n",n,cov/n,mod/n,naive/n}' "$out" > results/forecast/backtest-report.txt
cat results/forecast/backtest-report.txt
