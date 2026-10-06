#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CONTRACT_ID "PUBLIC-DISCLOSURE-EVALUATION-V1"
#define OUT_HEADER "contract\tconcept\tunit\tstart\tend\tvalue_a_raw\tvalue_b_raw\tcommon_scale\tdelta_coefficient\tbase_coefficient\tthreshold_basis_points\tclassification"

typedef struct {
    int sign;
    char *digits;
    size_t scale;
} Decimal;

static void die(const char *msg)
{
    fprintf(stderr, "%s\n", msg);
    exit(2);
}

static char *xstrdup(const char *s)
{
    size_t n = strlen(s);
    char *p = malloc(n + 1);
    if (!p) die("out of memory");
    memcpy(p, s, n + 1);
    return p;
}

static void strip_newline(char *s)
{
    size_t n = strlen(s);
    while (n > 0 && (s[n - 1] == '\n' || s[n - 1] == '\r'))
        s[--n] = '\0';
}

static char *normalize_digits_owned(char *s)
{
    size_t n = strlen(s);
    size_t i = 0;

    while (i + 1 < n && s[i] == '0')
        i++;

    if (i > 0)
        memmove(s, s + i, n - i + 1);

    return s;
}

static int is_zero_digits(const char *s)
{
    while (*s) {
        if (*s != '0') return 0;
        s++;
    }
    return 1;
}

static int parse_decimal(const char *raw, Decimal *out)
{
    const char *p = raw;
    size_t i, n, digits_n = 0, frac_n = 0;
    int sign = 1;
    int dot_seen = 0;
    int digit_seen = 0;
    char *digits;

    memset(out, 0, sizeof(*out));

    if (*p == '+' || *p == '-') {
        if (*p == '-') sign = -1;
        p++;
    }

    if (*p == '\0') return 0;

    n = strlen(p);
    digits = malloc(n + 1);
    if (!digits) die("out of memory");

    for (i = 0; i < n; i++) {
        unsigned char ch = (unsigned char)p[i];

        if (ch == '.') {
            if (dot_seen) {
                free(digits);
                return 0;
            }
            dot_seen = 1;
            continue;
        }

        if (!isdigit(ch)) {
            free(digits);
            return 0;
        }

        digit_seen = 1;
        digits[digits_n++] = (char)ch;

        if (dot_seen)
            frac_n++;
    }

    if (!digit_seen) {
        free(digits);
        return 0;
    }

    digits[digits_n] = '\0';
    normalize_digits_owned(digits);

    out->scale = frac_n;
    out->digits = digits;
    out->sign = is_zero_digits(digits) ? 0 : sign;
    return 1;
}

static void free_decimal(Decimal *d)
{
    free(d->digits);
    d->digits = NULL;
    d->scale = 0;
    d->sign = 0;
}

static char *append_zeros(const char *digits, size_t count)
{
    size_t n = strlen(digits);
    char *out = malloc(n + count + 1);
    size_t i;

    if (!out) die("out of memory");

    memcpy(out, digits, n);
    for (i = 0; i < count; i++)
        out[n + i] = '0';

    out[n + count] = '\0';
    return normalize_digits_owned(out);
}

static int cmp_big(const char *a, const char *b)
{
    size_t na = strlen(a);
    size_t nb = strlen(b);
    int c;

    if (na < nb) return -1;
    if (na > nb) return 1;

    c = strcmp(a, b);
    if (c < 0) return -1;
    if (c > 0) return 1;
    return 0;
}

static char *add_big(const char *a, const char *b)
{
    size_t na = strlen(a), nb = strlen(b);
    size_t n = (na > nb ? na : nb) + 1;
    char *out = malloc(n + 1);
    size_t ia = na, ib = nb, io = n;
    int carry = 0;

    if (!out) die("out of memory");
    out[n] = '\0';

    while (io > 0) {
        int da = 0, db = 0, sum;

        if (ia > 0) da = a[--ia] - '0';
        if (ib > 0) db = b[--ib] - '0';

        sum = da + db + carry;
        out[--io] = (char)('0' + (sum % 10));
        carry = sum / 10;
    }

    return normalize_digits_owned(out);
}

static char *sub_big(const char *a, const char *b)
{
    size_t na = strlen(a), nb = strlen(b);
    char *out;
    size_t ia = na, ib = nb, io = na;
    int borrow = 0;

    if (cmp_big(a, b) < 0)
        die("sub_big precondition violated");

    out = malloc(na + 1);
    if (!out) die("out of memory");
    out[na] = '\0';

    while (io > 0) {
        int da = a[--ia] - '0' - borrow;
        int db = 0;

        if (ib > 0) db = b[--ib] - '0';

        if (da < db) {
            da += 10;
            borrow = 1;
        } else {
            borrow = 0;
        }

        out[--io] = (char)('0' + (da - db));
    }

    return normalize_digits_owned(out);
}

static char *mul_small(const char *a, unsigned m)
{
    size_t na = strlen(a);
    size_t cap = na + 16;
    char *rev = malloc(cap);
    char *out;
    size_t i = na, nr = 0, j;
    unsigned long carry = 0;

    if (!rev) die("out of memory");

    if (m == 0 || is_zero_digits(a)) {
        free(rev);
        return xstrdup("0");
    }

    while (i > 0 || carry > 0) {
        unsigned long cur;

        if (nr + 1 >= cap) {
            char *tmp;
            cap *= 2;
            tmp = realloc(rev, cap);
            if (!tmp) die("out of memory");
            rev = tmp;
        }

        cur = carry;
        if (i > 0)
            cur += (unsigned long)(a[--i] - '0') * m;

        rev[nr++] = (char)('0' + (cur % 10));
        carry = cur / 10;
    }

    out = malloc(nr + 1);
    if (!out) die("out of memory");

    for (j = 0; j < nr; j++)
        out[j] = rev[nr - 1 - j];

    out[nr] = '\0';
    free(rev);
    return normalize_digits_owned(out);
}

