# COMMAND-NATIVE-001 — Results

## Summary

COMMAND-NATIVE-001 produced a valid negative result for the tested free-form textual command protocol.

The storage engine, decision task, and model controls were healthy:

    CORE015_BINARY_AUTHORITY=PASS
    MODEL_AUTHORITY=PASS
    CASE_DATABASE_VERIFY=PASS
    CONTROL_STATUS=PASS
    DUMP_STATUS=PASS

The COMMAND arm did not complete the decision under the text protocol.

## Attempt 001

Observed:

    TURN=1 CALL|find|policy:production:*widget*
    TURN=2 AGENT|CALL|get|policy:production:widget-minimum-version

The transcript serializer had inserted the `AGENT|` prefix, and the model later reproduced it.

Result:

    INVALID_HARNESS_PROTOCOL

## Attempt 002

Observed raw second response:

    CALL|get|dependency/widget-2.4
    CALLTYPE|get|dependency/widget-2.4
    END_CALLTYPE

The first line was a valid command, but the parser rejected the response because it contained multiple non-empty lines.

Result:

    INVALID_HARNESS_PROTOCOL

## Attempt 003

The response normalizer was changed to accept exactly one valid protocol line.

Observed:

    TURN=1 CALL|find|policy:production:*widget*
    TURN=2 CALL|get|policy:production:widget-minimum-version

The lexical `find` query returned no evidence. The model then constructed an exact key it had not observed.

Result:

    VALID_INTERFACE_RESULT
    FIND_STRUCTURED_QUERY_ASSUMPTION=OBSERVED
    EXACT_KEY_DISCIPLINE=FAIL

Attempt-003 script SHA-256:

    c917af3e5243c16f96cd76ebd19e9e3c205b674fda1e18aa494031a0013c9705

## Attempt 004

One change only: document command semantics more explicitly.

`find` was defined as lexical plain-text retrieval with no field predicates, colon syntax, Boolean query language, SQL, or filters. Exact-key operations were documented as requiring keys supplied by the task or previously observed through tools.

Attempt-004 script SHA-256:

    c8171c89690c62ebda293dff9bc8c2e85654287e9acfb4e5ca518821603618dc

Observed:

    TURN=1 CALL|find|Widget release dependency/widget-2.4 policy status
    TURN=2 CALL|get|Widget release dependency/widget-2.4 policy status

The documentation changed the model's `find` behavior from structured pseudo-query syntax to plain lexical text. However, the model then reused that free-text search phrase as an exact-key argument to `get` rather than transitioning to a durable key discovered from tool output.

Final Attempt-004 controls:

    CORE015_BINARY_AUTHORITY=PASS
    MODEL_AUTHORITY=PASS
    CASE_DATABASE_VERIFY=PASS
    CONTROL_STATUS=PASS
    DUMP_STATUS=PASS

Measured token counters from the incomplete COMMAND trajectory:

    CONTROL_PROMPT_TOKENS=187
    DUMP_PROMPT_TOKENS=1448
    COMMAND_TOTAL_PROMPT_TOKENS=1085
    COMMAND_MAX_PROMPT_TOKENS=563
    COMMAND_OUTPUT_TOKENS=30

These token counts are not used to claim an efficiency advantage because the COMMAND arm did not successfully complete the task.

## Final classification

    COMMAND-NATIVE-001=COMPLETE
    COMMAND_TEXT_PROTOCOL_V1=FAIL_FOR_THIS_MODEL_AND_TASK
    COMMAND_VOCABULARY_SUFFICIENCY=UNRESOLVED
    STORAGE_FAILURE=NO
    CORE015=RETAIN
    CORE016_CHANGE_EARNED=NO
    NEW_STORAGE_CHANGE_EARNED=NO
    NEW_COMMAND_EARNED=NO

## Architectural lesson

The experiment separates the database command model from the serialization used to invoke it.

A small command vocabulary may still be appropriate, but the evidence from COMMAND-NATIVE-001 does not support requiring an autonomous agent to express those commands through a fragile free-form text protocol.

The next earned experiment is therefore a transport test, not a storage change:

    same Yoda commands
    same task
    same model
    same scorer
    same durable evidence

    text protocol
        vs
    typed/native tool calls

That experiment is COMMAND-NATIVE-002.
