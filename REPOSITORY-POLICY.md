# Repository Policy

## Public project surface

Yoda is the single canonical active repository for the current research and engineering program.

```text
ACTIVE_CANONICAL_REPOSITORY=Yoda
```

Historical repositories are preserved as provenance, not presented as competing active projects.

---

## Direct Yoda lineage

### Sputnik

```text
ROLE=historical predecessor
ACTION=archive
CANONICAL_PROJECT=Yoda
```

Historical contribution:

- observation and discovery infrastructure;
- autonomous acquisition experiments;
- early separation between observation and knowledge/derivation.

Repository:

https://github.com/josefaquino/Sputnik

### vostok-os

```text
ROLE=historical predecessor
ACTION=archive
CANONICAL_PROJECT=Yoda
```

Historical contribution:

- YodaDB/Kyber systems experiments;
- CDC and durability mechanisms;
- crash recovery and benchmarking;
- early agent-oriented storage work.

Repository:

https://github.com/josefaquino/vostok-os

---

## Other owned repositories

The account currently contains older learning, exercise, portfolio and experimental repositories in addition to the direct Yoda lineage.

If the public-profile goal is:

> one active project = Yoda

then these repositories should be archived rather than deleted.

Current owned repositories outside Yoda include:

```text
AluraStore
amigo-secreto
amigo_secreto
Classificao_ML
crawler
CryptoWorld
db-capstone-project
db_meta
docker-ubuntu-install-dio
Estatistica_Alura_One
explora
Guessinggame
Introduction-to-Data-Science-in-python
Inventory-Demand-Forecasting
jogosorte
jose.chocolates
josefaquino.github.io
lab
linux-projeto1-iac
linux-projeto2-iac
linux-site-dio
livro-receitas
my-first-repo
OracleOne
repo-exercise
Sputnik
Telecom_X_Alura
the-unix-workbench
vostok-os
```

### Special case: josefaquino.github.io

Before archiving `josefaquino.github.io`, verify whether it is still being used for GitHub Pages.

If it is still serving a public site, either:

1. keep it active as infrastructure while Yoda remains the only active *project*; or
2. replace it with a minimal redirect/pointer to Yoda before archiving.

This is the only repository in the inventory that should not be mass-archived without checking its Pages role.

---

## Deletion policy

Do not delete repositories that contain meaningful project or learning history merely to clean the profile.

Preferred order:

```text
ACTIVE
↓
LEGACY
↓
ARCHIVED
```

Deletion is reserved for repositories that are truly accidental, empty, duplicated or have zero historical/evidentiary value.

---

## Profile policy

Recommended profile presentation:

```text
PINNED
└── Yoda

ACTIVE PROJECT
└── Yoda

HISTORICAL
├── Sputnik
├── vostok-os
└── archived older repositories
```

The profile should answer within seconds:

> What is the main project?

Answer:

> Yoda.

---

## History policy

The current Yoda repository remains focused on current architecture and evidence.

Historical predecessor code stays in its original repository so commit history and provenance remain intact.

Yoda links to that history through:

- [HISTORY.md](HISTORY.md)
- this repository policy
- case/evidence records

This preserves the principle:

```text
history is evidence
```
