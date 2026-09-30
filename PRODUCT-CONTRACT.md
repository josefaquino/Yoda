# Yoda v0.1 — Product Contract

**Status:** PRODUCT CONTRACT FROZEN  
**Engine Authority:** Yoda Simple Core — CORE-014  
**Architecture:** ISO C11 + POSIX.1-2008  
**Product Principle:** Small core. Strong evidence. Better autonomous decisions.

---

## 1. Purpose

Yoda is a **verifiable decision-state layer for autonomous software**.

Its purpose is to keep important decision evidence outside the model, outside transient prompts, and outside agent process memory so autonomous software can recover:

- what was known;
- where it came from;
- what changed;
- what became obsolete;
- what conflicts;
- and which evidence justified a decision.

Yoda does not attempt to make the decision for every agent.

Yoda provides the durable evidence state from which a decision can be made and audited.

---

## 2. Core Thesis

LLM context is temporary.

Autonomous software state often cannot be.

Therefore:

**decision evidence should be durable, independently verifiable, temporally aware, provenance-aware, and recoverable across executions.**

---

## 3. Product Model

Yoda exposes four fundamental concepts:

### Evidence

A durable knowledge object with:

- key;
- value;
- source;
- identity;
- history.

### Relation

A directed relationship between evidence objects.

Examples:

- `supersedes`
- `conflicts-with`
- `has-provenance`
- `governed-by`
- `tracked-by`
- `about`

### History

New state does not require destruction of old state.

Historical evidence remains available even when it is no longer operationally current.

### Context

A bounded evidence bundle retrieved for a current task.

Context is evidence supplied to an agent, not the agent itself.

---

## 4. Authority Model

The authoritative state is:

~~~text
data.yoda
~~~

All other structures are derived:

~~~text
HEAD
lookup.yoda
index.yoda
terms.yoda
edges.yoda
~~~

Derived state may be deleted and reconstructed.

Derived state must never become the source of truth.

---

## 5. Storage Properties

Yoda v0.1 uses:

- append-only authoritative storage;
- per-record commit trailers;
- SHA-256 content identities;
- crash-tail recovery;
- explicit verification;
- rebuildable derived indexes;
- direct key lookup;
- lexical retrieval;
- direct relational expansion.

A complete committed record is authoritative.

An incomplete append tail may be discarded.

Complete corrupt committed state fails closed.

---

## 6. CLI Contract

Yoda v0.1 exposes a deliberately small command surface:

~~~text
init
put
get
find
link
log
verify
context
~~~

### `init`

Create a Yoda evidence store.

### `put`

Store or update evidence.

### `get`

Retrieve the latest value for an exact evidence key.

### `find`

Retrieve evidence using lexical search.

### `link`

Create an explicit relationship between evidence objects.

### `log`

Inspect historical records.

### `verify`

Explicitly verify authoritative storage integrity.

### `context`

Produce a bounded evidence bundle suitable for autonomous software.

No additional command is added to v0.1 without evidence of a real developer need.

---

## 7. Validated Behavioral Properties

### MEMORY — AI-001

Yoda can recover evidence from a previous execution when that evidence is absent from the current task context.

Validated with a deterministic reference agent and Qwen.

### TIME — AI-002

Yoda can preserve historical evidence while exposing newer evidence that explicitly supersedes it.

Validated with a deterministic reference agent and Qwen.

### TRUST — AI-003

Yoda can preserve contradictory evidence together with provenance, conflict and authority relationships so a decision process can distinguish authoritative evidence from advisory evidence.

Validated with the deterministic reference agent.

Real-agent AI-003-R1 remains pending.

---

## 8. Context Semantics

Yoda CORE-014 currently provides:

~~~text
lexical retrieval
        +
direct 1-hop relational expansion
~~~

Yoda v0.1 does **not** claim arbitrary multi-hop graph planning.

If multiple evidence neighborhoods are required, an external harness may compose them into a bounded evidence bundle.

This boundary is explicit.

---

## 9. Decision Evidence Contract

Yoda should integrate with autonomous software through a minimal decision-state envelope.

Conceptually:

~~~text
decision:
    ALLOW | DENY | UNKNOWN

evidence:
    evidence-id
    evidence-id
    ...

reason:
    human-readable explanation

state:
    VERIFIED | UNVERIFIED | CONFLICTED

state_id:
    cryptographic identity
~~~

For v0.1 this contract may be produced by an external adapter.

It does not require modification of CORE-014.

---

## 10. Integration Boundary

Yoda governs **decision evidence**.

It does not need to govern execution.

