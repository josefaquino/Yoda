# A2 — Yoda Evaluation Lineage

## Status

```text
CASE=PUBLIC-DISCLOSURE-EVALUATION-LINEAGE-001
STAGE=A2
STATUS=PRE_REGISTERED
EXECUTED=NO
```

## Research gate

A2 asks:

> Can Yoda persist and byte-exactly recover the frozen public-disclosure evidence, structured facts, deterministic comparative evaluation, authority evidence and their lineage relations without changing Yoda or Kyber?

A2 does not fetch SEC data and does not rerun either evaluator.

```text
SEC_FETCHES=ZERO
CLASSIFICATION_EXECUTED=NO
```

## Important semantic boundary

The frozen A1 contract produces one comparative evaluation across State A and State B.

A2 therefore does not invent separate Evaluation A and Evaluation B objects.

The tested lineage is:

```text
Original Filing A
      |
      v
Fact A
      \
       \
        Evaluation A-to-B = UNCHANGED
       /
      /
Fact B
      ^
      |
Amendment Filing B

Filing B --supersedes--> Filing A
```

The semantic state to recover is:

```text
FILING_IDENTITY_CHANGED=YES
PUBLIC_DISCLOSURE_STATE_ADVANCED=YES
SELECTED_FACT_VALUE_CHANGED=NO
DETERMINISTIC_EVALUATION=UNCHANGED
```

## Frozen A0 authority

```text
A0_AUTHORITY=PASS_BY_FROZEN_SELECTION_COMPLETION

A0_C1_EXECUTION_LOCK_SHA256=
7bc7ed24b7e4468c618f72e8c61c02f5689df865deea32d8cc3c36eee993bde2

A0_C1_EVIDENCE_MANIFEST_SHA256=
40499e4c4545974f3ed106d72cc5da356bdbadc8a4478f0a152e6d4f454c84cb

CANONICAL_FACTS_SHA256=
0c2536899ddc8a568336fc5bedaa6de10e952635ede9fac2788d94c5fab0220d
```

## Frozen A1 authority

```text
A1_R1=PASS

A1_R1_EXECUTION_LOCK_SHA256=
85e493177e75aad351a45fcf9c5fb4aa2bf731dae483350aa10dc7a61cb31c0e

A1_R1_EVIDENCE_MANIFEST_SHA256=
6b5f0093426dac4b8a4603fbaf12f1859e0fb60e2eb09386a63ba8a49d425cc7

CANONICAL_EVALUATION_SHA256=
906cb399db9bd91730506ec6f89242f5f88c921e543f09a5ffdc54e05a956bcb

CLASSIFICATION=UNCHANGED
```

## Frozen semantic objects

```text
filing-state-A.tsv
SHA256=89223aafaf87a2bfbb82cf4d747100c7bfb27db05b1375729fb1b07f1b1936a3

filing-state-B.tsv
SHA256=de199efb1b4b60e165ea65eed194b60672062f7238b1591641749da8a2ac0e4d

fact-state-A.tsv
SHA256=56a76b46d98e31dfa239688822d982643ca04f6afdaf6043f84f832d732296a8

fact-state-B.tsv
SHA256=cba3183da39bdde93bdc72636078d2f20096007efe487d6ee8834c719ced4851

evaluation-A-to-B.tsv
SHA256=96a346233886ab6c669e1902798022b612fd0fbd987fba650c88b8e3deaa6241

transition-A-to-B.tsv
SHA256=384c15ee2e7ec606f375b285a376c7dec68829fa9e254709409a129f1e9a9190

OBJECT_COMMIT=
0dbe9151c078e466f00d4d01b60c7448de46195f
```

## Yoda authority

```text
YODA=/home/jose/YodaCore-015-FROZEN/product/yoda

EXPECTED_YODA_SHA256=
1a38316b4f370225ae52431074365eb921976e79db2f4688fb8154ce9218d9eb

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## A2 object set

A2 stores 25 objects:

```text
2 filing-state descriptors
2 raw SEC filing submissions
1 raw SEC Company Facts object
2 structured fact-state descriptors
1 canonical facts object
1 frozen selection record
1 frozen candidate-scan record
1 disclosure transition descriptor
1 deterministic evaluation descriptor
1 evaluation contract
2 independent evaluator sources
2 independent evaluator results
1 canonical evaluation result
1 A0 selection policy
2 A0 parser sources
1 A0 evidence summary
1 A0 evidence manifest
1 A1 evidence summary
1 A1 evidence manifest
```

## Core relation contract

Required lineage includes:

```text
filing-B --supersedes--> filing-A

filing-A --has-evidence--> raw-filing-A
filing-B --has-evidence--> raw-filing-B

fact-A --reported-in--> filing-A
fact-B --reported-in--> filing-B

fact-A --extracted-from--> companyfacts
fact-B --extracted-from--> companyfacts

companyfacts --parsed-by--> companyfacts-parser

selection --selected-by--> selection-policy
selection --has-evidence--> candidate-scan
selection --resolved-to--> filing-A
selection --resolved-to--> filing-B
selection --resolved-to--> fact-A
selection --resolved-to--> fact-B
selection --parsed-by--> submissions-parser
selection --parsed-by--> companyfacts-parser

canonical-facts --composed-from--> fact-A
canonical-facts --composed-from--> fact-B

transition --from-state--> fact-A
transition --to-state--> fact-B
transition --has-evaluation--> evaluation-A-to-B

evaluation-A-to-B --compares--> fact-A
evaluation-A-to-B --compares--> fact-B
evaluation-A-to-B --evaluated-by--> evaluation-contract
evaluation-A-to-B --supported-by--> canonical-evaluation

canonical-evaluation --supported-by--> c11-result
canonical-evaluation --supported-by--> awk-result

c11-result --evaluated-by--> c11-source
awk-result --evaluated-by--> awk-source

A0-summary --has-evidence--> A0-manifest
A1-summary --has-evidence--> A1-manifest

filing-A --has-evidence--> A0-summary
filing-B --has-evidence--> A0-summary
canonical-facts --has-evidence--> A0-summary
evaluation-A-to-B --has-evidence--> A1-summary
```

## Recovery requirements

PASS requires:

```text
YODA_VERIFY=PASS
BYTE_EXACT_RECOVERY=PASS

FILING_SUPERSEDES_RELATION_RECOVERY=PASS
FACT_PROVENANCE_RELATION_RECOVERY=PASS
SELECTION_PROVENANCE_RELATION_RECOVERY=PASS
EVALUATION_RELATION_RECOVERY=PASS
AUTHORITY_RELATION_RECOVERY=PASS
EVALUATION_LINEAGE_RELATION_RECOVERY=PASS

FILING_IDENTITY_CHANGED_RECOVERY=PASS
SELECTED_FACT_VALUE_STABLE_RECOVERY=PASS
EVALUATION_UNCHANGED_RECOVERY=PASS
EVALUATION_LINEAGE_SEMANTICS=PASS

FINAL_YODA_VERIFY=PASS
A2_EVIDENCE_INTEGRITY=PASS

SEC_FETCHES=ZERO
CLASSIFICATION_EXECUTED=NO
YODA_CHANGE=NO
KYBER_CHANGE=NO
```

## Next gate

Only A2 PASS authorizes:

```text
B_INDEPENDENT_EVALUATION_REPLAY_FROM_YODA_GET_ONLY
```
