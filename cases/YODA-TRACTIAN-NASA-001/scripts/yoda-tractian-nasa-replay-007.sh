#!/usr/bin/env bash
set -eu
export LC_ALL=C

ROOT="${YODA_CASE_ROOT:-$HOME/Yoda-Workspace/cases/YODA-TRACTIAN-NASA-001}"
FEAT="$ROOT/evidence/C11-SIGNAL-READER-005"
SRC="$ROOT/src/ims_causal_replay.c"
BIN="$ROOT/bin/yoda-ims-replay"
OUT="$ROOT/evidence/CAUSAL-REPLAY-007"

echo '============================================================'
echo ' YODA-TRACTIAN-NASA-001'
echo ' CAUSAL REPLAY 007 — REAL HISTORICAL VIBRATION'
echo '============================================================'

test -d "$ROOT/src"
test -d "$ROOT/bin"
test -f "$FEAT/features.tsv"
test -f "$FEAT/artifacts.sha256"
test ! -e "$SRC"
test ! -e "$BIN"
test ! -e "$OUT"
command -v cc >/dev/null
command -v sha256sum >/dev/null

mkdir "$OUT"
(
    cd "$FEAT"
    sha256sum -c artifacts.sha256
) > "$OUT/input-verification.log"
echo 'INPUT_EVIDENCE=PASS'

cat > "$SRC" <<'C'
#define _POSIX_C_SOURCE 200809L
#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHANNELS 4
#define SNAPSHOTS 984
#define BASELINE 100
#define RISE_RATIO 3.0
#define LOW_RATIO 0.10
#define RISE_STREAK 3

struct row {
    char time[20];
    char source[20];
    char hash[65];
    double rms;
};

static int split(char *s, char *f[8])
{
    size_t len = strlen(s);
    if (len && s[len - 1] == '\n') s[--len] = '\0';
    if (len && s[len - 1] == '\r') s[--len] = '\0';
    int n = 1;
    f[0] = s;
    for (char *p = s; *p; p++) {
        if (*p == '\t') {
            *p = '\0';
            if (n == 8) return 0;
            f[n++] = p + 1;
        }
    }
    if (n != 8) return 0;
    for (int i = 0; i < 8; i++) if (!*f[i]) return 0;
    return 1;
}

static int time_valid(const char *s)
{
    if (strlen(s) != 19) return 0;
    for (int i = 0; i < 19; i++) {
        char wanted = 0;
        if (i == 4 || i == 7) wanted = '-';
        if (i == 10) wanted = 'T';
        if (i == 13 || i == 16) wanted = ':';
        if (wanted ? s[i] != wanted : !isdigit((unsigned char)s[i]))
            return 0;
    }
    return 1;
}

static int parse_number(const char *s, double *v)
{
    char *end;
    errno = 0;
    *v = strtod(s, &end);
    return s != end && *end == '\0' && errno != ERANGE && isfinite(*v) && *v >= 0;
}

static int read_row(FILE *in, struct row *r, int channel)
{
    char *line = NULL;
    size_t cap = 0;
    ssize_t length = getline(&line, &cap, in);
    if (length < 0) { free(line); return feof(in) ? 0 : -1; }

    char *f[8];
    double rms, peak, crest;
    int ok = split(line, f) && time_valid(f[0]);
    if (ok) {
        char derived[20];
        snprintf(derived, sizeof derived, "%.4s.%.2s.%.2s.%.2s.%.2s.%.2s",
                 f[0], f[0]+5, f[0]+8, f[0]+11, f[0]+14, f[0]+17);
        ok = strlen(f[1]) == 19 && strcmp(f[1], derived) == 0 &&
             strlen(f[2]) == 64 && f[3][0] == (char)('0' + channel) &&
             f[3][1] == '\0' && strcmp(f[4], "20480") == 0;
        for (int i = 0; ok && i < 64; i++)
            if (!isxdigit((unsigned char)f[2][i])) ok = 0;
    }
    if (ok) {
        ok = parse_number(f[5], &rms) && parse_number(f[6], &peak) &&
             parse_number(f[7], &crest);
        if (ok) {
            double expected = rms > 0 ? peak / rms : 0;
            if (peak + 1e-10 < rms || fabs(crest - expected) > 1e-6 * (1 + expected))
                ok = 0;
        }
    }
    if (ok) {
        strcpy(r->time, f[0]);
        strcpy(r->source, f[1]);
        strcpy(r->hash, f[2]);
        r->rms = rms;
    }
    free(line);
    return ok ? 1 : -1;
}

