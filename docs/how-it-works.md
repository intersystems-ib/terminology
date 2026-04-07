# How It Works

This document explains the repository from the point of view of a developer who is new to the codebase.

The goal is not to restate every class. The goal is to explain the lifecycle of terminology data and the responsibilities of the main layers.

## Mental Model

This project turns SNOMED CT release files into runtime-ready structures and then serves that data through native and FHIR APIs.

At a high level:

```text
incoming RF2 files
    -> load source tables
    -> build derived tables
    -> serve terminology queries
```

## 1. Input Releases

The system expects RF2 ZIP files to be dropped into shared container folders.

Typical pattern:

- international release in `iris/shared/baseIn/`
- extension release in `iris/shared/in/`

The production layer detects those files and starts the ingestion flow.

## 2. Source Data Load

The load flow is centered on these parts:

- `Terminology.Production.BS.SnomedRf2FileService`
- `Terminology.Production.BP.SnomedRf2Load`
- `Terminology.Snomed.Utils.LoaderRf2`

Their combined responsibility is:

- detect incoming RF2 packages
- read release files
- load concepts, descriptions, relationships and refset members
- preserve release/version context needed for later queries

The source tables are the stable stored representation of the imported SNOMED content.

## 3. Derived Runtime Structures

Raw RF2 content is not the best shape for runtime terminology queries, so the repository builds additional tables.

### Preferred Terms

Relevant parts:

- `Terminology.Snomed.Utils.BuilderPreferredTerm`
- `Terminology_Snomed.PreferredTerm`
- `Terminology_Snomed.PreferredTermStage`

Purpose:

- determine the preferred display term for each concept
- respect configured language reference sets
- avoid expensive term resolution at query time

### ISA Closure

Relevant parts:

- `Terminology.Snomed.Utils.BuilderIsaClosure`
- `Terminology_Snomed.IsaClosure`

Purpose:

- precompute ancestor/descendant relationships
- support fast hierarchy traversal
- support subsumption checks without repeated recursive work at runtime

## 4. Request Handling Paths

There are two main API surfaces.

### Native SNOMED REST Path

The native path is centered on:

- `Terminology.Production.API`
- `Terminology.Production.BS.SnomedGatewayService`
- `Terminology.Production.BO.SnomedRepositoryOperation`
- `Terminology.Snomed.SnomedRepository`

This path exposes SNOMED-specific operations such as:

- search
- concept lookup
- descriptions
- hierarchy navigation
- refsets
- validate-code

### FHIR Terminology Path

The FHIR path is centered on:

- `Terminology.Fhir.Interactions`
- `Terminology.Fhir.Operations.TerminologyOperations`
- operation handlers such as `LookupOperation`, `ValidateCodeOperation`, `SubsumesOperation` and `ExpandOperation`
- `Terminology.Core.TermService`
- `Terminology.Snomed.SnomedAdapter`

This path is important because it shows the intended evolution of the repository:

- keep FHIR-facing classes focused on FHIR request and response behavior
- keep terminology logic in shared services and adapters
- keep SNOMED-specific query details out of generic FHIR classes

## 5. Why There Is Both A Native API And A FHIR API

The native API is useful because:

- it exposes the current SNOMED capabilities directly
- it is practical for internal development and validation
- it reflects the repo's original SNOMED-first implementation

The FHIR API is useful because:

- it shows how the same terminology capabilities can be exposed through a standard contract
- it pushes the codebase toward a reusable service layer
- it is the right direction for a partner-facing reference implementation

## 6. Why The Repo Is Not Fully Generic Yet

The project is intentionally not forcing every terminology into one abstract schema today.

The current approach is:

- keep SNOMED storage and load logic explicit
- introduce shared service contracts only where there is a real neutral operation
- add more terminologies later through adapters, not through premature generalization

That is why you will see both:

- strongly SNOMED-specific classes and tables
- newer core and FHIR-facing layers that are designed for future reuse

## 7. How To Read The Codebase

A practical reading order for a developer is:

1. [README.md](README.md)
2. [docs/getting-started.md](docs/getting-started.md)
3. [ARCHITECTURE.md](ARCHITECTURE.md)
4. `iris/src/Terminology/Production/API.cls`
5. `iris/src/Terminology/Snomed/SnomedRepository.cls`
6. `iris/src/Terminology/Core/TermService.cls`
7. `iris/src/Terminology/Snomed/SnomedAdapter.cls`
8. FHIR operation classes under `iris/src/Terminology/Fhir/Operations/`

## 8. How To Debug Problems

When debugging, first decide which phase is failing:

- intake problem: files were not detected or processed
- load problem: source tables were not populated correctly
- build problem: preferred term or closure tables were not created correctly
- query problem: repository or service logic is wrong
- API problem: request parsing or response mapping is wrong

That separation matches the intended architecture of the project and usually leads to the right part of the code quickly.
