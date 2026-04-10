# How It Works

This document explains the repository from the point of view of a developer or partner who is new to the codebase.

The goal is not to restate every class.
The goal is to explain how the repository works as a terminology server on InterSystems IRIS for Health and how the different layers fit together.

## Mental Model

This project ingests terminology releases, builds runtime-ready structures, and serves them through native and FHIR APIs.

At a high level:

```text
terminology packages
    -> terminology-specific load/build flows
    -> terminology-specific source/runtime tables
    -> shared service layer
    -> native and FHIR APIs
```

Today the main terminology examples are:

- SNOMED CT
- LOINC

## What Makes The Repo Interesting

The repo is not just about exposing endpoints.
It is intended to show how IRIS for Health can support a terminology server end to end:

- interoperability/production-based ingestion
- persistent storage and SQL access
- iFind-backed search where useful
- native REST APIs
- FHIR terminology APIs
- one integrated platform for multiple terminologies

## 1. Input Releases

The system expects terminology release packages to arrive in shared container folders.

Current examples:

- SNOMED packages under `iris/shared/in/snomed/`
- LOINC packages under `iris/shared/in/loinc/`

The IRIS production layer detects those files and starts the appropriate terminology load flow.

## 2. Terminology-Specific Load

The repository does not pretend that all terminologies have the same ingestion model.

### SNOMED Example

The SNOMED load flow is centered on:

- `Terminology.Production.BS.SnomedRf2FileService`
- `Terminology.Production.BP.SnomedRf2Load`
- `Terminology.Snomed.Utils.LoaderRf2`

Its responsibility is to import RF2 content into SNOMED-specific source tables.

### LOINC Example

The LOINC load flow is centered on:

- `Terminology.Production.BS.LoincFileService`
- `Terminology.Production.BP.LoincLoad`
- `Terminology.Loinc.Utils.Loader`

Its responsibility is to import LOINC package content into LOINC-specific tables.

This difference is intentional.
The server is integrated at the service/API level, not by pretending every terminology starts from the same physical source structure.

## 3. Runtime Structures

Raw loaded content is often not the best shape for runtime terminology queries.
The repository therefore builds optimized runtime structures.

### SNOMED Runtime Example

Relevant parts:

- `Terminology.Snomed.Utils.BuilderPreferredTerm`
- `Terminology.Snomed.Utils.BuilderIsaClosure`
- `Terminology_Snomed.PreferredTerm`
- `Terminology_Snomed.IsaClosure`

Purpose:

- preferred display resolution
- fast hierarchy traversal
- faster subsumption and search-related behavior

### LOINC Runtime Example

Relevant parts:

- `Terminology.Loinc.Utils.BuilderDisplay`
- `Terminology.Loinc.Utils.BuilderHierarchy`
- `Terminology_Loinc.Display`
- `Terminology_Loinc.Closure`
- `Terminology_Loinc.HierarchyEdge`

Purpose:

- runtime display selection
- fast hierarchy navigation
- simpler query behavior at API time

## 4. How One Integrated View Is Created

The integrated view is not created by forcing SNOMED CT and LOINC into one physical schema.

It is created by layering:

- terminology-specific storage and runtime structures at the bottom
- repositories that know how to query those structures
- adapters that translate common operations into terminology-specific behavior
- `Terminology.Core.TermService` at the shared logical layer
- native and FHIR APIs on top

That gives the repo two useful properties:

- each terminology keeps the semantics it really needs
- clients still interact with one terminology server

## 5. Request Handling Paths

There are two main API surfaces.

### Native REST Paths

Examples:

- `/terminology/snomed`
- `/terminology/loinc`

These paths expose terminology-specific operations directly.
They are useful for development, debugging and expressing terminology-specific behaviors that do not naturally collapse into one neutral contract.

### FHIR Terminology Path

The FHIR path is centered on:

- `Terminology.Fhir.Interactions`
- `Terminology.Fhir.Operations.TerminologyOperations`
- operation handlers such as `LookupOperation`, `ValidateCodeOperation`, `SubsumesOperation` and `ExpandOperation`
- `Terminology.Core.TermService`

This path matters because it shows how the same underlying terminology server can be exposed through a standard FHIR interface while still delegating real execution to the correct terminology implementation.

## 6. Request Tracing

The repository includes a simple terminology-owned trace facility for debugging request flow across both native and FHIR APIs.

