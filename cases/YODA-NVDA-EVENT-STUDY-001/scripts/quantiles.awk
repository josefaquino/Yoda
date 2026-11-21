# Sorted terminal prices, one price per line.
BEGIN{FS=OFS="\t";if(spot<=0){print "INVALID_SPOT" > "/dev/stderr";exit 2}}
{
 if($1 !~ /^[0-9]+([.][0-9]+)?$/||$1<=0){print "INVALID_SIMULATION" > "/dev/stderr";exit 2}
 if(n&&$1<p[n]){print "NOT_SORTED" > "/dev/stderr";exit 2}
 p[++n]=$1+0
 if($1<spot)below++
 if($1<=spot*.9)drop10++
 if($1>=spot*1.1)gain10++
}
function pct(q,idx){idx=int(q*n+.999999);if(idx<1)idx=1;if(idx>n)idx=n;return p[idx]}
END{
 if(n<100){print "INSUFFICIENT_SIMULATIONS" > "/dev/stderr";exit 2}
 print "metric","value"
 printf "p05\t%.4f\np10\t%.4f\np50\t%.4f\np90\t%.4f\np95\t%.4f\n",pct(.05),pct(.10),pct(.50),pct(.90),pct(.95)
 printf "prob_below_spot\t%.6f\nprob_loss_10pct\t%.6f\nprob_gain_10pct\t%.6f\n",below/n,drop10/n,gain10/n
 print "sample_count",n
}
