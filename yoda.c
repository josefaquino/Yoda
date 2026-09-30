#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define YODA_MAGIC "YODA001\0"
#define YODA_VERSION 1u

#define YODA_TYPE_PUT  1u
#define YODA_TYPE_LINK 2u

#define YODA_HEADER_SIZE 112u

#define YODA_TRAILER_MAGIC "YCMT001\0"
#define YODA_TRAILER_SIZE 40u

#define YODA_MAX_META  (1024u * 1024u)
#define YODA_IO_CHUNK  (1024u * 1024u)
#define YODA_MAX_VALUE (256ull * 1024ull * 1024ull)

/* ============================================================
 * SHA-256
 * ============================================================ */

typedef struct
{
    uint32_t h[8];
    uint64_t bitlen;
    uint8_t data[64];
    size_t datalen;
} sha256_ctx;

static const uint32_t k256[64] =
{
    0x428a2f98u,0x71374491u,0xb5c0fbcfu,0xe9b5dba5u,
    0x3956c25bu,0x59f111f1u,0x923f82a4u,0xab1c5ed5u,
    0xd807aa98u,0x12835b01u,0x243185beu,0x550c7dc3u,
    0x72be5d74u,0x80deb1feu,0x9bdc06a7u,0xc19bf174u,
    0xe49b69c1u,0xefbe4786u,0x0fc19dc6u,0x240ca1ccu,
    0x2de92c6fu,0x4a7484aau,0x5cb0a9dcu,0x76f988dau,
    0x983e5152u,0xa831c66du,0xb00327c8u,0xbf597fc7u,
    0xc6e00bf3u,0xd5a79147u,0x06ca6351u,0x14292967u,
    0x27b70a85u,0x2e1b2138u,0x4d2c6dfcu,0x53380d13u,
    0x650a7354u,0x766a0abbu,0x81c2c92eu,0x92722c85u,
    0xa2bfe8a1u,0xa81a664bu,0xc24b8b70u,0xc76c51a3u,
    0xd192e819u,0xd6990624u,0xf40e3585u,0x106aa070u,
    0x19a4c116u,0x1e376c08u,0x2748774cu,0x34b0bcb5u,
    0x391c0cb3u,0x4ed8aa4au,0x5b9cca4fu,0x682e6ff3u,
    0x748f82eeu,0x78a5636fu,0x84c87814u,0x8cc70208u,
    0x90befffau,0xa4506cebu,0xbef9a3f7u,0xc67178f2u
};

static uint32_t
rotr32(uint32_t x, uint32_t n)
{
    return (x >> n) | (x << (32u - n));
}

static void
sha256_transform(sha256_ctx *c, const uint8_t d[64])
{
    uint32_t w[64];

    for (size_t i = 0; i < 16; i++)
    {
        w[i] =
            ((uint32_t)d[i * 4] << 24) |
            ((uint32_t)d[i * 4 + 1] << 16) |
            ((uint32_t)d[i * 4 + 2] << 8) |
            d[i * 4 + 3];
    }

    for (size_t i = 16; i < 64; i++)
    {
        uint32_t s0 =
            rotr32(w[i - 15], 7) ^
            rotr32(w[i - 15], 18) ^
            (w[i - 15] >> 3);

        uint32_t s1 =
            rotr32(w[i - 2], 17) ^
            rotr32(w[i - 2], 19) ^
            (w[i - 2] >> 10);

        w[i] =
            w[i - 16] +
            s0 +
            w[i - 7] +
            s1;
    }

    uint32_t a = c->h[0];
    uint32_t b = c->h[1];
    uint32_t cc = c->h[2];
    uint32_t d0 = c->h[3];
    uint32_t e = c->h[4];
    uint32_t f = c->h[5];
    uint32_t g = c->h[6];
    uint32_t h = c->h[7];

    for (size_t i = 0; i < 64; i++)
    {
        uint32_t S1 =
            rotr32(e, 6) ^
            rotr32(e, 11) ^
            rotr32(e, 25);

        uint32_t ch =
            (e & f) ^
            ((~e) & g);

        uint32_t t1 =
            h +
            S1 +
            ch +
            k256[i] +
            w[i];

        uint32_t S0 =
            rotr32(a, 2) ^
            rotr32(a, 13) ^
            rotr32(a, 22);

        uint32_t maj =
            (a & b) ^
            (a & cc) ^
            (b & cc);

        uint32_t t2 =
            S0 +
            maj;

        h = g;
        g = f;
        f = e;
        e = d0 + t1;
        d0 = cc;
        cc = b;
        b = a;
        a = t1 + t2;
    }

    c->h[0] += a;
    c->h[1] += b;
    c->h[2] += cc;
    c->h[3] += d0;
    c->h[4] += e;
    c->h[5] += f;
    c->h[6] += g;
    c->h[7] += h;
}

static void
sha256_init(sha256_ctx *c)
{
    c->datalen = 0;
    c->bitlen = 0;

    c->h[0] = 0x6a09e667u;
    c->h[1] = 0xbb67ae85u;
    c->h[2] = 0x3c6ef372u;
    c->h[3] = 0xa54ff53au;
    c->h[4] = 0x510e527fu;
    c->h[5] = 0x9b05688cu;
    c->h[6] = 0x1f83d9abu;
    c->h[7] = 0x5be0cd19u;
}

static void
sha256_update(sha256_ctx *c, const void *vp, size_t n)
{
    const uint8_t *p =
        (const uint8_t *)vp;

    while (n--)
    {
        c->data[c->datalen++] =
            *p++;

        if (c->datalen == 64)
        {
            sha256_transform(
                c,
                c->data);

            c->bitlen += 512;
            c->datalen = 0;
        }
    }
}

static void
sha256_final(sha256_ctx *c, uint8_t out[32])
{
    size_t i =
        c->datalen;

    c->data[i++] =
        0x80;

    if (i > 56)
    {
        while (i < 64)
            c->data[i++] = 0;

        sha256_transform(
            c,
            c->data);

        i = 0;
    }

    while (i < 56)
        c->data[i++] = 0;

    c->bitlen +=
        (uint64_t)c->datalen * 8u;

    for (int j = 7; j >= 0; j--)
    {
        c->data[56 + (7 - j)] =
            (uint8_t)(
                c->bitlen >>
                (j * 8));
    }

    sha256_transform(
        c,
        c->data);

    for (i = 0; i < 8; i++)
    {
        out[i * 4] =
            (uint8_t)(
                c->h[i] >> 24);

        out[i * 4 + 1] =
            (uint8_t)(
                c->h[i] >> 16);

        out[i * 4 + 2] =
            (uint8_t)(
                c->h[i] >> 8);

        out[i * 4 + 3] =
            (uint8_t)c->h[i];
    }
}

/* ============================================================
 * ENCODING
 * ============================================================ */

static void
put_u32(uint8_t *p, uint32_t v)
{
    p[0] = (uint8_t)v;
    p[1] = (uint8_t)(v >> 8);
    p[2] = (uint8_t)(v >> 16);
    p[3] = (uint8_t)(v >> 24);
}

static void
put_u64(uint8_t *p, uint64_t v)
{
    for (int i = 0; i < 8; i++)
        p[i] =
            (uint8_t)(
                v >> (8 * i));
}

static uint32_t
get_u32(const uint8_t *p)
{
    return
        (uint32_t)p[0] |
        ((uint32_t)p[1] << 8) |
        ((uint32_t)p[2] << 16) |
        ((uint32_t)p[3] << 24);
}

static uint64_t
get_u64(const uint8_t *p)
{
    uint64_t v = 0;

    for (int i = 7; i >= 0; i--)
        v =
            (v << 8) |
            p[i];

    return v;
}

/* ============================================================
 * CORE
 * ============================================================ */

static void
die(const char *m)
{
    fprintf(
        stderr,
        "yoda: %s\n",
        m);

    exit(1);
}

static void
die_errno(const char *m)
{
    fprintf(
        stderr,
        "yoda: %s: %s\n",
        m,
        strerror(errno));

    exit(1);
}

static uint64_t
now_ns(void)
{
    struct timespec ts;

    if (clock_gettime(
            CLOCK_REALTIME,
            &ts) != 0)
    {
        die_errno(
            "clock_gettime");
    }

    return
        (uint64_t)ts.tv_sec *
            1000000000ull +
        (uint64_t)ts.tv_nsec;
}

static void
id_hex(
    const uint8_t id[32],
    char out[65])
{
    static const char hex[] =
        "0123456789abcdef";

    for (size_t i = 0; i < 32; i++)
    {
        out[i * 2] =
            hex[id[i] >> 4];

        out[i * 2 + 1] =
            hex[id[i] & 15];
    }

    out[64] = 0;
}

static int
id_zero(const uint8_t id[32])
{
    uint8_t x = 0;

    for (size_t i = 0; i < 32; i++)
        x |= id[i];

    return x == 0;
}

static int
write_all(
    int fd,
    const void *vp,
    size_t n)
{
    const uint8_t *p =
        vp;

    while (n)
    {
        ssize_t w =
            write(
                fd,
                p,
                n);

        if (w < 0)
        {
            if (errno == EINTR)
                continue;

            return -1;
        }

        if (w == 0)
            return -1;

        p += w;
        n -= (size_t)w;
    }

    return 0;
}

static int
pread_all(
    int fd,
    void *vp,
    size_t n,
    off_t off)
{
    uint8_t *p =
        vp;

    while (n)
    {
        ssize_t r =
            pread(
                fd,
                p,
                n,
                off);

        if (r < 0)
        {
            if (errno == EINTR)
                continue;

            return -1;
        }

        if (r == 0)
            return 0;

        p += r;
        off += r;
        n -= (size_t)r;
    }

    return 1;
}

static void
mkdir_p(const char *path)
{
    char *tmp =
        strdup(path);

    if (!tmp)
        die("oom");

    size_t n =
        strlen(tmp);

    if (n == 0)
    {
        free(tmp);
        return;
    }

    for (size_t i = 1; i < n; i++)
    {
        if (tmp[i] == '/')
        {
            tmp[i] = 0;

            if (*tmp &&
                mkdir(
                    tmp,
                    0755) != 0 &&
                errno != EEXIST)
            {
                die_errno(
                    "mkdir");
            }

            tmp[i] = '/';
        }
    }

    if (mkdir(
            tmp,
            0755) != 0 &&
        errno != EEXIST)
    {
        die_errno(
            "mkdir");
    }

    free(tmp);
}

static char *
dbfile(const char *db)
{
    size_t n =
        strlen(db) + 11;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/data.yoda",
        db);

    return p;
}

static off_t
file_size_fd(int fd)
{
    struct stat st;

    if (fstat(
            fd,
            &st) != 0)
    {
        die_errno(
            "fstat");
    }

    return st.st_size;
}

/* ============================================================
 * RECORD
 * ============================================================ */

typedef struct
{
    uint32_t type;
    uint64_t ts;

    uint32_t key_len;
    uint32_t source_len;
    uint32_t rel_len;
    uint32_t target_len;

    uint64_t value_len;

    uint8_t prev[32];
    uint8_t id[32];

    char *key;
    char *source;
    char *rel;
    char *target;

    off_t value_off;
    off_t next_off;
    off_t record_off;

    uint8_t hash_prefix[72];

} recmeta;

static void
rec_free(recmeta *r)
{
    free(r->key);
    free(r->source);
    free(r->rel);
    free(r->target);

    memset(
        r,
        0,
        sizeof(*r));
}

static char *
read_str(
    int fd,
    off_t *off,
    uint32_t n)
{
    char *s =
        malloc(
            (size_t)n + 1);

    if (!s)
        die("oom");

    if (n)
    {
        int rc =
            pread_all(
                fd,
                s,
                n,
                *off);

        if (rc != 1)
        {
            free(s);
            return NULL;
        }
    }

    s[n] = 0;

    *off +=
        (off_t)n;

    return s;
}

static int
rec_meta_at(
    int fd,
    off_t off,
    recmeta *r,
    off_t filesize)
{
    uint8_t h[
        YODA_HEADER_SIZE];

    memset(
        r,
        0,
        sizeof(*r));

    r->record_off =
        off;

    if (off == filesize)
        return 0;

    if (filesize - off <
        (off_t)YODA_HEADER_SIZE)
    {
        return -2;
    }

    int rc =
        pread_all(
            fd,
            h,
            sizeof(h),
            off);

    if (rc != 1)
        return -2;

    if (memcmp(
            h,
            YODA_MAGIC,
            8) != 0)
    {
        return -3;
    }

    if (get_u32(
            h + 8) !=
        YODA_VERSION)
    {
        return -4;
    }

    r->type =
        get_u32(
            h + 12);

    r->ts =
        get_u64(
            h + 16);

    r->key_len =
        get_u32(
            h + 24);

    r->source_len =
        get_u32(
            h + 28);

    r->rel_len =
        get_u32(
            h + 32);

    r->target_len =
        get_u32(
            h + 36);

    r->value_len =
        get_u64(
            h + 40);

    memcpy(
        r->prev,
        h + 48,
        32);

    memcpy(
        r->id,
        h + 80,
        32);

    memcpy(
        r->hash_prefix,
        h + 8,
        72);

    if (r->key_len > YODA_MAX_META ||
        r->source_len > YODA_MAX_META ||
        r->rel_len > YODA_MAX_META ||
        r->target_len > YODA_MAX_META ||
        r->value_len > YODA_MAX_VALUE)
    {
        return -5;
    }

    uint64_t total =
        (uint64_t)YODA_HEADER_SIZE +
        r->key_len +
        r->source_len +
        r->rel_len +
        r->target_len +
        r->value_len +
        YODA_TRAILER_SIZE;

    if (total >
        (uint64_t)(
            filesize - off))
    {
        return -2;
    }

    off +=
        (off_t)YODA_HEADER_SIZE;

    r->key =
        read_str(
            fd,
            &off,
            r->key_len);

    if (!r->key)
        return -2;

    r->source =
        read_str(
            fd,
            &off,
            r->source_len);

    if (!r->source)
    {
        rec_free(r);
        return -2;
    }

    r->rel =
        read_str(
            fd,
            &off,
            r->rel_len);

    if (!r->rel)
    {
        rec_free(r);
        return -2;
    }

    r->target =
        read_str(
            fd,
            &off,
            r->target_len);

    if (!r->target)
    {
        rec_free(r);
        return -2;
    }

    r->value_off =
        off;

    off_t trailer_off =
        off +
        (off_t)r->value_len;

    uint8_t trailer[
        YODA_TRAILER_SIZE];

    rc =
        pread_all(
            fd,
            trailer,
            sizeof(trailer),
            trailer_off);

    if (rc != 1)
    {
        rec_free(r);
        return -2;
    }

    if (memcmp(
            trailer,
            YODA_TRAILER_MAGIC,
            8) != 0)
    {
        rec_free(r);
        return -6;
    }

    if (memcmp(
            trailer + 8,
            r->id,
            32) != 0)
    {
        rec_free(r);
        return -6;
    }

    r->next_off =
        trailer_off +
        YODA_TRAILER_SIZE;

    return 1;
}

/* ============================================================
 * IN-MEMORY INDEX
 * ============================================================ */

static uint64_t
hash_key(const char *s)
{
    uint64_t h =
        1469598103934665603ull;

    while (*s)
    {
        h ^= (uint8_t)*s++;
        h *= 1099511628211ull;
    }

    return h;
}

typedef struct
{
    char *key;
    off_t off;
    uint8_t id[32];
    uint64_t ts;
    int used;

} idxent;

typedef struct
{
    idxent *e;
    size_t cap;
    size_t len;

} idxmap;

static void
idx_init(idxmap *m)
{
    m->cap = 1024;
    m->len = 0;

    m->e =
        calloc(
            m->cap,
            sizeof(*m->e));

    if (!m->e)
        die("oom");
}

static void
idx_destroy(idxmap *m)
{
    for (size_t i = 0;
         i < m->cap;
         i++)
    {
        if (m->e[i].used)
            free(m->e[i].key);
    }

    free(m->e);
}

static void
idx_insert_raw(
    idxmap *m,
    char *key,
    off_t off,
    const uint8_t id[32],
    uint64_t ts)
{
    size_t mask =
        m->cap - 1;

    size_t i =
        (size_t)hash_key(key) &
        mask;

    while (m->e[i].used)
        i =
            (i + 1) &
            mask;

    m->e[i].used = 1;
    m->e[i].key = key;
    m->e[i].off = off;
    m->e[i].ts = ts;

    memcpy(
        m->e[i].id,
        id,
        32);

    m->len++;
}

