#define _POSIX_C_SOURCE 200809L
#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define PATH_CAP 2048
#define MAX_DOCS 256

typedef struct {
    char path[PATH_CAP];
    char type[80];
    char title[512];
    char resource[PATH_CAP];
    char tags[1024];
    char status[40];
    int trust_window;
    int verified;
} Doc;

static Doc docs[MAX_DOCS];
static size_t n_docs;
static char root[PATH_CAP];
static unsigned errors;

static void die(const char *message) {
    fprintf(stderr, "ERROR: %s\n", message);
    exit(2);
}
static void issue(const char *doc, const char *problem, const char *value) {
    fprintf(stderr, "INVALID | %s | %s | %s\n", doc, problem, value);
    ++errors;
}
static char *trim(char *s) {
    while (isspace((unsigned char)*s)) ++s;
    size_t n = strlen(s);
    while (n && isspace((unsigned char)s[n-1])) s[--n] = '\0';
    return s;
}
static void unpack(char *s) {
    s = trim(s);
    size_t n = strlen(s);
    if (n >= 2 && ((s[0] == '"' && s[n-1] == '"') ||
                   (s[0] == '\'' && s[n-1] == '\''))) {
        memmove(s, s+1, n-2);
        s[n-2] = '\0';
    }
}
static void copyfield(char *dest, size_t cap, char *src) {
    src = trim(src);
    unpack(src);
    if (strlen(src) >= cap) die("metadata field too long");
    strcpy(dest, src);
}
static int keyvalue(char *line, char **key, char **val, int *depth) {
    int d=0;
    while (line[d] == ' ') ++d;
    *depth = d;
    char *s = line+d;
    if (s[0] == '-' && s[1] == ' ') s+=2;
    char *colon=strchr(s, ':');
    if (!colon) return 0;
    *colon='\0';
    *key=trim(s);
    *val=trim(colon+1);
    return 1;
}
static void join_file(char *out, size_t cap, const char *rel) {
    if (snprintf(out,cap,"%s/%s",root,rel) >= (int)cap) die("path too long");
}
static int safe_resource(const char *s) {
    if (s[0]!='/' || s[1]=='\0') return 0;
    if (strstr(s,"//") || strstr(s,"/../") || strstr(s,"/./") ||
        strcmp(s,"/..") == 0 || strchr(s,'\\') || strchr(s,'?') || strchr(s,'#')) return 0;
    for (const unsigned char *p=(const unsigned char*)s; *p; ++p)
        if (!isalnum(*p) && !strchr("/-_.",*p)) return 0;
    return 1;
}
static void local_ref(const char *file, const char *ref) {
    if (ref[0] != '/') return;
    if (!safe_resource(ref)) { issue(file,"unsafe bundle path",ref); return; }
    char target[PATH_CAP];
    join_file(target,sizeof target,ref+1);
    struct stat st;
    if (lstat(target,&st) != 0 || !S_ISREG(st.st_mode))
        issue(file,"unresolved local reference",ref);
}
static void scan_doc(Doc *doc) {
    char full[PATH_CAP]; join_file(full,sizeof full,doc->path);
    FILE *f=fopen(full,"r");
    if (!f) die("cannot read bundle file");
    char *line=NULL; size_t cap=0; ssize_t len;
    int started=0, front=0;
    while ((len=getline(&line,&cap,f)) != -1) {
        if (memchr(line,'\0',(size_t)len)) die("NUL inside OKF file");
        char *s=trim(line);
        if (!started) {
            started=1;
            if (strcmp(s,"---") == 0) {front=1; continue;}
            break;
        }
        if (!front) break;
        if (strcmp(s,"---") == 0) break;
        /* Restore no indentation needed for top-level detection: first nonspace
           character of the original line before trim was consumed. Instead,
           frontmatter keys tracked by checking source input in separate pass. */
        char *key=NULL,*val=NULL; int depth=0;
        if (!keyvalue(s,&key,&val,&depth)) continue;
        if (strcmp(key,"type")==0 && !*doc->type) copyfield(doc->type,sizeof doc->type,val);
        if (strcmp(key,"title")==0 && !*doc->title) copyfield(doc->title,sizeof doc->title,val);
        if (strcmp(key,"resource")==0 && !*doc->resource) {
            /* first resource is document's own identifier */
            copyfield(doc->resource,sizeof doc->resource,val);
        }
        if (strcmp(key,"tags")==0 && !*doc->tags) copyfield(doc->tags,sizeof doc->tags,val);
        if (strcmp(key,"status")==0 && !*doc->status) copyfield(doc->status,sizeof doc->status,val);
        if (strcmp(key,"trust_window_minutes")==0) doc->trust_window=atoi(val);
        if (strcmp(key,"verified")==0) doc->verified=1;
    }
    free(line); fclose(f);
    if (!*doc->status) strcpy(doc->status,"stable");
}
static void add_file(const char *rel) {
    if (n_docs>=MAX_DOCS) die("too many OKF files");
    Doc *d=&docs[n_docs++];
    memset(d,0,sizeof *d);
    if (snprintf(d->path,sizeof d->path,"%s",rel) >= (int)sizeof d->path) die("path too long");
    scan_doc(d);
}
static void walk(const char *rel) {
    char dirpath[PATH_CAP]; join_file(dirpath,sizeof dirpath,rel);
    DIR *d=opendir(dirpath);
    if (!d) die("cannot read directory");
    struct dirent *e;
    while ((e=readdir(d))) {
        if (strcmp(e->d_name,".")==0 || strcmp(e->d_name,"..")==0) continue;
        char child[PATH_CAP],full[PATH_CAP];
        if (*rel) {
            if (snprintf(child,sizeof child,"%s/%s",rel,e->d_name) >= (int)sizeof child) die("path too long");
        } else if (snprintf(child,sizeof child,"%s",e->d_name) >= (int)sizeof child) die("path too long");
        join_file(full,sizeof full,child);
        struct stat st;
        if (lstat(full,&st)) die("cannot stat bundle entry");
        if (S_ISDIR(st.st_mode)) walk(child);
        else if (S_ISREG(st.st_mode)) {
            size_t len=strlen(child);
            if (len>=3 && strcmp(child+len-3,".md")==0) add_file(child);
        }
        /* Symlinks ignored: no traversal outside the provided bundle. */
    }
    closedir(d);
}
static int cmpdoc(const void *a,const void *b) {
    return strcmp(((const Doc*)a)->path,((const Doc*)b)->path);
}
static int has_tag(const Doc *d,const char *tag) {
    if (strcmp(d->type,"Asset")!=0) return 0;
    char tmp[sizeof d->tags]; strcpy(tmp,d->tags);
    char *s=tmp;
    if (*s=='[') ++s;
    char *end=strchr(s,']'); if(end) *end='\0';
    while (s && *s) {
        char *comma=strchr(s,','); if (comma) *comma='\0';
        char *v=trim(s); unpack(v);
        if (strcmp(v,tag)==0) return 1;
        s=comma?comma+1:NULL;
    }
    return 0;
}
static void print_relations(const char *resource) {
    char full[PATH_CAP]; join_file(full,sizeof full,"relations.md");
    FILE *f=fopen(full,"r");
    if (!f) return;
    char *line=NULL; size_t cap=0;
    char from[PATH_CAP]="",to[PATH_CAP]="",type[64]="";
    int front=0,started=0;
    while (getline(&line,&cap,f)!=-1) {
        char *s=trim(line);
        if (!started) {started=1;front=strcmp(s,"---")==0;continue;}
        if (front && strcmp(s,"---")==0) break;
        char *key=NULL,*val=NULL;int depth=0;
        if (!keyvalue(s,&key,&val,&depth))continue;
        if (strcmp(key,"from")==0) {
            if (*from && *to && *type &&
                (strcmp(from,resource)==0 || strcmp(to,resource)==0))
                printf("RELATION=%s %s %s\n",from,type,to);
            copyfield(from,sizeof from,val); *to='\0';*type='\0';
        } else if (*from && strcmp(key,"to")==0) copyfield(to,sizeof to,val);
        else if (*from && strcmp(key,"type")==0) copyfield(type,sizeof type,val);
    }
    if (*from && *to && *type &&
        (strcmp(from,resource)==0 || strcmp(to,resource)==0))
        printf("RELATION=%s %s %s\n",from,type,to);
    free(line); fclose(f);
}
static void show_sources_and_links(const Doc *d) {
    char full[PATH_CAP]; join_file(full,sizeof full,d->path);
    FILE *f=fopen(full,"r"); if(!f)die("cannot read asset");
    char *line=NULL;size_t cap=0;
    int front=0,started=0,in_sources=0;
    char id[256]="";
    while (getline(&line,&cap,f)!=-1) {
        char *start=line;
        int indentation=0;
        while (start[indentation]==' ') ++indentation;
        char *s=trim(start);
        if (!started) {started=1;front=strcmp(s,"---")==0;continue;}
        if(front && strcmp(s,"---")==0) {front=0;continue;}
        if(front) {
            if(indentation==0) in_sources=(strcmp(s,"sources:")==0);
            if(in_sources) {
                char *key=NULL,*val=NULL;int depth=0;
                if(keyvalue(s,&key,&val,&depth)) {
                    if(strcmp(key,"id")==0) copyfield(id,sizeof id,val);
                    else if(strcmp(key,"resource")==0 && *id) {
                        char r[PATH_CAP];copyfield(r,sizeof r,val);
                        printf("SOURCE=%s -> %s\n",id,r);
                        *id='\0';
                    }
                }
            }
        } else {
            char *p=s;
            while ((p=strstr(p,"](/"))!=NULL) {
                p+=2;
                char *end=strchr(p,')'); if(!end)break;
                size_t n=(size_t)(end-p);
                if(n>1 && n<PATH_CAP) {
                    char val[PATH_CAP];memcpy(val,p,n);val[n]='\0';
                    printf("LINK=%s\n",val);
                }
                p=end+1;
            }
        }
    }
    free(line);fclose(f);
}
static void inspect_asset(const char *tag) {
    const Doc *found=NULL;
    for (size_t i=0;i<n_docs;i++) if (has_tag(&docs[i],tag)) {
        if (found) die("ambiguous asset tag");
        found=&docs[i];
    }
    if (!found) {fprintf(stderr,"NOT_FOUND | asset tag %s\n",tag);exit(3);}
    printf("ASSET=%s\nTITLE=%s\nRESOURCE=%s\nSTATUS=%s\n",
           tag,found->title,found->resource,found->status);
    printf("HUMAN_VERIFIED=%s\n",found->verified?"YES_METADATA":"NOT_RECORDED");
    if(found->trust_window>0)printf("TRUST_WINDOW_MINUTES=%d\n",found->trust_window);
    show_sources_and_links(found);
    print_relations(found->resource);
    puts("LIVE_SENSOR_STATE=NOT_AVAILABLE_IN_OKF");
}
static void check_bundle(void) {
    for(size_t i=0;i<n_docs;i++) {
        const Doc *d=&docs[i];
        if(strcmp(d->path,"index.md")==0 || strcmp(d->path,"log.md")==0) continue;
        if(!*d->type || !*d->title || !*d->resource)
            issue(d->path,"missing concept metadata","type/title/resource");
        else {
            char expected[PATH_CAP];
            if(snprintf(expected,sizeof expected,"/%s",d->path)>=(int)sizeof expected)die("path too long");
            if(strcmp(expected,d->resource)!=0)issue(d->path,"resource mismatch",d->resource);
        }
        char full[PATH_CAP];join_file(full,sizeof full,d->path);
        FILE *f=fopen(full,"r");if(!f)die("cannot open document for validation");
        char *line=NULL;size_t cap=0;int front=0,started=0;
        while(getline(&line,&cap,f)!=-1) {
            char *s=trim(line);
            if(!started){started=1;front=strcmp(s,"---")==0;continue;}
            if(front && strcmp(s,"---")==0){front=0;continue;}
            if(front) {
                char *key=NULL,*val=NULL;int depth=0;
                if(!keyvalue(s,&key,&val,&depth))continue;
                if(strcmp(key,"resource")==0 || strcmp(key,"from")==0 ||
                   strcmp(key,"to")==0 || strcmp(key,"canonical")==0) {
                    unpack(val);local_ref(d->path,val);
                }
            } else {
                char *p=s;
                while((p=strstr(p,"](/"))!=NULL) {
                    p+=2;char *end=strchr(p,')');if(!end)break;
                    size_t n=(size_t)(end-p);
                    if(n>1 && n<PATH_CAP) {
                        char val[PATH_CAP];memcpy(val,p,n);val[n]='\0';
                        local_ref(d->path,val);
                    }
                    p=end+1;
                }
            }
        }
        free(line);fclose(f);
    }
    if (errors) {printf("OKF_CHECK=FAIL ERRORS=%u\n",errors);exit(1);}
    printf("OKF_CHECK=PASS FILES=%zu\n",n_docs);
}
static void inventory(void) {
    static const char *types[]={"Asset","Heuristic","Policy","Reference","Relations","Skill","Tag Directory"};
    printf("BUNDLE_FILES=%zu\n",n_docs);
    for(size_t k=0;k<sizeof(types)/sizeof(types[0]);k++) {
        unsigned count=0;
        for(size_t j=0;j<n_docs;j++) if(strcmp(docs[j].type,types[k])==0) ++count;
        printf("TYPE=%s COUNT=%u\n",types[k],count);
    }
    for(size_t j=0;j<n_docs;j++) printf("FILE=%s TYPE=%s\n",docs[j].path,*docs[j].type?docs[j].type:"(metadata)");
}
int main(int argc,char **argv) {
    if(argc<3 || argc>4 || (strcmp(argv[1],"inspect")==0 && argc!=4) ||
       (strcmp(argv[1],"inspect")!=0 && argc!=3)) {
        fprintf(stderr,"Usage: %s inventory|check BUNDLE_DIR\n       %s inspect BUNDLE_DIR ASSET_TAG\n",argv[0],argv[0]);
        return 2;
    }
    struct stat st;
    if(snprintf(root,sizeof root,"%s",argv[2])>=(int)sizeof root)die("bundle path too long");
    if(stat(root,&st)!=0 || !S_ISDIR(st.st_mode))die("bundle directory not found");
    walk("");qsort(docs,n_docs,sizeof docs[0],cmpdoc);
    if(strcmp(argv[1],"inventory")==0)inventory();
    else if(strcmp(argv[1],"check")==0)check_bundle();
    else if(strcmp(argv[1],"inspect")==0)inspect_asset(argv[3]);
    else die("unknown command");
    return 0;
}