A typical integration is:

~~~text
observations / artifacts
          |
          v
        Yoda
          |
    decision evidence
          |
          v
ALLOW / DENY / UNKNOWN
     + evidence IDs
          |
          v
execution control plane
          |
          v
        agent
~~~

For a system such as Guild:

~~~text
Yoda
    -> evidence admission

Guild
    -> identity
    -> credentials
    -> authorization
    -> sandbox
    -> tools
    -> model access
    -> session audit
    -> execution
~~~

The systems are complementary.

---

## 11. Non-Goals for v0.1

Yoda v0.1 is not:

- an agent framework;
- an LLM runtime;
- a sandbox;
- a credential broker;
- an IAM system;
- a model gateway;
- a vector database;
- a distributed database;
- a graph database product;
- a cloud service;
- an orchestration platform;
- a replacement for Guild, LangChain, OpenAI, or other agent runtimes.

Yoda should not absorb those responsibilities without compelling external evidence.

---

## 12. Developer Experience

The target first experience is:

~~~bash
yoda init ./memory

echo "PostgreSQL 16 approved" |
yoda -d ./memory put evidence/db-validation \
     source=production-validation

yoda -d ./memory find postgres

yoda -d ./memory context \
     "production database"

yoda -d ./memory verify
~~~

Target:

**installation to first useful context in less than five minutes.**

No server must be required.

No account must be required.

No network connection must be required.

---

## 13. Product Principles

### Local first

Yoda must remain useful offline.

### Evidence first

Important outputs should be attributable to explicit evidence IDs.

### History is preserved

Current state must not require destroying historical truth.

### Derived state is disposable

Indexes accelerate truth; they do not define truth.

### Explicit verification

Expensive integrity verification happens when requested, not implicitly on every operation.

### Composition over expansion

Prefer small Unix-compatible interfaces to large internal frameworks.

### Evidence before features

No major capability is added because it is fashionable or theoretically useful.

Real usage must justify expansion.

---

## 14. Frozen Engine Baseline

The Yoda v0.1 product starts from the frozen CORE-014 baseline.

~~~text
SOURCE_SHA256
1d1ea6f7866307675d7b4cb37f42c5d82e52176a65debd8df3c8ea5c02be713b

BINARY_SHA256
06c1d2cb98099cb2d5b44f753fa3392da4f9a2bd42d39bd0a673270b01f9bfc8
~~~

Validated graph workload:

~~~text
10,000 logical objects
10,000 relations
20,003 physical records

forward relation lookup       PASS
reverse relation lookup       PASS
derived-edge rebuild          PASS
GET regression                PASS
FIND regression               PASS
full verify                   PASS
data.yoda authority           PASS
~~~

---

## 15. v0.1 Exit Criteria

Yoda v0.1 is considered a developer product candidate when:

~~~text
[ ] clean installation path exists
[ ] one binary can be distributed
[ ] README enables first context in <5 minutes
[ ] Product Contract is frozen
[ ] Decision Evidence Contract is executable
[ ] one real external integration is demonstrated
[ ] 3–5 external developers use Yoda
[ ] usage feedback is captured
[ ] next features are selected from evidence, not speculation
~~~

---

## 16. Metrics for the Next Phase

Storage performance remains observable, but product success is measured by:

~~~text
time_to_first_useful_context

relevant_evidence_retrieved

irrelevant_evidence_included

stale_evidence_detected

conflicts_exposed

decisions_with_evidence_ids

unsupported_actions_blocked

model_calls_avoided_on_deny
~~~

The primary question is no longer:

**“Is Yoda a fast database?”**

It is:

**“Does Yoda help autonomous software make decisions from better, verifiable evidence?”**

---

## 17. Expansion Rule

The following capabilities are intentionally deferred:

~~~text
embeddings
vector search
remote synchronization
cloud service
replication
distributed state
REST server
MCP server
SDK proliferation
multi-hop planner
signatures
RBAC
web dashboard
~~~

Any one of these may become important.

None belongs in the product solely because it is technically possible.

The next capability must be earned by developer usage.

---

## 18. Product Definition

**Yoda is a local, verifiable decision-state layer for autonomous software.**

It gives agents persistent, temporal and provenance-aware evidence while keeping history inspectable and the authoritative state independent of the model.

Its job is not to replace reasoning.

Its job is to give reasoning something trustworthy to stand on.

---

## YODA v0.1 PRODUCT PRINCIPLE

> Small core.  
> Durable evidence.  
> Explicit history.  
> Verifiable state.  
> Better autonomous decisions.
