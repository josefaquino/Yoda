# COMMAND-NATIVE-001 — Case Specification

## Research question

Can an autonomous agent recover decision-relevant durable state using only a small Yoda command vocabulary, without SQL, raw database access, or a full state dump in its prompt?

## Frozen authorities

The experiment used the frozen CORE-015 binary authority:

    1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb

Model authority:

    Ollama 0.32.6
    qwen2.5:14b
    model digest 7cdf5a0187d5c58cc5d369b255592f7841d1c4696d45a8c8a9489440385b22f6

The experiment retained the same decision task, durable state, scorer, model identity, and read-only Yoda operations while iterating on the textual command transport.

## Arms

### CONTROL

A fresh model receives the task without durable state.

Expected behavior:

    DECISION=UNKNOWN
    STATE=UNVERIFIED

This verifies that the model does not guess the deployment decision without evidence.

### DUMP

A fresh model receives the complete state dump in its prompt.

This is a positive control showing that the model and task are capable of producing the expected decision when all evidence is directly available.

### COMMAND

A fresh model receives no state dump. Durable state is available only through the Yoda command vocabulary:

    find
    get
    log
    context
    verify

The model must call `verify` at least once before a final decision.

## Decision task

The model must determine whether `dependency/widget-2.4` or `dependency/widget-2.5` may be deployed to production under the current durable policy and evidence.

The reference decision is:

    DECISION=DEPLOY
    SUBJECT=dependency/widget-2.5
    STATE=VERIFIED

Decision-critical evidence includes the production policy, Widget 2.5 validation, and the active security advisory affecting Widget 2.4.

## Attempt history

### Attempt 001

The transcript serialized the model's own valid command as `AGENT|CALL|...`. On the following turn the model reproduced that prefix, while the parser accepted only lines beginning with `CALL|`.

Classification:

    INVALID_HARNESS_PROTOCOL
    cause=transcript-prefix-contamination

### Attempt 002

The prefix contamination was removed. The model produced one valid `CALL|...` line plus auxiliary wrapper lines. The parser rejected the entire multiline response.

Classification:

    INVALID_HARNESS_PROTOCOL
    cause=multiline-rejection

### Attempt 003

The normalizer was changed to accept exactly one valid protocol line and ignore non-protocol wrapper text.

The model then treated `find` as if it accepted a structured query language, received no discovery result, and subsequently attempted an unobserved exact key.

Classification:

    VALID_INTERFACE_RESULT
    discoverability-friction=observed

### Attempt 004

Only the command documentation changed. `find` was explicitly defined as lexical plain-text search, and exact-key operations were documented as requiring keys supplied by the task or previously observed through tools.

The model changed its `find` behavior to plain lexical text, demonstrating that the documentation affected behavior. It nevertheless reused the free-text search phrase as the argument to `get` rather than transitioning to an observed exact durable key.

Classification:

    VALID_NEGATIVE_RESULT
    COMMAND_TEXT_PROTOCOL_V1=FAIL_FOR_THIS_MODEL_AND_TASK

## What this case does not prove

This case does not prove that:

- the Yoda storage engine failed;
- the command vocabulary is insufficient;
- SQL is required;
- a new command is required;
- the model cannot operate Yoda through a structured tool interface.

## Earned next hypothesis

Hold constant:

- CORE-015;
- task;
- durable state;
- model and model digest;
- scorer;
- command vocabulary.

Change only command transport:

    textual CALL|verb|arg protocol
                    ↓
    typed/native tool calls

This is the scope of COMMAND-NATIVE-002.
