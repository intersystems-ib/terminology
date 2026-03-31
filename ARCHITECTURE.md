# Architecture

## Project goal

Build an internal terminology server on InterSystems IRIS for Health that:
- starts from the current SNOMED CT base
- evolves into a reusable multi-terminology foundation
- exposes FHIR Terminology capabilities progressively
- can later be shared as an open source reference project

## Current starting point

The current repository already provides a working SNOMED-oriented base with:
- RF2 loading pipeline
- repository/query layer
- REST API layer
- derived structures for fast lookup/search/navigation

This project must preserve that investment and evolve it rather than rewrite everything.

## Target architecture principles

### 1. Hybrid model
Use:
- a **common core model** for cross-terminology concerns
- a **terminology-specific storage model** where needed

Do **not** force all terminologies into the exact same physical schema.
Do **not** create fully isolated products per terminology either.

Preferred approach:
- shared logical service contract
- specific storage/query implementations per terminology

### 2. Separation by responsibility
Keep these layers clearly separated:

- **FHIR/API layer**
  - exposes FHIR terminology operations and resources
  - should not know physical table details

- **Terminology service layer**
  - common business operations such as lookup, validate-code, subsumes, expand
  - routes requests to the correct terminology adapter

- **Terminology adapter layer**
  - terminology-specific implementation
  - e.g. SNOMED adapter, LOINC adapter

- **Repository/data access layer**
  - SQL and persistent access
  - optimized queries over IRIS storage

- **Load/build layer**
  - import external releases
  - build derived/optimized tables

### 3. Build on current repo structure
The existing SNOMED implementation is the starting point.
Near-term work should:
- understand current queries and tables
- stabilize the current SNOMED behavior
- reuse working logic for future FHIR operations

## Domain separation

### Core domain
Common concepts shared across terminologies:
- CodeSystem
- CodeSystemVersion
- ValueSet
- ConceptMap
- Language / designation metadata
- source provenance
- release metadata
- local catalog metadata

### SNOMED domain
SNOMED-specific structures remain specific:
- concept
- description
- relationship
- refset members
- preferred term derivation
- is-a closure
- language reference sets
- future ECL support if implemented

### Other terminology domains
LOINC, ICD, ATC, local catalogs, etc. may each have:
- dedicated load process
- dedicated physical structures if required
- shared service contract

## Near-term implementation strategy

### Phase A
Understand and document current SNOMED implementation:
- data model
- load flow
- repository methods
- current API endpoints
- performance structures

### Phase B
Create a common terminology service contract:
- LookupCode
- ValidateCode
- Subsumes
- SearchConcepts
- ExpandValueSet
- TranslateConcept

Current implementation rule:
- keep the initial common contract deliberately narrow
- route current SNOMED lookup, validate-code, subsumes and search through `Terminology.Core.TermService`
- keep SNOMED-native navigation and refset operations in `Terminology.Snomed.SnomedAdapter` until there is a real neutral use case

### Phase C
Implement FHIR over the common service contract, not directly over tables.

### Phase D
Add second terminology support only after the common service contract is stable.

## Proposed package direction

### Existing repo base
Keep current packages where possible.

### Suggested evolution
- `Terminology.Core`
- `Terminology.Snomed`
- `Terminology.Fhir`
- `Terminology.Mapping`
- `Terminology.Loinc`

Within each area, separate:
- Model
- Service
- Repository
- API
- Load
- Build

## Non-goals for the first MVP
Not required in first iteration:
- complete support for all FHIR terminology features
- full multi-terminology parity
- authoring workflows
- terminology governance UI
- sophisticated ValueSet composition engine for every code system

## Architectural rule for Codex
When modifying code:
- prefer extending current structure instead of replacing it
- avoid introducing generic abstractions unless they support at least 2 real use cases
- keep SNOMED-specific logic out of generic FHIR classes
- document every new service contract before implementing it
- add short meaningful comments to classes, methods and persistent properties when that improves maintainability and developer understanding