static FILE *output(const char *dir, const char *name)
{
    char path[4096];
    if (snprintf(path, sizeof path, "%s/%s", dir, name) >= (int)sizeof path)
        return NULL;
    return fopen(path, "w");
}

int main(int argc, char **argv)
{
    if (argc != 3) {
        fprintf(stderr, "usage: %s features.tsv output-directory\n", argv[0]);
        return 2;
    }
    FILE *in = fopen(argv[1], "r");
    if (!in) { perror(argv[1]); return 2; }
    FILE *replay = output(argv[2], "replay.tsv");
    FILE *events = output(argv[2], "events.tsv");
    FILE *base = output(argv[2], "baseline.tsv");
    if (!replay || !events || !base) {
        fprintf(stderr, "OUTPUT_OPEN=FAIL\n");
        return 2;
    }
    char header[256];
    if (!fgets(header, sizeof header, in) ||
        strcmp(header, "timestamp\tsource_file\tsource_sha256\tchannel\tsamples\trms\tpeak_abs\tcrest_factor\n") != 0) {
        fprintf(stderr, "INPUT_HEADER=REJECT\n");
        return 1;
    }
    fprintf(replay, "index\ttimestamp\tratio_ch1\tratio_ch2\tratio_ch3\tratio_ch4\trise_mask\tlow_energy_all\tstate\n");
    fprintf(events, "index\ttimestamp\tevent\tchannels\tratio_ch1\tratio_ch2\tratio_ch3\tratio_ch4\tsource_sha256\n");
    fprintf(base, "channel\tbaseline_rms_first100\trise_threshold_3x\tlow_energy_threshold_0.1x\n");

    double sum[CHANNELS] = {0}, mean[CHANNELS] = {0};
    int streak[CHANNELS] = {0};
    int rise_events = 0, low_events = 0;
    char previous[20] = "";
    for (int i = 1; i <= SNAPSHOTS; i++) {
        struct row r[CHANNELS];
        for (int c = 0; c < CHANNELS; c++) {
            int rc = read_row(in, &r[c], c + 1);
            if (rc != 1) {
                fprintf(stderr, "ROW_REJECT capture=%d channel=%d\n", i, c + 1);
                return 1;
            }
            if (c && (strcmp(r[0].time, r[c].time) ||
                      strcmp(r[0].source, r[c].source) ||
                      strcmp(r[0].hash, r[c].hash))) {
                fprintf(stderr, "CAPTURE_IDENTITY=REJECT capture=%d\n", i);
                return 1;
            }
        }
        if (previous[0] && strcmp(previous, r[0].time) >= 0) {
            fprintf(stderr, "CHRONOLOGY=REJECT capture=%d\n", i);
            return 1;
        }
        strcpy(previous, r[0].time);
        if (i <= BASELINE) {
            for (int c = 0; c < CHANNELS; c++) sum[c] += r[c].rms;
            fprintf(replay, "%d\t%s\tNA\tNA\tNA\tNA\t0\t0\tCALIBRATION\n", i, previous);
            if (i == BASELINE) {
                for (int c = 0; c < CHANNELS; c++) {
                    mean[c] = sum[c] / BASELINE;
                    if (!isfinite(mean[c]) || mean[c] <= 0) {
                        fprintf(stderr, "BASELINE=REJECT channel=%d\n", c + 1);
                        return 1;
                    }
                    fprintf(base, "%d\t%.12g\t%.12g\t%.12g\n", c + 1,
                            mean[c], RISE_RATIO*mean[c], LOW_RATIO*mean[c]);
                }
            }
            continue;
        }
        double ratios[CHANNELS];
        int mask = 0, candidates = 0, low = 1, newly_sustained = 0;
        for (int c = 0; c < CHANNELS; c++) {
            ratios[c] = r[c].rms / mean[c];
            if (!isfinite(ratios[c])) {
                fprintf(stderr, "RATIO=REJECT capture=%d\n", i);
                return 1;
            }
            if (ratios[c] > LOW_RATIO) low = 0;
            if (ratios[c] >= RISE_RATIO) {
                streak[c]++;
                if (streak[c] >= RISE_STREAK) mask |= (1 << c);
                else candidates |= (1 << c);
                if (streak[c] == RISE_STREAK)
                    newly_sustained |= (1 << c);
            } else streak[c] = 0;
        }
        for (int c = 0; c < CHANNELS; c++) {
            if (newly_sustained & (1 << c)) {
                fprintf(events, "%d\t%s\tRMS_RISE_PERSISTENT\tCH%d\t%.8g\t%.8g\t%.8g\t%.8g\t%s\n",
                        i, previous, c + 1, ratios[0], ratios[1], ratios[2], ratios[3], r[0].hash);
                rise_events++;
            }
        }
        if (low) {
            fprintf(events, "%d\t%s\tLOW_ENERGY_COMMON_MODE\tALL\t%.8g\t%.8g\t%.8g\t%.8g\t%s\n",
                    i, previous, ratios[0], ratios[1], ratios[2], ratios[3], r[0].hash);
            low_events++;
        }
        const char *state = low ? "LOW_ENERGY_COMMON_MODE" : mask ? "RMS_RISE_PERSISTENT" :
                            candidates ? "RMS_RISE_CANDIDATE" : "NO_RULE_TRIGGER";
        fprintf(replay, "%d\t%s\t%.8g\t%.8g\t%.8g\t%.8g\t%d\t%d\t%s\n",
                i, previous, ratios[0], ratios[1], ratios[2], ratios[3], mask, low, state);
    }
    char *extra = NULL;
    size_t cap = 0;
    ssize_t more = getline(&extra, &cap, in);
    free(extra);
    if (more >= 0 || ferror(in)) {
        fprintf(stderr, "INVENTORY=REJECT extra_row_or_error\n");
        return 1;
    }
    if (fclose(in) || fclose(replay) || fclose(events) || fclose(base)) {
        fprintf(stderr, "OUTPUT_CLOSE=FAIL\n");
        return 1;
    }
    printf("CAUSAL_REPLAY=PASS SNAPSHOTS=%d BASELINE=%d RISE_RATIO=%.1f PERSISTENCE=%d LOW_RATIO=%.2f\n",
           SNAPSHOTS, BASELINE, RISE_RATIO, RISE_STREAK, LOW_RATIO);
    printf("RISE_TRANSITIONS=%d LOW_ENERGY_SNAPSHOTS=%d\n", rise_events, low_events);
    return 0;
}
C

