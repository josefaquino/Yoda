# COMMAND-NATIVE-001 — R2-Kyber Replication and Experimental Corrections

## Purpose

This document records a faithful local replication of the Command-Native experiment concept proposed by R2-Kyber, followed by the methodological corrections earned from the run.

The objective is preserved:

> Compare an agent that receives the relevant state directly in its prompt with an agent that starts without that state and retrieves evidence selectively through a small Yoda-style command vocabulary.

This replication was used as an experimental calibration step. It is not treated as a product benchmark or as evidence against the original idea.

## Replication environment

The local replication used:

    Ollama 0.32.6
    qwen2.5:14b
    model digest 7cdf5a0187d5

Replica identities:

    yoda-r2-replica
    SHA256=b9bc7cd74b3e412cef09149b9a0afcfb764ffe0a4ba305796961cbaa223b1a6c

    command-native-001-real-v2-r2-replica.sh
    SHA256=eb6632e0070df39e21e0a737d9c923bedde99e2de8a9072dd91f74200929744c

The replica intentionally used a JSON-backed workshop CLI so the original experimental behavior could be reproduced without modifying the frozen Yoda core.

## Measured run

### Arm A — full context

    prompt tokens = 966
    eval tokens   = 357
    total tokens  = 1323

### Arm B — command-native loop

The model executed:

    Step 1
    COMMAND: yoda context MOD-AUTH-088

    Step 2
    COMMAND: yoda find vulnerability

    Step 3
    FINAL_DECISION

Measured totals:

    prompt tokens = 1699
    eval tokens   = 113
    total tokens  = 1812

For this run:

    ARM_A_TOTAL_TOKENS=1323
    ARM_B_TOTAL_TOKENS=1812
    COMMAND_NATIVE_TOKEN_ADVANTAGE=NO

This is a valid measured result. The next experiment must remain neutral: either arm may be more efficient.

## Important observation from the final decision

The durable state defined two different content hashes:

    PKG-DEP-001
    status=DEPRECATED_VULNERABLE
    hash=a1b2c3d4e5f60708

    PKG-DEP-002
    status=APPROVED_SECURE
    hash=9988776655443322

The model correctly identified:

    active dependency = PKG-DEP-001
    vulnerability     = CVE-2026-8891
    migration target  = PKG-DEP-002

However, its final response associated the migration target with:

    a1b2c3d4e5f60708

That is the hash belonging to PKG-DEP-001, not PKG-DEP-002.

Therefore a scorer that checks only for the presence of expected strings can report PASS even when the final evidence relationship is semantically incorrect.

## Verification observation

The observed autonomous trajectory contained only:

    context
    find

No `verify` command was executed before the final decision.

Therefore the word `verified` in the final response is not sufficient evidence that cryptographic verification occurred.

The corrected experiment must score the execution trace, not only words in the final answer.

## Few-shot calibration observation

The replicated prompt included an example using the same target case and the same expected command trajectory:

    context MOD-AUTH-088
    find vulnerability
    verify <known hash>
    final decision

This is useful for demonstrating command syntax, but it prevents the run from measuring independent command discovery.

The corrected experiment will therefore teach only command semantics and syntax. It will not include examples containing the test subject, expected evidence, expected command order, CVE, target package, or target hash.

## Corrections earned for the next run

The original research objective remains unchanged. The next harness will make the following methodological corrections.

### 1. Real Yoda authority

Use the frozen real CORE-015 binary and gate its SHA-256 before execution.

    EXPECTED_CORE015_SHA256=
    1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb

No JSON-backed mock will be used in the official experiment.

### 2. Same model and controlled inference

Both arms must use the same:

    model
    model digest
    seed
    temperature
    output contract

Each arm starts from a fresh conversation context.

### 3. No target-answer leakage

The command arm may receive documentation of the available commands, but no example may contain:

    test subject
    expected CVE
    expected migration target
    expected hash
    expected command sequence

### 4. Autonomous command selection

The model must decide independently:

    which command to call
    which argument to use
    what evidence is still missing
    when enough evidence has been gathered
    when to return the final decision

### 5. Evidence provenance

The harness must record every durable key and authority identity actually observed through tool output.

A final evidence claim passes only if the claimed item was observed through the experiment trace.

### 6. Exact semantic scoring

The scorer must validate relationships, not isolated strings.

For the dependency-audit scenario this includes, at minimum:

    ACTIVE_DEPENDENCY=PKG-DEP-001
    VULNERABILITY=CVE-2026-8891
    MIGRATION_TARGET=PKG-DEP-002
    TARGET_HASH=9988776655443322

A correct CVE plus an incorrect target/hash relationship must fail.

### 7. Verification gate

If the final answer claims verified evidence, at least one real Yoda `verify` operation must appear in the trace and must verify the relevant decision-critical object or authority.

    VERIFY_CALLS >= 1

The scorer must not infer verification merely from the word `verified`.

### 8. Invented-evidence detection

The harness must detect whether the model cites a durable key, hash, authority ID, or evidence object that was neither provided in the task nor observed through Yoda.

    INVENTED_EVIDENCE=NO

is required for PASS.

### 9. Authority gate

The run must preserve and compare the Yoda authority identity associated with the decision state.

    AUTHORITY_MATCH=YES

is required for a fully grounded PASS.

### 10. Honest token accounting

Ollama counters remain authoritative:

    prompt_eval_count
    eval_count
    total_duration

The experiment will report separately:

    ARM_A_PROMPT_TOKENS
    ARM_A_EVAL_TOKENS
    ARM_A_TOTAL_TOKENS

    ARM_B_TOTAL_PROMPT_TOKENS
    ARM_B_MAX_PROMPT_TOKENS
    ARM_B_TOTAL_EVAL_TOKENS
    ARM_B_TOTAL_TOKENS

    ARM_B_TOOL_CALLS
    ARM_B_YODA_BYTES_RETURNED

No token-efficiency claim is made unless both arms successfully complete the same task.

## Corrected research question

The calibrated experiment will test:

> Can the same model solve the same decision task by selectively retrieving durable evidence through real Yoda commands instead of receiving the complete durable state in its prompt?

The experiment does not assume that the command-native arm will win.

Possible outcomes include:

    lower total token use
    lower maximum working-context pressure
    higher total token use but better evidence isolation
    equivalent performance
    command-discoverability failure
    command-vocabulary gap
    model/tool-use failure

All are valid evidence.

## Next experiment

The next official run is:

    COMMAND-NATIVE-001-R1
    REAL SELECTIVE DURABLE-STATE RETRIEVAL

Frozen design:

    ARM A
    same task + full durable-state dump

    ARM B
    same task + no state dump
    autonomous access to real Yoda commands only

    BOTH
    same real CORE-015
    same qwen2.5:14b authority
    same scorer contract
    fresh context
    measured Ollama counters
    complete raw trace

## Conclusion

The replication strengthened the original Command-Native idea by showing exactly what the official experiment must measure.

The central hypothesis is retained.

    EXPERIMENT_IDEA=RETAIN
    REPLICATION_EXECUTION=PASS
    PRODUCT_CLAIM_FROM_REPLICA=NO
    COMMAND-NATIVE-001-R1_DESIGN_EARNED=YES

The next step is not to optimize for PASS. It is to run the corrected experiment and accept whichever result the evidence produces.
