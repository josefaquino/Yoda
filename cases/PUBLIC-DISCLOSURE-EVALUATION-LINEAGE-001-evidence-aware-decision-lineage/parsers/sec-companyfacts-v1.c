#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char *accn;
    char *form;
    char *start;
    char *end;
    char *val;
} Entry;

typedef struct {
    Entry *v;
    size_t n;
    size_t cap;
} EntryVec;

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

static const char *skip_ws(const char *p, const char *end)
{
    while (p < end && isspace((unsigned char)*p)) p++;
    return p;
}

static char *dup_range(const char *a, const char *b)
{
    size_t n = (size_t)(b - a);
    char *s = malloc(n + 1);
    if (!s) return NULL;
    memcpy(s, a, n);
    s[n] = '\0';
    return s;
}

static char *parse_json_string(const char **pp, const char *end)
{
    const char *p = *pp;
    size_t cap = 64, n = 0;
    char *out;

    if (p >= end || *p != '"') return NULL;
    p++;

    out = malloc(cap);
    if (!out) return NULL;

    while (p < end && *p != '"') {
        unsigned char ch = (unsigned char)*p++;

        if (ch == '\\') {
            if (p >= end) { free(out); return NULL; }
            ch = (unsigned char)*p++;

            switch (ch) {
            case '"': case '\\': case '/': break;
            case 'b': ch = '\b'; break;
            case 'f': ch = '\f'; break;
            case 'n': ch = '\n'; break;
            case 'r': ch = '\r'; break;
            case 't': ch = '\t'; break;
            case 'u':
                if (end - p < 4 ||
                    !isxdigit((unsigned char)p[0]) ||
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

    if (p >= end || *p != '"') { free(out); return NULL; }
    p++;

    out[n] = '\0';
    *pp = p;
    return out;
}

static const char *find_key_range(const char *start, const char *end, const char *key)
{
    size_t kn = strlen(key);
    size_t pn = kn + 3;
    char *pat;
    const char *p;

    pat = malloc(pn);
    if (!pat) return NULL;

    pat[0] = '"';
    memcpy(pat + 1, key, kn);
    pat[kn + 1] = '"';
    pat[kn + 2] = '\0';

    p = start;
    while (p < end) {
        const char *hit = strstr(p, pat);
        if (!hit || hit >= end) {
            free(pat);
            return NULL;
        }
        if (hit + kn + 2 <= end) {
            free(pat);
            return hit;
        }
        p = hit + 1;
    }

    free(pat);
    return NULL;
}

static const char *find_matching(const char *openp, const char *end, char open_ch, char close_ch)
{
    const char *p = openp;
    int depth = 0;
    int in_string = 0;
    int escape = 0;

    for (; p < end; p++) {
        char ch = *p;

        if (in_string) {
            if (escape) {
                escape = 0;
                continue;
            }
            if (ch == '\\') {
                escape = 1;
                continue;
            }
            if (ch == '"') in_string = 0;
            continue;
        }

        if (ch == '"') {
            in_string = 1;
            continue;
        }

        if (ch == open_ch) depth++;
        else if (ch == close_ch) {
            depth--;
            if (depth == 0) return p;
        }
    }

    return NULL;
}

static int key_container_status(const char *start, const char *end, const char *key,
                                char open_ch, char close_ch,
                                const char **out_start, const char **out_end)
{
    const char *p = find_key_range(start, end, key);
    const char *q, *r;

    if (!p) return 2;

    q = strchr(p, ':');
    if (!q || q >= end) return 0;

    q = skip_ws(q + 1, end);
    if (q >= end || *q != open_ch) return 0;

    r = find_matching(q, end, open_ch, close_ch);
    if (!r) return 0;

    *out_start = q;
    *out_end = r + 1;
    return 1;
}

static char *field_string(const char *obj, const char *obj_end, const char *key)
{
    const char *p = find_key_range(obj, obj_end, key);
    const char *q;

    if (!p) return NULL;
    q = strchr(p, ':');
    if (!q || q >= obj_end) return NULL;
    q = skip_ws(q + 1, obj_end);
    if (q >= obj_end || *q != '"') return NULL;

    return parse_json_string(&q, obj_end);
}

static char *field_raw(const char *obj, const char *obj_end, const char *key)
{
    const char *p = find_key_range(obj, obj_end, key);
    const char *q, *r;

    if (!p) return NULL;
    q = strchr(p, ':');
    if (!q || q >= obj_end) return NULL;
    q = skip_ws(q + 1, obj_end);
    if (q >= obj_end) return NULL;

    if (*q == '"') {
        return parse_json_string(&q, obj_end);
    }

    r = q;
    while (r < obj_end && *r != ',' && *r != '}') r++;
    while (r > q && isspace((unsigned char)r[-1])) r--;

    return dup_range(q, r);
}

static void free_entry(Entry *e)
{
    free(e->accn);
    free(e->form);
    free(e->start);
    free(e->end);
    free(e->val);
    memset(e, 0, sizeof(*e));
}

static int push_entry(EntryVec *vec, Entry *e)
{
    if (vec->n == vec->cap) {
        size_t new_cap = vec->cap ? vec->cap * 2 : 16;
        Entry *tmp = realloc(vec->v, new_cap * sizeof(Entry));
        if (!tmp) return 0;
        vec->v = tmp;
        vec->cap = new_cap;
    }

    vec->v[vec->n++] = *e;
    memset(e, 0, sizeof(*e));
    return 1;
}

static void free_vec(EntryVec *vec)
{
    size_t i;
    for (i = 0; i < vec->n; i++) free_entry(&vec->v[i]);
    free(vec->v);
    vec->v = NULL;
    vec->n = vec->cap = 0;
}

static int collect_usd_entries(const char *json, size_t len,
                               const char *concept, EntryVec *out)
{
    const char *end = json + len;
    const char *gaap_a, *gaap_b;
    const char *concept_a, *concept_b;
    const char *units_a, *units_b;
    const char *usd_a, *usd_b;
    const char *p;

    int rc;

    rc = key_container_status(json, end, "us-gaap", '{', '}', &gaap_a, &gaap_b);
    if (rc != 1) return rc;

    rc = key_container_status(gaap_a, gaap_b, concept, '{', '}', &concept_a, &concept_b);
    if (rc != 1) return rc;

    rc = key_container_status(concept_a, concept_b, "units", '{', '}', &units_a, &units_b);
    if (rc != 1) return rc;

    rc = key_container_status(units_a, units_b, "USD", '[', ']', &usd_a, &usd_b);
    if (rc != 1) return rc;

    p = usd_a + 1;

    while (p < usd_b - 1) {
        const char *obj_end;
        Entry e;

        p = skip_ws(p, usd_b - 1);

        if (p >= usd_b - 1) break;
        if (*p == ',') { p++; continue; }
        if (*p != '{') return 0;

        obj_end = find_matching(p, usd_b, '{', '}');
        if (!obj_end) return 0;

        memset(&e, 0, sizeof(e));
        e.accn = field_string(p, obj_end + 1, "accn");
        e.form = field_string(p, obj_end + 1, "form");
        e.start = field_string(p, obj_end + 1, "start");
        e.end = field_string(p, obj_end + 1, "end");
        e.val = field_raw(p, obj_end + 1, "val");

        if (!e.accn || !e.form || !e.end || !e.val) {
            free_entry(&e);
            return 0;
        }

        if (!push_entry(out, &e)) {
            free_entry(&e);
            return 0;
        }

        p = obj_end + 1;
    }

    return 1;
}

static int select_pair(const EntryVec *all,
                       const char *orig_accn,
                       const char *amend_accn,
                       const char *report_date,
                       const char *kind,
                       size_t *orig_idx,
                       size_t *amend_idx,
                       size_t *orig_count,
                       size_t *amend_count)
{
    size_t i;
    size_t oi = 0, ai = 0;
    size_t on = 0, an = 0;

    for (i = 0; i < all->n; i++) {
        const Entry *e = &all->v[i];

        if (strcmp(e->end, report_date) != 0) continue;

        if (strcmp(e->accn, orig_accn) == 0 &&
            strcmp(e->form, "10-K") == 0) {
            oi = i;
            on++;
        }

        if (strcmp(e->accn, amend_accn) == 0 &&
            strcmp(e->form, "10-K/A") == 0) {
            ai = i;
            an++;
        }
    }

    *orig_count = on;
    *amend_count = an;

    if (on != 1 || an != 1) return 0;

    if (strcmp(kind, "instant") == 0) {
        const char *os = all->v[oi].start;
        const char *as = all->v[ai].start;

        if ((os && *os) || (as && *as)) return 0;
    } else if (strcmp(kind, "duration") == 0) {
        const char *os = all->v[oi].start;
        const char *as = all->v[ai].start;

        if (!os || !*os || !as || !*as) return 0;
        if (strcmp(os, as) != 0) return 0;
    } else {
        return 0;
    }

    *orig_idx = oi;
    *amend_idx = ai;
    return 1;
}

static const char *show_start(const char *s)
{
    return (s && *s) ? s : "-";
}

int main(int argc, char **argv)
{
    const char *mode;
    const char *path;
    const char *concept;
    const char *kind;
    const char *report_date;
    const char *orig_accn;
    const char *amend_accn;
    char *json = NULL;
    size_t len = 0;
    EntryVec all = {0};
    size_t oi = 0, ai = 0, on = 0, an = 0;
    int eligible;
    int collect_rc;

    if (argc != 8) {
        fprintf(stderr,
                "usage: %s check|reveal FILE CONCEPT instant|duration REPORT_DATE ORIGINAL_ACCN AMENDMENT_ACCN\n",
                argv[0]);
        return 2;
    }

    mode = argv[1];
    path = argv[2];
    concept = argv[3];
    kind = argv[4];
    report_date = argv[5];
    orig_accn = argv[6];
    amend_accn = argv[7];

    if (strcmp(mode, "check") != 0 && strcmp(mode, "reveal") != 0)
        return 3;

    json = read_all(path, &len);
    if (!json) return 4;

    collect_rc = collect_usd_entries(json, len, concept, &all);

    if (collect_rc == 2) {
        free(json);
        puts("PARSER_STATUS=PASS");
        puts("ELIGIBLE=NO");
        puts("REASON=CONCEPT_OR_USD_UNIT_NOT_AVAILABLE");
        return 0;
    }

    if (collect_rc != 1) {
        free_vec(&all);
        free(json);
        fprintf(stderr, "companyfacts parser structural failure\n");
        return 6;
    }

    puts("PARSER_STATUS=PASS");

    eligible = select_pair(&all,
                           orig_accn,
                           amend_accn,
                           report_date,
                           kind,
                           &oi,
                           &ai,
                           &on,
                           &an);

    if (strcmp(mode, "check") == 0) {
        printf("ORIGINAL_MATCH_COUNT=%zu\n", on);
        printf("AMENDMENT_MATCH_COUNT=%zu\n", an);

        if (!eligible) {
            puts("ELIGIBLE=NO");
            puts("REASON=FACT_CONTEXT_CONTRACT_NOT_SATISFIED");
        } else {
            puts("ELIGIBLE=YES");
            printf("CONTEXT_START=%s\n", show_start(all.v[oi].start));
            printf("CONTEXT_END=%s\n", all.v[oi].end);
        }
    } else {
        if (!eligible) {
            free_vec(&all);
            free(json);
            return 5;
        }

        puts("state\taccession\tform\tconcept\tunit\tstart\tend\tvalue_raw");
        printf("A\t%s\t%s\t%s\tUSD\t%s\t%s\t%s\n",
               all.v[oi].accn,
               all.v[oi].form,
               concept,
               show_start(all.v[oi].start),
               all.v[oi].end,
               all.v[oi].val);

        printf("B\t%s\t%s\t%s\tUSD\t%s\t%s\t%s\n",
               all.v[ai].accn,
               all.v[ai].form,
               concept,
               show_start(all.v[ai].start),
               all.v[ai].end,
               all.v[ai].val);
    }

    free_vec(&all);
    free(json);
    return 0;
}