cc -std=c11 -O2 -Wall -Wextra -Werror -pedantic "$SRC" -lm -o "$BIN"
echo 'C11_BUILD=PASS'

"$BIN" "$FEAT/features.tsv" "$OUT" > "$OUT/replay.log" 2>&1
cat "$OUT/replay.log"

awk -F '\t' '
NR==1 { if (NF!=9 || $1!="index") exit 1; next }
{
    if (NF!=9 || $1!=NR-1) exit 1
    if (NR<=101 && $9!="CALIBRATION") exit 1
    if (NR>101 && $3=="NA") exit 1
    prev_state=last_state
    last_state=$9
    count++
}
END {
    if (count!=984 || prev_state!="LOW_ENERGY_COMMON_MODE" ||
        last_state!="LOW_ENERGY_COMMON_MODE") exit 1
    print "REPLAY_ROWS=984"
    print "FINAL_TWO_LOW_ENERGY=PASS"
}' "$OUT/replay.tsv"

awk -F '\t' '
NR==1 {next}
$3=="RMS_RISE_PERSISTENT" && $4=="CH1" {rise1++}
$3=="LOW_ENERGY_COMMON_MODE" && $4=="ALL" {low++}
END {
    printf "CH1_RISE_TRANSITIONS=%d\n",rise1
    printf "LOW_ENERGY_EVENTS=%d\n",low
    if (rise1<1 || low<2) exit 1
}' "$OUT/events.tsv"

echo
echo '=== BASELINE — FIRST 100 SNAPSHOTS ==='
cat "$OUT/baseline.tsv"
echo
echo '=== FIRST 15 EVENTS ==='
sed -n '1,16p' "$OUT/events.tsv"
echo
echo '=== LAST 4 SNAPSHOTS ==='
tail -4 "$OUT/replay.tsv"

(
    cd "$OUT"
    sha256sum replay.tsv events.tsv baseline.tsv replay.log input-verification.log > artifacts.sha256
)
sha256sum "$SRC" "$BIN" > "$OUT/code.sha256"

echo
echo 'CAUSAL_REPLAY_007=PASS'
echo 'INTERPRETATION=OBSERVATION_ONLY'
echo 'FAILURE_DIAGNOSIS=NOT_IMPLEMENTED'
echo 'FUTURE_INFORMATION=NOT_USED_IN_RULES'
echo 'EXISTING_YODA_COMPONENTS=UNCHANGED'
echo "EVIDENCE_DIR=$OUT"