static void
idx_grow(idxmap *m)
{
    idxent *old =
        m->e;

    size_t oldcap =
        m->cap;

    m->cap *= 2;

    m->e =
        calloc(
            m->cap,
            sizeof(*m->e));

    if (!m->e)
        die("oom");

    m->len = 0;

    for (size_t i = 0;
         i < oldcap;
         i++)
    {
        if (old[i].used)
        {
            idx_insert_raw(
                m,
                old[i].key,
                old[i].off,
                old[i].id,
                old[i].ts);
        }
    }

    free(old);
}

static idxent *
idx_get(
    idxmap *m,
    const char *key)
{
    size_t mask =
        m->cap - 1;

    size_t i =
        (size_t)hash_key(key) &
        mask;

    while (m->e[i].used)
    {
        if (strcmp(
                m->e[i].key,
                key) == 0)
        {
            return &m->e[i];
        }

        i =
            (i + 1) &
            mask;
    }

    return NULL;
}

static void
idx_put(
    idxmap *m,
    const char *key,
    off_t off,
    const uint8_t id[32],
    uint64_t ts)
{
    if ((m->len + 1) * 10 >
        m->cap * 7)
    {
        idx_grow(m);
    }

    idxent *e =
        idx_get(
            m,
            key);

    if (e)
    {
        e->off = off;
        e->ts = ts;

        memcpy(
            e->id,
            id,
            32);

        return;
    }

    char *k =
        strdup(key);

    if (!k)
        die("oom");

    idx_insert_raw(
        m,
        k,
        off,
        id,
        ts);
}


/* ============================================================
 * PERSISTENT DERIVED INDEX
 * ============================================================ */

#define YODA_INDEX_MAGIC "YIDX003\0"
#define YODA_INDEX_VERSION 3u

#define YODA_INDEX_HEADER_SIZE 24u
#define YODA_INDEX_ENTRY_FIXED 72u

#define YODA_INDEX_PUT  1u
#define YODA_INDEX_LINK 2u

typedef struct
{
    char *from;
    char *rel;
    char *to;

    uint64_t ts;

    off_t record_off;

    uint8_t id[32];

} yoda_relation;

typedef struct
{
    yoda_relation *v;

    size_t n;
    size_t cap;

} yoda_relations;

static void
relations_init(
    yoda_relations *r)
{
    memset(
        r,
        0,
        sizeof(*r));
}

static void
relations_free(
    yoda_relations *r)
{
    for (size_t i = 0;
         i < r->n;
         i++)
    {
        free(r->v[i].from);
        free(r->v[i].rel);
        free(r->v[i].to);
    }

    free(r->v);

    memset(
        r,
        0,
        sizeof(*r));
}

static void
relations_add(
    yoda_relations *r,
    const char *from,
    const char *rel,
    const char *to,
    uint64_t ts,
    off_t record_off,
    const uint8_t id[32])
{
    if (r->n ==
        r->cap)
    {
        size_t nc =
            r->cap
                ? r->cap * 2
                : 32;

        yoda_relation *nv =
            realloc(
                r->v,
                nc * sizeof(*nv));

        if (!nv)
            die("oom");

        r->v = nv;
        r->cap = nc;
    }

    yoda_relation *x =
        &r->v[r->n++];

    memset(
        x,
        0,
        sizeof(*x));

    x->from =
        strdup(from);

    x->rel =
        strdup(rel);

    x->to =
        strdup(to);

    if (!x->from ||
        !x->rel ||
        !x->to)
    {
        die("oom");
    }

    x->ts =
        ts;

    x->record_off =
        record_off;

    memcpy(
        x->id,
        id,
        32);
}

static char *
indexfile(const char *db)
{
    size_t n =
        strlen(db) + 12;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/index.yoda",
        db);

    return p;
}

static char *
index_tmpfile(const char *db)
{
    size_t n =
        strlen(db) + 17;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/index.yoda.tmp",
        db);

    return p;
}

static void
fsync_dir_path(const char *db)
{
    int dfd =
        open(
            db,
            O_RDONLY |
            O_DIRECTORY);

    if (dfd < 0)
        die_errno(
            "open db directory");

    if (fsync(dfd) != 0)
    {
        close(dfd);

        die_errno(
            "fsync db directory");
    }

    close(dfd);
}

static void
index_write_entry(
    int fd,
    uint32_t type,
    uint64_t data_size,
    uint64_t record_off,
    uint64_t ts,
    const uint8_t id[32],
    const char *key,
    const char *rel,
    const char *target)
{
    size_t kl =
        key
            ? strlen(key)
            : 0;

    size_t rl =
        rel
            ? strlen(rel)
            : 0;

    size_t tl =
        target
            ? strlen(target)
            : 0;

    if (kl > UINT32_MAX ||
        rl > UINT32_MAX ||
        tl > UINT32_MAX)
    {
        die(
            "index field too large");
    }

    uint8_t e[
        YODA_INDEX_ENTRY_FIXED];

    memset(
        e,
        0,
        sizeof(e));

    put_u32(
        e,
        type);

    put_u32(
        e + 4,
        (uint32_t)kl);

    put_u32(
        e + 8,
        (uint32_t)rl);

    put_u32(
        e + 12,
        (uint32_t)tl);

    put_u64(
        e + 16,
        data_size);

    put_u64(
        e + 24,
        record_off);

    put_u64(
        e + 32,
        ts);

    if (id)
    {
        memcpy(
            e + 40,
            id,
            32);
    }

    if (write_all(
            fd,
            e,
            sizeof(e)) != 0)
    {
        die_errno(
            "write index entry");
    }

    if (kl &&
        write_all(
            fd,
            key,
            kl) != 0)
    {
        die_errno(
            "write index key");
    }

    if (rl &&
        write_all(
            fd,
            rel,
            rl) != 0)
    {
        die_errno(
            "write index relation");
    }

    if (tl &&
        write_all(
            fd,
            target,
            tl) != 0)
    {
        die_errno(
            "write index target");
    }
}

static void
build_state_from_data(
    int fd,
    idxmap *m,
    yoda_relations *rels)
{
    off_t size =
        file_size_fd(fd);

    off_t off = 0;

    while (off < size)
    {
        recmeta r;

        int rc =
            rec_meta_at(
                fd,
                off,
                &r,
                size);

        if (rc != 1)
        {
            die(
                "database log is corrupt or truncated");
        }

        if (r.type ==
            YODA_TYPE_PUT)
        {
            idx_put(
                m,
                r.key,
                r.record_off,
                r.id,
                r.ts);
        }
        else if (r.type ==
                 YODA_TYPE_LINK)
        {
            relations_add(
                rels,
                r.key,
                r.rel,
                r.target,
                r.ts,
                r.record_off,
                r.id);
        }

        off =
            r.next_off;

        rec_free(&r);
    }
}

static void
index_write_snapshot(
    const char *db,
    idxmap *m,
    yoda_relations *rels,
    off_t data_size)
{
    char *tmp =
        index_tmpfile(db);

    char *dst =
        indexfile(db);

    int fd =
        open(
            tmp,
            O_CREAT |
            O_TRUNC |
            O_WRONLY,
            0644);

    if (fd < 0)
        die_errno(
            "create index temp");

    uint8_t h[
        YODA_INDEX_HEADER_SIZE];

    memset(
        h,
        0,
        sizeof(h));

    memcpy(
        h,
        YODA_INDEX_MAGIC,
        8);

    put_u32(
        h + 8,
        YODA_INDEX_VERSION);

    put_u64(
        h + 16,
        (uint64_t)data_size);

    if (write_all(
            fd,
            h,
            sizeof(h)) != 0)
    {
        close(fd);

        die_errno(
            "write index header");
    }

    for (size_t i = 0;
         i < m->cap;
         i++)
    {
        if (!m->e[i].used)
            continue;

        index_write_entry(
            fd,
            YODA_INDEX_PUT,
            (uint64_t)data_size,
            (uint64_t)m->e[i].off,
            m->e[i].ts,
            m->e[i].id,
            m->e[i].key,
            "",
            "");
    }

    for (size_t i = 0;
         i < rels->n;
         i++)
    {
        yoda_relation *r =
            &rels->v[i];

        index_write_entry(
            fd,
            YODA_INDEX_LINK,
            (uint64_t)data_size,
            (uint64_t)r->record_off,
            r->ts,
            r->id,
            r->from,
            r->rel,
            r->to);
    }

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync index");
    }

    if (close(fd) != 0)
        die_errno(
            "close index");

    if (rename(
            tmp,
            dst) != 0)
    {
        die_errno(
            "rename index");
    }

    fsync_dir_path(db);

    free(tmp);
    free(dst);
}

static char *
index_read_string(
    int fd,
    off_t *off,
    uint32_t n,
    off_t size)
{
    if (n >
        YODA_MAX_META)
    {
        return NULL;
    }

    if (size - *off <
        (off_t)n)
    {
        return NULL;
    }

    char *s =
        malloc(
            (size_t)n + 1);

    if (!s)
        die("oom");

    if (n &&
        pread_all(
            fd,
            s,
            n,
            *off) != 1)
    {
        free(s);

        return NULL;
    }

    s[n] = 0;

    *off +=
        (off_t)n;

    return s;
}

static int
index_load_state(
    const char *db,
    int data_fd,
    idxmap *m,
    yoda_relations *rels,
    off_t expected_data_size)
{
    char *p =
        indexfile(db);

    int fd =
        open(
            p,
            O_RDONLY);

    free(p);

    if (fd < 0)
    {
        if (errno ==
            ENOENT)
        {
            return 0;
        }

        die_errno(
            "open index");
    }

    off_t size =
        file_size_fd(fd);

    if (size <
        (off_t)YODA_INDEX_HEADER_SIZE)
    {
        close(fd);

        return 0;
    }

    uint8_t h[
        YODA_INDEX_HEADER_SIZE];

    if (pread_all(
            fd,
            h,
            sizeof(h),
            0) != 1)
    {
        close(fd);

        return 0;
    }

    if (memcmp(
            h,
            YODA_INDEX_MAGIC,
            8) != 0 ||
        get_u32(
            h + 8) !=
            YODA_INDEX_VERSION)
    {
        close(fd);

        return 0;
    }

    uint64_t base_size =
        get_u64(
            h + 16);

    if (base_size >
        (uint64_t)expected_data_size)
    {
        close(fd);

        return 0;
    }

    uint64_t indexed_size =
        base_size;

    off_t off =
        YODA_INDEX_HEADER_SIZE;

    while (off < size)
    {
        if (size - off <
            (off_t)YODA_INDEX_ENTRY_FIXED)
        {
            close(fd);

            return 0;
        }

        uint8_t e[
            YODA_INDEX_ENTRY_FIXED];

        if (pread_all(
                fd,
                e,
                sizeof(e),
                off) != 1)
        {
            close(fd);

            return 0;
        }

        off +=
            YODA_INDEX_ENTRY_FIXED;

        uint32_t type =
            get_u32(e);

        uint32_t kl =
            get_u32(
                e + 4);

        uint32_t rl =
            get_u32(
                e + 8);

        uint32_t tl =
            get_u32(
                e + 12);

        uint64_t entry_data_size =
            get_u64(
                e + 16);

        uint64_t record_off =
            get_u64(
                e + 24);

        uint64_t ts =
            get_u64(
                e + 32);

        const uint8_t *id =
            e + 40;

        if (entry_data_size <
                indexed_size ||
            entry_data_size >
                (uint64_t)expected_data_size ||
            record_off >=
                entry_data_size)
        {
            close(fd);

            return 0;
        }

        char *key =
            index_read_string(
                fd,
                &off,
                kl,
                size);

        if (!key)
        {
            close(fd);

            return 0;
        }

        char *rel =
            index_read_string(
                fd,
                &off,
                rl,
                size);

        if (!rel)
        {
            free(key);
            close(fd);

            return 0;
        }

        char *target =
            index_read_string(
                fd,
                &off,
                tl,
                size);

        if (!target)
        {
            free(key);
            free(rel);
            close(fd);

            return 0;
        }

        recmeta r;

        int rc =
            rec_meta_at(
                data_fd,
                (off_t)record_off,
                &r,
                expected_data_size);

        if (rc != 1 ||
            r.next_off >
                (off_t)entry_data_size ||
            r.ts != ts ||
            memcmp(
                r.id,
                id,
                32) != 0)
        {
            if (rc == 1)
                rec_free(&r);

            free(key);
            free(rel);
            free(target);
            close(fd);

            return 0;
        }

        if (type ==
            YODA_INDEX_PUT)
        {
            if (r.type !=
                    YODA_TYPE_PUT ||
                rl != 0 ||
                tl != 0 ||
                strcmp(
                    r.key,
                    key) != 0)
            {
                rec_free(&r);

                free(key);
                free(rel);
                free(target);
                close(fd);

                return 0;
            }

            idx_put(
                m,
                key,
                (off_t)record_off,
                id,
                ts);
        }
        else if (type ==
                 YODA_INDEX_LINK)
        {
            if (r.type !=
                    YODA_TYPE_LINK ||
                strcmp(
                    r.key,
                    key) != 0 ||
                strcmp(
                    r.rel,
                    rel) != 0 ||
                strcmp(
                    r.target,
                    target) != 0)
            {
                rec_free(&r);

                free(key);
                free(rel);
                free(target);
                close(fd);

                return 0;
            }

            if (rels)
            {
                relations_add(
                    rels,
                    key,
                    rel,
                    target,
                    ts,
                    (off_t)record_off,
                    id);
            }
        }
        else
        {
            rec_free(&r);

            free(key);
            free(rel);
            free(target);
            close(fd);

            return 0;
        }

        rec_free(&r);

        free(key);
        free(rel);
        free(target);

        indexed_size =
            entry_data_size;
    }

    close(fd);

    return
        indexed_size ==
        (uint64_t)expected_data_size;
}

static void
index_reset(
    idxmap *m)
{
    idx_destroy(m);
    idx_init(m);
}

static void
load_or_rebuild_state(
    const char *db,
    int data_fd,
    idxmap *m,
    yoda_relations *rels)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    if (index_load_state(
            db,
            data_fd,
            m,
            rels,
            data_size))
    {
        return;
    }

    index_reset(m);

    if (rels)
    {
        relations_free(rels);
        relations_init(rels);
    }

    yoda_relations rebuilt;

    relations_init(
        &rebuilt);

    build_state_from_data(
        data_fd,
        m,
        &rebuilt);

    index_write_snapshot(
        db,
        m,
        &rebuilt,
        data_size);

    if (rels)
    {
        *rels =
            rebuilt;
    }
    else
    {
        relations_free(
            &rebuilt);
    }
}

static void
load_or_rebuild_index(
    const char *db,
    int data_fd,
    idxmap *m)
{
    load_or_rebuild_state(
        db,
        data_fd,
        m,
        NULL);
}

static int
index_open_append(
    const char *db)
{
    char *p =
        indexfile(db);

    int fd =
        open(
            p,
            O_WRONLY |
            O_APPEND);

    free(p);

    if (fd < 0)
        die_errno(
            "open index append");

    return fd;
}

static void
index_append_put(
    const char *db,
    int data_fd,
    off_t record_off)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    recmeta r;

    if (rec_meta_at(
            data_fd,
            record_off,
            &r,
            data_size) != 1)
    {
        die(
            "cannot read appended PUT");
    }

    if (r.type !=
        YODA_TYPE_PUT)
    {
        rec_free(&r);

        die(
            "appended record is not PUT");
    }

    int fd =
        index_open_append(
            db);

    index_write_entry(
        fd,
        YODA_INDEX_PUT,
        (uint64_t)data_size,
        (uint64_t)record_off,
        r.ts,
        r.id,
        r.key,
        "",
        "");

    if (fdatasync(fd) != 0)
    {
        close(fd);
        rec_free(&r);

        die_errno(
            "fdatasync index PUT");
    }

    close(fd);

    rec_free(&r);
}

static void
index_append_link(
    const char *db,
    int data_fd,
    off_t record_off)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    recmeta r;

    if (rec_meta_at(
            data_fd,
            record_off,
            &r,
            data_size) != 1)
    {
        die(
            "cannot read appended LINK");
    }

    if (r.type !=
        YODA_TYPE_LINK)
    {
        rec_free(&r);

        die(
            "appended record is not LINK");
    }

    int fd =
        index_open_append(
            db);

    index_write_entry(
        fd,
        YODA_INDEX_LINK,
        (uint64_t)data_size,
        (uint64_t)record_off,
        r.ts,
        r.id,
        r.key,
        r.rel,
        r.target);

    if (fdatasync(fd) != 0)
    {
        close(fd);
        rec_free(&r);

        die_errno(
            "fdatasync index LINK");
    }

    close(fd);

    rec_free(&r);
}
/* ============================================================
 * DIRECT PERSISTENT LOOKUP
 * ============================================================ */