It is centered on:

- `Terminology.Core.Trace`
- the global `^TSTrace`

This trace is intentionally separate from:

- FHIR server internal logging such as `^FSLOG`
- interoperability production logging through `Ens.Util.Log`

The goal of `^TSTrace` is to give one request-level picture of what happened from API entry to SQL execution.

At a high level, the trace captures:

- request start and end
- native or FHIR request context
- service-layer method calls
- repository SQL execution
- errors raised along the path

Each traced request receives a numeric request id under `^TSTrace("req",reqId,...)`.
Detailed entries are stored in order under:

- `^TSTrace("req",reqId,"entry",seq,...)`

This structure keeps the trace readable in a terminal `ZW ^TSTrace` view while still making it easy to follow request order.

### Native Tracing Path

For the native APIs, tracing starts at the REST/interop boundary and then follows the shared terminology stack:

- `Terminology.Production.API`
- `Terminology.Core.TermService`
- terminology adapter and repository classes
- SQL execution helpers

### FHIR Tracing Path

For the FHIR APIs, request lifecycle tracing is attached to the custom interactions class:

- `Terminology.Fhir.Interactions.OnBeforeRequest`
- `Terminology.Fhir.Interactions.OnAfterRequest`

That means one FHIR trace is created per request, while lower-level FHIR methods add detail entries without starting nested traces.

## 7. Why The Architecture Uses TermService, Adapters And Repositories

### TermService

`Terminology.Core.TermService` is the shared logical contract.

It answers questions like:

- which terminology should handle this operation?
- what is the integrated server view of this request?
- which common operations are stable enough to expose across systems?

### Adapters

Adapters exist because shared operations do not imply identical terminology semantics.

Examples:

- SNOMED and LOINC both support lookup, but not through the same physical model
- value set semantics differ
- hierarchy semantics differ

Adapters let the repo preserve those differences without leaking them everywhere.

### Repositories

Repositories exist because SQL and runtime optimization are still terminology-specific.

This is where IRIS-specific query behavior belongs, including:

- direct SQL access
- ordering and lookup rules
- iFind-backed search behavior where used

## 8. Why There Is Both A Native API And A FHIR API

The native APIs are useful because:

- they expose terminology-specific capabilities directly
- they are practical for internal validation and debugging
- they make terminology-specific behavior visible without FHIR abstraction in the way

The FHIR API is useful because:

- it demonstrates standards-based terminology exposure on IRIS for Health
- it pushes the architecture toward a reusable common service layer
- it is important for partner-facing conversations about interoperability

## 9. How To Read The Codebase

### Fastest Technical Path

1. [README.md](../README.md)
2. [docs/getting-started.md](getting-started.md)
3. Try one native and one FHIR example for both SNOMED and LOINC
4. [ARCHITECTURE.md](../ARCHITECTURE.md)

### Architecture Path

1. [README.md](../README.md)
2. [ARCHITECTURE.md](../ARCHITECTURE.md)
3. `iris/src/Terminology/Core/TermService.cls`
4. one adapter and one repository for SNOMED
5. one adapter and one repository for LOINC
6. FHIR operation classes under `iris/src/Terminology/Fhir/Operations/`

### Partner Conversation Path

1. [README.md](../README.md)
2. [ARCHITECTURE.md](../ARCHITECTURE.md)
3. the `.http` files under `docs/http/`
4. the SQL examples under `docs/sql/`

## 10. How To Debug Problems

When debugging, first decide which phase is failing:

- intake problem: files were not detected or processed
- load problem: source tables were not populated correctly
- build problem: runtime structures were not created correctly
- query problem: repository or adapter logic is wrong
- API problem: request parsing or response mapping is wrong

That separation matches the architecture and usually leads to the right part of the code quickly.

If you need the full path of one request, enable `^TSTrace("enabled")=1` and inspect `^TSTrace` after repeating the call.
That is especially useful when you need to correlate FHIR or native requests with the SQL statements executed underneath.

## 11. Future Direction

The repository is intended to grow as a multi-terminology example on IRIS for Health.

That includes:

- adding more terminologies through the same service/adapter/repository pattern
- expanding the integrated terminology surface where the shared contract is justified
- exploring additional search and discovery patterns on IRIS where they add practical value

Possible future exploration may include vector database features for selected terminology-server functions, but the current focus remains the structured terminology server built on the existing IRIS platform capabilities.
