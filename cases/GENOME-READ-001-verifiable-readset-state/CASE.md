# GENOME-READ-001 — Case Contract

## Question

Can KyberDB preserve a real paired-end sequencing ReadSet — including pair identity, nucleotide sequence and quality strings for both mates — and reconstruct exactly the same canonical state after persistence, verification and close/reopen?

## Public authority

- Authority: EMBL-EBI ENA
- Run accession: `SRR10058842`
- Study accession: `PRJNA563564`
- Sample accession: `SAMN12676338`
- Experiment accession: `SRX6792841`
- Platform: `ILLUMINA`
- Instrument: `Illumina HiSeq 2500`
- Layout: `PAIRED`
- Strategy: `WGS`

ENA metadata reported:

```text
READ_COUNT=1835120
BASE_COUNT=458780000
FASTQ_FILE_COUNT=2
```

Official FASTQ files:

```text
SRR10058842_1.fastq.gz
SRR10058842_2.fastq.gz
```

Official MD5 values:

```text
R1 dedc30ba684c20e224a702b4b56d63ce
R2 96d413085568e519fda51c4e57c588ab
```

## Oracle authority

The deterministic sample was generated with:

```text
seqtk 1.4-r122
Debian package 1.4-2
binary SHA-256:
ee715b8df1196960a746f2df090af69335237a5d9ce5407ba878740b556744d7
```

Sampling contract:

```text
PAIR_COUNT=10000
SEED=100
```

The same seed was applied independently to the two mate files, then pair identity was required to match exactly.

## Canonical ReadSet state

Each canonical row is:

```text
PAIR_ID<TAB>R1_SEQUENCE<TAB>R1_QUALITY<TAB>R2_SEQUENCE<TAB>R2_QUALITY
```

The Stage A1 oracle contains exactly 10,000 paired rows.

Validation requires:

```text
PAIR_IDENTITY_EQUIVALENCE=PASS
BAD_ORACLE_ROWS=0
ORACLE_PAIR_COUNT=10000
```

Frozen oracle SHA-256:

```text
2c900493cc32a0c847fb7b78421c0afeab8e21a006fa6b9415951913f9eb9ae7
```

## Kyber representation under test

The experimental Stage B adapter uses one ordinary key/value record per read pair:

```text
key:
readpair/<PAIR_ID>

value:
R1_SEQUENCE<TAB>R1_QUALITY<TAB>R2_SEQUENCE<TAB>R2_QUALITY
```

This is an experimental adapter for the case. It is not declared to be the final ReadSet storage format.

## Engine boundary

The case uses the frozen KyberDB Public Embedded ABI only.

Frozen identities:

```text
kyber.h SHA-256:
6d2dfadfa6bb69da86984709af72bcd633c874f2dc7b63658c17c99dc498437d

libkyber.a SHA-256:
ff054b12821f2db44dbdcef561c2911c9481467e5a663ab06153bf6ea89e5be4
```

No internal API and no engine modification is permitted.

## Required lifecycle

```text
real FASTQ pair
    ↓
canonical 10K oracle
    ↓
Kyber puts
    ↓
durable commit
    ↓
verify
    ↓
source oracle closed
    ↓
close
    ↓
reopen existing repo
    ↓
verify
    ↓
GET all 10K pair IDs
    ↓
reconstruct canonical ReadSet
    ↓
byte-exact comparison with oracle
```

## PASS gates

The case is PASS only if all of the following are derived from execution evidence:

```text
PAIR_PUT_COUNT=10000
POST_REOPEN_PAIR_COUNT=10000
VERIFY_PRE_CLOSE=PASS
SOURCE_ORACLE_CLOSED_BEFORE_REOPEN=PASS
CLOSE_REOPEN=PASS
VERIFY_POST_REOPEN=PASS
MISSING=0
MISMATCH=0
POST_REOPEN_READSET_EQUIVALENCE=PASS
STAGE_B_EVIDENCE_INTEGRITY=PASS
ENGINE_CHANGE=NO
PUBLIC_ABI_ONLY=YES
```

Additionally:

```text
ORACLE_SHA256 == KYBER_READSET_SHA256
```

## Non-claims

GENOME-READ-001 does not establish:

- alignment correctness;
- BAM/CRAM support;
- variant calling;
- assembly;
- clinical use;
- biological interpretation;
- competitive performance;
- production readiness;
- a final genomic schema.

The only claim under test is exact durable ReadSet state for the frozen workload.
