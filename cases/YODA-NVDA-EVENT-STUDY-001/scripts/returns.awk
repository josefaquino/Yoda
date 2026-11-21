# POSIX awk. Input: date, NVDA, QQQ, SOXX tab-separated, including header.
BEGIN { FS=OFS="\t"; print "date", "nvda", "qqq", "soxx" }
NR==1 {next}
{
 if($2<=0||$3<=0||$4<=0){print "BAD_PRICE " $1 > "/dev/stderr";exit 2}
 if(have)printf "%s\t%.10f\t%.10f\t%.10f\n",$1,$2/prev_n-1,$3/prev_q-1,$4/prev_s-1
 prev_n=$2;prev_q=$3;prev_s=$4;have=1
}