#define YODA_LOOKUP_MAGIC "YLKP001\0"
#define YODA_LOOKUP_VERSION 1u

#define YODA_LOOKUP_HEADER_SIZE 64u
#define YODA_LOOKUP_SLOT_SIZE   64u

#define YODA_LOOKUP_EMPTY 0u
#define YODA_LOOKUP_USED  1u

static char *
lookupfile(const char *db)
{
    size_t n =
        strlen(db) + 13;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/lookup.yoda",
        db);

    return p;
}

static char *
lookup_tmpfile(const char *db)
{
    size_t n =
        strlen(db) + 17;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/lookup.yoda.tmp",
        db);

    return p;
}

static int
lookup_pwrite_all(
    int fd,
    const void *vp,
    size_t n,
    off_t off)
{
    const uint8_t *p =
        vp;

    while (n)
    {
        ssize_t w =
            pwrite(
                fd,
                p,
                n,
                off);

        if (w < 0)
        {
            if (errno == EINTR)
                continue;

            return -1;
        }

        if (w == 0)
            return -1;

        p += w;
        off += w;
        n -= (size_t)w;
    }

    return 0;
}

static uint64_t
lookup_slots_for_count(
    size_t count)
{
    uint64_t slots = 16;

    while ((uint64_t)count >
           (slots * 7u) / 10u)
    {
        if (slots >
            (UINT64_MAX / 2u))
        {
            die(
                "lookup capacity overflow");
        }

        slots *= 2u;
    }

    return slots;
}

static off_t
lookup_slot_offset(
    uint64_t slot)
{
    return
        (off_t)YODA_LOOKUP_HEADER_SIZE +
        (off_t)(
            slot *
            YODA_LOOKUP_SLOT_SIZE);
}

static void
lookup_header_encode(
    uint8_t h[YODA_LOOKUP_HEADER_SIZE],
    uint64_t committed_end,
    uint64_t slots,
    uint64_t used)
{
    memset(
        h,
        0,
        YODA_LOOKUP_HEADER_SIZE);

    memcpy(
        h,
        YODA_LOOKUP_MAGIC,
        8);

    put_u32(
        h + 8,
        YODA_LOOKUP_VERSION);

    put_u64(
        h + 16,
        committed_end);

    put_u64(
        h + 24,
        slots);

    put_u64(
        h + 32,
        used);
}

static void
lookup_header_write_fd(
    int fd,
    uint64_t committed_end,
    uint64_t slots,
    uint64_t used)
{
    uint8_t h[
        YODA_LOOKUP_HEADER_SIZE];

    lookup_header_encode(
        h,
        committed_end,
        slots,
        used);

    if (lookup_pwrite_all(
            fd,
            h,
            sizeof(h),
            0) != 0)
    {
        die_errno(
            "write lookup header");
    }
}

static void
lookup_slot_encode(
    uint8_t slot[YODA_LOOKUP_SLOT_SIZE],
    uint64_t key_hash,
    uint64_t record_off,
    uint64_t ts,
    const uint8_t id[32])
{
    memset(
        slot,
        0,
        YODA_LOOKUP_SLOT_SIZE);

    put_u32(
        slot,
        YODA_LOOKUP_USED);

    put_u64(
        slot + 8,
        key_hash);

    put_u64(
        slot + 16,
        record_off);

    put_u64(
        slot + 24,
        ts);

    memcpy(
        slot + 32,
        id,
        32);
}

static int
lookup_slot_matches_key(
    int data_fd,
    off_t data_size,
    const uint8_t slot[YODA_LOOKUP_SLOT_SIZE],
    const char *key)
{
    uint64_t record_off =
        get_u64(
            slot + 16);

    if (record_off >=
        (uint64_t)data_size)
    {
        return -1;
    }

    recmeta r;

    int rc =
        rec_meta_at(
            data_fd,
            (off_t)record_off,
            &r,
            data_size);

    if (rc != 1)
        return -1;

    int valid =
        r.type ==
            YODA_TYPE_PUT &&
        r.ts ==
            get_u64(
                slot + 24) &&
        memcmp(
            r.id,
            slot + 32,
            32) == 0;

    if (!valid)
    {
        rec_free(&r);
        return -1;
    }

    int match =
        strcmp(
            r.key,
            key) == 0;

    rec_free(&r);

    return match;
}

static int
lookup_open_valid(
    const char *db,
    uint64_t expected_end,
    int *fd_out,
    uint64_t *slots_out,
    uint64_t *used_out)
{
    char *p =
        lookupfile(db);

    int fd =
        open(
            p,
            O_RDWR);

    free(p);

    if (fd < 0)
        return 0;

    off_t size =
        file_size_fd(fd);

    if (size <
        (off_t)YODA_LOOKUP_HEADER_SIZE)
    {
        close(fd);
        return 0;
    }

    uint8_t h[
        YODA_LOOKUP_HEADER_SIZE];

    if (pread_all(
            fd,
            h,
            sizeof(h),
            0) != 1)
    {
        close(fd);
        return 0;
    }

    if (memcmp(
            h,
            YODA_LOOKUP_MAGIC,
            8) != 0 ||
        get_u32(
            h + 8) !=
            YODA_LOOKUP_VERSION)
    {
        close(fd);
        return 0;
    }

    uint64_t committed_end =
        get_u64(
            h + 16);

    uint64_t slots =
        get_u64(
            h + 24);

    uint64_t used =
        get_u64(
            h + 32);

    if (committed_end !=
        expected_end)
    {
        close(fd);
        return 0;
    }

    if (slots < 16 ||
        (slots &
         (slots - 1u)) != 0)
    {
        close(fd);
        return 0;
    }

    if (used > slots)
    {
        close(fd);
        return 0;
    }

    if (slots >
        (UINT64_MAX -
         YODA_LOOKUP_HEADER_SIZE) /
        YODA_LOOKUP_SLOT_SIZE)
    {
        close(fd);
        return 0;
    }

    uint64_t expected_size =
        YODA_LOOKUP_HEADER_SIZE +
        slots *
        YODA_LOOKUP_SLOT_SIZE;

    if ((uint64_t)size !=
        expected_size)
    {
        close(fd);
        return 0;
    }

    *fd_out =
        fd;

    *slots_out =
        slots;

    *used_out =
        used;

    return 1;
}

static void
lookup_snapshot_insert(
    int fd,
    uint64_t slots,
    const char *key,
    off_t record_off,
    uint64_t ts,
    const uint8_t id[32])
{
    uint64_t h =
        hash_key(key);

    uint64_t mask =
        slots - 1u;

    uint64_t pos =
        h & mask;

    uint8_t slot[
        YODA_LOOKUP_SLOT_SIZE];

    for (uint64_t probe = 0;
         probe < slots;
         probe++)
    {
        off_t off =
            lookup_slot_offset(
                pos);

        if (pread_all(
                fd,
                slot,
                sizeof(slot),
                off) != 1)
        {
            die(
                "cannot read lookup slot");
        }

        uint32_t state =
            get_u32(slot);

        if (state ==
            YODA_LOOKUP_EMPTY)
        {
            lookup_slot_encode(
                slot,
                h,
                (uint64_t)record_off,
                ts,
                id);

            if (lookup_pwrite_all(
                    fd,
                    slot,
                    sizeof(slot),
                    off) != 0)
            {
                die_errno(
                    "write lookup slot");
            }

            return;
        }

        pos =
            (pos + 1u) &
            mask;
    }

    die(
        "lookup table full");
}

static void
lookup_rebuild(
    const char *db,
    int data_fd)
{
    idxmap m;

    idx_init(&m);

    yoda_relations rels;

    relations_init(
        &rels);

    build_state_from_data(
        data_fd,
        &m,
        &rels);

    relations_free(
        &rels);

    uint64_t slots =
        lookup_slots_for_count(
            m.len);

    char *tmp =
        lookup_tmpfile(db);

    char *dst =
        lookupfile(db);

    int fd =
        open(
            tmp,
            O_CREAT |
            O_TRUNC |
            O_RDWR,
            0644);

    if (fd < 0)
        die_errno(
            "create lookup temp");

    uint64_t total =
        YODA_LOOKUP_HEADER_SIZE +
        slots *
        YODA_LOOKUP_SLOT_SIZE;

    if (total >
        (uint64_t)INT64_MAX)
    {
        close(fd);

        die(
            "lookup file too large");
    }

    if (ftruncate(
            fd,
            (off_t)total) != 0)
    {
        close(fd);

        die_errno(
            "size lookup file");
    }

    off_t data_size =
        file_size_fd(
            data_fd);

    lookup_header_write_fd(
        fd,
        (uint64_t)data_size,
        slots,
        (uint64_t)m.len);

    for (size_t i = 0;
         i < m.cap;
         i++)
    {
        if (!m.e[i].used)
            continue;

        lookup_snapshot_insert(
            fd,
            slots,
            m.e[i].key,
            m.e[i].off,
            m.e[i].ts,
            m.e[i].id);
    }

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync lookup");
    }

    if (close(fd) != 0)
        die_errno(
            "close lookup");

    if (rename(
            tmp,
            dst) != 0)
    {
        die_errno(
            "rename lookup");
    }

    fsync_dir_path(db);

    free(tmp);
    free(dst);

    idx_destroy(&m);
}

static int
lookup_find_raw(
    const char *db,
    int data_fd,
    const char *key,
    off_t *record_off_out)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    int fd = -1;

    uint64_t slots = 0;
    uint64_t used = 0;

    if (!lookup_open_valid(
            db,
            (uint64_t)data_size,
            &fd,
            &slots,
            &used))
    {
        return -1;
    }

    (void)used;

    uint64_t h =
        hash_key(key);

    uint64_t mask =
        slots - 1u;

    uint64_t pos =
        h & mask;

    uint8_t slot[
        YODA_LOOKUP_SLOT_SIZE];

    for (uint64_t probe = 0;
         probe < slots;
         probe++)
    {
        off_t off =
            lookup_slot_offset(
                pos);

        if (pread_all(
                fd,
                slot,
                sizeof(slot),
                off) != 1)
        {
            close(fd);
            return -1;
        }

        uint32_t state =
            get_u32(slot);

        if (state ==
            YODA_LOOKUP_EMPTY)
        {
            close(fd);
            return 0;
        }

        if (state !=
            YODA_LOOKUP_USED)
        {
            close(fd);
            return -1;
        }

        if (get_u64(
                slot + 8) ==
            h)
        {
            int match =
                lookup_slot_matches_key(
                    data_fd,
                    data_size,
                    slot,
                    key);

            if (match < 0)
            {
                close(fd);
                return -1;
            }

            if (match)
            {
                *record_off_out =
                    (off_t)get_u64(
                        slot + 16);

                close(fd);

                return 1;
            }
        }

        pos =
            (pos + 1u) &
            mask;
    }

    close(fd);

    return 0;
}

static int
lookup_find(
    const char *db,
    int data_fd,
    const char *key,
    off_t *record_off_out)
{
    int rc =
        lookup_find_raw(
            db,
            data_fd,
            key,
            record_off_out);

    if (rc >= 0)
        return rc;

    lookup_rebuild(
        db,
        data_fd);

    rc =
        lookup_find_raw(
            db,
            data_fd,
            key,
            record_off_out);

    if (rc < 0)
        die(
            "lookup rebuild failed");

    return rc;
}

static void
lookup_update_after_put(
    const char *db,
    int data_fd,
    off_t record_off)
{
    off_t new_size =
        file_size_fd(
            data_fd);

    recmeta new_record;

    if (rec_meta_at(
            data_fd,
            record_off,
            &new_record,
            new_size) != 1)
    {
        die(
            "cannot read new PUT for lookup");
    }

    if (new_record.type !=
        YODA_TYPE_PUT)
    {
        rec_free(
            &new_record);

        die(
            "lookup update expected PUT");
    }

    int fd = -1;

    uint64_t slots = 0;
    uint64_t used = 0;

    if (!lookup_open_valid(
            db,
            (uint64_t)record_off,
            &fd,
            &slots,
            &used))
    {
        rec_free(
            &new_record);

        lookup_rebuild(
            db,
            data_fd);

        return;
    }

    uint64_t h =
        hash_key(
            new_record.key);

    uint64_t mask =
        slots - 1u;

    uint64_t pos =
        h & mask;

    uint8_t slot[
        YODA_LOOKUP_SLOT_SIZE];

    for (uint64_t probe = 0;
         probe < slots;
         probe++)
    {
        off_t slot_off =
            lookup_slot_offset(
                pos);

        if (pread_all(
                fd,
                slot,
                sizeof(slot),
                slot_off) != 1)
        {
            close(fd);

            rec_free(
                &new_record);

            lookup_rebuild(
                db,
                data_fd);

            return;
        }

        uint32_t state =
            get_u32(slot);

        if (state ==
            YODA_LOOKUP_EMPTY)
        {
            if ((used + 1u) >
                (slots * 7u) / 10u)
            {
                close(fd);

                rec_free(
                    &new_record);

                lookup_rebuild(
                    db,
                    data_fd);

                return;
            }

            lookup_slot_encode(
                slot,
                h,
                (uint64_t)record_off,
                new_record.ts,
                new_record.id);

            if (lookup_pwrite_all(
                    fd,
                    slot,
                    sizeof(slot),
                    slot_off) != 0)
            {
                close(fd);
                rec_free(&new_record);

                die_errno(
                    "update lookup slot");
            }

            used++;

            lookup_header_write_fd(
                fd,
                (uint64_t)new_size,
                slots,
                used);

            if (fdatasync(fd) != 0)
            {
                close(fd);
                rec_free(&new_record);

                die_errno(
                    "fdatasync lookup update");
            }

            close(fd);

            rec_free(
                &new_record);

            return;
        }

        if (state !=
            YODA_LOOKUP_USED)
        {
            close(fd);

            rec_free(
                &new_record);

            lookup_rebuild(
                db,
                data_fd);

            return;
        }

        if (get_u64(
                slot + 8) ==
            h)
        {
            int match =
                lookup_slot_matches_key(
                    data_fd,
                    new_size,
                    slot,
                    new_record.key);

            if (match < 0)
            {
                close(fd);

                rec_free(
                    &new_record);

                lookup_rebuild(
                    db,
                    data_fd);

                return;
            }

            if (match)
            {
                lookup_slot_encode(
                    slot,
                    h,
                    (uint64_t)record_off,
                    new_record.ts,
                    new_record.id);

                if (lookup_pwrite_all(
                        fd,
                        slot,
                        sizeof(slot),
                        slot_off) != 0)
                {
                    close(fd);
                    rec_free(&new_record);

                    die_errno(
                        "replace lookup slot");
                }

                lookup_header_write_fd(
                    fd,
                    (uint64_t)new_size,
                    slots,
                    used);

                if (fdatasync(fd) != 0)
                {
                    close(fd);
                    rec_free(&new_record);

                    die_errno(
                        "fdatasync lookup replace");
                }

                close(fd);

                rec_free(
                    &new_record);

                return;
            }
        }

        pos =
            (pos + 1u) &
            mask;
    }

    close(fd);

    rec_free(
        &new_record);

    lookup_rebuild(
        db,
        data_fd);
}

static void
lookup_advance_after_nonput(
    const char *db,
    int data_fd,
    off_t previous_end)
{
    off_t new_size =
        file_size_fd(
            data_fd);

    int fd = -1;

    uint64_t slots = 0;
    uint64_t used = 0;

    if (!lookup_open_valid(
            db,
            (uint64_t)previous_end,
            &fd,
            &slots,
            &used))
    {
        lookup_rebuild(
            db,
            data_fd);

        return;
    }

    lookup_header_write_fd(
        fd,
        (uint64_t)new_size,
        slots,
        used);

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync lookup advance");
    }

    close(fd);
}
/* ============================================================
 * WRITE DERIVED-STATE FAST PATH
 * ============================================================ */

static int
index_quick_usable(
    const char *db)
{
    char *p =
        indexfile(db);

    int fd =
        open(
            p,
            O_RDONLY);

    free(p);

    if (fd < 0)
        return 0;

    off_t size =
        file_size_fd(fd);

    if (size <
        (off_t)YODA_INDEX_HEADER_SIZE)
    {
        close(fd);
        return 0;
    }

    uint8_t h[
        YODA_INDEX_HEADER_SIZE];

    int rc =
        pread_all(
            fd,
            h,
            sizeof(h),
            0);

    close(fd);

    if (rc != 1)
        return 0;

    if (memcmp(
            h,
            YODA_INDEX_MAGIC,
            8) != 0)
    {
        return 0;
    }

    if (get_u32(
            h + 8) !=
        YODA_INDEX_VERSION)
    {
        return 0;
    }

    return 1;
}

