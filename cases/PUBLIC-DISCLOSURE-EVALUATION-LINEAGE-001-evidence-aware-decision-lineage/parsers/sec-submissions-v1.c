#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char **v;
    size_t n;
} StrVec;

static char *read_all(const char *path, size_t *len_out)
{
    FILE *fp = fopen(path, "rb");
    long n;
    char *buf;

    if (!fp) return NULL;
    if (fseek(fp, 0, SEEK_END) != 0) { fclose(fp); return NULL; }
    n = ftell(fp);
    if (n < 0) { fclose(fp); return NULL; }
    if (fseek(fp, 0, SEEK_SET) != 0) { fclose(fp); return NULL; }

    buf = malloc((size_t)n + 1);
    if (!buf) { fclose(fp); return NULL; }

    if (n > 0 && fread(buf, 1, (size_t)n, fp) != (size_t)n) {
        free(buf);
        fclose(fp);
        return NULL;
    }

    buf[n] = '\0';
    fclose(fp);
    *len_out = (size_t)n;
    return buf;
}

static const char *skip_ws(const char *p)
{
    while (*p && isspace((unsigned char)*p)) p++;
    return p;
}

static char *parse_string(const char **pp)
{
    const char *p = *pp;
    size_t cap = 64, n = 0;
    char *out;

    if (*p != '"') return NULL;
    p++;

    out = malloc(cap);
    if (!out) return NULL;

    while (*p && *p != '"') {
        unsigned char ch = (unsigned char)*p++;

        if (ch == '\\') {
            ch = (unsigned char)*p++;
            switch (ch) {
            case '"': case '\\': case '/': break;
            case 'b': ch = '\b'; break;
            case 'f': ch = '\f'; break;
            case 'n': ch = '\n'; break;
            case 'r': ch = '\r'; break;
            case 't': ch = '\t'; break;
            case 'u':
                if (!isxdigit((unsigned char)p[0]) ||
                    !isxdigit((unsigned char)p[1]) ||
                    !isxdigit((unsigned char)p[2]) ||
                    !isxdigit((unsigned char)p[3])) {
                    free(out);
                    return NULL;
                }
                p += 4;
                ch = '?';
                break;
            default:
                free(out);
                return NULL;
            }
        }

        if (n + 2 > cap) {
            char *tmp;
            cap *= 2;
            tmp = realloc(out, cap);
            if (!tmp) { free(out); return NULL; }
            out = tmp;
        }

        out[n++] = (char)ch;
    }

    if (*p != '"') { free(out); return NULL; }
    p++;

    out[n] = '\0';
    *pp = p;
    return out;
}

static const char *find_key(const char *json, const char *key)
{
    size_t kn = strlen(key);
    size_t pn = kn + 3;
    char *pat = malloc(pn);
    const char *p;

    if (!pat) return NULL;
    pat[0] = '"';
    memcpy(pat + 1, key, kn);
    pat[kn + 1] = '"';
    pat[kn + 2] = '\0';

    p = strstr(json, pat);
    free(pat);
    return p;
}

static int extract_string_array(const char *json, const char *key, StrVec *out)
{
    const char *p = find_key(json, key);
    size_t cap = 32;

    out->v = NULL;
    out->n = 0;

    if (!p) return 0;

    p = strchr(p, ':');
    if (!p) return 0;
    p = skip_ws(p + 1);
    if (*p != '[') return 0;
    p++;

    out->v = calloc(cap, sizeof(char *));
    if (!out->v) return 0;

    for (;;) {
        char *s;

        p = skip_ws(p);

        if (*p == ']') {
            p++;
            return 1;
        }

        if (*p != '"') return 0;

        s = parse_string(&p);
        if (!s) return 0;

        if (out->n == cap) {
            char **tmp;
            cap *= 2;
            tmp = realloc(out->v, cap * sizeof(char *));
            if (!tmp) { free(s); return 0; }
            out->v = tmp;
        }

        out->v[out->n++] = s;

        p = skip_ws(p);
        if (*p == ',') {
            p++;
            continue;
        }
        if (*p == ']') {
            p++;
            return 1;
        }
        return 0;
    }
}

static void free_vec(StrVec *v)
{
    size_t i;
    for (i = 0; i < v->n; i++) free(v->v[i]);
    free(v->v);
    v->v = NULL;
    v->n = 0;
}

static int ends_with(const char *s, const char *suffix)
{
    size_t ns = strlen(s), nt = strlen(suffix);
    if (nt > ns) return 0;
    return strcmp(s + ns - nt, suffix) == 0;
}

static int mode_rows(const char *json)
{
    StrVec acc = {0}, filed = {0}, report = {0}, form = {0};
    size_t i;
    int ok = 0;

    if (!extract_string_array(json, "accessionNumber", &acc)) goto done;
    if (!extract_string_array(json, "filingDate", &filed)) goto done;
    if (!extract_string_array(json, "reportDate", &report)) goto done;
    if (!extract_string_array(json, "form", &form)) goto done;

    if (acc.n != filed.n || acc.n != report.n || acc.n != form.n) goto done;

    puts("accession\tfiling_date\treport_date\tform");
    for (i = 0; i < acc.n; i++) {
        printf("%s\t%s\t%s\t%s\n",
               acc.v[i], filed.v[i], report.v[i], form.v[i]);
    }

    ok = 1;

done:
    free_vec(&acc);
    free_vec(&filed);
    free_vec(&report);
    free_vec(&form);
    return ok;
}

static int mode_history(const char *json)
{
    const char *p = json;
    size_t count = 0;

    while ((p = strstr(p, "\"name\"")) != NULL) {
        const char *q = strchr(p, ':');
        char *name;

        if (!q) break;
        q = skip_ws(q + 1);
        if (*q != '"') { p += 6; continue; }

        name = parse_string(&q);
        if (!name) return 0;

        if (strstr(name, "-submissions-") && ends_with(name, ".json")) {
            puts(name);
            count++;
        }

        free(name);
        p = q;
    }

    (void)count;
    return 1;
}

int main(int argc, char **argv)
{
    char *json;
    size_t len = 0;
    int ok = 0;

    if (argc != 3) {
        fprintf(stderr, "usage: %s rows|history-files FILE\n", argv[0]);
        return 2;
    }

    json = read_all(argv[2], &len);
    if (!json) return 3;
    (void)len;

    if (strcmp(argv[1], "rows") == 0)
        ok = mode_rows(json);
    else if (strcmp(argv[1], "history-files") == 0)
        ok = mode_history(json);
    else {
        free(json);
        return 4;
    }

    free(json);
    return ok ? 0 : 5;
}
