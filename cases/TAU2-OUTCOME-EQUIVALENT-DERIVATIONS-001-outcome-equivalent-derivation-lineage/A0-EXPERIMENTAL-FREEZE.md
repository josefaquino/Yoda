# A0 — Experimental Freeze

## Status

```text
CASE=TAU2-OUTCOME-EQUIVALENT-DERIVATIONS-001
STAGE=A0
STATUS=PRE_REGISTERED
EXECUTED=NO
```

## Purpose

A0 freezes the exact deterministic execution contract for the two selected derivations.

A0 does not execute either trajectory and does not invoke the tau2 runtime evaluator.

```text
TRAJECTORY_EXECUTED=NO
TAU2_RUNTIME_EXECUTED=NO
MODEL_ENDPOINT_CALLED=NO
USER_SIMULATOR_EXECUTED=NO
GOLDEN_STATE_MATERIALIZED=NO
YODA_WRITES=ZERO
```

## PRE-A0 authority

```text
PRE_A0_R1=PASS

PRE_A0_SELECTION_LOCK_SHA256=
3fadca4c055749eaabcf1a5ef5186cabf2636c0c3044d41ae7c13388e39840dd

PRE_A0_EVIDENCE_MANIFEST_SHA256=
dbc68eb5611218bb8064adb16e0177572e87b94ad68de18f7f8f609b4b546597

PRE_A0_SELECTION_CONSOLE_SHA256=
0786d3928f4cc112e6172e9ab993410a5d3cfd69847eb67f662f798b2f99731a

SELECTED_TASK_ID=7

SELECTED_TASK_SHA256=
3afcd45425f2397430b1680a51350043b0beefc825635ac6a32cc1f8b9182c6d

REFERENCE_SEQUENCE_SHA256=
686d852e4d51fbf780cc030e55a36f066972ac67e477b3b39d563685d03b8a77

ALTERNATIVE_SEQUENCE_SHA256=
b1d6615d0fa826545702f7db61194359b1d919cfc7667fe10d330bc546c4ffe6
```

## Selected task

The frozen task is Airline task 7 from tau2-bench v1.0.1.

Reference action sequence:

```text
0  get_reservation_details
   reservation_id=XEHM4B

1  get_reservation_details
   reservation_id=59XX6W

2  update_reservation_flights
   reservation_id=XEHM4B
   cabin=business
   flights=HAT005@2024-05-20,HAT178@2024-05-30
   payment_id=credit_card_2408938

3  cancel_reservation
   reservation_id=XEHM4B

4  cancel_reservation
   reservation_id=59XX6W
```

Reward authority:

```text
REWARD_BASIS=DB,COMMUNICATE
COMMUNICATE_INFO=1628
ACTION_IN_REWARD_BASIS=NO
NL_ASSERTION_IN_REWARD_BASIS=NO
```

## Frozen derivation transformation

Trajectory A uses the frozen reference action order.

Trajectory B changes only the order of actions 0 and 1:

```text
TRAJECTORY_A_ACTION_ORDER=0,1,2,3,4
TRAJECTORY_B_ACTION_ORDER=1,0,2,3,4

TRANSFORMATION=
SWAP_ADJACENT_INDEPENDENT_READ_ACTIONS

LEFT_ACTION_TOOL=get_reservation_details
LEFT_ACTION_ARGUMENT=reservation_id:XEHM4B

RIGHT_ACTION_TOOL=get_reservation_details
RIGHT_ACTION_ARGUMENT=reservation_id:59XX6W
```

Both swapped tools are upstream-declared READ tools.

All WRITE actions and WRITE arguments remain byte-equivalent and order-equivalent between A and B.

## Deterministic trajectory contract

A1 will not call an LLM or user simulator.

The two trajectories will be constructed deterministically using the frozen upstream tau2 runtime.

```text
TRAJECTORY_GENERATOR=DETERMINISTIC_HARNESS
AGENT_MODEL=NONE
USER_MODEL=NONE

DOMAIN=airline
MODE=HALF_DUPLEX
SOLO_MODE=FALSE
STRICT_REPLAY=TRUE

TERMINATION_REASON=AGENT_STOP
EVALUATION_TYPE=ALL
```

Each trajectory will contain the frozen tool-call sequence and tool responses produced by the exact frozen Airline environment.

Both trajectories use the same final assistant communication:

```text
The total cost of your other upcoming flights is $1,628.
```

This text is fixed before either trajectory is executed.

## Correctness contract

The official tau2 evaluator remains the sole correctness authority.

For task 7:

```text
FINAL_REWARD =
DB_REWARD * COMMUNICATE_REWARD
```