static int
lookup_quick_current(
    const char *db,
    int data_fd)
{
    int lookup_fd = -1;

    uint64_t slots = 0;
    uint64_t used = 0;

    off_t data_size =
        file_size_fd(
            data_fd);

    int ok =
        lookup_open_valid(
            db,
            (uint64_t)data_size,
            &lookup_fd,
            &slots,
            &used);

    (void)slots;
    (void)used;

    if (ok)
        close(lookup_fd);

    return ok;
}

static void
derived_state_rebuild_for_write(
    const char *db,
    int data_fd)
{
    idxmap m;

    idx_init(&m);

    /*
     * index.yoda remains independently rebuildable.
     * This full path is recovery-only, not the normal PUT path.
     */
    load_or_rebuild_index(
        db,
        data_fd,
        &m);

    idx_destroy(&m);

    lookup_rebuild(
        db,
        data_fd);
}

static void
derived_state_ensure_for_write(
    const char *db,
    int data_fd)
{
    if (index_quick_usable(db) &&
        lookup_quick_current(
            db,
            data_fd))
    {
        return;
    }

    derived_state_rebuild_for_write(
        db,
        data_fd);
}

static int
direct_lookup_record(
    const char *db,
    int data_fd,
    const char *key,
    off_t *record_off)
{
    int rc =
        lookup_find_raw(
            db,
            data_fd,
            key,
            record_off);

    if (rc < 0)
    {
        derived_state_rebuild_for_write(
            db,
            data_fd);

        rc =
            lookup_find_raw(
                db,
                data_fd,
                key,
                record_off);
    }

    if (rc < 0)
        die(
            "direct lookup unavailable after rebuild");

    return rc;
}
/* ============================================================
 * DERIVED LEXICAL TERMS INDEX
 * ============================================================ */

#define YODA_TERMS_MAGIC "YTRM001\0"
#define YODA_TERMS_VERSION 1u

#define YODA_TERMS_HEADER_SIZE 64u
#define YODA_TERMS_SLOT_SIZE   80u
#define YODA_TERMS_POST_SIZE   16u

#define YODA_TERMS_SLOTS 4096u
#define YODA_TERM_MAX    47u

#define YODA_TERMS_EMPTY 0u
#define YODA_TERMS_USED  1u

static char *
termsfile(const char *db)
{
    size_t n =
        strlen(db) + 12;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/terms.yoda",
        db);

    return p;
}

static char *
terms_tmpfile(const char *db)
{
    size_t n =
        strlen(db) + 16;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/terms.yoda.tmp",
        db);

    return p;
}

static off_t
terms_slot_offset(
    uint64_t slot)
{
    return
        (off_t)YODA_TERMS_HEADER_SIZE +
        (off_t)(
            slot *
            YODA_TERMS_SLOT_SIZE);
}

static off_t
terms_postings_start(void)
{
    return
        (off_t)YODA_TERMS_HEADER_SIZE +
        (off_t)(
            YODA_TERMS_SLOTS *
            YODA_TERMS_SLOT_SIZE);
}

static int
terms_pwrite_all(
    int fd,
    const void *vp,
    size_t n,
    off_t off)
{
    const uint8_t *p =
        vp;

    while (n)
    {
        ssize_t w =
            pwrite(
                fd,
                p,
                n,
                off);

        if (w < 0)
        {
            if (errno == EINTR)
                continue;

            return -1;
        }

        if (w == 0)
            return -1;

        p += w;
        off += w;
        n -= (size_t)w;
    }

    return 0;
}

static int
term_has_alpha(
    const char *s)
{
    while (*s)
    {
        if (isalpha(
                (unsigned char)*s))
        {
            return 1;
        }

        s++;
    }

    return 0;
}

static int
term_normalize(
    const char *src,
    size_t n,
    char out[YODA_TERM_MAX + 1])
{
    size_t j = 0;

    for (size_t i = 0;
         i < n;
         i++)
    {
        unsigned char c =
            (unsigned char)src[i];

        if (!isalnum(c) &&
            c != '_' &&
            c != '-')
        {
            continue;
        }

        if (j >=
            YODA_TERM_MAX)
        {
            return 0;
        }

        out[j++] =
            (char)tolower(c);
    }

    out[j] = 0;

    if (j < 2)
        return 0;

    if (!term_has_alpha(out))
        return 0;

    return 1;
}

static void
terms_header_write(
    int fd,
    uint64_t committed_end,
    uint64_t used)
{
    uint8_t h[
        YODA_TERMS_HEADER_SIZE];

    memset(
        h,
        0,
        sizeof(h));

    memcpy(
        h,
        YODA_TERMS_MAGIC,
        8);

    put_u32(
        h + 8,
        YODA_TERMS_VERSION);

    put_u64(
        h + 16,
        committed_end);

    put_u64(
        h + 24,
        YODA_TERMS_SLOTS);

    put_u64(
        h + 32,
        used);

    if (terms_pwrite_all(
            fd,
            h,
            sizeof(h),
            0) != 0)
    {
        die_errno(
            "write terms header");
    }
}

static int
terms_header_read(
    int fd,
    uint64_t *committed_end,
    uint64_t *used)
{
    if (file_size_fd(fd) <
        terms_postings_start())
    {
        return 0;
    }

    uint8_t h[
        YODA_TERMS_HEADER_SIZE];

    if (pread_all(
            fd,
            h,
            sizeof(h),
            0) != 1)
    {
        return 0;
    }

    if (memcmp(
            h,
            YODA_TERMS_MAGIC,
            8) != 0)
    {
        return 0;
    }

    if (get_u32(
            h + 8) !=
        YODA_TERMS_VERSION)
    {
        return 0;
    }

    if (get_u64(
            h + 24) !=
        YODA_TERMS_SLOTS)
    {
        return 0;
    }

    uint64_t u =
        get_u64(
            h + 32);

    if (u >
        YODA_TERMS_SLOTS)
    {
        return 0;
    }

    *committed_end =
        get_u64(
            h + 16);

    *used =
        u;

    return 1;
}

static int
terms_open_valid(
    const char *db,
    uint64_t expected_end,
    int flags,
    int *fd_out,
    uint64_t *used_out)
{
    char *p =
        termsfile(db);

    int fd =
        open(
            p,
            flags);

    free(p);

    if (fd < 0)
        return 0;

    uint64_t committed_end = 0;
    uint64_t used = 0;

    if (!terms_header_read(
            fd,
            &committed_end,
            &used))
    {
        close(fd);
        return 0;
    }

    if (committed_end !=
        expected_end)
    {
        close(fd);
        return 0;
    }

    *fd_out =
        fd;

    *used_out =
        used;

    return 1;
}

static void
terms_slot_encode(
    uint8_t slot[YODA_TERMS_SLOT_SIZE],
    const char *term,
    uint64_t hash,
    uint64_t head,
    uint64_t count)
{
    size_t n =
        strlen(term);

    memset(
        slot,
        0,
        YODA_TERMS_SLOT_SIZE);

    put_u32(
        slot,
        YODA_TERMS_USED);

    put_u32(
        slot + 4,
        (uint32_t)n);

    put_u64(
        slot + 8,
        hash);

    put_u64(
        slot + 16,
        head);

    put_u64(
        slot + 24,
        count);

    memcpy(
        slot + 32,
        term,
        n);
}

static int
terms_slot_term_equal(
    const uint8_t slot[YODA_TERMS_SLOT_SIZE],
    const char *term)
{
    uint32_t n =
        get_u32(
            slot + 4);

    size_t tn =
        strlen(term);

    if ((size_t)n != tn)
        return 0;

    if (n >
        YODA_TERM_MAX)
    {
        return 0;
    }

    return
        memcmp(
            slot + 32,
            term,
            n) == 0;
}

static int
terms_find_slot(
    int fd,
    const char *term,
    uint64_t *slot_number,
    uint8_t slot_out[YODA_TERMS_SLOT_SIZE])
{
    uint64_t hash =
        hash_key(term);

    uint64_t mask =
        YODA_TERMS_SLOTS - 1u;

    uint64_t pos =
        hash & mask;

    uint8_t slot[
        YODA_TERMS_SLOT_SIZE];

    for (uint64_t probe = 0;
         probe <
            YODA_TERMS_SLOTS;
         probe++)
    {
        off_t off =
            terms_slot_offset(
                pos);

        if (pread_all(
                fd,
                slot,
                sizeof(slot),
                off) != 1)
        {
            return -1;
        }

        uint32_t state =
            get_u32(slot);

        if (state ==
            YODA_TERMS_EMPTY)
        {
            *slot_number =
                pos;

            memcpy(
                slot_out,
                slot,
                sizeof(slot));

            return 0;
        }

        if (state !=
            YODA_TERMS_USED)
        {
            return -1;
        }

        if (get_u64(
                slot + 8) ==
                hash &&
            terms_slot_term_equal(
                slot,
                term))
        {
            *slot_number =
                pos;

            memcpy(
                slot_out,
                slot,
                sizeof(slot));

            return 1;
        }

        pos =
            (pos + 1u) &
            mask;
    }

    return -2;
}

static int
terms_append_posting(
    int fd,
    uint64_t *used,
    const char *term,
    off_t record_off)
{
    uint64_t slot_number = 0;

    uint8_t slot[
        YODA_TERMS_SLOT_SIZE];

    int found =
        terms_find_slot(
            fd,
            term,
            &slot_number,
            slot);

    if (found == -2)
        return 0;

    if (found < 0)
        return -1;

    uint64_t old_head = 0;
    uint64_t count = 0;

    if (found)
    {
        old_head =
            get_u64(
                slot + 16);

        count =
            get_u64(
                slot + 24);
    }
    else
    {
        if (*used >=
            YODA_TERMS_SLOTS)
        {
            return 0;
        }

        (*used)++;
    }

    off_t post_off =
        lseek(
            fd,
            0,
            SEEK_END);

    if (post_off < 0)
        return -1;

    uint8_t post[
        YODA_TERMS_POST_SIZE];

    memset(
        post,
        0,
        sizeof(post));

    put_u64(
        post,
        (uint64_t)record_off);

    put_u64(
        post + 8,
        old_head);

    if (write_all(
            fd,
            post,
            sizeof(post)) != 0)
    {
        return -1;
    }

    terms_slot_encode(
        slot,
        term,
        hash_key(term),
        (uint64_t)post_off,
        count + 1u);

    if (terms_pwrite_all(
            fd,
            slot,
            sizeof(slot),
            terms_slot_offset(
                slot_number)) != 0)
    {
        return -1;
    }

    return 1;
}

static int
terms_index_text(
    int fd,
    uint64_t *used,
    const uint8_t *text,
    size_t n,
    off_t record_off)
{
    size_t start = 0;

    for (size_t i = 0;
         i <= n;
         i++)
    {
        int sep =
            i == n;

        if (!sep)
        {
            unsigned char c =
                text[i];

            sep =
                !isalnum(c) &&
                c != '_' &&
                c != '-';
        }

        if (!sep)
            continue;

        if (i > start)
        {
            char term[
                YODA_TERM_MAX + 1];

            if (term_normalize(
                    (const char *)
                        text + start,
                    i - start,
                    term))
            {
                int rc =
                    terms_append_posting(
                        fd,
                        used,
                        term,
                        record_off);

                if (rc <= 0)
                    return rc;
            }
        }

        start =
            i + 1;
    }

    return 1;
}

static int
terms_index_record(
    int terms_fd,
    uint64_t *used,
    int data_fd,
    const recmeta *r)
{
    if (r->type !=
        YODA_TYPE_PUT)
    {
        return 1;
    }

    int rc =
        terms_index_text(
            terms_fd,
            used,
            (const uint8_t *)r->key,
            r->key_len,
            r->record_off);

    if (rc <= 0)
        return rc;

    rc =
        terms_index_text(
            terms_fd,
            used,
            (const uint8_t *)r->source,
            r->source_len,
            r->record_off);

    if (rc <= 0)
        return rc;

    if (r->value_len == 0)
        return 1;

    if (r->value_len >
        SIZE_MAX)
    {
        return -1;
    }

    size_t vn =
        (size_t)r->value_len;

    uint8_t *value =
        malloc(
            vn
                ? vn
                : 1);

    if (!value)
        die("oom");

    if (pread_all(
            data_fd,
            value,
            vn,
            r->value_off) != 1)
    {
        free(value);

        return -1;
    }

    rc =
        terms_index_text(
            terms_fd,
            used,
            value,
            vn,
            r->record_off);

    free(value);

    return rc;
}

static void
terms_rebuild(
    const char *db,
    int data_fd)
{
    char *tmp =
        terms_tmpfile(db);

    char *dst =
        termsfile(db);

    int fd =
        open(
            tmp,
            O_CREAT |
            O_TRUNC |
            O_RDWR,
            0644);

    if (fd < 0)
        die_errno(
            "create terms temp");

    off_t base =
        terms_postings_start();

    if (ftruncate(
            fd,
            base) != 0)
    {
        close(fd);

        die_errno(
            "size terms table");
    }

    uint64_t used = 0;

    terms_header_write(
        fd,
        0,
        used);

    off_t data_size =
        file_size_fd(
            data_fd);

    off_t off = 0;

    while (off <
           data_size)
    {
        recmeta r;

        if (rec_meta_at(
                data_fd,
                off,
                &r,
                data_size) != 1)
        {
            close(fd);

            die(
                "cannot rebuild terms from data");
        }

        int rc =
            terms_index_record(
                fd,
                &used,
                data_fd,
                &r);

        off =
            r.next_off;

        rec_free(&r);

        if (rc == 0)
        {
            close(fd);

            die(
                "terms table capacity exhausted");
        }

        if (rc < 0)
        {
            close(fd);

            die(
                "terms rebuild failed");
        }
    }

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync terms body");
    }

    terms_header_write(
        fd,
        (uint64_t)data_size,
        used);

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync terms header");
    }

    if (close(fd) != 0)
        die_errno(
            "close terms");

    if (rename(
            tmp,
            dst) != 0)
    {
        die_errno(
            "rename terms");
    }

    fsync_dir_path(db);

    free(tmp);
    free(dst);
}

static int
terms_open_current(
    const char *db,
    int data_fd)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    int fd = -1;
    uint64_t used = 0;

    if (terms_open_valid(
            db,
            (uint64_t)data_size,
            O_RDONLY,
            &fd,
            &used))
    {
        (void)used;

        return fd;
    }

    terms_rebuild(
        db,
        data_fd);

    if (!terms_open_valid(
            db,
            (uint64_t)data_size,
            O_RDONLY,
            &fd,
            &used))
    {
        die(
            "terms rebuild did not produce valid index");
    }

    return fd;
}

static void
terms_update_after_put(
    const char *db,
    int data_fd,
    off_t record_off)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    int fd = -1;
    uint64_t used = 0;

    if (!terms_open_valid(
            db,
            (uint64_t)record_off,
            O_RDWR,
            &fd,
            &used))
    {
        terms_rebuild(
            db,
            data_fd);

        return;
    }

    recmeta r;

    if (rec_meta_at(
            data_fd,
            record_off,
            &r,
            data_size) != 1)
    {
        close(fd);

        die(
            "cannot read PUT for terms");
    }

    int rc =
        terms_index_record(
            fd,
            &used,
            data_fd,
            &r);

    rec_free(&r);

    if (rc == 0)
    {
        close(fd);

        terms_rebuild(
            db,
            data_fd);

        return;
    }

    if (rc < 0)
    {
        close(fd);

        die(
            "incremental terms update failed");
    }

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync terms postings");
    }

    terms_header_write(
        fd,
        (uint64_t)data_size,
        used);

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync terms checkpoint");
    }

    close(fd);
}

static void
terms_advance_after_nonput(
    const char *db,
    int data_fd,
    off_t previous_end)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    int fd = -1;
    uint64_t used = 0;

    if (!terms_open_valid(
            db,
            (uint64_t)previous_end,
            O_RDWR,
            &fd,
            &used))
    {
        terms_rebuild(
            db,
            data_fd);

        return;
    }

    terms_header_write(
        fd,
        (uint64_t)data_size,
        used);

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync terms advance");
    }

    close(fd);
}

static int
terms_lookup_term(
    int fd,
    const char *term,
    uint64_t *head,
    uint64_t *count)
{
    uint64_t slot_number = 0;

    uint8_t slot[
        YODA_TERMS_SLOT_SIZE];

    int rc =
        terms_find_slot(
            fd,
            term,
            &slot_number,
            slot);

    (void)slot_number;

    if (rc <= 0)
        return rc;

    uint64_t h =
        get_u64(
            slot + 16);

    uint64_t c =
        get_u64(
            slot + 24);

    off_t size =
        file_size_fd(fd);

    if (h != 0 &&
        (h <
             (uint64_t)
             terms_postings_start() ||
         h +
             YODA_TERMS_POST_SIZE >
             (uint64_t)size))
    {
        return -1;
    }

    *head =
        h;

    *count =
        c;

    return 1;
}

