# TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001

## PRE-A0 — Capability and Task Selection Policy

```text
CASE=TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001
STAGE=PRE-A0
MODE=READ_ONLY_CAPABILITY_AND_TASK_AUDIT

TRAJECTORY_EXECUTION=NO
MODEL_ENDPOINT_CALLED=NO
GOLDEN_STATE_MATERIALIZED=NO

YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Research question

Can Yoda preserve two materially distinct agent derivations that converge on the same accepted tau2-bench Airline outcome, without treating either trajectory as the definition of correctness, and later reproduce both derivations and their outcome equivalence using only recovered artifacts?

## External authority

```text
UPSTREAM_REPOSITORY=https://github.com/sierra-research/tau2-bench
RELEASE_TAG=v1.0.1
TAG_OBJECT_SHA=b711c1ead46f55111bf765cf44d5da8bacc2d28c
RELEASE_COMMIT=fc0055dc4e0a316c3f83133267fbd6faaa770992

DOMAIN=airline
TASK_SPLIT=base
MODE=text
```

Pinned Git blob identities:

```text
PYPROJECT_BLOB_SHA=55a9d9cf6ebd8bf2326798f4923988917e431086
EVALUATION_DOC_BLOB_SHA=2552c6c488e157a4366238880a870e83b7aa1758
LICENSE_BLOB_SHA=f0323a32227c1327820da33d2fb9d3338a27ac84

AIRLINE_DB_BLOB_SHA=c6a1e817aa9102c5822e83affb3595acbc312701
AIRLINE_POLICY_BLOB_SHA=8098be7db3f47de943fad39d1e057ede6cc6cd04
AIRLINE_SPLIT_TASKS_BLOB_SHA=c83cce155671e66a6bf07450fd2845fe0eb1f229
AIRLINE_TASKS_BLOB_SHA=ea4ff5e3f5e3d97ca391846a6e8dd9eb3437dc80
AIRLINE_TOOLS_BLOB_SHA=adc5c09a155d82d91e2f0647682023419eaca2ea
```

## Correctness authority

Correctness is outcome-based.

```text
CORRECTNESS_AUTHORITY=TAU2_EXTERNAL_JUDGE
REFERENCE_ACTIONS_DEFINE_ONLY_CORRECT_TRAJECTORY=NO
ACTION_MATCHING_REQUIRED_FOR_AIRLINE=NO
```

The reference actions may be replayed to derive the target terminal database state, but the trajectory itself is not the correctness definition.

## Frozen inclusion criteria

Every selected task must satisfy:

```text
DOMAIN=airline
TASK_IN_BASE_SPLIT=YES

REWARD_BASIS_CONTAINS_DB=YES
REWARD_BASIS_CONTAINS_ACTION=NO

REFERENCE_ACTION_COUNT>=3
STATE_CHANGING_REFERENCE_ACTION_COUNT>=1

GOLDEN_DB_AUTHORITY_PRESENT=YES
EXTERNAL_EVALUATION_AUTHORITY_PRESENT=YES

ALTERNATIVE_TRANSFORMATION_CLASS=
SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS
```

## Tool-type authority

Tool mutability is taken only from the frozen upstream decorators in:

```text
src/tau2/domains/airline/tools.py
```

A task action is classified as READ, WRITE, or GENERIC from the frozen upstream `@is_tool(ToolType.*)` declaration.

No local reclassification of a tool is permitted.

## Alternative transformation rule

The only PRE-A0 transformation class is:

```text
SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS
```

For a pair of adjacent reference actions `Ai, Ai+1`:

```text
TOOL_TYPE(Ai)=READ
TOOL_TYPE(Ai+1)=READ

Ai mutates state = NO
Ai+1 mutates state = NO

both argument objects are already fully specified
in the frozen reference action data

the transformed trajectory preserves:
- every action
- every action argument
- every WRITE action
- every business effect
- policy
- tools
- task
- judge
- initial database

only the order of that adjacent READ pair changes
```

Because both operations are upstream-declared READ operations and all arguments are already frozen literals, the transformation does not require output from one call to construct the arguments of the other.

A0 must still audit the selected pair and freeze the exact transformation before either trajectory is executed.

## Material distinctness candidate

The transformation is considered materially distinct at PRE-A0 because:

```text
CANONICAL_TOOL_SEQUENCE_A != CANONICAL_TOOL_SEQUENCE_B
```

Differences only in timestamps, runtime duration, token counts, random identifiers, log ordering, or ephemeral request identifiers are not sufficient.

## Selection order

Selection is deterministic:

```text
1. Enumerate every task in split_tasks.json["base"].
2. Resolve each ID against tasks.json.
3. Sort IDs numerically ascending.
4. Apply the frozen inclusion criteria.
5. For each eligible task, scan adjacent action pairs
   from lowest action index to highest.
6. The first pair satisfying the frozen READ-swap rule
   makes that task selection-eligible.
7. Select the first selection-eligible task.
8. Stop immediately.
```

No task may be skipped because it is inconvenient, boring, complex, or later produces a failed trajectory.

## Prohibited selection inputs

Selection must not use:

```text
model leaderboard results
agent success rates
previous trajectory outputs
manual trial executions
judge outcomes from candidate tasks
Yoda behavior
commercial attractiveness
task narrative preference
```

## PRE-A0 preflight

The preflight may:

```text
clone the exact release
verify commit and Git blob identities
validate JSON syntax
verify documentation authority
extract upstream tool types
run a synthetic selector self-test
```

It must not enumerate the real task set for selection or emit a selected task.

```text
FINAL_TASK_SELECTED=NO
```

## PRE-A0 scientific audit

Only after preflight PASS may the scientific selection gate:

```text
enumerate real Airline base tasks
build the task inventory
apply the frozen policy
freeze exactly one selected task
freeze exactly one adjacent READ-swap candidate
produce evidence manifests
```

Still:

```text
TRAJECTORY_EXECUTION=NO
MODEL_ENDPOINT_CALLED=NO
GOLDEN_STATE_MATERIALIZED=NO
YODA_WRITES=ZERO
```

## PASS

```text
PRE_A0=PASS

RELEASE=FROZEN
DOMAIN=airline
TASK_SPLIT=base
TASK_SELECTION_POLICY=FROZEN

CANDIDATE_TASK_IDENTIFIED=PASS
ALTERNATIVE_TRANSFORMATION_PLAUSIBILITY=PASS

TRAJECTORY_EXECUTED=NO
MODEL_ENDPOINT_CALLED=NO
GOLDEN_STATE_MATERIALIZED=NO
YODA_WRITES=ZERO

NEXT_GATE=A0_EXPERIMENTAL_FREEZE
```

If no task satisfies the frozen policy:

```text
PRE_A0=NOT_READY
CASE_HYPOTHESIS=NOT_EVALUATED
```

This is not CASE FAIL.
