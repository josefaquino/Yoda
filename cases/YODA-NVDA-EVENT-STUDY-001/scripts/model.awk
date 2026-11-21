# POSIX awk. NVDA daily returns ~ alpha + beta_QQQ*QQQ + beta_SOXX*SOXX.
BEGIN{FS=OFS="\t"}
NR==1{next}
{
 if($1>="2025-06-02"&&$1<="2026-06-23"){
  n++;y=$2;x=$3;z=$4
  sy+=y;sx+=x;sz+=z;sxx+=x*x;szz+=z*z;sxz+=x*z;sxy+=x*y;szy+=z*y
  cal_y[n]=y;cal_x[n]=x;cal_z[n]=z
 }
 if($1>="2026-06-24"&&$1<="2026-11-20"){m++;date[m]=$1;ty[m]=$2;tx[m]=$3;tz[m]=$4}
}
END{
 if(n<180||m<90){printf "INSUFFICIENT_DATA training=%d study=%d\n",n,m > "/dev/stderr";exit 2}
 xx=sxx-sx*sx/n;zz=szz-sz*sz/n;xz=sxz-sx*sz/n;xy=sxy-sx*sy/n;zy=szy-sz*sy/n
 det=xx*zz-xz*xz;if(det<=1e-16){print "COLLINEAR_FACTOR_MODEL" > "/dev/stderr";exit 3}
 bq=(xy*zz-zy*xz)/det;bs=(zy*xx-xy*xz)/det;a=sy/n-bq*sx/n-bs*sz/n
 for(i=1;i<=n;i++){e=cal_y[i]-a-bq*cal_x[i]-bs*cal_z[i];rss+=e*e}
 rmse=sqrt(rss/(n-3))
 print "metric","value" > model_file
 printf "training_days\t%d\nstudy_days\t%d\nalpha\t%.10f\nbeta_qqq\t%.10f\nbeta_soxx\t%.10f\ntraining_residual_sd\t%.10f\n",n,m,a,bq,bs,rmse >> model_file
 print "date","nvda_return","qqq_return","soxx_return","expected","abnormal","cum_abnormal" > abnormal_file
 for(i=1;i<=m;i++){expected=a+bq*tx[i]+bs*tz[i];abnormal=ty[i]-expected;car+=abnormal;printf "%s\t%.10f\t%.10f\t%.10f\t%.10f\t%.10f\t%.10f\n",date[i],ty[i],tx[i],tz[i],expected,abnormal,car >> abnormal_file}
 printf "MODEL_OK training=%d study=%d beta_qqq=%.4f beta_soxx=%.4f\n",n,m,bq,bs
}
