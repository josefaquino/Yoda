#define _POSIX_C_SOURCE 200809L
#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define CAP 4096
#define MAX_SOURCES 32

typedef struct {char id[256], resource[CAP];} Source;
typedef struct {
    char type[80],claim[CAP],quote[CAP],source[256],contributor[256];
    char confidence[64],review[64];
    int human_verified;
    Source sources[MAX_SOURCES]; size_t nsources;
} Heuristic;

static int errors=0;
static void failure(const char *file,const char *why) {
    fprintf(stderr,"TRUST_INVALID | %s | %s\n",file,why);++errors;
}
static char *strip(char *s) {
    while(isspace((unsigned char)*s)) s++;
    size_t n=strlen(s);
    while(n && isspace((unsigned char)s[n-1]))s[--n]=0;
    return s;
}
static void unquote(char *s){
    size_t n=strlen(s);
    if(n>1 && ((s[0]=='"'&&s[n-1]=='"')||(s[0]=='\''&&s[n-1]=='\''))){
        memmove(s,s+1,n-2);s[n-2]=0;
    }
}
static int setfield(char *dst,size_t cap,char *v) {
    v=strip(v);unquote(v);
    if(strlen(v)>=cap)return -1;
    strcpy(dst,v);return 0;
}
static void put(char *out,size_t cap,const char *src,const char *key,const char *file) {
    if(setfield(out,cap,(char*)src)<0){
        failure(file,key);out[0]=0;
    }
}
static int present_local(const char *bundle,const char *ref,char *full,size_t size){
    if(strncmp(ref,"/references/",12)!=0 || strstr(ref,"..") || strstr(ref,"//") || strchr(ref,'\\'))return 0;
    if(snprintf(full,size,"%s%s",bundle,ref)>=(int)size)return 0;
    struct stat st;return lstat(full,&st)==0 && S_ISREG(st.st_mode);
}
static int quote_exists(const char *path,const char *quote){
    FILE *f=fopen(path,"r");if(!f)return 0;
    char *line=NULL;size_t cap=0;int found=0;
    while(getline(&line,&cap,f)!=-1){if(strstr(line,quote)){found=1;break;}}
    free(line);fclose(f);return found;
}
static int read_heuristic(const char *file,Heuristic *h){
    FILE *f=fopen(file,"r");if(!f){failure(file,"cannot read heuristic");return 0;}
    char *line=NULL;size_t cap=0;ssize_t len;int front=0,seen=0,in_verify=0,in_sources=0;
    while((len=getline(&line,&cap,f))!=-1){
        if(memchr(line,'\0',(size_t)len)){failure(file,"NUL byte");break;}
        char *s=strip(line);if(!seen){seen=1;if(strcmp(s,"---")){failure(file,"missing YAML frontmatter");break;}front=1;continue;}
        if(!front||!strcmp(s,"---"))break;
        int indent=0;while(line[indent]==' ')indent++;
        /* strip() above advances a pointer but does not modify leading spaces. */
        if(indent==0){in_verify=!strncmp(s,"verified:",9);in_sources=!strncmp(s,"sources:",8);}
        if(in_verify && indent>0 && strstr(s,"human:"))h->human_verified=1;
        char *key=s;if(!strncmp(key,"- ",2))key+=2;
        char *colon=strchr(key,':');if(!colon)continue;*colon=0;
        char *v=strip(colon+1);key=strip(key);
        if(indent==0){
            if(!strcmp(key,"type"))put(h->type,sizeof h->type,v,key,file);
            else if(!strcmp(key,"claim"))put(h->claim,sizeof h->claim,v,key,file);
            else if(!strcmp(key,"quote"))put(h->quote,sizeof h->quote,v,key,file);
            else if(!strcmp(key,"source"))put(h->source,sizeof h->source,v,key,file);
            else if(!strcmp(key,"contributor"))put(h->contributor,sizeof h->contributor,v,key,file);
            else if(!strcmp(key,"confidence"))put(h->confidence,sizeof h->confidence,v,key,file);
            else if(!strcmp(key,"review_status"))put(h->review,sizeof h->review,v,key,file);
        } else if(in_sources){
            if(indent==2 && !strcmp(key,"id")){
                if(h->nsources>=MAX_SOURCES){failure(file,"too many sources");break;}
                Source *z=&h->sources[h->nsources++];
                put(z->id,sizeof z->id,v,"source id",file);
            }else if(indent==4 && !strcmp(key,"resource") && h->nsources){
                Source *z=&h->sources[h->nsources-1];
                put(z->resource,sizeof z->resource,v,"source resource",file);
            }
        }
    }
    free(line);fclose(f);return 1;
}
static int check_heuristic(const char *bundle,const char *name){
    char file[CAP];if(snprintf(file,sizeof file,"%s/heuristics/%s",bundle,name)>=(int)sizeof file)return 0;
    Heuristic h={0};if(!read_heuristic(file,&h))return 0;
    int old=errors;
    if(strcmp(h.type,"Heuristic"))failure(file,"type must be Heuristic");
    if(!*h.claim||!*h.quote||!*h.contributor||!*h.source||!*h.confidence||!*h.review)failure(file,"incomplete claim contract");
    if(strcmp(h.review,"confirmed"))failure(file,"heuristic not confirmed: not admissible for this release");
    if(!h.human_verified)failure(file,"human verification missing");
    if(strcmp(h.confidence,"high") && strcmp(h.confidence,"medium") && strcmp(h.confidence,"low"))failure(file,"invalid confidence");
    const char *resource=NULL;
    for(size_t i=0;i<h.nsources;i++)if(!strcmp(h.sources[i].id,h.source)){
        resource=h.sources[i].resource;break;
    }
    if(!resource)failure(file,"source id has no source receipt");
    else {
        char sourcefile[CAP];
        if(!present_local(bundle,resource,sourcefile,sizeof sourcefile))failure(file,"source reference missing/unsafe/not local");
        else if(*h.quote && !quote_exists(sourcefile,h.quote))failure(file,"literal quote not found in referenced source");
    }
    if(errors==old)printf("CLAIM=CONFIRMED FILE=heuristics/%s SOURCE=%s QUOTE=VERIFIED\n",name,h.source);
    return errors==old;
}
static int check_learned(const char *bundle,unsigned *pending,unsigned *rejected){
    char file[CAP];if(snprintf(file,sizeof file,"%s/learned.md",bundle)>=(int)sizeof file)return 0;
    FILE *f=fopen(file,"r");if(!f){failure(file,"cannot read learned.md");return 0;}
    char *line=NULL;size_t cap=0;int seen=0,front=0,in_claims=0,active=0;
    char review[64]="";int reject_reason=0;unsigned total=0;
    while(getline(&line,&cap,f)!=-1){
        int indent=0;while(line[indent]==' ')indent++;
        char *s=strip(line);
        if(!seen){seen=1;if(strcmp(s,"---")){failure(file,"missing frontmatter");break;}front=1;continue;}
        if(!front || !strcmp(s,"---"))break;
        if(indent==0)in_claims=!strcmp(s,"proposed_claims:");
        if(!in_claims)continue;
        if(indent==2 && !strncmp(s,"- claim:",8)){
            if(active){
                if(!strcmp(review,"pending")){++*pending;printf("CLAIM=PENDING AUTHORITY=HYPOTHESIS_ONLY\n");}
                else if(!strcmp(review,"rejected") && reject_reason){++*rejected;printf("CLAIM=REJECTED AUTHORITY=NONE\n");}
                else failure(file,"invalid proposed claim review status/rejection reason");
            }
            ++total;active=1;review[0]=0;reject_reason=0;
        }else if(active && indent==4){
            char *colon=strchr(s,':');if(!colon)continue;*colon=0;
            char *key=strip(s),*v=strip(colon+1);
            if(!strcmp(key,"review_status"))put(review,sizeof review,v,"review_status",file);
            if(!strcmp(key,"rejection_reason") && *v)reject_reason=1;
        }
    }
    if(active){
        if(!strcmp(review,"pending")){++*pending;printf("CLAIM=PENDING AUTHORITY=HYPOTHESIS_ONLY\n");}
        else if(!strcmp(review,"rejected") && reject_reason){++*rejected;printf("CLAIM=REJECTED AUTHORITY=NONE\n");}
        else failure(file,"invalid proposed claim review status/rejection reason");
    }
    if(!total)failure(file,"no proposed claims found");
    free(line);fclose(f);return errors==0;
}
int main(int argc,char **argv){
    if(argc!=2){fprintf(stderr,"Usage: %s BUNDLE_DIR\n",argv[0]);return 2;}
    const char *bundle=argv[1];char dir[CAP];
    if(snprintf(dir,sizeof dir,"%s/heuristics",bundle)>=(int)sizeof dir)return 2;
    DIR *d=opendir(dir);if(!d){perror("heuristics");return 2;}
    struct dirent *ent;unsigned confirmed=0,pending=0,rejected=0;
    while((ent=readdir(d))){
        size_t n=strlen(ent->d_name);
        if(n<4 || strcmp(ent->d_name+n-3,".md"))continue;
        if(strchr(ent->d_name,'/'))continue;
        confirmed+=(unsigned)check_heuristic(bundle,ent->d_name);
    }
    closedir(d);
    check_learned(bundle,&pending,&rejected);
    if(!confirmed)failure(bundle,"no confirmed heuristics verified");
    if(errors){printf("OKF_TRUST=FAIL ERRORS=%d\n",errors);return 1;}
    printf("OKF_TRUST=PASS CONFIRMED=%u PENDING=%u REJECTED=%u\n",confirmed,pending,rejected);
    puts("NOTE=Metadata human review is not independently authenticated; no live telemetry checked");
    return 0;
}
