# Yoda Decision Receipt v1

**Status:** product contract frozen; product-layer implementation validated.

> **Agents make decisions. Yoda gives those decisions receipts.**

Decision Receipt v1 is Yoda's portable evidence envelope for agent decisions. It packages the preserved state, context, rule, evaluator, decision result and integrity evidence needed for independent verification.

## Public interface

The frozen public interface is:

```bash
yoda decision get <decision_id> --output <bundle-dir>
yoda decision verify <bundle-dir>
```

The validated product-layer implementation passed ALLOW and REFUSE receipt generation, independent verification, stable exit-code behavior, resealed tamper rejection and passthrough to the unchanged CORE-014.

The current repository binary on `main` should not be assumed to include these commands until the product layer is integrated and published. This directory documents the frozen v1 contract and the validated implementation milestone.

## Validated scope

The initial backend is deliberately narrow:

```text
INITIAL_BACKEND=VALIDATED_CASE_REGISTRY
REGISTERED_DECISIONS=4
HORIZONTAL_BACKEND_DISCOVERY=NOT_IMPLEMENTED
```

Decision Receipt v1 therefore proves the interface and trust boundary for the validated backend. It does not yet claim automatic receipt generation for arbitrary decisions in arbitrary Yoda stores.

## Evidence basis

The source CASE is:

```text
YODA-AGENT-DECISION-RECEIPT-001=VALIDATED

PORTABLE_DECISION_EVIDENCE=PASS
THIRD_PARTY_VERIFICATION=PASS
RESEALED_TAMPER_DETECTION=PASS

YODA_CHANGE=NO
KYBER_CHANGE=NO
```

The validated product implementation reported:

```text
YODA_DECISION_RECEIPT_V1_PRODUCT_IMPLEMENTATION_002=PASS
IMPLEMENTATION_STATUS=IMPLEMENTED
PUBLIC_INTERFACE=yoda decision

DECISION_GET_ALLOW_TEXT=PASS
DECISION_GET_REFUSE_JSON=PASS
DECISION_VERIFY_ALLOW=PASS
DECISION_VERIFY_REFUSE=PASS

PUBLIC_TAMPER_REJECTION=PASS
CORE_014_PASSTHROUGH=PASS
YODA_CORE_IDENTITY_UNCHANGED=PASS
YODA_DATA_IDENTITY_UNCHANGED=PASS
```

## Read next

- [CONTRACT.md](CONTRACT.md)
- [CLI.md](CLI.md)
- [TRUST-MODEL.md](TRUST-MODEL.md)
- [ERROR-CODES.md](ERROR-CODES.md)
- [EXAMPLES.md](EXAMPLES.md)