static int
terms_read_posting(
    int fd,
    uint64_t posting_off,
    uint64_t *record_off,
    uint64_t *next)
{
    off_t size =
        file_size_fd(fd);

    if (posting_off <
            (uint64_t)
            terms_postings_start() ||
        posting_off +
            YODA_TERMS_POST_SIZE >
            (uint64_t)size)
    {
        return 0;
    }

    uint8_t p[
        YODA_TERMS_POST_SIZE];

    if (pread_all(
            fd,
            p,
            sizeof(p),
            (off_t)posting_off) != 1)
    {
        return 0;
    }

    *record_off =
        get_u64(p);

    *next =
        get_u64(
            p + 8);

    return 1;
}
/* ============================================================
 * DERIVED RELATION EDGE INDEX
 * ============================================================ */

#define YODA_EDGES_MAGIC "YEDG001\0"
#define YODA_EDGES_VERSION 1u

#define YODA_EDGES_HEADER_SIZE 64u
#define YODA_EDGES_SLOT_SIZE   32u
#define YODA_EDGES_POST_SIZE   16u

#define YODA_EDGES_EMPTY 0u
#define YODA_EDGES_USED  1u

static char *
edgesfile(const char *db)
{
    size_t n =
        strlen(db) + 12;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/edges.yoda",
        db);

    return p;
}

static char *
edges_tmpfile(const char *db)
{
    size_t n =
        strlen(db) + 16;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/edges.yoda.tmp",
        db);

    return p;
}

static int
edges_pwrite_all(
    int fd,
    const void *vp,
    size_t n,
    off_t off)
{
    const uint8_t *p =
        vp;

    while (n)
    {
        ssize_t w =
            pwrite(
                fd,
                p,
                n,
                off);

        if (w < 0)
        {
            if (errno == EINTR)
                continue;

            return -1;
        }

        if (w == 0)
            return -1;

        p += w;
        off += w;
        n -= (size_t)w;
    }

    return 0;
}

static uint64_t
edges_slots_for_endpoints(
    uint64_t endpoints)
{
    uint64_t slots = 16;

    while (endpoints >
           (slots * 7u) / 10u)
    {
        if (slots >
            UINT64_MAX / 2u)
        {
            die(
                "edges capacity overflow");
        }

        slots *= 2u;
    }

    return slots;
}

static off_t
edges_slot_offset(
    uint64_t slot)
{
    return
        (off_t)YODA_EDGES_HEADER_SIZE +
        (off_t)(
            slot *
            YODA_EDGES_SLOT_SIZE);
}

static off_t
edges_postings_start(
    uint64_t slots)
{
    return
        (off_t)YODA_EDGES_HEADER_SIZE +
        (off_t)(
            slots *
            YODA_EDGES_SLOT_SIZE);
}

static void
edges_header_write(
    int fd,
    uint64_t committed_end,
    uint64_t slots,
    uint64_t used,
    uint64_t postings)
{
    uint8_t h[
        YODA_EDGES_HEADER_SIZE];

    memset(
        h,
        0,
        sizeof(h));

    memcpy(
        h,
        YODA_EDGES_MAGIC,
        8);

    put_u32(
        h + 8,
        YODA_EDGES_VERSION);

    put_u64(
        h + 16,
        committed_end);

    put_u64(
        h + 24,
        slots);

    put_u64(
        h + 32,
        used);

    put_u64(
        h + 40,
        postings);

    if (edges_pwrite_all(
            fd,
            h,
            sizeof(h),
            0) != 0)
    {
        die_errno(
            "write edges header");
    }
}

static int
edges_header_read(
    int fd,
    uint64_t *committed_end,
    uint64_t *slots,
    uint64_t *used,
    uint64_t *postings)
{
    if (file_size_fd(fd) <
        (off_t)
        YODA_EDGES_HEADER_SIZE)
    {
        return 0;
    }

    uint8_t h[
        YODA_EDGES_HEADER_SIZE];

    if (pread_all(
            fd,
            h,
            sizeof(h),
            0) != 1)
    {
        return 0;
    }

    if (memcmp(
            h,
            YODA_EDGES_MAGIC,
            8) != 0)
    {
        return 0;
    }

    if (get_u32(
            h + 8) !=
        YODA_EDGES_VERSION)
    {
        return 0;
    }

    uint64_t s =
        get_u64(
            h + 24);

    uint64_t u =
        get_u64(
            h + 32);

    uint64_t p =
        get_u64(
            h + 40);

    if (s < 16 ||
        (s & (s - 1u)) != 0)
    {
        return 0;
    }

    if (u > s)
        return 0;

    if (s >
        (UINT64_MAX -
         YODA_EDGES_HEADER_SIZE) /
        YODA_EDGES_SLOT_SIZE)
    {
        return 0;
    }

    uint64_t base =
        YODA_EDGES_HEADER_SIZE +
        s *
        YODA_EDGES_SLOT_SIZE;

    if (p >
        (UINT64_MAX - base) /
        YODA_EDGES_POST_SIZE)
    {
        return 0;
    }

    uint64_t expected_size =
        base +
        p *
        YODA_EDGES_POST_SIZE;

    if ((uint64_t)
        file_size_fd(fd) !=
        expected_size)
    {
        return 0;
    }

    *committed_end =
        get_u64(
            h + 16);

    *slots =
        s;

    *used =
        u;

    *postings =
        p;

    return 1;
}

static int
edges_open_valid(
    const char *db,
    uint64_t expected_end,
    int flags,
    int *fd_out,
    uint64_t *slots_out,
    uint64_t *used_out,
    uint64_t *postings_out)
{
    char *p =
        edgesfile(db);

    int fd =
        open(
            p,
            flags);

    free(p);

    if (fd < 0)
        return 0;

    uint64_t committed_end = 0;
    uint64_t slots = 0;
    uint64_t used = 0;
    uint64_t postings = 0;

    if (!edges_header_read(
            fd,
            &committed_end,
            &slots,
            &used,
            &postings))
    {
        close(fd);
        return 0;
    }

    if (committed_end !=
        expected_end)
    {
        close(fd);
        return 0;
    }

    *fd_out = fd;
    *slots_out = slots;
    *used_out = used;
    *postings_out = postings;

    return 1;
}

static void
edges_slot_encode(
    uint8_t slot[
        YODA_EDGES_SLOT_SIZE],
    uint64_t hash,
    uint64_t head,
    uint64_t count)
{
    memset(
        slot,
        0,
        YODA_EDGES_SLOT_SIZE);

    put_u32(
        slot,
        YODA_EDGES_USED);

    put_u64(
        slot + 8,
        hash);

    put_u64(
        slot + 16,
        head);

    put_u64(
        slot + 24,
        count);
}

static int
edges_read_posting(
    int fd,
    uint64_t slots,
    uint64_t posting_off,
    uint64_t *record_off,
    uint64_t *next)
{
    off_t size =
        file_size_fd(fd);

    uint64_t start =
        (uint64_t)
        edges_postings_start(
            slots);

    if (posting_off <
            start ||
        posting_off +
            YODA_EDGES_POST_SIZE >
            (uint64_t)size)
    {
        return 0;
    }

    uint8_t p[
        YODA_EDGES_POST_SIZE];

    if (pread_all(
            fd,
            p,
            sizeof(p),
            (off_t)posting_off) != 1)
    {
        return 0;
    }

    *record_off =
        get_u64(p);

    *next =
        get_u64(
            p + 8);

    return 1;
}

static int
edges_slot_matches_key(
    int edges_fd,
    uint64_t slots,
    int data_fd,
    off_t data_size,
    const uint8_t slot[
        YODA_EDGES_SLOT_SIZE],
    const char *key)
{
    uint64_t head =
        get_u64(
            slot + 16);

    uint64_t record_off = 0;
    uint64_t next = 0;

    if (!edges_read_posting(
            edges_fd,
            slots,
            head,
            &record_off,
            &next))
    {
        return -1;
    }

    (void)next;

    if (record_off >=
        (uint64_t)data_size)
    {
        return -1;
    }

    recmeta r;

    if (rec_meta_at(
            data_fd,
            (off_t)record_off,
            &r,
            data_size) != 1)
    {
        return -1;
    }

    if (r.type !=
        YODA_TYPE_LINK)
    {
        rec_free(&r);
        return -1;
    }

    int match =
        strcmp(
            r.key,
            key) == 0 ||
        strcmp(
            r.target,
            key) == 0;

    rec_free(&r);

    return match;
}

static int
edges_find_slot(
    int edges_fd,
    uint64_t slots,
    int data_fd,
    const char *key,
    uint64_t *slot_number,
    uint8_t slot_out[
        YODA_EDGES_SLOT_SIZE])
{
    uint64_t hash =
        hash_key(key);

    uint64_t mask =
        slots - 1u;

    uint64_t pos =
        hash & mask;

    off_t data_size =
        file_size_fd(
            data_fd);

    uint8_t slot[
        YODA_EDGES_SLOT_SIZE];

    for (uint64_t probe = 0;
         probe < slots;
         probe++)
    {
        if (pread_all(
                edges_fd,
                slot,
                sizeof(slot),
                edges_slot_offset(
                    pos)) != 1)
        {
            return -1;
        }

        uint32_t state =
            get_u32(slot);

        if (state ==
            YODA_EDGES_EMPTY)
        {
            *slot_number =
                pos;

            memcpy(
                slot_out,
                slot,
                sizeof(slot));

            return 0;
        }

        if (state !=
            YODA_EDGES_USED)
        {
            return -1;
        }

        if (get_u64(
                slot + 8) ==
            hash)
        {
            int match =
                edges_slot_matches_key(
                    edges_fd,
                    slots,
                    data_fd,
                    data_size,
                    slot,
                    key);

            if (match < 0)
                return -1;

            if (match)
            {
                *slot_number =
                    pos;

                memcpy(
                    slot_out,
                    slot,
                    sizeof(slot));

                return 1;
            }
        }

        pos =
            (pos + 1u) &
            mask;
    }

    return -2;
}

static int
edges_append_endpoint(
    int edges_fd,
    uint64_t slots,
    uint64_t *used,
    uint64_t *postings,
    int data_fd,
    const char *endpoint,
    off_t link_record_off)
{
    uint64_t slot_number = 0;

    uint8_t slot[
        YODA_EDGES_SLOT_SIZE];

    int found =
        edges_find_slot(
            edges_fd,
            slots,
            data_fd,
            endpoint,
            &slot_number,
            slot);

    if (found == -2)
        return 0;

    if (found < 0)
        return -1;

    uint64_t old_head = 0;
    uint64_t count = 0;

    if (found)
    {
        old_head =
            get_u64(
                slot + 16);

        count =
            get_u64(
                slot + 24);
    }
    else
    {
        if ((*used + 1u) >
            (slots * 7u) / 10u)
        {
            return 0;
        }

        (*used)++;
    }

    off_t post_off =
        lseek(
            edges_fd,
            0,
            SEEK_END);

    if (post_off < 0)
        return -1;

    uint8_t post[
        YODA_EDGES_POST_SIZE];

    memset(
        post,
        0,
        sizeof(post));

    put_u64(
        post,
        (uint64_t)
        link_record_off);

    put_u64(
        post + 8,
        old_head);

    if (write_all(
            edges_fd,
            post,
            sizeof(post)) != 0)
    {
        return -1;
    }

    (*postings)++;

    edges_slot_encode(
        slot,
        hash_key(endpoint),
        (uint64_t)post_off,
        count + 1u);

    if (edges_pwrite_all(
            edges_fd,
            slot,
            sizeof(slot),
            edges_slot_offset(
                slot_number)) != 0)
    {
        return -1;
    }

    return 1;
}

static void
edges_count_links(
    int data_fd,
    uint64_t *link_count)
{
    off_t size =
        file_size_fd(
            data_fd);

    off_t off = 0;

    uint64_t links = 0;

    while (off < size)
    {
        recmeta r;

        if (rec_meta_at(
                data_fd,
                off,
                &r,
                size) != 1)
        {
            die(
                "cannot count edges from data");
        }

        if (r.type ==
            YODA_TYPE_LINK)
        {
            links++;
        }

        off =
            r.next_off;

        rec_free(&r);
    }

    *link_count =
        links;
}

static void
edges_rebuild(
    const char *db,
    int data_fd)
{
    uint64_t links = 0;

    edges_count_links(
        data_fd,
        &links);

    uint64_t endpoint_upper =
        links >
        UINT64_MAX / 2u
            ? UINT64_MAX
            : links * 2u;

    uint64_t slots =
        edges_slots_for_endpoints(
            endpoint_upper);

    char *tmp =
        edges_tmpfile(db);

    char *dst =
        edgesfile(db);

    int fd =
        open(
            tmp,
            O_CREAT |
            O_TRUNC |
            O_RDWR,
            0644);

    if (fd < 0)
        die_errno(
            "create edges temp");

    off_t base =
        edges_postings_start(
            slots);

    if (ftruncate(
            fd,
            base) != 0)
    {
        close(fd);

        die_errno(
            "size edges table");
    }

    uint64_t used = 0;
    uint64_t postings = 0;

    edges_header_write(
        fd,
        0,
        slots,
        used,
        postings);

    off_t data_size =
        file_size_fd(
            data_fd);

    off_t off = 0;

    while (off <
           data_size)
    {
        recmeta r;

        if (rec_meta_at(
                data_fd,
                off,
                &r,
                data_size) != 1)
        {
            close(fd);

            die(
                "cannot rebuild edges from data");
        }

        off_t record_off =
            r.record_off;

        if (r.type ==
            YODA_TYPE_LINK)
        {
            int rc =
                edges_append_endpoint(
                    fd,
                    slots,
                    &used,
                    &postings,
                    data_fd,
                    r.key,
                    record_off);

            if (rc <= 0)
            {
                rec_free(&r);
                close(fd);

                die(
                    "edges rebuild source insert failed");
            }

            if (strcmp(
                    r.key,
                    r.target) != 0)
            {
                rc =
                    edges_append_endpoint(
                        fd,
                        slots,
                        &used,
                        &postings,
                        data_fd,
                        r.target,
                        record_off);

                if (rc <= 0)
                {
                    rec_free(&r);
                    close(fd);

                    die(
                        "edges rebuild target insert failed");
                }
            }
        }

        off =
            r.next_off;

        rec_free(&r);
    }

    edges_header_write(
        fd,
        (uint64_t)data_size,
        slots,
        used,
        postings);

    if (fdatasync(fd) != 0)
    {
        close(fd);

        die_errno(
            "fdatasync edges rebuild");
    }

    if (close(fd) != 0)
        die_errno(
            "close edges");

    if (rename(
            tmp,
            dst) != 0)
    {
        die_errno(
            "rename edges");
    }

    fsync_dir_path(db);

    free(tmp);
    free(dst);
}

static int
edges_open_current(
    const char *db,
    int data_fd)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    int fd = -1;

    uint64_t slots = 0;
    uint64_t used = 0;
    uint64_t postings = 0;

    if (edges_open_valid(
            db,
            (uint64_t)data_size,
            O_RDONLY,
            &fd,
            &slots,
            &used,
            &postings))
    {
        (void)slots;
        (void)used;
        (void)postings;

        return fd;
    }

    edges_rebuild(
        db,
        data_fd);

    if (!edges_open_valid(
            db,
            (uint64_t)data_size,
            O_RDONLY,
            &fd,
            &slots,
            &used,
            &postings))
    {
        die(
            "edges rebuild did not produce valid index");
    }

    return fd;
}

static void
edges_advance_after_nonlink(
    const char *db,
    int data_fd,
    off_t previous_end)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    int fd = -1;

    uint64_t slots = 0;
    uint64_t used = 0;
    uint64_t postings = 0;

    if (!edges_open_valid(
            db,
            (uint64_t)previous_end,
            O_RDWR,
            &fd,
            &slots,
            &used,
            &postings))
    {
        edges_rebuild(
            db,
            data_fd);

        return;
    }

    /*
     * Derived state only.
     * A PUT cannot alter relations, so advancing the checkpoint
     * needs only a header write. No authority depends on this
     * file; after a crash, stale metadata simply rebuilds.
     */
    edges_header_write(
        fd,
        (uint64_t)data_size,
        slots,
        used,
        postings);

    close(fd);
}

