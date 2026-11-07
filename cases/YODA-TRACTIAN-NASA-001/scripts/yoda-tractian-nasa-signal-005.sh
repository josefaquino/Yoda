#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

ROOT="$HOME/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001"
DATA="$ROOT/datasets/2nd_test"
SRC="$ROOT/src/ims_signal_reader.c"
BIN="$ROOT/bin/yoda-ims-signal"
OUT="$ROOT/evidence/C11-SIGNAL-READER-005"

echo "============================================================"
echo " YODA-TRACTIAN-NASA-001"
echo " C11 SIGNAL READER 005"
echo " REAL NASA IMS VIBRATION"
echo "============================================================"

test -d "$DATA"
test ! -e "$SRC"
test ! -e "$BIN"
test ! -e "$OUT"

command -v cc >/dev/null
command -v sha256sum >/dev/null
command -v find >/dev/null
command -v sort >/dev/null
command -v awk >/dev/null

mkdir -p "$ROOT/bin" "$OUT"

echo
echo "=== 1. CREATE C11 SIGNAL READER ==="

cat > "$SRC" <<'C'
#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHANNELS 4
#define EXPECTED_SAMPLES 20480
#define EXPECTED_FILES 984

static int number2(const char *s)
{
    return 10 * (s[0] - '0') + (s[1] - '0');
}

static int valid_timestamp(const char *s)
{
    const int dots[] = {4, 7, 10, 13, 16};

    if (strlen(s) != 19)
        return 0;

    for (int i = 0; i < 19; i++) {
        int dot = 0;

        for (int j = 0; j < 5; j++)
            if (i == dots[j])
                dot = 1;

        if (dot ? s[i] != '.' :
                  !isdigit((unsigned char)s[i]))
            return 0;
    }

    int year =
        (s[0] - '0') * 1000 +
        (s[1] - '0') * 100 +
        (s[2] - '0') * 10 +
        (s[3] - '0');

    int mon = number2(s + 5);
    int day = number2(s + 8);

    static const int days[] = {
        0, 31, 28, 31, 30, 31, 30,
        31, 31, 30, 31, 30, 31
    };

    if (year < 1900 || mon < 1 || mon > 12)
        return 0;

    int limit = days[mon];

    if (mon == 2 &&
        ((year % 4 == 0 && year % 100 != 0) ||
          year % 400 == 0))
        limit = 29;

    return day >= 1 &&
           day <= limit &&
           number2(s + 11) < 24 &&
           number2(s + 14) < 60 &&
           number2(s + 17) < 60;
}

