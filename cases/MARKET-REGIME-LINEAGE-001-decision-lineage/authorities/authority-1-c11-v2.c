#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

static int parse_fixed5(const char *s, long long *out) {
    int sign = 1, fd = 0, sd = 0;
    const char *p = s;
    long long w = 0, f = 0;
    if (*p == '+') p++;
    else if (*p == '-') { sign = -1; p++; }
    while (*p >= '0' && *p <= '9') {
        sd = 1;
        if (w > (LLONG_MAX - 9) / 10) return 0;
        w = w * 10 + (*p - '0');
        p++;
    }
    if (!sd) return 0;
    if (*p == '.') {
        p++;
        while (*p >= '0' && *p <= '9') {
            if (fd >= 5) return 0;
            f = f * 10 + (*p - '0');
            fd++;
            p++;
        }
    }
    if (*p != '\0') return 0;
    while (fd < 5) { f *= 10; fd++; }
    if (w > (LLONG_MAX - f) / 100000) return 0;
    *out = sign * (w * 100000 + f);
    return 1;
}

static int split6(char *l, char **f) {
    int n = 0;
    char *p = l;
    f[n++] = p;
    while (*p) {
        if (*p == '\t') {
            *p = '\0';
            if (n >= 6) return 0;
            f[n++] = p + 1;
        }
        p++;
    }
    return n == 6;
}

int main(int argc, char **argv) {
    FILE *fp;
    char line[4096], *f[6], date[11] = {0};
    long long d = 0, n = 0, v = 0, x;
    int hd = 0, hn = 0, hv = 0, rows = 0, rf, nf, vf, score;
    const char *lab;

    if (argc != 3 || strlen(argv[1]) != 1 || !strchr("ABC", argv[1][0])) return 2;
    if (!(fp = fopen(argv[2], "r"))) return 3;

    if (!fgets(line, sizeof line, fp)) { fclose(fp); return 4; }
    line[strcspn(line, "\r\n")] = '\0';
    if (strcmp(line, "evaluation_date\tseries_id\tobservation_date\tvintage_date\tvalue\tunits")) { fclose(fp); return 5; }

    while (fgets(line, sizeof line, fp)) {
        line[strcspn(line, "\r\n")] = '\0';
        if (!*line) continue;
        if (!split6(line, f)) { fclose(fp); return 6; }
        if (strlen(f[0]) != 10) { fclose(fp); return 7; }
        if (!*date) memcpy(date, f[0], 11);
        else if (strcmp(date, f[0])) { fclose(fp); return 8; }
        if (!parse_fixed5(f[4], &x)) { fclose(fp); return 9; }

        if (!strcmp(f[1], "DGS10")) {
            if (hd || strcmp(f[5], "percent")) { fclose(fp); return 10; }
            d = x; hd = 1;
        } else if (!strcmp(f[1], "NFCI")) {
            if (hn || strcmp(f[5], "index")) { fclose(fp); return 11; }
            n = x; hn = 1;
        } else if (!strcmp(f[1], "VIXCLS")) {
            if (hv || strcmp(f[5], "index")) { fclose(fp); return 12; }
            v = x; hv = 1;
        } else { fclose(fp); return 13; }
        rows++;
    }
    fclose(fp);

    if (rows != 3 || !hd || !hn || !hv) return 14;

    rf = d >= 400000;
    nf = n >= 0;
    vf = v >= 2000000;
    score = rf + nf + vf;
    lab = score == 0 ? "CALM" : score == 1 ? "FRAGILE" : "STRESSED";

    printf("%s\t%s\t%lld\t%lld\t%lld\t%d\t%d\t%d\t%d\t%s\n",
           argv[1], date, d, n, v, rf, nf, vf, score, lab);
    return 0;
}
