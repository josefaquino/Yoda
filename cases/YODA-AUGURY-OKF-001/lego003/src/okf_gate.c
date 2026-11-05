#define _POSIX_C_SOURCE 200809L
#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PATH_CAP 4096
#define ID_CAP 128

typedef enum { UNKNOWN, CONFIRMED, PENDING, REJECTED } Review;

static char *trim(char *s) {
    while (isspace((unsigned char)*s)) ++s;
    size_t n = strlen(s);
    while (n && isspace((unsigned char)s[n-1])) s[--n] = '\0';
    return s;
}

static int starts(const char *s, const char *p) {
    return strncmp(s, p, strlen(p)) == 0;
}

static Review parse_review(const char *s) {
    if (!strcmp(s, "confirmed")) return CONFIRMED;
    if (!strcmp(s, "pending")) return PENDING;
    if (!strcmp(s, "rejected")) return REJECTED;
    return UNKNOWN;
}

static const char *review_text(Review r) {
    switch(r) {
      case CONFIRMED: return "CONFIRMED";
      case PENDING: return "PENDING";
      case REJECTED: return "REJECTED";
      default: return "UNKNOWN";
    }
}

static int path_join(char *out, size_t n, const char *bundle, const char *relative) {
    int r = snprintf(out,n,"%s/%s",bundle,relative);
    return r >= 0 && (size_t)r < n;
}

/* Conservative small scanner for the known Northfield frontmatter shape. */
static int read_window(const char *bundle, long *window) {
    char path[PATH_CAP];
    if (!path_join(path,sizeof path,bundle,"assets/slurry-charge-pump-101a.md")) return 0;
    FILE *f=fopen(path,"r"); if(!f)return 0;
    char *line=NULL;size_t cap=0;ssize_t len;int delimiters=0,found=0;
    while((len=getline(&line,&cap,f))!=-1){
        if(memchr(line,'\0',(size_t)len))break;
        char *s=trim(line);
        if(!strcmp(s,"---")){if(++delimiters==2)break;continue;}
        if(delimiters!=1)continue;
        if(starts(s,"trust_window_minutes:")){
            if(found++)break;
            s=trim(s+strlen("trust_window_minutes:"));
            errno=0;char *end=NULL;long v=strtol(s,&end,10);
            if(errno || end==s || *trim(end) || v<=0 || v>1000000)break;
            *window=v;
        }
    }
    free(line);fclose(f);
    return delimiters==2 && found==1 && *window>0;
}

static int read_heuristic(const char *bundle,const char *relative,Review *review){
    char path[PATH_CAP];if(!path_join(path,sizeof path,bundle,relative))return 0;
    FILE *f=fopen(path,"r");if(!f)return 0;
    char *line=NULL;size_t cap=0;ssize_t len;int delim=0,count=0;
    Review candidate=UNKNOWN;
    while((len=getline(&line,&cap,f))!=-1){
        if(memchr(line,'\0',(size_t)len))break;
        char *s=trim(line);
        if(!strcmp(s,"---")){if(++delim==2)break;continue;}
        if(delim!=1)continue;
        if(starts(s,"review_status:")){
            count++;
            candidate=parse_review(trim(s+strlen("review_status:")));
        }
    }
    free(line);fclose(f);
    if(delim!=2 || count!=1 || candidate==UNKNOWN)return 0;
    *review=candidate;return 1;
}

static int read_learned(const char *bundle,Review *a,Review *b){
    char path[PATH_CAP];if(!path_join(path,sizeof path,bundle,"learned.md"))return 0;
    FILE *f=fopen(path,"r");if(!f)return 0;
    char *line=NULL;size_t cap=0;ssize_t len;int delim=0,active=0,claims=0;
    int reasons[2]={0,0};Review v[2]={UNKNOWN,UNKNOWN};
    while((len=getline(&line,&cap,f))!=-1){
        if(memchr(line,'\0',(size_t)len))break;
        int indent=0;while(line[indent]==' ')indent++;
        char *s=trim(line);
        if(!strcmp(s,"---")){if(++delim==2)break;continue;}
        if(delim!=1)continue;
        if(indent==0 && !strcmp(s,"proposed_claims:")){active=1;continue;}
        if(indent==0 && active){active=0;continue;}
        if(!active)continue;
        if(indent==2 && starts(s,"- claim:")){
            if(++claims>2)break;
        }else if(claims>0 && claims<=2 && indent==4){
            if(starts(s,"review_status:"))v[claims-1]=parse_review(trim(s+strlen("review_status:")));
            else if(starts(s,"rejection_reason:")){
                if(*trim(s+strlen("rejection_reason:")))reasons[claims-1]=1;
            }
        }
    }
    free(line);fclose(f);
    if(delim!=2 || claims!=2 || v[0]!=PENDING || v[1]!=REJECTED || !reasons[1])return 0;
    *a=v[0];*b=v[1];return 1;
}