PASS for one trajectory requires:

```text
DB_REWARD=1.0
COMMUNICATE_REWARD=1.0
FINAL_REWARD=1.0
```

Action checks may be produced diagnostically by `EvaluationType.ALL`, but they do not gate task 7 because `ACTION` is absent from `reward_basis`.

NL assertions do not execute because `NL_ASSERTION` is absent from task 7 reward_basis.

## Outcome-equivalence contract

A1 outcome equivalence requires:

```text
TRAJECTORY_A_FINAL_REWARD=1.0
TRAJECTORY_B_FINAL_REWARD=1.0

TRAJECTORY_A_DB_REWARD=1.0
TRAJECTORY_B_DB_REWARD=1.0

TRAJECTORY_A_COMMUNICATE_REWARD=1.0
TRAJECTORY_B_COMMUNICATE_REWARD=1.0

TRAJECTORY_A_FINAL_AGENT_DB_HASH
==
TRAJECTORY_B_FINAL_AGENT_DB_HASH

REFERENCE_SEQUENCE_SHA256
!=
ALTERNATIVE_SEQUENCE_SHA256
```

The two trajectories are not required to have identical read outputs ordering, message ordering, or trajectory bytes.

## Frozen upstream release

```text
UPSTREAM_REPOSITORY=sierra-research/tau2-bench
RELEASE_TAG=v1.0.1
RELEASE_COMMIT=fc0055dc4e0a316c3f83133267fbd6faaa770992
PYTHON_REQUIREMENT=>=3.12,<3.14
```

Frozen authority blob identities:

```text
pyproject.toml
55a9d9cf6ebd8bf2326798f4923988917e431086

docs/evaluation.md
2552c6c488e157a4366238880a870e83b7aa1758

airline/db.json
c6a1e817aa9102c5822e83affb3595acbc312701

airline/policy.md
8098be7db3f47de943fad39d1e057ede6cc6cd04

airline/tasks.json
ea4ff5e3f5e3d97ca391846a6e8dd9eb3437dc80

airline/split_tasks.json
c83cce155671e66a6bf07450fd2845fe0eb1f229

airline/tools.py
adc5c09a155d82d91e2f0647682023419eaca2ea

airline/environment.py
e1cabffe7ed4ad895904aa5248319dd307e77a97

airline/data_model.py
1b65884c10349950a1fc31c8ad96a8d804e093a1

environment/environment.py
0dce3d21826273e789eb25fa167b95ab148fa4f4

data_model/message.py
0449e2f2ce82cc03dd351520549eb9e24eb70bf9

data_model/tasks.py
28f37885f0282bd3b82eed18bfe8aa2350fba2b7

data_model/simulation.py
edc805ee2e645d62edd6e8b1c20b24a12b175d74

evaluator/evaluator.py
76c95a83e9049d70a5570b93989797c0626974b6

evaluator/evaluator_env.py
a2e0a1a07cffd9394cc462376799289b1e9fbedd

evaluator/evaluator_communicate.py
1bac18fd8830304894da767d2e6b7efe6e779e89
```

## PRE-A0 policy identity

Use Git identity because the policy document contains non-ASCII text.

```text
PRE_A0_POLICY_COMMIT=
ca68b7050f0ace6674a69512ae6ea5e21651de0c

PRE_A0_POLICY_BLOB_SHA=
168142480692be4b40cdd890609572b5984b8969
```

## A0 PASS

A0 PASS requires exact freezing of all authorities and the execution contract, with no trajectory evaluation.

```text
A0=PASS

TASK_ID=7
TRAJECTORY_A=FROZEN
TRAJECTORY_B=FROZEN
COMMUNICATION_CONTRACT=FROZEN
EVALUATION_CONTRACT=FROZEN
UPSTREAM_AUTHORITY=FROZEN

TRAJECTORY_EXECUTED=NO
TAU2_RUNTIME_EXECUTED=NO
MODEL_ENDPOINT_CALLED=NO
USER_SIMULATOR_EXECUTED=NO
GOLDEN_STATE_MATERIALIZED=NO
YODA_WRITES=ZERO
YODA_CHANGE=NO
KYBER_CHANGE=NO

NEXT_GATE=A1_DUAL_DERIVATION_EXTERNAL_JUDGMENT
```

## Non-claims

This CASE is not an LLM capability benchmark.

A PASS would not show that a model independently discovered both trajectories.

It tests whether two materially distinct deterministic assistant-tool derivations can be judged outcome-equivalent by an external benchmark and later be preserved and replayed through Yoda.