static void
edges_update_after_link(
    const char *db,
    int data_fd,
    off_t record_off)
{
    off_t data_size =
        file_size_fd(
            data_fd);

    recmeta r;

    if (rec_meta_at(
            data_fd,
            record_off,
            &r,
            data_size) != 1)
    {
        die(
            "cannot read LINK for edges");
    }

    if (r.type !=
        YODA_TYPE_LINK)
    {
        rec_free(&r);

        die(
            "edges update expected LINK");
    }

    int fd = -1;

    uint64_t slots = 0;
    uint64_t used = 0;
    uint64_t postings = 0;

    if (!edges_open_valid(
            db,
            (uint64_t)record_off,
            O_RDWR,
            &fd,
            &slots,
            &used,
            &postings))
    {
        rec_free(&r);

        edges_rebuild(
            db,
            data_fd);

        return;
    }

    /*
     * Conservative capacity check. A rebuild chooses a larger
     * table from authoritative data if this LINK could push the
     * table beyond its load threshold.
     */
    if ((used + 2u) >
        (slots * 7u) / 10u)
    {
        close(fd);
        rec_free(&r);

        edges_rebuild(
            db,
            data_fd);

        return;
    }

    int rc =
        edges_append_endpoint(
            fd,
            slots,
            &used,
            &postings,
            data_fd,
            r.key,
            record_off);

    if (rc <= 0)
    {
        close(fd);
        rec_free(&r);

        edges_rebuild(
            db,
            data_fd);

        return;
    }

    if (strcmp(
            r.key,
            r.target) != 0)
    {
        rc =
            edges_append_endpoint(
                fd,
                slots,
                &used,
                &postings,
                data_fd,
                r.target,
                record_off);

        if (rc <= 0)
        {
            close(fd);
            rec_free(&r);

            edges_rebuild(
                db,
                data_fd);

            return;
        }
    }

    edges_header_write(
        fd,
        (uint64_t)data_size,
        slots,
        used,
        postings);

    if (fdatasync(fd) != 0)
    {
        close(fd);
        rec_free(&r);

        die_errno(
            "fdatasync edges update");
    }

    close(fd);

    rec_free(&r);
}

static int
edges_lookup_head(
    int edges_fd,
    uint64_t slots,
    int data_fd,
    const char *key,
    uint64_t *head,
    uint64_t *count)
{
    uint64_t slot_number = 0;

    uint8_t slot[
        YODA_EDGES_SLOT_SIZE];

    int rc =
        edges_find_slot(
            edges_fd,
            slots,
            data_fd,
            key,
            &slot_number,
            slot);

    (void)slot_number;

    if (rc <= 0)
        return rc;

    *head =
        get_u64(
            slot + 16);

    *count =
        get_u64(
            slot + 24);

    return 1;
}
/* ============================================================
 * RECORD HASH
 * ============================================================ */

static void
compute_record_id(
    uint8_t h[YODA_HEADER_SIZE],
    const char *key,
    const char *source,
    const char *rel,
    const char *target,
    const uint8_t *value,
    size_t value_len,
    uint8_t out[32])
{
    sha256_ctx c;

    sha256_init(&c);

    sha256_update(
        &c,
        h + 8,
        72);

    sha256_update(
        &c,
        key,
        strlen(key));

    sha256_update(
        &c,
        source,
        strlen(source));

    sha256_update(
        &c,
        rel,
        strlen(rel));

    sha256_update(
        &c,
        target,
        strlen(target));

    if (value_len)
    {
        sha256_update(
            &c,
            value,
            value_len);
    }

    sha256_final(
        &c,
        out);
}

/* ============================================================
 * IO
 * ============================================================ */

static uint8_t *
read_stdin_all(size_t *outn)
{
    size_t cap =
        65536;

    size_t n =
        0;

    uint8_t *b =
        malloc(cap);

    if (!b)
        die("oom");

    for (;;)
    {
        if (n == cap)
        {
            if (cap >=
                YODA_MAX_VALUE)
            {
                die(
                    "stdin value exceeds 256 MiB");
            }

            size_t nc =
                cap * 2;

            if (nc >
                YODA_MAX_VALUE)
            {
                nc =
                    (size_t)YODA_MAX_VALUE;
            }

            uint8_t *nb =
                realloc(
                    b,
                    nc);

            if (!nb)
                die("oom");

            b = nb;
            cap = nc;
        }

        ssize_t r =
            read(
                STDIN_FILENO,
                b + n,
                cap - n);

        if (r < 0)
        {
            if (errno == EINTR)
                continue;

            die_errno(
                "read stdin");
        }

        if (r == 0)
            break;

        n +=
            (size_t)r;
    }

    *outn = n;

    return b;
}

static const char *
parse_source(
    int argc,
    char **argv,
    int start)
{
    for (int i = start;
         i < argc;
         i++)
    {
        if (strncmp(
                argv[i],
                "source=",
                7) == 0)
        {
            return
                argv[i] + 7;
        }

        if (strcmp(
                argv[i],
                "--source") == 0 &&
            i + 1 < argc)
        {
            return
                argv[i + 1];
        }
    }

    return "stdin";
}

static int
open_db(
    const char *db,
    int flags)
{
    char *p =
        dbfile(db);

    int fd =
        open(
            p,
            flags,
            0644);

    free(p);

    if (fd < 0)
        die_errno(
            "open database");

    return fd;
}

static void
lock_fd(
    int fd,
    short type)
{
    struct flock fl;

    memset(
        &fl,
        0,
        sizeof(fl));

    fl.l_type =
        type;

    fl.l_whence =
        SEEK_SET;

    while (fcntl(
            fd,
            F_SETLKW,
            &fl) != 0)
    {
        if (errno == EINTR)
            continue;

        die_errno(
            "fcntl lock");
    }
}

static void
unlock_fd(int fd)
{
    struct flock fl;

    memset(
        &fl,
        0,
        sizeof(fl));

    fl.l_type =
        F_UNLCK;

    fl.l_whence =
        SEEK_SET;

    if (fcntl(
            fd,
            F_SETLK,
            &fl) != 0)
    {
        die_errno(
            "fcntl unlock");
    }
}

/* ============================================================
 * FAST HEAD / CRASH TAIL RECOVERY
 * ============================================================ */

#define YODA_HEAD_MAGIC "YHEAD001"
#define YODA_HEAD_VERSION 1u
#define YODA_HEAD_SIZE 56u

static char *
headfile(const char *db)
{
    size_t n =
        strlen(db) + 6;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/HEAD",
        db);

    return p;
}

static char *
headtmpfile(const char *db)
{
    size_t n =
        strlen(db) + 10;

    char *p =
        malloc(n);

    if (!p)
        die("oom");

    snprintf(
        p,
        n,
        "%s/HEAD.tmp",
        db);

    return p;
}

static void
head_write(
    const char *db,
    uint64_t committed_end,
    const uint8_t id[32])
{
    char *tmp =
        headtmpfile(db);

    char *dst =
        headfile(db);

    int fd =
        open(
            tmp,
            O_CREAT |
            O_TRUNC |
            O_WRONLY,
            0644);

    if (fd < 0)
        die_errno(
            "create HEAD temp");

    uint8_t h[
        YODA_HEAD_SIZE];

    memset(
        h,
        0,
        sizeof(h));

    memcpy(
        h,
        YODA_HEAD_MAGIC,
        8);

    put_u32(
        h + 8,
        YODA_HEAD_VERSION);

    put_u64(
        h + 16,
        committed_end);

    if (id)
    {
        memcpy(
            h + 24,
            id,
            32);
    }

    if (write_all(
            fd,
            h,
            sizeof(h)) != 0)
    {
        close(fd);
        die_errno(
            "write HEAD");
    }

    if (fdatasync(fd) != 0)
    {
        close(fd);
        die_errno(
            "fdatasync HEAD");
    }

    if (close(fd) != 0)
        die_errno(
            "close HEAD");

    if (rename(
            tmp,
            dst) != 0)
    {
        die_errno(
            "rename HEAD");
    }

    fsync_dir_path(db);

    free(tmp);
    free(dst);
}

static int
head_read(
    const char *db,
    int data_fd,
    off_t data_size,
    uint64_t *committed_end,
    uint8_t id[32])
{
    char *p =
        headfile(db);

    int fd =
        open(
            p,
            O_RDONLY);

    free(p);

    if (fd < 0)
    {
        if (errno == ENOENT)
            return 0;

        return 0;
    }

    if (file_size_fd(fd) !=
        (off_t)YODA_HEAD_SIZE)
    {
        close(fd);
        return 0;
    }

    uint8_t h[
        YODA_HEAD_SIZE];

    if (pread_all(
            fd,
            h,
            sizeof(h),
            0) != 1)
    {
        close(fd);
        return 0;
    }

    close(fd);

    if (memcmp(
            h,
            YODA_HEAD_MAGIC,
            8) != 0)
    {
        return 0;
    }

    if (get_u32(
            h + 8) !=
        YODA_HEAD_VERSION)
    {
        return 0;
    }

    uint64_t end =
        get_u64(
            h + 16);

    if (end >
        (uint64_t)data_size)
    {
        return 0;
    }

    memcpy(
        id,
        h + 24,
        32);

    if (end == 0)
    {
        uint8_t x = 0;

        for (size_t i = 0;
             i < 32;
             i++)
        {
            x |= id[i];
        }

        if (x != 0)
            return 0;

        *committed_end = 0;

        return 1;
    }

    if (end <
        YODA_TRAILER_SIZE)
    {
        return 0;
    }

    uint8_t trailer[
        YODA_TRAILER_SIZE];

    if (pread_all(
            data_fd,
            trailer,
            sizeof(trailer),
            (off_t)end -
                YODA_TRAILER_SIZE) != 1)
    {
        return 0;
    }

    if (memcmp(
            trailer,
            YODA_TRAILER_MAGIC,
            8) != 0)
    {
        return 0;
    }

    if (memcmp(
            trailer + 8,
            id,
            32) != 0)
    {
        return 0;
    }

    *committed_end =
        end;

    return 1;
}

static void
head_update_from_data(
    const char *db,
    int data_fd)
{
    off_t size =
        file_size_fd(
            data_fd);

    if (size == 0)
    {
        uint8_t zero[32] =
            {0};

        head_write(
            db,
            0,
            zero);

        return;
    }

    if (size <
        (off_t)YODA_TRAILER_SIZE)
    {
        die(
            "cannot checkpoint incomplete data");
    }

    uint8_t trailer[
        YODA_TRAILER_SIZE];

    if (pread_all(
            data_fd,
            trailer,
            sizeof(trailer),
            size -
                YODA_TRAILER_SIZE) != 1)
    {
        die(
            "cannot read final trailer");
    }

    if (memcmp(
            trailer,
            YODA_TRAILER_MAGIC,
            8) != 0)
    {
        die(
            "final record has no commit trailer");
    }

    head_write(
        db,
        (uint64_t)size,
        trailer + 8);
}

static void
recover_scan_from(
    const char *db,
    int fd,
    off_t start,
    off_t size,
    uint8_t last_id[32])
{
    off_t off =
        start;

    while (off < size)
    {
        recmeta r;

        int rc =
            rec_meta_at(
                fd,
                off,
                &r,
                size);

        if (rc == 1)
        {
            memcpy(
                last_id,
                r.id,
                32);

            off =
                r.next_off;

            rec_free(
                &r);

            continue;
        }

        if (rc == -2)
        {
            if (ftruncate(
                    fd,
                    off) != 0)
            {
                die_errno(
                    "truncate incomplete tail");
            }

            if (fdatasync(fd) != 0)
            {
                die_errno(
                    "fdatasync recovered data");
            }

            head_write(
                db,
                (uint64_t)off,
                last_id);

            return;
        }

        die(
            "database corruption before tail");
    }

    head_write(
        db,
        (uint64_t)off,
        last_id);
}

static void
recover_data_tail(
    const char *db)
{
    char *p =
        dbfile(db);

    int fd =
        open(
            p,
            O_RDWR);

    free(p);

    if (fd < 0)
        die_errno(
            "open database for recovery");

    lock_fd(
        fd,
        F_WRLCK);

    off_t size =
        file_size_fd(fd);

    uint64_t head_end = 0;

    uint8_t head_id[32] =
        {0};

    int valid =
        head_read(
            db,
            fd,
            size,
            &head_end,
            head_id);

    /*
     * Normal fast path:
     *
     * HEAD identifies the final durable trailer and data.yoda
     * has exactly that size. No historical record scan.
     */
    if (valid &&
        head_end ==
            (uint64_t)size)
    {
        unlock_fd(fd);
        close(fd);

        return;
    }

    if (valid)
    {
        recover_scan_from(
            db,
            fd,
            (off_t)head_end,
            size,
            head_id);

        unlock_fd(fd);
        close(fd);

        return;
    }

    /*
     * Missing or invalid HEAD:
     * data.yoda remains authority. Reconstruct HEAD by one
     * complete scan.
     */
    uint8_t zero[32] =
        {0};

    recover_scan_from(
        db,
        fd,
        0,
        size,
        zero);

    unlock_fd(fd);
    close(fd);
}
/* ============================================================
 * INIT
 * ============================================================ */

static void
cmd_init(const char *path)
{
    mkdir_p(path);

    char *p =
        dbfile(path);

    int fd =
        open(
            p,
            O_CREAT |
            O_EXCL |
            O_WRONLY,
            0644);

    if (fd < 0)
    {
        if (errno == EEXIST)
        {
            die(
                "database already initialized");
        }

        die_errno(
            "create data.yoda");
    }

    if (fsync(fd) != 0)
        die_errno(
            "fsync data.yoda");

    close(fd);

    int dfd =
        open(
            path,
            O_RDONLY |
            O_DIRECTORY);

    if (dfd >= 0)
    {
        fsync(dfd);
        close(dfd);
    }

    printf(
        "INIT=PASS\n"
        "DB=%s\n",
        path);

    free(p);
}

/* ============================================================
 * APPEND
 * ============================================================ */

static void
append_record_fd(
    int fd,
    uint32_t type,
    const char *key,
    const char *source,
    const char *rel,
    const char *target,
    const uint8_t prev[32],
    const uint8_t *value,
    size_t value_len)
{
    size_t kl =
        strlen(key);

    size_t sl =
        strlen(source);

    size_t rl =
        strlen(rel);

    size_t tl =
        strlen(target);

    if (kl > YODA_MAX_META ||
        sl > YODA_MAX_META ||
        rl > YODA_MAX_META ||
        tl > YODA_MAX_META ||
        value_len > YODA_MAX_VALUE)
    {
        die(
            "record too large");
    }

    uint8_t h[
        YODA_HEADER_SIZE];

    memset(
        h,
        0,
        sizeof(h));

    memcpy(
        h,
        YODA_MAGIC,
        8);

    put_u32(
        h + 8,
        YODA_VERSION);

    put_u32(
        h + 12,
        type);

    put_u64(
        h + 16,
        now_ns());

    put_u32(
        h + 24,
        (uint32_t)kl);

    put_u32(
        h + 28,
        (uint32_t)sl);

    put_u32(
        h + 32,
        (uint32_t)rl);

    put_u32(
        h + 36,
        (uint32_t)tl);

    put_u64(
        h + 40,
        (uint64_t)value_len);

    memcpy(
        h + 48,
        prev,
        32);

    uint8_t id[32];

    compute_record_id(
        h,
        key,
        source,
        rel,
        target,
        value,
        value_len,
        id);

    memcpy(
        h + 80,
        id,
        32);

    uint8_t trailer[
        YODA_TRAILER_SIZE];

    memset(
        trailer,
        0,
        sizeof(trailer));

    memcpy(
        trailer,
        YODA_TRAILER_MAGIC,
        8);

    memcpy(
        trailer + 8,
        id,
        32);

    if (lseek(
            fd,
            0,
            SEEK_END) < 0)
    {
        die_errno(
            "lseek end");
    }

    if (write_all(
            fd,
            h,
            sizeof(h)) != 0 ||
        write_all(
            fd,
            key,
            kl) != 0 ||
        write_all(
            fd,
            source,
            sl) != 0 ||
        write_all(
            fd,
            rel,
            rl) != 0 ||
        write_all(
            fd,
            target,
            tl) != 0 ||
        (value_len &&
         write_all(
             fd,
             value,
             value_len) != 0) ||
        write_all(
            fd,
            trailer,
            sizeof(trailer)) != 0)
    {
        die_errno(
            "append record");
    }

    if (fdatasync(fd) != 0)
        die_errno(
            "fdatasync");

    char hex[65];

    id_hex(
        id,
        hex);

    printf(
        "ID=%s\n",
        hex);
}

/* ============================================================
 * PUT
 * ============================================================ */

