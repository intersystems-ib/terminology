# Architecture

## Project Goal

Build a terminology server on InterSystems IRIS for Health that:

- supports multiple terminologies through one architectural model
- currently exposes SNOMED CT and LOINC
- exposes both native and FHIR terminology APIs
- uses IRIS features such as interoperability, persistence, SQL and iFind in one integrated platform
- serves as a reference implementation for developers and partner conversations

## Documentation Positioning

This file explains how the repository is structured and why the architecture is shaped this way.

For setup steps, use [docs/getting-started.md](docs/getting-started.md).
For a narrative walkthrough, use [docs/how-it-works.md](docs/how-it-works.md).
For contribution rules, use [CONVENTIONS.md](CONVENTIONS.md).

## Architectural Position

This repository is intentionally not built around one universal terminology schema.

Instead it uses:

- shared service contracts where there is a real common concept
- terminology-specific adapters where behavior diverges
- terminology-specific repositories where storage and query semantics diverge
- thin native and FHIR layers on top

That approach allows the server to expose one integrated view while still respecting the real complexity of SNOMED CT, LOINC and future terminologies.

## Why IRIS For Health Fits This Problem

IRIS for Health is part of the architecture, not just the runtime.

The repository takes advantage of IRIS for:

- production-based ingestion and operational orchestration
- persistent storage and SQL access
- integrated FHIR exposure
- iFind-backed search where that improves runtime query behavior
- one environment for load, build, query and API delivery

This is why the repository can present one terminology server instead of a loose collection of disconnected services.

## Current Implemented Architecture

The repository already contains a working multi-terminology server with:

- SNOMED CT ingestion, runtime structures and native/FHIR exposure
- LOINC ingestion, runtime structures and native/FHIR exposure
- a common service layer that routes supported terminology operations
- terminology-specific adapters and repositories underneath that common layer

### Runtime Request Flow

```text
Client
  |
  +--> Native terminology APIs
  |
  +--> FHIR terminology APIs
          |
          v
  Terminology.Core.TermService
          |
          +--> SNOMED adapter -> SNOMED repository
          |
          +--> LOINC adapter  -> LOINC repository
          |
          v
      IRIS tables
```

### Load And Build Flow

```text
Terminology release packages
  |
  v
IRIS production / file intake
  |
  +--> SNOMED load + build
  |
  +--> LOINC load + build
  |
  +--> CIE load + build
  |
  v
Terminology-specific source and runtime tables
```

## Current Main Components

### Shared FHIR And Service Path

- `Terminology.Fhir.Interactions`
- `Terminology.Fhir.Operations.TerminologyOperations`
- operation-specific classes such as:
  - `Terminology.Fhir.Operations.LookupOperation`
  - `Terminology.Fhir.Operations.ValidateCodeOperation`
  - `Terminology.Fhir.Operations.SubsumesOperation`
  - `Terminology.Fhir.Operations.ExpandOperation`
- `Terminology.Core.TermService`

This path exposes one FHIR-oriented surface while routing behavior to the appropriate terminology implementation.

### Native SNOMED Path

- `Terminology.Production.API`
- `Terminology.Production.BS.SnomedGatewayService`
- `Terminology.Production.BO.SnomedRepositoryOperation`
- `Terminology.Snomed.SnomedRepository`

This path exposes SNOMED-specific native operations for search, lookup, hierarchy navigation, refsets and validation.

### Native LOINC Path

- `Terminology.Production.API`
- `Terminology.Production.BS.LoincGatewayService`
- `Terminology.Production.BO.LoincRepositoryOperation`
- `Terminology.Loinc.LoincRepository`

This path exposes LOINC-specific native operations for search, lookup, displays, parts, hierarchy navigation, groups and validation.

### Terminology Adapters

- `Terminology.Snomed.SnomedAdapter`
- `Terminology.Loinc.LoincAdapter`

These classes translate common terminology operations into terminology-specific repository behavior.

### Load And Build Paths

SNOMED:

- `Terminology.Production.BS.SnomedRf2FileService`
- `Terminology.Production.BP.SnomedRf2Load`
- `Terminology.Snomed.Utils.LoaderRf2`
- `Terminology.Snomed.Utils.BuilderPreferredTerm`
- `Terminology.Snomed.Utils.BuilderIsaClosure`

LOINC:

- `Terminology.Production.BS.LoincFileService`
- `Terminology.Production.BP.LoincLoad`
- `Terminology.Loinc.Utils.Loader`
- `Terminology.Loinc.Utils.BuilderDisplay`
- `Terminology.Loinc.Utils.BuilderHierarchy`

## Why TermService, Adapters And Repositories

### TermService

`Terminology.Core.TermService` exists to define the integrated logical view of the server.

Responsibilities:

- expose shared terminology operations
- route requests to the correct adapter
- keep API and FHIR layers from hard-coding terminology-specific internals

### Adapters

Adapters exist because shared operations do not mean identical terminology behavior.

Responsibilities:

- translate shared operations into terminology-specific behavior
- preserve terminology-specific semantics when the common contract is too coarse to express them directly
- shield API and FHIR layers from storage and model details

### Repositories

Repositories exist because SQL and physical query behavior are still terminology-specific.

Responsibilities:

- contain SQL
- map rows into DTO/result shapes
- encode IRIS-specific query optimization choices such as iFind usage and ordering semantics

This separation is important.
It lets the repo expose one server while still allowing each terminology to keep its own model, hierarchy behavior and runtime optimization strategy.

## Data Model

