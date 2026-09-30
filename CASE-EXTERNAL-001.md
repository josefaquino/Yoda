# YODA CASE-EXTERNAL-001

## Independent Developer Decision-State Validation

### Question

Can a developer with no prior Yoda knowledge download the release,
run it, reproduce a decision-state example, understand the evidence,
and verify the resulting state without assistance from the authors?

## Starting Conditions

The tester receives only:

- the release archive;
- the files contained in the archive.

No knowledge of Yoda internals is required.

## Procedure

Verify package integrity:

    sha256sum -c SHA256SUMS

Run the included case:

    cd examples/decision-state
    ./run.sh

## Scenario

An earlier production validation states:

    Orion production database:
    PostgreSQL 15.4 approved.

A later validation states:

    Orion production database:
    PostgreSQL 16 approved after successful validation.

The newer evidence is explicitly related to the older evidence through:

    supersedes

Yoda must preserve both pieces of evidence.

Historical truth must not be deleted merely because a newer state exists.

## Expected Observations

The tester should be able to observe:

1. both evidence objects still exist;
2. the newer evidence is independently retrievable;
3. the older evidence is independently retrievable;
4. a relation connects the newer evidence to the older evidence;
5. search can discover relevant evidence;
6. context can produce a bounded evidence bundle;
7. verify reports authoritative storage integrity.

## Pass Gates

Record:

    PACKAGE_HASH=PASS|FAIL
    BINARY_EXECUTION=PASS|FAIL
    INIT=PASS|FAIL
    INGEST=PASS|FAIL
    LINK=PASS|FAIL
    GET=PASS|FAIL
    FIND=PASS|FAIL
    CONTEXT=PASS|FAIL
    VERIFY=PASS|FAIL

Human evaluation:

    PRODUCT_PURPOSE_UNDERSTOOD=YES|NO
    AUTHOR_ASSISTANCE_REQUIRED=YES|NO

The purpose of this case is not performance benchmarking.

The purpose is independent product comprehension and reproducibility.
