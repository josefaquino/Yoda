BEGIN{FS="\t";OFS="\t";rows=0;hd=hn=hv=0}
function bad(c){exit c}
function fixed4(s,sign,b,a,k,w,f){sign=1;b=s;if(substr(b,1,1)=="+")b=substr(b,2);else if(substr(b,1,1)=="-"){sign=-1;b=substr(b,2)}if(b!~/^[0-9]+([.][0-9]+)?$/)bad(20);k=split(b,a,".");w=a[1]+0;f=(k==2?a[2]:"");if(length(f)>4)bad(21);while(length(f)<4)f=f"0";if(f=="")f="0000";return sign*(w*10000+(f+0))}
NR==1{if($0!="evaluation_date\tseries_id\tobservation_date\tvintage_date\tvalue\tunits")bad(22);next}
{if(NF!=6)bad(23);if(length($1)!=10)bad(24);if(date=="")date=$1;else if(date!=$1)bad(25);x=fixed4($5);if($2=="DGS10"){if(hd||$6!="percent")bad(26);d=x;hd=1}else if($2=="NFCI"){if(hn||$6!="index")bad(27);n=x;hn=1}else if($2=="VIXCLS"){if(hv||$6!="index")bad(28);v=x;hv=1}else bad(29);rows++}
END{if(rows!=3||!hd||!hn||!hv)exit 30;rf=(d>=40000?1:0);nf=(n>=0?1:0);vf=(v>=200000?1:0);score=rf+nf+vf;if(score==0)lab="CALM";else if(score==1)lab="FRAGILE";else lab="STRESSED";print state,date,d,n,v,rf,nf,vf,score,lab}
