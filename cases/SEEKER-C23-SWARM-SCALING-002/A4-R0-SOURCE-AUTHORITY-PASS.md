# A4-R0 Source Authority — PASS

## Verdict

```text
A4_R0_SOURCE_AUTHORITY=PASS
BYTE_IDENTICAL_REBUILD=YES
PROJECT_SOURCE_MUTATED=NO
CONTROL_AGENT_MUTATED=NO
FRONTIER_MUTATED=NO
SEEKER_EXECUTED=NO
NEXT_GATE=A4_R1_CANDIDATE_BUILD
```

## Frozen control authorities

```text
CONTROL_AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

FRONTIER_SHA256=
c26a3d75693addede036e1feb77b9b435ca887fa3d09a28cd1f7018a1768e8b5

A3_EVIDENCE_MANIFEST_SHA256=
fef59c315bc2bef4f45f47bc15e214667c6b97ae7ed4548bc4cad542233e3c29
```

## Source identities

```text
main.c=
c30255eb14fedc7bbc5efa4443f882a6dcda17f2c3a4acdd26b7dec6193469a5

yoda_agent_driver.c=
573da1ad4b19b398d656acf3f2999406523da724241cbc80d80ff8fe895d38a3

yoda_agent_driver.h=
c6a76672936ebdbb537434da77330d157a9d9436af91e2a7ca002f801bd8f20a

Makefile=
9c3b0744acecd84fc9dd6c632134b7aa2acfb14e256e295b9f20adee3d5eca69
```

## Rebuild authority

```text
TOOLCHAIN=gcc 14.2.0 / GNU Make 4.4.1

CONTROL_AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

REBUILT_AGENT_SHA256=
dd96630ec0c891871d141632d453dc7893f00a81027cd7878ca85059f6eb998a

BYTE_IDENTICAL_REBUILD=YES
```

## Evidence identities

```text
SOURCE_BUNDLE_SHA256=
20f6cd930dd78ab7de50965cb8f339544c4fb6afa3399839b32a144848664c3d

A4_R0_EVIDENCE_MANIFEST_SHA256=
5a832d57b39ed3f94a680261914e6de6adde4ce25cc61801160729a544081cd3

A4_R0_HARNESS_SHA256=
b4cb68fa5c7fc723e847ebebbb3c9cbff298c6482317f06fb2d1587b9dd8272e

A4_R0_CONSOLE_SHA256=
1a2492ed215d02cfad6c0c217c0ccded738e1d49ccaaeee43e71ea6a814df2e1
```

## Conclusion

The current local source tree is established as the exact source authority for the frozen control binary.

A4-R1 may derive the batched-reservation candidate from these frozen source files without modifying the control project.