The physical model is intentionally terminology-specific where that makes sense.

### SNOMED Data Model

Source tables:

- `Terminology_Snomed.Concept`
- `Terminology_Snomed.Description`
- `Terminology_Snomed.Relationship`
- `Terminology_Snomed.RefsetMember`

Derived tables:

- `Terminology_Snomed.PreferredTerm`
- `Terminology_Snomed.PreferredTermStage`
- `Terminology_Snomed.IsaClosure`
- `Terminology_Snomed.LanguageRefSetConfig`

### LOINC Data Model

Source/runtime tables:

- `Terminology_Loinc.Code`
- `Terminology_Loinc.Display`
- `Terminology_Loinc.Part`
- `Terminology_Loinc.CodePartLink`
- `Terminology_Loinc.HierarchyEdge`
- `Terminology_Loinc.Closure`
- `Terminology_Loinc.LoincGroup`
- `Terminology_Loinc.GroupMember`

### CIE Data model

Source/runtime tables:

- `Terminology_CIE.Chapter`
- `Terminology_CIE.Code`
- `Terminology_CIE.Family`
- `Terminology_CIE.HierarchyEdge`

### Shared Metadata

Shared metadata used by the integrated API/FHIR layers is stored separately in the core area, for example:

- `Terminology_Core.CodeSystem`
- `Terminology_Core.VersionRelease`

## End-To-End Flow

### 1. Release Intake

The containerized environment watches input folders under `iris/shared/`.

Current examples:

- SNOMED packages under `iris/shared/in/snomed/`
- LOINC packages under `iris/shared/in/loinc/`
- CIE packages under `iris/shared/in/cie/`

The IRIS production detects those files and starts the appropriate terminology load flow.

### 2. Terminology-Specific Load

Each terminology is loaded using terminology-aware logic.

That is deliberate.
The project does not pretend that SNOMED RF2 and LOINC package structures are the same.

### 3. Runtime Structure Build

After raw content is loaded, build steps create runtime-optimized structures such as:

- preferred-term structures
- display structures
- closure/hierarchy structures

These exist so the server does not have to reconstruct expensive query semantics on every request.

### 4. Query Serving

Once runtime structures exist:

- native terminology endpoints route through their terminology-specific operation and repository paths
- FHIR operations route through `Terminology.Core.TermService`
- adapters delegate execution to the correct terminology-specific repository

## Separation By Responsibility

### API Layer

Responsibilities:

- parse requests
- validate request shape
- map results into native or FHIR responses
- call services

Must not:

- implement SQL
- know terminology table internals in detail
- duplicate business logic already owned by services or repositories

### Terminology Service Layer

Responsibilities:

- define shared terminology operations
- route requests to the correct adapter
- keep cross-terminology contracts stable

Current example:

- `Terminology.Core.TermService`

### Adapter Layer

Responsibilities:

- implement terminology-specific behavior behind common contracts
- translate shared operations into terminology-specific repository calls

Current examples:

- `Terminology.Snomed.SnomedAdapter`
- `Terminology.Loinc.LoincAdapter`
- `Terminology.CIE.CIEAdapter`

### Repository Layer

Responsibilities:

- contain SQL
- map rows into result shapes
- encode IRIS-specific query optimization

Current examples:

- `Terminology.Snomed.SnomedRepository`
- `Terminology.Loinc.LoincRepository`
- `Terminology.CIE.CIERepository`

### Load / Build Layer

Responsibilities:

- import external files
- load source content
- build optimized structures
- preserve release/version metadata

## Current Versus Target Direction

### Current State

The repository already operates as a multi-terminology example, with SNOMED CT and LOINC implemented.

At the same time:

- physical models remain terminology-specific
- some native APIs are terminology-specific by design
- the common service surface is still intentionally narrow

### Target Direction

The target is a hybrid model:

- one integrated logical service contract for shared terminology operations
- terminology-specific storage and behavior where needed
- additional adapters for future code systems instead of forcing one universal schema

```text
Core terminology contracts
  |
  +--> SNOMED adapter
  +--> LOINC adapter
  +--> CIE adapter
  +--> future terminology adapters
```

This avoids both extremes:

- forcing all terminologies into one physical model
- creating fully isolated implementations with no integrated service layer

## Near-Term Architectural Priorities

### 1. Preserve The Working Terminology Implementations

The current SNOMED and LOINC implementations are the working base.
Architectural changes should extend them, not flatten them.

### 2. Stabilize The Shared Contract

The common service surface should stay narrow until at least two real terminology use cases justify expansion.

Current justified shared operations include:

- lookup
- validate-code
- subsumes
- search
- value set metadata and expansion support where already implemented

### 3. Keep FHIR On Top Of Services

FHIR operations should depend on shared terminology services, not query terminology tables directly.

### 4. Add More Terminologies Through Adapters

Future terminologies should plug in through the same service/adapter/repository pattern.

## Package Direction

The intended package shape is:

- `Terminology.Core`
- `Terminology.Snomed`
- `Terminology.Loinc`
- `Terminology.Fhir`
- `Terminology.Mapping`

Within each area, keep responsibilities separated by:

- model
- service
- repository
- API
- load
- build

## Non-Goals For The Current Stage

Not required in the current stage:

- complete enterprise FHIR terminology parity
- authoring workflows
- one universal physical schema for every terminology
- promising future implementation directions before the current common contract is stable

Exploration areas may grow later, including additional search and discovery patterns on IRIS, but the current architectural focus remains the integrated multi-terminology server built on the existing IRIS capabilities.