static char *aligned_abs(const Decimal *d, size_t common_scale)
{
    if (common_scale < d->scale)
        die("scale precondition violated");

    return append_zeros(d->digits, common_scale - d->scale);
}

static char *delta_abs(const Decimal *a, const Decimal *b,
                       size_t common_scale,
                       char **a_abs_out,
                       char **b_abs_out)
{
    char *aa = aligned_abs(a, common_scale);
    char *bb = aligned_abs(b, common_scale);
    char *delta;

    *a_abs_out = aa;
    *b_abs_out = bb;

    if (a->sign == 0)
        return xstrdup(bb);

    if (b->sign == 0)
        return xstrdup(aa);

    if (a->sign == b->sign) {
        if (cmp_big(aa, bb) >= 0)
            delta = sub_big(aa, bb);
        else
            delta = sub_big(bb, aa);
    } else {
        delta = add_big(aa, bb);
    }

    return delta;
}

static int split_tsv(char *line, char **fields, size_t expected)
{
    size_t n = 0;
    char *p = line;

    if (expected == 0) return 0;

    fields[n++] = p;

    while (*p) {
        if (*p == '\t') {
            *p = '\0';
            if (n >= expected) return 0;
            fields[n++] = p + 1;
        }
        p++;
    }

    return n == expected;
}

int main(int argc, char **argv)
{
    FILE *fp;
    char header[4096];
    char line_a[8192];
    char line_b[8192];
    char extra[8];
    char *a[8], *b[8];
    Decimal da = {0}, db = {0};
    size_t common_scale = 0;
    char *aa = NULL, *bb = NULL, *delta = NULL, *base = NULL;
    char *left = NULL, *right = NULL;
    const char *classification;

    if (argc != 2) {
        fprintf(stderr, "usage: %s canonical-facts.tsv\n", argv[0]);
        return 2;
    }

    fp = fopen(argv[1], "rb");
    if (!fp) return 3;

    if (!fgets(header, sizeof(header), fp) ||
        !fgets(line_a, sizeof(line_a), fp) ||
        !fgets(line_b, sizeof(line_b), fp)) {
        fclose(fp);
        return 4;
    }

    if (fgets(extra, sizeof(extra), fp) != NULL) {
        fclose(fp);
        return 5;
    }

    fclose(fp);

    strip_newline(header);
    strip_newline(line_a);
    strip_newline(line_b);

    if (strcmp(header,
               "state\taccession\tform\tconcept\tunit\tstart\tend\tvalue_raw") != 0)
        return 6;

    if (!split_tsv(line_a, a, 8) || !split_tsv(line_b, b, 8))
        return 7;

    if (strcmp(a[0], "A") != 0 ||
        strcmp(b[0], "B") != 0 ||
        strcmp(a[2], "10-K") != 0 ||
        strcmp(b[2], "10-K/A") != 0)
        return 8;

    if (strcmp(a[3], b[3]) != 0 ||
        strcmp(a[4], b[4]) != 0 ||
        strcmp(a[5], b[5]) != 0 ||
        strcmp(a[6], b[6]) != 0 ||
        strcmp(a[4], "USD") != 0) {
        classification = "NOT_COMPARABLE";
        printf("%s\n", OUT_HEADER);
        printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t-\t-\t-\t100\t%s\n",
               CONTRACT_ID, a[3], a[4], a[5], a[6], a[7], b[7],
               classification);
        return 0;
    }

    if (!parse_decimal(a[7], &da) || !parse_decimal(b[7], &db)) {
        free_decimal(&da);
        free_decimal(&db);

        classification = "NOT_EVALUABLE";
        printf("%s\n", OUT_HEADER);
        printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t-\t-\t-\t100\t%s\n",
               CONTRACT_ID, a[3], a[4], a[5], a[6], a[7], b[7],
               classification);
        return 0;
    }

    common_scale = da.scale > db.scale ? da.scale : db.scale;
    delta = delta_abs(&da, &db, common_scale, &aa, &bb);

    if (cmp_big(aa, bb) >= 0)
        base = xstrdup(aa);
    else
        base = xstrdup(bb);

    if (is_zero_digits(delta)) {
        classification = "UNCHANGED";
    } else {
        left = mul_small(delta, 10000U);
        right = mul_small(base, 100U);

        if (cmp_big(left, right) <= 0)
            classification = "CHANGED_WITHIN_THRESHOLD";
        else
            classification = "CHANGED_ABOVE_THRESHOLD";
    }

    printf("%s\n", OUT_HEADER);
    printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%zu\t%s\t%s\t100\t%s\n",
           CONTRACT_ID,
           a[3],
           a[4],
           a[5],
           a[6],
           a[7],
           b[7],
           common_scale,
           delta,
           base,
           classification);

    free(left);
    free(right);
    free(base);
    free(delta);
    free(aa);
    free(bb);
    free_decimal(&da);
    free_decimal(&db);

    return 0;
}
