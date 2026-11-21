# POSIX awk. Forecast via de-meaned block bootstrap, EWMA volatility.
BEGIN {
 FS=OFS="\t"
 if(asof=="")asof="2026-11-20"
 if(horizon=="")horizon=60
 if(sims=="")sims=10000
 if(lookback=="")lookback=100
 if(seed=="")seed=20261120
 if(block=="")block=5
 if(lambda=="")lambda=.94
 if(horizon<1||horizon>260||sims<100||sims>100000||lookback<40||block<1||block>20||lambda<=0||lambda>=1){print "INVALID_MODEL_PARAMETERS" > "/dev/stderr";exit 2}
 srand(seed)
}
NR==1 {if($1!="date"||$2!="NVDA"){print "BAD_PRICE_HEADER" > "/dev/stderr";exit 2};next}
$1<=asof {
 if($1 !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/||$2 !~ /^[0-9]+([.][0-9]+)?$/||$2<=0){print "INVALID_PRICE_ROW " NR > "/dev/stderr";exit 2}
 if(n&&$1<=date[n]){print "NONINCREASING_DATES" > "/dev/stderr";exit 2}
 n++;date[n]=$1;price[n]=$2+0
}
END {
 if(n<81){print "INSUFFICIENT_TRAINING_PRICES " n > "/dev/stderr";exit 2}
 if(date[n]!=asof){print "ASOF_NOT_A_TRADING_DAY " asof " LAST=" date[n] > "/dev/stderr";exit 2}
 nr=n-1;first=nr-lookback+1;if(first<1)first=1
 count=nr-first+1
 if(count<60){print "INSUFFICIENT_RETURNS" > "/dev/stderr";exit 2}
 for(i=1;i<=nr;i++)lr[i]=log(price[i+1]/price[i])
 for(i=first;i<=nr;i++)mean+=lr[i]
 mean/=count
 for(i=first;i<=nr;i++)ss+=(lr[i]-mean)^2
 hist_sd=sqrt(ss/(count-1))
 if(hist_sd<1e-12){print "ZERO_VOLATILITY" > "/dev/stderr";exit 2}
 w=1;sw=0;sv=0
 for(i=nr;i>=first;i--){sw+=w;sv+=w*(lr[i]-mean)^2;w*=lambda}
 ewma_sd=sqrt(sv/sw);scale=ewma_sd/hist_sd
 if(scale>3)scale=3
 if(scale<.33)scale=.33
 spot=price[n]
 print "simulation","terminal_price","terminal_return"
 for(j=1;j<=sims;j++){
  lp=log(spot)
  for(k=0;k<horizon;){
   start=first+int(rand()*(count-block+1))
   for(b=0;b<block&&k<horizon;b++){lp+=(lr[start+b]-mean)*scale;k++}
  }
  terminal=exp(lp)
  printf "%d\t%.8f\t%.10f\n",j,terminal,terminal/spot-1
 }
 if(metadata_file!=""){
  print "metric","value" > metadata_file
  print "asof",asof >> metadata_file
  printf "spot\t%.8f\n",spot >> metadata_file
  print "horizon_sessions",horizon >> metadata_file
  print "simulations",sims >> metadata_file
  print "lookback_returns",count >> metadata_file
  print "block_sessions",block >> metadata_file
  print "random_seed",seed >> metadata_file
  printf "historical_daily_sd\t%.10f\newma_daily_sd\t%.10f\nvolatility_scale\t%.8f\nassumed_daily_drift\t0\n",hist_sd,ewma_sd,scale >> metadata_file
  print "model","zero-drift EWMA-scaled historical block bootstrap" >> metadata_file
  close(metadata_file)
 }
}
