#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
quotes=${1:-options/quotes.tsv}
terminal=results/forecast/terminal-samples.tsv
meta=results/forecast/model-metadata.tsv
[ -s "$quotes" ] && [ -s "$terminal" ] && [ -s "$meta" ] || { echo "NO_TRADE=YES REASON=NEED_FORECAST_AND_VERIFIED_OPTION_QUOTES"; exit 2; }
asof=$(awk -F '\t' '$1=="asof"{print $2}' "$meta")
[ "$asof" = "2026-11-20" ] || { echo "NO_TRADE=YES REASON=FORECAST_ORIGIN_MISMATCH"; exit 2; }
awk -F '\t' '
NR==1 {if($1!="contract"||$2!="bid"||$3!="ask"||$4!="quote_time_utc") exit 2;next}
($1=="NVDA270219P00125000"||$1=="NVDA270219P00105000"){
 if($2 !~ /^[0-9]+([.][0-9]+)?$/||$3 !~ /^[0-9]+([.][0-9]+)?$/||$2<=0||$3<$2||$4 !~ /^2026-11-20T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z$/)exit 2
 if($1=="NVDA270219P00125000"){longask=$3;timestamp=$4;l++}
 if($1=="NVDA270219P00105000"){shortbid=$2;timestamp2=$4;s++}
}
END{if(l!=1||s!=1||timestamp!=timestamp2||longask-shortbid<=0||longask-shortbid>=20)exit 2;printf "%.8f\n",longask-shortbid}
' "$quotes" > results/forecast/.debit.part || { rm -f results/forecast/.debit.part; echo "NO_TRADE=YES REASON=INVALID_OR_STALE_OPTION_QUOTES"; exit 2; }
debit=$(cat results/forecast/.debit.part)
rm -f results/forecast/.debit.part
awk -F '\t' -v d="$debit" '
NR==1 {next}
{p=$2+0;payoff=125-p;if(payoff<0)payoff=0;hedge=105-p;if(hedge<0)hedge=0;net=payoff-hedge-d;sum+=net;n++;if(net>0)wins++}
END{if(n<100)exit 2;printf "STRATEGY=BEAR_PUT_DEBIT_SPREAD\nEXPIRY=2027-02-19\nLONG_PUT_STRIKE=125\nSHORT_PUT_STRIKE=105\nDEBIT_PER_SHARE=%.4f\nMAX_LOSS_PER_100_SHARES=%.2f\nMAX_GAIN_PER_100_SHARES=%.2f\nBREAKEVEN=%.4f\nMODEL_EXPECTED_PNL_PER_100_SHARES=%.2f\nMODEL_PROFIT_PROB=%.4f\nASSUMPTION=EXPIRY_INTRINSIC_ONLY_EXCLUDES_FEES_AND_ASSIGNMENT\n",d,100*d,100*(20-d),125-d,100*sum/n,wins/n}
' "$terminal" | tee results/forecast/options-assessment.txt
