# FIELD-001 — Multi-Agent Decision State

## Question

Can independent processes recover consistent decision-relevant
evidence from shared durable state without sharing their transient
context?

## Scenario

Widget 2.4 passed production validation.

A later critical security advisory blocks Widget 2.4 from production.

Widget 2.5 passes production validation and addresses that advisory.

A production security policy requires validated software that is not
blocked by an active critical security advisory.

Two independent processes query the same durable Yoda state.

They do not exchange conversational context.

## Arms

### Agent A

Security investigator.

Retrieves the state around Widget 2.4 and the security advisory.

### Agent B

Deployment lead.

Retrieves the state around Widget 2.5 and production deployment.

## Boundary

FIELD-001 does not claim Yoda is an agent or reasoning engine.

The two reference agents are deterministic independent processes.

FIELD-001-R1 will replace them with real isolated model agents.

## Success

Both independent processes must recover the shared governing policy.

Agent A must recover the blocking advisory for Widget 2.4.

Agent B must recover current Widget 2.5 validation and advisory
resolution.

The authoritative Yoda state must verify successfully.