static int parse_signal(
    const char *file,
    long double sums[CHANNELS],
    double peaks[CHANNELS])
{
    FILE *f = fopen(file, "r");

    if (!f) {
        perror(file);
        return 0;
    }

    char line[4096];
    unsigned long rows = 0;
    int good = 1;

    while (fgets(line, sizeof line, f)) {
        rows++;

        if (!strchr(line, '\n') && !feof(f)) {
            good = 0;
            break;
        }

        char *p = line;

        for (int c = 0; c < CHANNELS; c++) {
            while (isspace((unsigned char)*p))
                p++;

            if (!*p) {
                good = 0;
                break;
            }

            errno = 0;
            char *end;
            double x = strtod(p, &end);

            if (p == end ||
                errno == ERANGE ||
                !isfinite(x)) {
                good = 0;
                break;
            }

            sums[c] += (long double)x *
                       (long double)x;

            double a = fabs(x);

            if (a > peaks[c])
                peaks[c] = a;

            p = end;
        }

        if (!good)
            break;

        while (isspace((unsigned char)*p))
            p++;

        if (*p || rows > EXPECTED_SAMPLES) {
            good = 0;
            break;
        }
    }

    if (ferror(f))
        good = 0;

    if (fclose(f) != 0)
        good = 0;

    if (!good || rows != EXPECTED_SAMPLES) {
        fprintf(
            stderr,
            "SIGNAL_REJECT file=%s row=%lu expected=%d\n",
            file, rows, EXPECTED_SAMPLES
        );
        return 0;
    }

    return 1;
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(
            stderr,
            "usage: %s sources.sha256\n",
            argv[0]
        );
        return 2;
    }

    FILE *manifest = fopen(argv[1], "r");

    if (!manifest) {
        perror(argv[1]);
        return 2;
    }

    char *line = NULL;
    size_t cap = 0;
    ssize_t len;

    char previous[20] = {0};
    unsigned long files = 0;

    puts(
        "timestamp\tsource_file\tsource_sha256\t"
        "channel\tsamples\trms\tpeak_abs\tcrest_factor"
    );

    while ((len = getline(&line, &cap, manifest)) != -1) {
        if (len > 0 && line[len - 1] == '\n')
            line[--len] = '\0';

        if (len < 67 ||
            line[64] != ' ' ||
            line[65] != ' ') {
            fprintf(
                stderr,
                "MANIFEST_REJECT line=%lu\n",
                files + 1
            );
            goto bad;
        }

        for (int i = 0; i < 64; i++) {
            if (!isxdigit((unsigned char)line[i])) {
                fprintf(
                    stderr,
                    "HASH_REJECT line=%lu\n",
                    files + 1
                );
                goto bad;
            }
        }

        char hash[65];
        memcpy(hash, line, 64);
        hash[64] = '\0';

        const char *path = line + 66;

        if (!*path)
            goto bad;

        const char *name = strrchr(path, '/');
        name = name ? name + 1 : path;

        if (!valid_timestamp(name)) {
            fprintf(
                stderr,
                "TIMESTAMP_REJECT file=%s\n",
                path
            );
            goto bad;
        }

        if (files && strcmp(previous, name) >= 0) {
            fprintf(
                stderr,
                "CHRONOLOGY_REJECT current=%s previous=%s\n",
                name, previous
            );
            goto bad;
        }

        strcpy(previous, name);

        long double sums[CHANNELS] = {0};
        double peaks[CHANNELS] = {0};

        if (!parse_signal(path, sums, peaks))
            goto bad;

        char stamp[20];

        snprintf(
            stamp,
            sizeof stamp,
            "%.4s-%.2s-%.2sT%.2s:%.2s:%.2s",
            name,
            name + 5,
            name + 8,
            name + 11,
            name + 14,
            name + 17
        );

        for (int c = 0; c < CHANNELS; c++) {
            double rms = (double)sqrtl(
                sums[c] / EXPECTED_SAMPLES
            );

            double crest =
                rms > 0 ? peaks[c] / rms : 0;

            if (!isfinite(rms) || !isfinite(crest)) {
                fprintf(
                    stderr,
                    "METRIC_REJECT file=%s channel=%d\n",
                    path, c + 1
                );
                goto bad;
            }

            printf(
                "%s\t%s\t%s\t%d\t%d\t%.12g\t%.12g\t%.12g\n",
                stamp,
                name,
                hash,
                c + 1,
                EXPECTED_SAMPLES,
                rms,
                peaks[c],
                crest
            );
        }

        files++;
    }

    if (ferror(manifest) ||
        files != EXPECTED_FILES ||
        fclose(manifest) != 0) {
        fprintf(
            stderr,
            "INVENTORY_REJECT files=%lu expected=%d\n",
            files, EXPECTED_FILES
        );
        free(line);
        return 1;
    }

    free(line);

    fprintf(
        stderr,
        "IMS_READER=PASS FILES=%lu CHANNEL_ROWS=%lu "
        "SAMPLES_PER_FILE=%d ORDER=STRICT_CHRONOLOGICAL\n",
        files,
        files * CHANNELS,
        EXPECTED_SAMPLES
    );

    return 0;

bad:
    free(line);
    fclose(manifest);
    return 1;
}
C

echo "SOURCE_C11=CREATED"

