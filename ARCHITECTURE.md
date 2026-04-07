# Architecture

## Project Goal

Build a terminology server on InterSystems IRIS for Health that:

- starts from a working SNOMED CT implementation
- evolves into a reusable multi-terminology foundation
- exposes FHIR terminology capabilities progressively
- serves as an open source reference for developers implementing terminology services on IRIS

## Documentation Positioning

This file explains how the repository is structured and how it currently works.

For setup steps, use [docs/getting-started.md](docs/getting-started.md).
For a narrative walkthrough, use [docs/how-it-works.md](docs/how-it-works.md).
For contribution rules, use [CONVENTIONS.md](CONVENTIONS.md).

## Current Implemented Architecture

The repository already contains a working SNOMED-oriented server with:

- file-driven RF2 ingestion
- source tables for core SNOMED components
- derived tables for preferred terms and hierarchy traversal
- a native REST API
- an initial FHIR terminology API
- a common service layer that can route terminology operations

### Runtime Request Flow

```text
Client
  |
  v
REST / FHIR API
  |
  v
Gateway / Service Layer
  |
  v
Repository
  |
  v
IRIS Tables
```

### Load And Build Flow

```text
RF2 files
  |
  v
SnomedRf2FileService
  |
  v
SnomedRf2Load / LoaderRf2
  |
  v
Concept / Description / Relationship / RefsetMember
  |
  +--> BuilderPreferredTerm -> PreferredTerm
  |
  +--> BuilderIsaClosure -> IsaClosure
```

## Current Main Components

### Native SNOMED API Path

- `Terminology.Production.API`
- `Terminology.Production.BS.SnomedGatewayService`
- `Terminology.Production.BO.SnomedRepositoryOperation`
- `Terminology.Snomed.SnomedRepository`

This path exposes SNOMED-specific native endpoints for search, lookup, hierarchy navigation, refsets and validation.

### FHIR Terminology Path

- `Terminology.Fhir.Interactions`
- `Terminology.Fhir.Operations.TerminologyOperations`
- operation-specific classes such as:
  - `Terminology.Fhir.Operations.LookupOperation`
  - `Terminology.Fhir.Operations.ValidateCodeOperation`
  - `Terminology.Fhir.Operations.SubsumesOperation`
  - `Terminology.Fhir.Operations.ExpandOperation`
- `Terminology.Core.TermService`
- terminology adapters such as `Terminology.Snomed.SnomedAdapter`

This path exposes a FHIR-oriented surface while reusing shared terminology behavior instead of querying SNOMED tables directly from the FHIR layer.

### Load And Build Path

- `Terminology.Production.BS.SnomedRf2FileService`
- `Terminology.Production.BP.SnomedRf2Load`
- `Terminology.Snomed.Utils.LoaderRf2`
- `Terminology.Snomed.Utils.BuilderPreferredTerm`
- `Terminology.Snomed.Utils.BuilderIsaClosure`

This path turns incoming RF2 releases into runtime-ready structures.

## Data Model

### Source Tables

The base SNOMED content is stored in terminology-specific tables:

- `Terminology_Snomed.Concept`
- `Terminology_Snomed.Description`
- `Terminology_Snomed.Relationship`
- `Terminology_Snomed.RefsetMember`

These tables retain the semantics of the imported RF2 content and act as the authoritative stored source for downstream build steps.

### Derived Tables

The project also builds optimized runtime tables:

- `Terminology_Snomed.PreferredTerm`
- `Terminology_Snomed.PreferredTermStage`
- `Terminology_Snomed.IsaClosure`
- `Terminology_Snomed.LanguageRefSetConfig`

These tables exist because some API behaviors should not repeatedly resolve language preference, transitive hierarchy or runtime search logic from raw RF2 rows.

### Data Model Rationale

```text
RF2 source content
  |
  +--> stored with close fidelity to SNOMED structures
  |
  +--> transformed into optimized runtime tables
          |
          +--> faster preferred-term lookup
          +--> faster ancestor/descendant traversal
          +--> simpler API and repository queries
```

## End-To-End Flow

### 1. Release Intake

The containerized environment watches input folders under `iris/shared/`.

Typical flow:

- the international SNOMED package is placed in `iris/shared/baseIn/`
- an extension package is placed in `iris/shared/in/`
- the production detects those files
- the load process imports the RF2 records into SNOMED source tables

### 2. Release Normalization

The RF2 loader merges imported content into a single runtime release context and preserves the identifiers and metadata needed for later terminology operations.

### 3. Derived Structure Build

After source data is available, builder processes create:

- preferred term rows for language- and dialect-aware display
- closure rows for fast `is-a` traversal and subsumption checks

### 4. Query Serving

Once the derived structures exist, request handling becomes simpler:

- native SNOMED endpoints route requests through the production/gateway/repository path
- FHIR operations route requests through `Terminology.Core.TermService`
- terminology-specific execution is delegated to the SNOMED adapter and repository layer

## Separation By Responsibility

The architectural rule is to keep each layer narrow and explicit.

### API Layer

Responsibilities:

- parse requests
- validate request shape
- map results into native or FHIR responses
- call services

Must not:

- implement SQL
- know SNOMED table structure in detail
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

Current example:

- `Terminology.Snomed.SnomedAdapter`

### Repository Layer

Responsibilities:

- contain SQL
- map rows into result shapes
- encode IRIS-specific query optimizations

Current example:

- `Terminology.Snomed.SnomedRepository`

### Load / Build Layer

Responsibilities:

- import external files
- load source content
- build optimized structures
- preserve release/version metadata

## Current Versus Target Direction

### Current State

The repository is SNOMED-first.

That means:

- most physical tables are SNOMED-specific
- load logic is centered on SNOMED RF2
- native APIs are SNOMED-specific
- FHIR support currently maps mainly to SNOMED-backed behavior

### Target Direction

The target is a hybrid model:

- a shared logical service contract for terminology operations
- terminology-specific storage where that makes sense
- additional adapters for future code systems instead of forcing a single universal schema

```text
Core domain contracts
  |
  +--> SNOMED adapter
  +--> future LOINC adapter
  +--> future mapping adapter
```

This avoids both extremes:

- forcing all terminologies into one physical model
- creating fully isolated implementations with no shared service contract

## Near-Term Architectural Priorities

### 1. Preserve The Working SNOMED Base

The current SNOMED implementation is the foundation. Architectural changes should extend it, not replace it.

### 2. Stabilize The Shared Contract

The common service surface should stay narrow until at least two real terminology use cases justify expansion.

Current justified shared operations include:

- lookup
- validate-code
- subsumes
- concept search

### 3. Keep FHIR On Top Of Services

FHIR operations should depend on shared terminology services, not query physical SNOMED tables directly.

### 4. Add More Terminologies Only After The Contract Holds

A second terminology should be added after the common service contract is stable enough to support it without broad rework.

## Package Direction

The intended package shape is:

- `Terminology.Core`
- `Terminology.Snomed`
- `Terminology.Fhir`
- `Terminology.Mapping`
- `Terminology.Loinc`

Within each area, keep responsibilities separated by:

- model
- service
- repository
- API
- load
- build

## Non-Goals For The First MVP

Not required in the first iteration:

- complete FHIR terminology parity
- full multi-terminology support
- authoring workflows
- governance UI
- a full generic ValueSet composition engine
- broad abstractions that do not yet support multiple real use cases

## Architectural Rule For Contributors

When modifying code:

- extend the current structure rather than rewriting it
- keep SNOMED-specific logic out of generic FHIR classes
- keep SQL inside repositories
- document new service contracts before widening them
- update this file when the implemented runtime flow changes