static void
cmd_put(
    const char *db,
    const char *key,
    const char *source)
{
    int fd =
        open_db(
            db,
            O_RDWR);

    lock_fd(
        fd,
        F_WRLCK);

    /*
     * Normal path is O(1):
     *   HEAD valid
     *   index header valid
     *   lookup checkpoint == current data size
     *
     * No index.yoda materialization.
     */
    derived_state_ensure_for_write(
        db,
        fd);

    uint8_t prev[32] =
        {0};

    off_t previous_off = 0;

    int found =
        direct_lookup_record(
            db,
            fd,
            key,
            &previous_off);

    if (found)
    {
        recmeta previous;

        if (rec_meta_at(
                fd,
                previous_off,
                &previous,
                file_size_fd(fd)) != 1)
        {
            unlock_fd(fd);
            close(fd);

            die(
                "cannot read previous version");
        }

        if (previous.type !=
                YODA_TYPE_PUT ||
            strcmp(
                previous.key,
                key) != 0)
        {
            rec_free(&previous);

            unlock_fd(fd);
            close(fd);

            die(
                "previous version lookup mismatch");
        }

        memcpy(
            prev,
            previous.id,
            32);

        rec_free(
            &previous);
    }

    size_t n = 0;

    uint8_t *v =
        read_stdin_all(
            &n);

    off_t record_off =
        file_size_fd(fd);

    append_record_fd(
        fd,
        YODA_TYPE_PUT,
        key,
        source,
        "",
        "",
        prev,
        v,
        n);

    /*
     * Durability order:
     *
     * data.yoda -> HEAD -> index.yoda -> lookup.yoda
     *
     * lookup is last. Therefore a current lookup checkpoint
     * proves the previous derived-state write sequence reached
     * completion.
     */
    head_update_from_data(
        db,
        fd);

    index_append_put(
        db,
        fd,
        record_off);

    lookup_update_after_put(
        db,
        fd,
        record_off);

    terms_update_after_put(
        db,
        fd,
        record_off);

    edges_advance_after_nonlink(
        db,
        fd,
        record_off);

    free(v);

    unlock_fd(fd);

    close(fd);
}
/* ============================================================
 * GET
 * ============================================================ */

static void
stream_value(
    int fd,
    const recmeta *r)
{
    uint8_t *buf =
        malloc(
            YODA_IO_CHUNK);

    if (!buf)
        die("oom");

    uint64_t left =
        r->value_len;

    off_t off =
        r->value_off;

    while (left)
    {
        size_t n =
            left >
            YODA_IO_CHUNK
                ? YODA_IO_CHUNK
                : (size_t)left;

        int rc =
            pread_all(
                fd,
                buf,
                n,
                off);

        if (rc != 1)
        {
            free(buf);

            die(
                "truncated value");
        }

        if (write_all(
                STDOUT_FILENO,
                buf,
                n) != 0)
        {
            free(buf);

            die_errno(
                "write stdout");
        }

        off +=
            (off_t)n;

        left -= n;
    }

    free(buf);
}

static void
cmd_get(
    const char *db,
    const char *key)
{
    int fd =
        open_db(
            db,
            O_RDONLY);

    off_t record_off = 0;

    int found =
        lookup_find(
            db,
            fd,
            key,
            &record_off);

    if (!found)
    {
        close(fd);
        exit(2);
    }

    recmeta r;

    int rc =
        rec_meta_at(
            fd,
            record_off,
            &r,
            file_size_fd(fd));

    if (rc != 1)
    {
        close(fd);

        die(
            "corrupt lookup record");
    }

    if (r.type !=
            YODA_TYPE_PUT ||
        strcmp(
            r.key,
            key) != 0)
    {
        rec_free(&r);
        close(fd);

        die(
            "lookup key mismatch");
    }

    stream_value(
        fd,
        &r);

    rec_free(&r);

    close(fd);
}
/* ============================================================
 * FIND / SEARCH
 * ============================================================ */

typedef struct
{
    char **v;
    size_t n;
} query_terms;

typedef struct
{
    char *key;
    off_t record_off;
    uint64_t ts;
    int score;
} search_hit;

static void
query_free(
    query_terms *q)
{
    for (size_t i = 0;
         i < q->n;
         i++)
    {
        free(q->v[i]);
    }

    free(q->v);

    memset(
        q,
        0,
        sizeof(*q));
}

static void
query_parse(
    const char *query,
    query_terms *q)
{
    memset(
        q,
        0,
        sizeof(*q));

    char *tmp =
        strdup(
            query
                ? query
                : "");

    if (!tmp)
        die("oom");

    char *save = NULL;

    for (char *raw =
             strtok_r(
                 tmp,
                 " \t\r\n",
                 &save);
         raw;
         raw =
             strtok_r(
                 NULL,
                 " \t\r\n",
                 &save))
    {
        char term[
            YODA_TERM_MAX + 1];

        if (!term_normalize(
                raw,
                strlen(raw),
                term))
        {
            continue;
        }

        int duplicate = 0;

        for (size_t i = 0;
             i < q->n;
             i++)
        {
            if (strcmp(
                    q->v[i],
                    term) == 0)
            {
                duplicate = 1;
                break;
            }
        }

        if (duplicate)
            continue;

        char **nv =
            realloc(
                q->v,
                (q->n + 1) *
                sizeof(*q->v));

        if (!nv)
            die("oom");

        q->v =
            nv;

        q->v[q->n] =
            strdup(term);

        if (!q->v[q->n])
            die("oom");

        q->n++;
    }

    free(tmp);
}

static int
contains_ci_text(
    const char *hay,
    const char *needle)
{
    if (!*needle)
        return 1;

    size_t nl =
        strlen(needle);

    for (const char *p = hay;
         *p;
         p++)
    {
        size_t i = 0;

        while (i < nl &&
               p[i] &&
               tolower(
                   (unsigned char)p[i]) ==
               tolower(
                   (unsigned char)needle[i]))
        {
            i++;
        }

        if (i == nl)
            return 1;
    }

    return 0;
}

static int
contains_ci_bytes(
    const uint8_t *buf,
    size_t n,
    const char *needle,
    size_t nl)
{
    if (nl == 0)
        return 1;

    if (nl > n)
        return 0;

    for (size_t i = 0;
         i + nl <= n;
         i++)
    {
        size_t j = 0;

        while (j < nl &&
               tolower(
                   (unsigned char)
                   buf[i + j]) ==
               tolower(
                   (unsigned char)
                   needle[j]))
        {
            j++;
        }

        if (j == nl)
            return 1;
    }

    return 0;
}

static int
search_score_record(
    int fd,
    const recmeta *r,
    const query_terms *q)
{
    if (q->n == 0)
        return 0;

    uint8_t *value = NULL;

    size_t value_n = 0;

    if (r->value_len)
    {
        if (r->value_len >
            SIZE_MAX)
        {
            return -1;
        }

        value_n =
            (size_t)r->value_len;

        value =
            malloc(value_n);

        if (!value)
            die("oom");

        if (pread_all(
                fd,
                value,
                value_n,
                r->value_off) != 1)
        {
            free(value);

            die(
                "truncated value");
        }
    }

    int score = 0;

    for (size_t i = 0;
         i < q->n;
         i++)
    {
        int in_key =
            contains_ci_text(
                r->key,
                q->v[i]);

        int in_source =
            contains_ci_text(
                r->source,
                q->v[i]);

        int in_value =
            value &&
            contains_ci_bytes(
                value,
                value_n,
                q->v[i],
                strlen(q->v[i]));

        if (!in_key &&
            !in_source &&
            !in_value)
        {
            free(value);

            return -1;
        }

        if (in_key)
            score += 8;

        if (in_source)
            score += 4;

        if (in_value)
            score += 2;
    }

    free(value);

    return score;
}

static int
cmp_search_hit(
    const void *a,
    const void *b)
{
    const search_hit *x =
        a;

    const search_hit *y =
        b;

    if (x->score !=
        y->score)
    {
        return
            y->score -
            x->score;
    }

    if (x->ts <
        y->ts)
    {
        return 1;
    }

    if (x->ts >
        y->ts)
    {
        return -1;
    }

    return strcmp(
        x->key,
        y->key);
}

static int
hit_has_key(
    search_hit *hits,
    size_t n,
    const char *key)
{
    for (size_t i = 0;
         i < n;
         i++)
    {
        if (strcmp(
                hits[i].key,
                key) == 0)
        {
            return 1;
        }
    }

    return 0;
}

static void
search_hits_free(
    search_hit *hits,
    size_t n)
{
    for (size_t i = 0;
         i < n;
         i++)
    {
        free(
            hits[i].key);
    }

    free(hits);
}

static search_hit *
search_collect_all_keys(
    const char *db,
    int fd,
    size_t limit,
    size_t *out_n)
{
    idxmap m;

    idx_init(&m);

    load_or_rebuild_index(
        db,
        fd,
        &m);

    size_t cap =
        m.len
            ? m.len
            : 1;

    search_hit *hits =
        calloc(
            cap,
            sizeof(*hits));

    if (!hits)
        die("oom");

    size_t n = 0;

    for (size_t i = 0;
         i < m.cap;
         i++)
    {
        if (!m.e[i].used)
            continue;

        hits[n].key =
            strdup(
                m.e[i].key);

        if (!hits[n].key)
            die("oom");

        hits[n].record_off =
            m.e[i].off;

        hits[n].ts =
            m.e[i].ts;

        hits[n].score = 0;

        n++;
    }

    idx_destroy(&m);

    qsort(
        hits,
        n,
        sizeof(*hits),
        cmp_search_hit);

    if (limit &&
        n > limit)
    {
        for (size_t i = limit;
             i < n;
             i++)
        {
            free(
                hits[i].key);
        }

        n =
            limit;
    }

    *out_n =
        n;

    return hits;
}

static search_hit *
search_collect(
    const char *db,
    int fd,
    const char *query,
    size_t limit,
    size_t *out_n)
{
    query_terms q;

    query_parse(
        query,
        &q);

    if (q.n == 0)
    {
        query_free(&q);

        return
            search_collect_all_keys(
                db,
                fd,
                limit,
                out_n);
    }

    int terms_fd =
        terms_open_current(
            db,
            fd);

    size_t anchor =
        SIZE_MAX;

    uint64_t anchor_head = 0;
    uint64_t anchor_count =
        UINT64_MAX;

    for (size_t i = 0;
         i < q.n;
         i++)
    {
        uint64_t head = 0;
        uint64_t count = 0;

        int rc =
            terms_lookup_term(
                terms_fd,
                q.v[i],
                &head,
                &count);

        if (rc < 0)
        {
            close(terms_fd);

            terms_rebuild(
                db,
                fd);

            terms_fd =
                terms_open_current(
                    db,
                    fd);

            rc =
                terms_lookup_term(
                    terms_fd,
                    q.v[i],
                    &head,
                    &count);
        }

        if (rc == 0)
        {
            close(terms_fd);
            query_free(&q);

            *out_n = 0;

            return
                calloc(
                    1,
                    sizeof(search_hit));
        }

        if (rc < 0)
        {
            close(terms_fd);
            query_free(&q);

            die(
                "terms lookup failed");
        }

        if (count <
            anchor_count)
        {
            anchor =
                i;

            anchor_head =
                head;

            anchor_count =
                count;
        }
    }

    (void)anchor;

    size_t cap =
        limit
            ? limit
            : 64;

    if (cap == 0)
        cap = 1;

    search_hit *hits =
        calloc(
            cap,
            sizeof(*hits));

    if (!hits)
        die("oom");

    size_t n = 0;

    uint64_t posting =
        anchor_head;

    while (posting)
    {
        uint64_t record_off = 0;
        uint64_t next = 0;

        if (!terms_read_posting(
                terms_fd,
                posting,
                &record_off,
                &next))
        {
            search_hits_free(
                hits,
                n);

            close(terms_fd);

            query_free(&q);

            terms_rebuild(
                db,
                fd);

            return
                search_collect(
                    db,
                    fd,
                    query,
                    limit,
                    out_n);
        }

        posting =
            next;

        if (record_off >=
            (uint64_t)
            file_size_fd(fd))
        {
            continue;
        }

        recmeta r;

        if (rec_meta_at(
                fd,
                (off_t)record_off,
                &r,
                file_size_fd(fd)) != 1)
        {
            continue;
        }

        if (r.type !=
            YODA_TYPE_PUT)
        {
            rec_free(&r);
            continue;
        }

        off_t latest_off = 0;

        int latest =
            lookup_find(
                db,
                fd,
                r.key,
                &latest_off);

        if (!latest ||
            latest_off !=
                (off_t)record_off)
        {
            rec_free(&r);
            continue;
        }

        if (hit_has_key(
                hits,
                n,
                r.key))
        {
            rec_free(&r);
            continue;
        }

        int score =
            search_score_record(
                fd,
                &r,
                &q);

        if (score >= 0)
        {
            if (n == cap)
            {
                size_t nc =
                    cap * 2;

                search_hit *nh =
                    realloc(
                        hits,
                        nc *
                        sizeof(*hits));

                if (!nh)
                    die("oom");

                memset(
                    nh + cap,
                    0,
                    (nc - cap) *
                    sizeof(*nh));

                hits = nh;
                cap = nc;
            }

            hits[n].key =
                strdup(
                    r.key);

            if (!hits[n].key)
                die("oom");

            hits[n].record_off =
                (off_t)record_off;

            hits[n].ts =
                r.ts;

            hits[n].score =
                score;

            n++;

            /*
             * Postings are newest-first.
             * For the CLI limit use-case, stop once enough
             * current matches have been found.
             */
            if (limit &&
                n >= limit)
            {
                rec_free(&r);
                break;
            }
        }

        rec_free(&r);
    }

    close(terms_fd);

    query_free(&q);

    qsort(
        hits,
        n,
        sizeof(*hits),
        cmp_search_hit);

    *out_n =
        n;

    return hits;
}

static void
cmd_find(
    const char *db,
    const char *query,
    size_t limit)
{
    int fd =
        open_db(
            db,
            O_RDONLY);

    size_t n = 0;

    search_hit *hits =
        search_collect(
            db,
            fd,
            query,
            limit,
            &n);

    for (size_t i = 0;
         i < n;
         i++)
    {
        puts(
            hits[i].key);
    }

    search_hits_free(
        hits,
        n);

    close(fd);

    if (n == 0)
        exit(2);
}
/* ============================================================
 * LOG
 * ============================================================ */

static void
print_time(
    uint64_t ns,
    char out[32])
{
    time_t s =
        (time_t)(
            ns /
            1000000000ull);

    struct tm tm;

    if (!gmtime_r(
            &s,
            &tm))
    {
        strcpy(
            out,
            "1970-01-01T00:00:00Z");

        return;
    }

    strftime(
        out,
        32,
        "%Y-%m-%dT%H:%M:%SZ",
        &tm);
}

static void
cmd_log(
    const char *db,
    const char *key)
{
    int fd =
        open_db(
            db,
            O_RDONLY);

    off_t size =
        file_size_fd(fd);

    off_t off = 0;

    size_t n = 0;

    while (off < size)
    {
        recmeta r;

        int rc =
            rec_meta_at(
                fd,
                off,
                &r,
                size);

        if (rc != 1)
        {
            die(
                "database log is corrupt or truncated");
        }

        if (strcmp(
                r.key,
                key) == 0)
        {
            char id[65];
            char prev[65];
            char ts[32];

            id_hex(
                r.id,
                id);

            id_hex(
                r.prev,
                prev);

            print_time(
                r.ts,
                ts);

            if (r.type ==
                YODA_TYPE_PUT)
            {
                printf(
                    "PUT\t%s\t%s\t%s\t%s\t%" PRIu64 "\n",
                    ts,
                    id,
                    id_zero(r.prev)
                        ? "-"
                        : prev,
                    r.source,
                    r.value_len);
            }
            else if (r.type ==
                     YODA_TYPE_LINK)
            {
                printf(
                    "LINK\t%s\t%s\t%s\t%s\t%s\n",
                    ts,
                    id,
                    r.rel,
                    r.target,
                    r.source);
            }

            n++;
        }

        off =
            r.next_off;

        rec_free(&r);
    }

    close(fd);

    if (n == 0)
        exit(2);
}

/* ============================================================
 * LINK
 * ============================================================ */

static void
cmd_link(
    const char *db,
    const char *from,
    const char *rel,
    const char *to,
    const char *source)
{
    uint8_t zero[32] =
        {0};

    int fd =
        open_db(
            db,
            O_RDWR);

    lock_fd(
        fd,
        F_WRLCK);

    derived_state_ensure_for_write(
        db,
        fd);

    off_t from_off = 0;
    off_t to_off = 0;

    if (!direct_lookup_record(
            db,
            fd,
            from,
            &from_off))
    {
        unlock_fd(fd);
        close(fd);

        die(
            "link source not found");
    }

    if (!direct_lookup_record(
            db,
            fd,
            to,
            &to_off))
    {
        unlock_fd(fd);
        close(fd);

        die(
            "link target not found");
    }

    (void)from_off;
    (void)to_off;

    off_t record_off =
        file_size_fd(fd);

    append_record_fd(
        fd,
        YODA_TYPE_LINK,
        from,
        source,
        rel,
        to,
        zero,
        NULL,
        0);

    head_update_from_data(
        db,
        fd);

    index_append_link(
        db,
        fd,
        record_off);

    lookup_advance_after_nonput(
        db,
        fd,
        record_off);

    terms_advance_after_nonput(
        db,
        fd,
        record_off);

    edges_update_after_link(
        db,
        fd,
        record_off);

    unlock_fd(fd);

    close(fd);
}
/* ============================================================
 * VERIFY
 * ============================================================ */

