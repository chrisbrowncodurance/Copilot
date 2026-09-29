---
name: resharper-test-session
description: Identify tests covering one or more methods or selected code and generate an importable ReSharper .testsession file. Use when the user asks for a ReSharper test session for a method, code selection, list of methods, current method, or affected code.
---

# ReSharper Test Session

Identify tests that exercise specified production code and generate a ReSharper `.testsession` file for manual import into
Visual Studio.

## Inputs

Accept any of:

- a method name, preferably qualified with its type
- a list of methods
- a requirement-to-change-impact map containing methods, types, or precise code ranges
- a pasted or selected section of code
- a file path and line range
- the method containing the current IDE caret

Resolve the target in this order:

1. Explicit file, type, method, or line-range arguments.
2. An orchestrator-provided change-impact map with evidence and confidence.
3. Code supplied in the prompt.
4. Current IDE selection or caret context when the IDE supplies it.
5. Ask for the file path and method name when none of the above identifies one unambiguously.

Never guess what "current method" means when editor context is unavailable.

When invoked with a change-impact map:

- accept high-confidence targets
- accept medium-confidence targets only when marked as user-approved
- reject low-confidence targets
- deduplicate targets before test discovery
- retain requirement IDs so output can group tests and uncovered targets by requirement

## Test discovery

Build an evidence map before generating the session.

1. Resolve every target to its file, namespace, containing type, method signature, and production project.
2. Find direct tests:
   - test methods that invoke the target
   - tests that invoke the target through a fake, fixture, subject-under-test, controller, consumer, handler, or service
   - parameterised test methods whose cases exercise the target
3. Find behavioural tests:
   - tests of public entry points that call the target
   - Reqnroll scenarios whose step definitions reach the target
   - integration or component tests whose setup and assertions demonstrate the target behaviour
4. Resolve direct dependencies invoked by each target:
   - extension methods
   - methods on injected services or repositories
   - methods called through interfaces, including the concrete implementation when it can be resolved unambiguously
   - static collaborators
   - private or local helper methods
   - constructors and factories whose behaviour is part of the selected code path
5. For each direct dependency, find its direct, transitive, and coverage-report tests using the same evidence rules.
   Include those tests in the session, but label them `dependency coverage`; they demonstrate the dependency's behaviour and
   do not by themselves prove coverage of the originally selected method.
6. Stop dependency expansion after one call edge. Do not recursively include dependencies called by those dependencies.
7. When a service or interface call has multiple possible runtime implementations, include tests for an implementation only
   when dependency registration, construction, or the selected code makes that implementation unambiguous. Otherwise report
   the implementations as ambiguous and exclude their tests unless the user approves them.
8. Use symbol references or call hierarchy when available. Otherwise use focused code search across test projects and trace
   the call path from the test to the target.
9. Do not include a test based only on similar naming.
10. Classify evidence:
   - `direct`: the test or its subject directly invokes the target
   - `transitive`: a verified call path connects the test to the target
   - `coverage-report`: a current coverage artefact explicitly maps the test to the target
   - `dependency coverage`: the test covers a direct dependency invoked by the target
11. Include `direct`, `transitive`, `coverage-report`, and `dependency coverage` tests. Report ambiguous candidates separately and exclude them from
   the session unless the user approves them.
12. Deduplicate parameterised cases at the test-method ancestor when selecting the method includes all of its cases.

## Test identity

For each selected test, determine:

- test framework identifier used by ReSharper, such as `NUnit3x` or the identifier found in an existing exported session
- test project GUID from the loaded `.sln` or `.slnf`
- target framework in JetBrains form
- fully qualified test method or test ancestor name

Construct each test ID as:

`<framework>::<project-guid-without-braces>::<jetbrains-target-framework>::<fully-qualified-test-name>`

Common target framework conversions:

| Project target | JetBrains target framework |
|---|---|
| `net48` | `.NETFramework,Version=v4.8` |
| `net8.0` | `.NETCoreApp,Version=v8.0` |
| `net9.0` | `.NETCoreApp,Version=v9.0` |

For any other target, derive the value from a known `.testsession` entry or fail with a clear explanation. Do not silently
invent framework identifiers, project GUIDs, target framework values, or fully qualified names.

Prefer an existing `.testsession` from the same solution as authoritative evidence for identifier formatting. ReSharper
result exports such as `<model><node ...>` XML files are not importable session definitions and must not be used as the
output template.

## Generate the session

1. Choose an output beneath `.copilot/test-sessions/` in the repository unless the user requests another location.
2. Use a descriptive filename ending in `.testsession`, for example
   `.copilot/test-sessions/ShipmentService-CreateShipment.testsession`.
3. Run the bundled writer:

```powershell
& "<skill-directory>\Write-ReSharperTestSession.ps1" `
  -SessionName "<descriptive session name>" `
  -OutputPath "<absolute output path>" `
  -TestId @(
    "<first complete ReSharper test ID>",
    "<second complete ReSharper test ID>"
  )
```

4. Parse the generated file as XML and verify:
   - root element is `SessionState`
   - namespace is `urn:schemas-jetbrains-com:jetbrains-ut-session`
   - one `TestId` exists for every deduplicated selected test
   - there is no `<Not>` element
5. Never modify an existing `.testsession` unless the user explicitly requests it or the pair-programmer explicitly marks
   an existing branch-derived session as stale after material requirement changes.

## Output

Report:

- generated `.testsession` path
- selected test count
- selected tests grouped by target method
- direct dependencies found for each target, including the resolved implementation for service/interface calls
- dependency-coverage tests grouped beneath the dependency they cover
- evidence classification for each test
- excluded ambiguous candidates
- unresolved or ambiguous service implementations
- any target that has no identified tests

Always include these import instructions:

1. Open the solution in Visual Studio with ReSharper enabled.
2. Open **ReSharper | Windows | Unit Test Sessions**, or press **Ctrl+Alt+R**.
3. In the **Unit Test Sessions** window, click **Import Session** on the toolbar.
4. Select the generated `.testsession` file.
5. Allow ReSharper to finish test discovery, then run the imported session.

If **Import Session** is not visible in Unit Test Sessions, open **ReSharper | Windows | Unit Test Explorer** and use
**Import Session** there.

## Safety and accuracy

- Do not claim that static analysis proves runtime coverage.
- Do not present dependency-coverage tests as proof that the originally selected method executes that dependency.
- Prefer a current per-test coverage artefact when one exists.
- State when the result is an evidence-based impact set rather than measured coverage.
- Do not run the selected tests unless the user also asks.
- Do not add generated sessions to Git unless the user explicitly asks.
