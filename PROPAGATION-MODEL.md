# Yoda Propagation Model

## Purpose

Yoda should grow through propagation, not through feature accumulation or top-down marketing.

The objective is to turn real problems into reproducible evidence, reproducible evidence into reusable experiments, and reusable experiments into new knowledge that other developers can reproduce, adapt, publish, and extend.

This model is part of Yoda's product direction. It does not change CORE-014 or the Yoda v0.1 Product Contract.

## Origin

Yoda inherits this idea from the project's earlier lineage.

LarvalCrawler was designed to discover, classify, learn, generate new candidates, and expand its knowledge autonomously.

Yoda applies the same underlying pattern to developer knowledge:

    problem
      -> experiment
      -> evidence
      -> reproduce
      -> adapt
      -> publish
      -> fork
      -> generate new experiments
      -> expand organically

LarvalCrawler propagated discoveries.

Yoda should propagate verifiable knowledge.

## Core Principle

> Evidence should propagate.

Every useful Yoda experiment should be:

- reproducible;
- understandable;
- adaptable;
- independently verifiable;
- publishable;
- forkable;
- able to generate another experiment.

A case is not complete merely because it produces `PASS`.

A case reaches its strongest form when another developer can reproduce it, replace the original scenario with a real problem of their own, publish the result, and allow a third developer to continue the chain.

## Propagation Loop

    REAL PROBLEM
         |
         v
    YODA EXPERIMENT
         |
         v
       GITHUB
         |
         +-----------------+
         |                 |
         v                 v
      DOWNLOAD            FORK
         |                 |
         v                 v
        RUN               ADAPT
         |                 |
         v                 v
       LEARN             PUBLISH
         |                 |
         +--------+--------+
                  |
                  v
             MORE USERS
                  |
                  v
            MORE PROBLEMS
                  |
                  v
             BETTER YODA

Download is distribution.

Fork is evolution.

## Unit of Growth

The primary unit of organic growth is not the database itself and not a marketing page.

It is a useful, reproducible problem.

A developer may arrive at Yoda while searching for a problem such as:

    multi-agent shared state

rather than searching for:

    Yoda database

The intended path is:

    developer finds a real problem
      -> finds a Yoda case
      -> runs it
      -> recognizes the same class of problem
      -> adapts the case
      -> publishes the experiment
      -> another developer discovers it
      -> reproduces or forks it

This creates propagation rather than one-way adoption.

## Yoda Case

The initial propagation object is a `Yoda Case`.

A case should be small enough to clone and run, but complete enough to preserve evidence, method, expected behavior, and lineage.

Recommended structure:

    cases/
    `-- FIELD-001-example/
        |-- README.md
        |-- CASE.md
        |-- run.sh
        |-- evidence/
        |-- expected/
        |-- RESULTS.md
        `-- SHA256SUMS

A case should make three actions obvious:

    Reproduce
    Adapt
    Publish your variant

## Minimal Case Identity

A published case should carry a small identity block:

    CASE_ID=FIELD-001
    TITLE=Multi-Agent Decision State
    YODA_VERSION=v0.1.0-preview.1
    CORE=CORE-014
    STATUS=PASS

When derived from an earlier experiment, it should also record lineage:

    DERIVED_FROM=FIELD-001

Additional relationships may be represented explicitly when useful:

    reproduces
    derived-from
    contradicts
    supersedes

The purpose is not to create a centralized registry now.

The purpose is to make experiment lineage understandable and machine-readable enough to evolve later.

## Propagation Gates

A community-oriented case should aim to satisfy:

    REPRODUCIBLE=YES
    ADAPTABLE=YES
    REPUBLISHABLE=YES
    FORKABLE=YES

The stronger product gate is therefore not only:

> Can a stranger run Yoda?

It is:

> Can a stranger run Yoda, solve a problem, and produce something another stranger can reuse?

## Community Role

Developers are not only users.

They can become contributors of verifiable knowledge.

A developer may:

- reproduce an existing case;
- adapt it to another domain;
- publish a new variant;
- contradict a prior result with evidence;
- supersede an outdated result;
- improve the experiment contract;
- expose a missing Yoda capability through real usage.

The resulting network should grow through useful artifacts rather than through centralized control.

## GitHub as the Initial Propagation Network

Yoda does not need a proprietary cloud or hosted collaboration system to test this model.

GitHub already provides the initial propagation surface:

- discovery;
- cloning;
- forks;
- pull requests;
- issues;
- history;
- collaboration;
- distribution.

Yoda remains local and offline-capable.

GitHub provides the network through which experiments can propagate.

## Product Development from Community Evidence

The roadmap should emerge from repeated real-world problems, not from speculative feature design.

The preferred loop is:

    users
      -> problems
      -> cases
      -> evidence
      -> repeated friction
      -> product change

A feature becomes interesting when independent cases repeatedly expose the same missing capability.

For example, if community cases repeatedly require easier import, structured output, signatures, or another primitive, that repeated demand becomes evidence for prioritization.

A single request is an observation.

Repeated independent demand is a signal.

The product should evolve from signals.

## Growth Metrics

Early Yoda growth should not be optimized primarily for stars, impressions, or downloads.

More meaningful signals are:

    stranger_downloaded
    stranger_ran_case
    stranger_understood
    stranger_adapted_case
    stranger_published_variant
    stranger_returned
    stranger_told_someone_else

The strongest early growth signal is propagation:

    one case
      -> independent reproduction
      -> adaptation
      -> publication
      -> new user
      -> new case

## Three Validation Vectors

Yoda currently has three complementary external validation vectors.

### 1. Simplicity

Question:

> What should we remove?

This tests whether Yoda remains small, composable, and understandable.

### 2. AI Engineering Primitive

Question:

> Is durable, verifiable decision state a useful primitive for agentic systems, or is the problem being solved at the wrong layer?

This tests the core product thesis.

### 3. Community Propagation

Question:

> Does this solve a real problem strongly enough that a normal developer will reproduce it, adapt it, and publish something another developer can reuse?

This tests whether Yoda can become a living developer ecosystem.

## Non-Goals

The propagation model does not imply that Yoda should immediately build:

- a centralized case registry;
- a hosted collaboration platform;
- social features;
- cloud synchronization;
- package discovery infrastructure;
- reputation systems;
- a proprietary marketplace.

Those mechanisms should appear only if real propagation produces evidence that they are needed.

The initial strategy is deliberately simpler:

    local Yoda
      + reproducible cases
      + GitHub
      + ordinary developers

## Product Principle

> Yoda grows by propagation: real problems become reproducible evidence, reproducible evidence becomes reusable experiments, and reusable experiments generate new knowledge.

This is not only a growth strategy.

It is the intended product behavior.

Small core.
Durable evidence.
Explicit history.
Verifiable state.
Reproducible experiments.
Organic propagation.