static int evaluate(const char *id,const char *claim,long age,long window,Review cold,Review settle,Review pending,Review rejected){
    Review r=UNKNOWN;
    if(!strcmp(claim,"cold-start"))r=cold;
    else if(!strcmp(claim,"settle"))r=settle;
    else if(!strcmp(claim,"pending"))r=pending;
    else if(!strcmp(claim,"rejected"))r=rejected;
    else return 0;
    if(r==UNKNOWN)return 0;
    const char *fresh=age<=window?"FRESH_ASSUMED":"STALE_ASSUMED";
    const char *decision = (r==REJECTED) ? "IGNORE_CLAIM" :
        (r==PENDING) ? "HYPOTHESIS_ONLY" :
        (age>window) ? "ADVISORY_ONLY" : "CONTEXT_ELIGIBLE_FOR_HUMAN_REVIEW";
    printf("SCENARIO=%s CLAIM=%s REVIEW=%s READING=%s WINDOW_MIN=%ld DECISION=%s CONTROL_ACTION=FORBIDDEN DATA=SIMULATED\n",
           id,claim,review_text(r),fresh,window,decision);
    return 1;
}

int main(int argc,char **argv){
    if(argc!=3){fprintf(stderr,"usage: %s BUNDLE_DIR SCENARIOS_TSV\n",argv[0]);return 2;}
    long window=0;Review cold=UNKNOWN,settle=UNKNOWN,pending=UNKNOWN,rejected=UNKNOWN;
    if(!read_window(argv[1],&window)
       ||!read_heuristic(argv[1],"heuristics/pump-101a-cold-start.md",&cold)
       ||!read_heuristic(argv[1],"heuristics/clarifier-settling-phase.md",&settle)
       ||!read_learned(argv[1],&pending,&rejected)){
       fprintf(stderr,"GATE=FAIL reason=missing_or_invalid_okf_policy_or_review_metadata\n");return 1;
    }
    FILE *f=fopen(argv[2],"r");if(!f){perror("scenarios");return 2;}
    char *line=NULL;size_t cap=0;ssize_t len;unsigned rows=0;int failure=0;
    while((len=getline(&line,&cap,f))!=-1){
       if(memchr(line,'\0',(size_t)len)){failure=1;break;}
       char *s=trim(line);if(!*s || *s=='#')continue;
       char *f1=s;char *p=strchr(f1,'\t');if(!p){failure=1;break;}*p++='\0';
       char *f2=p;p=strchr(f2,'\t');if(!p){failure=1;break;}*p++='\0';
       char *f3=p;if(strchr(f3,'\t')){failure=1;break;}
       f1=trim(f1);f2=trim(f2);f3=trim(f3);
       if(!*f1||strlen(f1)>=ID_CAP){failure=1;break;}
       for(const char *q=f1;*q;q++) if(!isalnum((unsigned char)*q) && *q!='-' && *q!='_'){failure=1;break;}
       if(failure)break;
       errno=0;char *end=NULL;long age=strtol(f3,&end,10);
       if(errno||end==f3||*end||age<0||age>1000000 ||!evaluate(f1,f2,age,window,cold,settle,pending,rejected)){
           failure=1;break;
       }
       rows++;
    }
    free(line);if(ferror(f))failure=1;fclose(f);
    if(failure || !rows){fprintf(stderr,"GATE=FAIL reason=invalid_scenario_tsv\n");return 1;}
    printf("OKF_GATE=PASS SCENARIOS=%u TELEMETRY=NOT_CONNECTED HUMAN_CONTROL=REQUIRED\n",rows);
    return 0;
}