static int
verify_one(
    int fd,
    const recmeta *r)
{
    sha256_ctx c;

    sha256_init(&c);

    sha256_update(
        &c,
        r->hash_prefix,
        72);

    sha256_update(
        &c,
        r->key,
        r->key_len);

    sha256_update(
        &c,
        r->source,
        r->source_len);

    sha256_update(
        &c,
        r->rel,
        r->rel_len);

    sha256_update(
        &c,
        r->target,
        r->target_len);

    uint8_t *buf =
        malloc(
            YODA_IO_CHUNK);

    if (!buf)
        die("oom");

    uint64_t left =
        r->value_len;

    off_t off =
        r->value_off;

    while (left)
    {
        size_t n =
            left >
            YODA_IO_CHUNK
                ? YODA_IO_CHUNK
                : (size_t)left;

        int rc =
            pread_all(
                fd,
                buf,
                n,
                off);

        if (rc != 1)
        {
            free(buf);
            return 0;
        }

        sha256_update(
            &c,
            buf,
            n);

        off +=
            (off_t)n;

        left -= n;
    }

    free(buf);

    uint8_t got[32];

    sha256_final(
        &c,
        got);

    return
        memcmp(
            got,
            r->id,
            32) == 0;
}

static void
cmd_verify(
    const char *db,
    const char *key)
{
    int fd =
        open_db(
            db,
            O_RDONLY);

    off_t size =
        file_size_fd(fd);

    off_t off = 0;

    uint64_t all = 0;
    uint64_t matched = 0;

    while (off < size)
    {
        recmeta r;

        int rc =
            rec_meta_at(
                fd,
                off,
                &r,
                size);

        if (rc != 1)
        {
            fprintf(
                stderr,
                "VERIFY=FAIL OFFSET=%jd RC=%d\n",
                (intmax_t)off,
                rc);

            exit(1);
        }

        all++;

        if (!key ||
            strcmp(
                r.key,
                key) == 0)
        {
            matched++;

            if (!verify_one(
                    fd,
                    &r))
            {
                char id[65];

                id_hex(
                    r.id,
                    id);

                fprintf(
                    stderr,
                    "VERIFY=FAIL ID=%s\n",
                    id);

                exit(1);
            }
        }

        off =
            r.next_off;

        rec_free(&r);
    }

    close(fd);

    if (key &&
        matched == 0)
    {
        exit(2);
    }

    printf(
        "VERIFY=PASS\n"
        "RECORDS_SCANNED=%" PRIu64 "\n"
        "RECORDS_VERIFIED=%" PRIu64 "\n",
        all,
        matched);
}

/* ============================================================
 * CONTEXT
 * ============================================================ */

typedef struct
{
    char **v;
    size_t n;
    size_t cap;
} yoda_seen;

static void
seen_init(
    yoda_seen *s)
{
    memset(
        s,
        0,
        sizeof(*s));
}

static void
seen_free(
    yoda_seen *s)
{
    for (size_t i = 0;
         i < s->n;
         i++)
    {
        free(s->v[i]);
    }

    free(s->v);

    memset(
        s,
        0,
        sizeof(*s));
}

static int
seen_has(
    const yoda_seen *s,
    const char *key)
{
    for (size_t i = 0;
         i < s->n;
         i++)
    {
        if (strcmp(
                s->v[i],
                key) == 0)
        {
            return 1;
        }
    }

    return 0;
}

static void
seen_add(
    yoda_seen *s,
    const char *key)
{
    if (seen_has(
            s,
            key))
    {
        return;
    }

    if (s->n ==
        s->cap)
    {
        size_t nc =
            s->cap
                ? s->cap * 2
                : 16;

        char **nv =
            realloc(
                s->v,
                nc *
                sizeof(*nv));

        if (!nv)
            die("oom");

        s->v = nv;
        s->cap = nc;
    }

    s->v[s->n] =
        strdup(key);

    if (!s->v[s->n])
        die("oom");

    s->n++;
}

static size_t
stream_value_limited(
    int fd,
    const recmeta *r,
    size_t max_bytes)
{
    uint8_t *buf =
        malloc(
            YODA_IO_CHUNK);

    if (!buf)
        die("oom");

    uint64_t allowed =
        r->value_len;

    if (max_bytes != 0 &&
        allowed >
        max_bytes)
    {
        allowed =
            max_bytes;
    }

    uint64_t left =
        allowed;

    off_t off =
        r->value_off;

    size_t written = 0;

    while (left)
    {
        size_t n =
            left >
            YODA_IO_CHUNK
                ? YODA_IO_CHUNK
                : (size_t)left;

        if (pread_all(
                fd,
                buf,
                n,
                off) != 1)
        {
            free(buf);

            die(
                "truncated value");
        }

        if (write_all(
                STDOUT_FILENO,
                buf,
                n) != 0)
        {
            free(buf);

            die_errno(
                "write stdout");
        }

        off +=
            (off_t)n;

        left -= n;
        written += n;
    }

    free(buf);

    return written;
}

static int
context_emit_offset(
    int fd,
    yoda_seen *seen,
    off_t record_off,
    const char *link_from,
    const char *link_rel,
    const char *link_to,
    size_t byte_budget,
    size_t *used)
{
    recmeta r;

    if (rec_meta_at(
            fd,
            record_off,
            &r,
            file_size_fd(fd)) != 1)
    {
        return 0;
    }

    if (r.type !=
        YODA_TYPE_PUT)
    {
        rec_free(&r);
        return 0;
    }

    if (seen_has(
            seen,
            r.key))
    {
        rec_free(&r);
        return 0;
    }

    if (byte_budget != 0 &&
        *used >=
        byte_budget)
    {
        rec_free(&r);
        return 0;
    }

    if (link_rel)
    {
        printf(
            "@link %s --%s--> %s\n",
            link_from,
            link_rel,
            link_to);
    }

    printf(
        "--- %s ---\n",
        r.key);

    fflush(stdout);

    size_t remaining = 0;

    if (byte_budget != 0)
    {
        remaining =
            byte_budget -
            *used;
    }

    size_t wrote =
        stream_value_limited(
            fd,
            &r,
            remaining);

    *used +=
        wrote;

    if ((uint64_t)wrote <
        r.value_len)
    {
        printf(
            "\n[truncated]\n");
    }
    else
    {
        putchar('\n');
    }

    seen_add(
        seen,
        r.key);

    rec_free(&r);

    return 1;
}

static int
context_emit_edge_neighbors(
    const char *db,
    int data_fd,
    int edges_fd,
    uint64_t edges_slots,
    yoda_seen *seen,
    const char *primary,
    size_t limit,
    size_t byte_budget,
    size_t *used,
    size_t *emitted)
{
    uint64_t head = 0;
    uint64_t count = 0;

    int rc =
        edges_lookup_head(
            edges_fd,
            edges_slots,
            data_fd,
            primary,
            &head,
            &count);

    if (rc < 0)
        return -1;

    if (rc == 0)
        return 1;

    uint64_t posting =
        head;

    uint64_t visited = 0;

    while (posting &&
           visited < count &&
           *emitted < limit)
    {
        uint64_t record_off = 0;
        uint64_t next = 0;

        if (!edges_read_posting(
                edges_fd,
                edges_slots,
                posting,
                &record_off,
                &next))
        {
            return -1;
        }

        posting =
            next;

        visited++;

        if (record_off >=
            (uint64_t)
            file_size_fd(data_fd))
        {
            return -1;
        }

        recmeta link;

        if (rec_meta_at(
                data_fd,
                (off_t)record_off,
                &link,
                file_size_fd(data_fd)) != 1)
        {
            return -1;
        }

        if (link.type !=
            YODA_TYPE_LINK)
        {
            rec_free(&link);
            return -1;
        }

        const char *related =
            NULL;

        if (strcmp(
                link.key,
                primary) == 0)
        {
            related =
                link.target;
        }
        else if (strcmp(
                     link.target,
                     primary) == 0)
        {
            related =
                link.key;
        }

        if (related &&
            !seen_has(
                seen,
                related))
        {
            off_t related_off = 0;

            int found =
                lookup_find(
                    db,
                    data_fd,
                    related,
                    &related_off);

            if (found)
            {
                *emitted +=
                    (size_t)
                    context_emit_offset(
                        data_fd,
                        seen,
                        related_off,
                        link.key,
                        link.rel,
                        link.target,
                        byte_budget,
                        used);
            }
        }

        rec_free(&link);

        if (byte_budget != 0 &&
            *used >=
            byte_budget)
        {
            break;
        }
    }

    return 1;
}

static void
cmd_context(
    const char *db,
    const char *query,
    size_t limit,
    size_t byte_budget)
{
    int fd =
        open_db(
            db,
            O_RDONLY);

    if (limit == 0)
        limit = 8;

    size_t hit_count = 0;

    search_hit *hits =
        search_collect(
            db,
            fd,
            query,
            limit,
            &hit_count);

    if (hit_count == 0)
    {
        search_hits_free(
            hits,
            hit_count);

        close(fd);

        exit(2);
    }

    int edges_fd =
        edges_open_current(
            db,
            fd);

    uint64_t committed_end = 0;
    uint64_t edges_slots = 0;
    uint64_t edges_used = 0;
    uint64_t edges_postings = 0;

    if (!edges_header_read(
            edges_fd,
            &committed_end,
            &edges_slots,
            &edges_used,
            &edges_postings))
    {
        close(edges_fd);
        search_hits_free(
            hits,
            hit_count);
        close(fd);

        die(
            "cannot read edges header");
    }

    (void)committed_end;
    (void)edges_used;
    (void)edges_postings;

    yoda_seen seen;

    seen_init(
        &seen);

    size_t used = 0;
    size_t emitted = 0;

    for (size_t i = 0;
         i < hit_count &&
         emitted < limit;
         i++)
    {
        emitted +=
            (size_t)
            context_emit_offset(
                fd,
                &seen,
                hits[i].record_off,
                NULL,
                NULL,
                NULL,
                byte_budget,
                &used);

        if (emitted >=
                limit ||
            (byte_budget != 0 &&
             used >=
                byte_budget))
        {
            break;
        }

        int rc =
            context_emit_edge_neighbors(
                db,
                fd,
                edges_fd,
                edges_slots,
                &seen,
                hits[i].key,
                limit,
                byte_budget,
                &used,
                &emitted);

        if (rc < 0)
        {
            close(edges_fd);

            edges_rebuild(
                db,
                fd);

            edges_fd =
                edges_open_current(
                    db,
                    fd);

            if (!edges_header_read(
                    edges_fd,
                    &committed_end,
                    &edges_slots,
                    &edges_used,
                    &edges_postings))
            {
                seen_free(&seen);
                search_hits_free(
                    hits,
                    hit_count);
                close(edges_fd);
                close(fd);

                die(
                    "edges recovery failed");
            }

            rc =
                context_emit_edge_neighbors(
                    db,
                    fd,
                    edges_fd,
                    edges_slots,
                    &seen,
                    hits[i].key,
                    limit,
                    byte_budget,
                    &used,
                    &emitted);

            if (rc < 0)
            {
                seen_free(&seen);
                search_hits_free(
                    hits,
                    hit_count);
                close(edges_fd);
                close(fd);

                die(
                    "edges remained corrupt after rebuild");
            }
        }
    }

    seen_free(&seen);

    search_hits_free(
        hits,
        hit_count);

    close(edges_fd);
    close(fd);

    if (emitted == 0)
        exit(2);
}

static char *
join_args(
    int argc,
    char **argv,
    int start)
{
    size_t n = 1;

    for (int i = start;
         i < argc;
         i++)
    {
        n +=
            strlen(argv[i]) +
            1;
    }

    char *s =
        malloc(n);

    if (!s)
        die("oom");

    s[0] = 0;

    for (int i = start;
         i < argc;
         i++)
    {
        if (i > start)
            strcat(
                s,
                " ");

        strcat(
            s,
            argv[i]);
    }

    return s;
}

static size_t
parse_size(
    const char *s,
    const char *name)
{
    if (!s ||
        !*s)
    {
        die(name);
    }

    errno = 0;

    char *end = NULL;

    unsigned long long v =
        strtoull(
            s,
            &end,
            10);

    if (errno != 0 ||
        !end ||
        *end != 0 ||
        v > SIZE_MAX)
    {
        die(name);
    }

    return
        (size_t)v;
}
/* ============================================================
 * CLI
 * ============================================================ */

static void
usage(void)
{
    fprintf(
        stderr,
        "usage: "
        "yoda init PATH | "
        "yoda [-d PATH] put KEY [source=X] | "
        "get KEY | "
        "find [--limit N] [QUERY...] | "
        "log KEY | "
        "link FROM REL TO [source=X] | "
        "verify [KEY] | "
        "context [--limit N] [--bytes N] QUERY...\n");

    exit(64);
}

int
main(
    int argc,
    char **argv)
{
    if (argc < 2)
        usage();

    if (strcmp(
            argv[1],
            "init") == 0)
    {
        if (argc != 3)
            usage();

        cmd_init(
            argv[2]);

        return 0;
    }

    const char *db =
        ".yoda";

    int i = 1;

    if (i < argc &&
        strcmp(
            argv[i],
            "-d") == 0)
    {
        if (i + 1 >= argc)
            usage();

        db =
            argv[i + 1];

        i += 2;
    }

    if (i >= argc)
        usage();

    recover_data_tail(
        db);

    const char *cmd =
        argv[i++];

    if (strcmp(
            cmd,
            "put") == 0)
    {
        if (i >= argc)
            usage();

        const char *key =
            argv[i++];

        cmd_put(
            db,
            key,
            parse_source(
                argc,
                argv,
                i));
    }
    else if (strcmp(
                 cmd,
                 "get") == 0)
    {
        if (i + 1 != argc)
            usage();

        cmd_get(
            db,
            argv[i]);
    }
    else if (strcmp(
                 cmd,
                 "find") == 0)
    {
        size_t limit = 0;

        while (i < argc)
        {
            if (strcmp(
                    argv[i],
                    "--limit") == 0)
            {
                if (i + 1 >= argc)
                    usage();

                limit =
                    parse_size(
                        argv[i + 1],
                        "invalid --limit");

                i += 2;
                continue;
            }

            break;
        }

        char *q =
            join_args(
                argc,
                argv,
                i);

        cmd_find(
            db,
            q,
            limit);

        free(q);
    }
    else if (strcmp(
                 cmd,
                 "log") == 0)
    {
        if (i + 1 != argc)
            usage();

        cmd_log(
            db,
            argv[i]);
    }
    else if (strcmp(
                 cmd,
                 "link") == 0)
    {
        if (i + 2 >= argc)
            usage();

        const char *from =
            argv[i];

        const char *rel =
            argv[i + 1];

        const char *to =
            argv[i + 2];

        cmd_link(
            db,
            from,
            rel,
            to,
            parse_source(
                argc,
                argv,
                i + 3));
    }
    else if (strcmp(
                 cmd,
                 "verify") == 0)
    {
        const char *key =
            i < argc
                ? argv[i]
                : NULL;

        if (i + 1 < argc)
            usage();

        cmd_verify(
            db,
            key);
    }
    else if (strcmp(
                 cmd,
                 "context") == 0)
    {
        size_t limit = 8;
        size_t bytes = 12000;

        while (i < argc)
        {
            if (strcmp(
                    argv[i],
                    "--limit") == 0)
            {
                if (i + 1 >= argc)
                    usage();

                limit =
                    parse_size(
                        argv[i + 1],
                        "invalid --limit");

                i += 2;
                continue;
            }

            if (strcmp(
                    argv[i],
                    "--bytes") == 0)
            {
                if (i + 1 >= argc)
                    usage();

                bytes =
                    parse_size(
                        argv[i + 1],
                        "invalid --bytes");

                i += 2;
                continue;
            }

            break;
        }

        if (i >= argc)
            usage();

        char *q =
            join_args(
                argc,
                argv,
                i);

        cmd_context(
            db,
            q,
            limit,
            bytes);

        free(q);
    }
    else
    {
        usage();
    }

    return 0;
}