echo
echo "=== 2. COMPILE C11 ==="

cc \
    -std=c11 \
    -O2 \
    -Wall \
    -Wextra \
    -Werror \
    -pedantic \
    "$SRC" \
    -lm \
    -o "$BIN"

echo "C11_BUILD=PASS"

echo
echo "=== 3. INVENTORY NASA FILES ==="

COUNT="$(
    find "$DATA" -type f |
    wc -l |
    tr -d ' '
)"

LINKS="$(
    find "$DATA" -type l |
    wc -l |
    tr -d ' '
)"

echo "SOURCE_FILES=$COUNT"
echo "SYMLINKS=$LINKS"

test "$COUNT" -eq 984
test "$LINKS" -eq 0

echo "SOURCE_INVENTORY=PASS"

echo
echo "=== 4. GENERATE SOURCE HASH MANIFEST ==="

find "$DATA" -type f -print0 |
    sort -z |
    xargs -0 -r sha256sum \
    > "$OUT/sources.sha256"

test "$(wc -l < "$OUT/sources.sha256")" -eq 984

sha256sum -c --status "$OUT/sources.sha256"

echo "SOURCE_HASHES=PASS"

echo
echo "=== 5. PROCESS ALL NASA SNAPSHOTS ==="

"$BIN" "$OUT/sources.sha256" \
    > "$OUT/features.tsv" \
    2> "$OUT/reader.log"

cat "$OUT/reader.log"

echo
echo "=== 6. VALIDATE OUTPUT ==="

awk -F '\t' '
NR == 1 {
    if (NF != 8)
        exit 1
    next
}
{
    if (NF != 8 ||
        $4 < 1 || $4 > 4 ||
        $5 != 20480 ||
        $6 < 0 ||
        $7 < 0 ||
        $8 < 0)
        exit 1

    count++
}
END {
    printf "FEATURE_ROWS=%d\n", count
    if (count != 3936)
        exit 1
}
' "$OUT/features.tsv"

echo "FEATURE_VALIDATION=PASS"

echo
echo "=== 7. RECHECK SOURCE INTEGRITY ==="

sha256sum -c --status "$OUT/sources.sha256"

echo "SOURCE_UNCHANGED=PASS"

echo
echo "=== 8. SHOW CHANNEL 1 FIRST OBSERVATIONS ==="

awk -F '\t' '
NR > 1 && $4 == 1 && n++ < 5 {
    printf "TIMESTAMP=%s RMS=%s PEAK=%s CREST=%s\n",
        $1, $6, $7, $8
}
' "$OUT/features.tsv"

echo
echo "=== 9. SHOW CHANNEL 1 LAST OBSERVATIONS ==="

awk -F '\t' '
NR > 1 && $4 == 1 {
    n++
    if (n > 979)
        printf "TIMESTAMP=%s RMS=%s PEAK=%s CREST=%s\n",
            $1, $6, $7, $8
}
' "$OUT/features.tsv"

echo
echo "=== 10. RECORD ARTIFACT INTEGRITY ==="

(
    cd "$OUT"
    sha256sum \
        sources.sha256 \
        features.tsv \
        reader.log \
        > artifacts.sha256
)

sha256sum "$SRC" "$BIN" \
    > "$OUT/code.sha256"

echo
echo "============================================================"
echo " C11 SIGNAL READER 005 — COMPLETE"
echo "============================================================"

echo "C11_SIGNAL_READER_005=PASS"
echo "NASA_SNAPSHOTS=984"
echo "FEATURE_ROWS=3936"
echo "FEATURES=RMS,PEAK_ABS,CREST_FACTOR"
echo "DATA=REAL_HISTORICAL"
echo "TELEMETRY=NOT_LIVE"
echo "FAULT_PREDICTION=NOT_IMPLEMENTED"
echo "EXISTING_YODA_COMPONENTS=UNCHANGED"
echo "EVIDENCE_DIR=$OUT"
