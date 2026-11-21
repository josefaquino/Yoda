/* Standalone C11 JSON extractor for Nasdaq public historical responses.
   Validation-first: fail closed on null, schema drift or malformed rows.
   No dependency except libc and libm. */
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <math.h>
#define MAX_INPUT (32u*1024u*1024u)
#define MAX_DEPTH 100
#define MAX_TOKENS 300000
typedef struct { int type; size_t lo,hi; int first,next; } Tok;
enum {OBJECT=1,ARRAY,STRING,ATOM};
typedef struct { char *s; size_t n,p; Tok *t; int count,cap,error; } Parser;
static void ws(Parser *p){while(p->p<p->n && isspace((unsigned char)p->s[p->p]))p->p++;}
static int add(Parser *p,int typ,size_t lo){
 if(p->count>=MAX_TOKENS){p->error=1;return -1;}
 if(p->count==p->cap){int cap=p->cap?p->cap*2:2048;Tok*tmp=realloc(p->t,(size_t)cap*sizeof(*tmp));if(!tmp){p->error=1;return -1;}p->t=tmp;p->cap=cap;}
 int j=p->count++;p->t[j]=(Tok){typ,lo,0,-1,-1};return j;
}
static int parse(Parser*p,int depth);
static int parse_string(Parser*p){
 if(p->p>=p->n||p->s[p->p]!='"'){p->error=1;return -1;}
 p->p++;int idx=add(p,STRING,p->p);if(idx<0)return -1;
 while(p->p<p->n){
  unsigned char c=(unsigned char)p->s[p->p++];
  if(c=='"'){p->t[idx].hi=p->p-1;return idx;}
  if(c<32){p->error=1;return -1;}
  if(c=='\\'){
   if(p->p>=p->n){p->error=1;return -1;}
   c=(unsigned char)p->s[p->p++];
   if(c=='u'){for(int i=0;i<4;i++){if(p->p>=p->n||!isxdigit((unsigned char)p->s[p->p++])){p->error=1;return -1;}}}
   else if(!strchr("\"\\/bfnrt",c)){p->error=1;return -1;}
  }
 }
 p->error=1;return -1;
}
static int parse(Parser*p,int depth){
 if(depth>MAX_DEPTH){p->error=1;return -1;}
 ws(p);if(p->p>=p->n){p->error=1;return -1;}
 char ch=p->s[p->p];if(ch=='"')return parse_string(p);
 if(ch=='{'||ch=='['){
  int obj=ch=='{';int idx=add(p,obj?OBJECT:ARRAY,p->p++);if(idx<0)return -1;
  int last=-1;ws(p);
  if(p->p<p->n&&p->s[p->p]==(obj?'}':']')){p->p++;p->t[idx].hi=p->p;return idx;}
  for(;;){
   int key=-1,val;
   if(obj){key=parse_string(p);if(key<0)return -1;ws(p);if(p->p==p->n||p->s[p->p++]!=':'){p->error=1;return -1;}}
   val=parse(p,depth+1);if(val<0)return -1;
   if(obj){
    if(last<0)p->t[idx].first=key;else p->t[last].next=key;
    p->t[key].next=val;last=val;
   }else{
    if(last<0)p->t[idx].first=val;else p->t[last].next=val;
    last=val;
   }
   ws(p);if(p->p>=p->n){p->error=1;return -1;}
   char c=p->s[p->p++];if(c==(obj?'}':']'))break;
   if(c!=','){p->error=1;return -1;}
   ws(p);
  }
  p->t[idx].hi=p->p;return idx;
 }
 int idx=add(p,ATOM,p->p);if(idx<0)return -1;
 while(p->p<p->n&&!isspace((unsigned char)p->s[p->p])&&!strchr(",]}:",p->s[p->p]))p->p++;
 if(p->p==p->t[idx].lo){p->error=1;return -1;}
 p->t[idx].hi=p->p;return idx;
}
static int eq(Parser*p,int tok,const char*s){return tok>=0&&p->t[tok].type==STRING&&strlen(s)==p->t[tok].hi-p->t[tok].lo&&!memcmp(p->s+p->t[tok].lo,s,strlen(s));}
static int field(Parser*p,int obj,const char*key){
 if(obj<0||p->t[obj].type!=OBJECT)return -1;
 for(int i=p->t[obj].first;i>=0;){int v=p->t[i].next;if(v<0)return -1;if(eq(p,i,key))return v;i=p->t[v].next;}
 return -1;
}
static int is_null(Parser*p,int t){return t<0||(p->t[t].type==ATOM&&p->t[t].hi-p->t[t].lo==4&&!memcmp(p->s+p->t[t].lo,"null",4));}
static int extract(Parser*p,int t,char*dest,size_t cap){
 if(t<0||(p->t[t].type!=STRING&&p->t[t].type!=ATOM))return 0;
 size_t z=p->t[t].hi-p->t[t].lo;if(z>=cap||z==0)return 0;
 memcpy(dest,p->s+p->t[t].lo,z);dest[z]=0;
 if(strchr(dest,'\\'))return 0;
 return 1;
}
static int decimal(Parser*p,int t,int isvolume,double*out){
 char buf[128],clean[128];if(!extract(p,t,buf,sizeof(buf)))return 0;
 size_t j=0;int dots=0,digits=0;
 for(size_t i=0;buf[i];i++){
  char c=buf[i];if(c=='$'&&i==0&&!isvolume)continue;
  if(c==',')continue;
  if(c=='.'&&!isvolume&&dots++==0){clean[j++]=c;continue;}
  if(c>='0'&&c<='9'){clean[j++]=c;digits++;continue;}
  return 0;
 }
 if(!digits)return 0;
 clean[j]=0;errno=0;char*end;double x=strtod(clean,&end);
 if(errno||*end||!isfinite(x)||x<0||(!isvolume&&x==0))return 0;
 *out=x;return 1;
}
static int leap(int y){return y%4==0&&(y%100!=0||y%400==0);}
static int dateparse(Parser*p,int t,int*ymd,char iso[11]){
 char tmp[64];int m,d,y,n=0;if(!extract(p,t,tmp,sizeof(tmp)))return 0;
 if(sscanf(tmp,"%2d/%2d/%4d%n",&m,&d,&y,&n)!=3||tmp[n])return 0;
 if(y<1990||y>2100||m<1||m>12)return 0;
 const int md[]={0,31,28,31,30,31,30,31,31,30,31,30,31};int days=md[m]+(m==2&&leap(y));
 if(d<1||d>days)return 0;
 *ymd=y*10000+m*100+d;
 iso[0]=(char)('0'+y/1000);iso[1]=(char)('0'+(y/100)%10);iso[2]=(char)('0'+(y/10)%10);iso[3]=(char)('0'+y%10);iso[4]='-';
 iso[5]=(char)('0'+m/10);iso[6]=(char)('0'+m%10);iso[7]='-';iso[8]=(char)('0'+d/10);iso[9]=(char)('0'+d%10);iso[10]=0;return 1;
}
typedef struct {int ymd;char day[11];double open,high,low,close,volume;} Bar;
static int cmp(const void*a,const void*b){const Bar*x=a,*y=b;return (x->ymd>y->ymd)-(x->ymd<y->ymd);}
static int row(Parser*p,int i,Bar*b){
 if(p->t[i].type!=OBJECT)return 0;
 int close=field(p,i,"close");if(close<0)close=field(p,i,"close/last");
 if(!dateparse(p,field(p,i,"date"),&b->ymd,b->day)||
 !decimal(p,field(p,i,"open"),0,&b->open)||
 !decimal(p,field(p,i,"high"),0,&b->high)||
 !decimal(p,field(p,i,"low"),0,&b->low)||
 !decimal(p,close,0,&b->close)||
 !decimal(p,field(p,i,"volume"),1,&b->volume))return 0;
 if(b->high<b->low||b->high<b->open||b->high<b->close||b->low>b->open||b->low>b->close)return 0;
 return 1;
}
int main(int argc,char**argv){
 if(argc!=2){fprintf(stderr,"USAGE: %s RAW_NASDAQ.json\n",argv[0]);return 2;}
 FILE*f=fopen(argv[1],"rb");if(!f){perror("open");return 2;}
 if(fseek(f,0,SEEK_END)||ftell(f)<0){perror("size");fclose(f);return 2;}
 long size=ftell(f);rewind(f);
 if(size==0||(unsigned long)size>MAX_INPUT){fprintf(stderr,"INVALID_JSON_SIZE\n");fclose(f);return 2;}
 Parser p={0};p.n=(size_t)size;p.s=malloc(p.n+1);if(!p.s){fclose(f);return 2;}
 if(fread(p.s,1,p.n,f)!=p.n){fprintf(stderr,"SHORT_JSON_READ\n");fclose(f);free(p.s);return 2;}fclose(f);p.s[p.n]=0;
 int root=parse(&p,0);ws(&p);
 if(p.error||root<0||p.p!=p.n||p.t[root].type!=OBJECT){fprintf(stderr,"INVALID_JSON\n");free(p.s);free(p.t);return 2;}
 int data=field(&p,root,"data"),table=field(&p,data,"tradesTable"),rows=field(&p,table,"rows");
 if(is_null(&p,data)||rows<0||p.t[rows].type!=ARRAY){fprintf(stderr,"NASDAQ_DATA_NULL_OR_SCHEMA_DRIFT\n");free(p.s);free(p.t);return 3;}
 size_t cap=2048,n=0;Bar*b=malloc(cap*sizeof(*b));if(!b){free(p.s);free(p.t);return 2;}
 for(int t=p.t[rows].first;t>=0;t=p.t[t].next){
  if(n==cap){cap*=2;Bar*tmp=realloc(b,cap*sizeof(*b));if(!tmp){free(b);free(p.s);free(p.t);return 2;}b=tmp;}
  if(!row(&p,t,&b[n])){fprintf(stderr,"INVALID_NASDAQ_ROW row=%zu\n",n+1);free(b);free(p.s);free(p.t);return 4;}
  n++;
 }
 if(n<2){fprintf(stderr,"INSUFFICIENT_NASDAQ_ROWS %zu\n",n);free(b);free(p.s);free(p.t);return 3;}
 qsort(b,n,sizeof(*b),cmp);
 for(size_t i=1;i<n;i++)if(b[i].ymd<=b[i-1].ymd){fprintf(stderr,"DUPLICATE_NASDAQ_DATE %s\n",b[i].day);free(b);free(p.s);free(p.t);return 4;}
 puts("Date,Open,High,Low,Close,Volume");
 for(size_t i=0;i<n;i++)printf("%s,%.6f,%.6f,%.6f,%.6f,%.0f\n",b[i].day,b[i].open,b[i].high,b[i].low,b[i].close,b[i].volume);
 fprintf(stderr,"NASDAQ_ROWS_VALID=%zu FIRST=%s LAST=%s\n",n,b[0].day,b[n-1].day);
 free(b);free(p.s);free(p.t);return 0;
}
