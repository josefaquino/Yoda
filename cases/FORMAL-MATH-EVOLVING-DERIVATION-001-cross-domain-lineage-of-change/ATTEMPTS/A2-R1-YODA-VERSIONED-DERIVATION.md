# A2-R1 — Yoda Versioned Derivation

## Status

```text
STATUS=PRE-REGISTERED
READY_FOR_EXECUTION=YES
EXECUTED=NO
```

---

## Research Question

> **Can Yoda preserve a versioned derivation between two independently verified formal proof states without changing Yoda or Kyber?**

This is the first gate in this CASE whose primary subject is Yoda itself.

A0 froze authorities.

A1.0 discovered a secondary-authority capability boundary.

A1-R1 established two distinct proof states that both passed Lean and were independently VERIFIED by OxiLean.

A2 asks only whether Yoda can preserve that already-established derivation.

---

## Input authority

```text
A1_R1_EVIDENCE_MANIFEST_SHA256=
fad7416a7528d9d6ec885836668668d20c3cb942bc04b4f509949f92227c8bca
```

All formal inputs come from A1-R1.

No theorem is changed.

No proof is rewritten.

No formal evidence is regenerated.

No formal authority is added.

---

## Inputs

```text
Statement

Proof A

Proof B

Transformation A -> B

Lean Evidence A

Lean Evidence B

OxiLean Evidence A

OxiLean Evidence B

A1-R1 Evidence Authority
```

Logical Yoda object count:

```text
OBJECT_COUNT=9
```

The two Lean evidence objects are backed by the already-frozen A1-R1 summary evidence. The OxiLean evidence objects are backed by the original A1-R1 JSON reports. The A1-R1 authority object is backed by the original A1-R1 SHA256 manifest.

---

## Required derivation relations

```text
Proof B --derived-from--> Proof A
Proof B --transformed-by--> Transformation

Proof A --proves--> Statement
Proof B --proves--> Statement

Proof A --validated-by--> Lean Evidence A
Proof B --validated-by--> Lean Evidence B

Proof A --rechecked-by--> OxiLean Evidence A
Proof B --rechecked-by--> OxiLean Evidence B
```

All state and evaluation objects remain tied to the frozen A1-R1 evidence authority.

---

## Success Criteria

### Recovery

```text
Statement
-> byte-exact recoverable

Proof A
-> byte-exact recoverable

Proof B
-> byte-exact recoverable

Transformation
-> byte-exact recoverable

Lean evidence
-> byte-exact recoverable

OxiLean evidence
-> byte-exact recoverable

A1-R1 evidence authority
-> byte-exact recoverable
```

### Relation recovery

At minimum:

```text
Proof B
derived-from
Proof A
```

must remain recoverable from bounded Yoda context.

### Durable-state integrity

```text
Yoda verify = PASS
data.yoda identity frozen
A2 evidence manifest = PASS
```

---

## Independent Replay Boundary

A2 intentionally does not rerun Lean or OxiLean.

The replay equations:

```text
Lean(A') = Lean(A)
Lean(B') = Lean(B)

OxiLean(A') = OxiLean(A)
OxiLean(B') = OxiLean(B)
```

belong to Stage B.

A2 must preserve all bytes and evidence required for Stage B to perform that replay without reconstructing the original A1-R1 workspace.

---

## Architectural Constraints

```text
NEW_THEOREM=NO
NEW_CORPUS=NO
NEW_WORKLOAD=NO
NEW_FORMAL_AUTHORITY=NO

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

---

## Current official sequence

```text
A0
PASS

A1.0
CAPABILITY_BOUNDARY_DISCOVERED

A1-R1
PASS

A2
READY_FOR_EXECUTION
```

The next question is no longer whether Lean accepts the proof, whether OxiLean can evaluate the declaration, or whether MiniF2F is an adequate workload.

The question is now Yoda's derivation-preservation behavior.
