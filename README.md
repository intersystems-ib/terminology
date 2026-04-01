# Terminology Server on InterSystems IRIS

This repository is a open source implementation of a terminology server built on InterSystems IRIS for Health.

The project is structured to evolve into a multi-terminology foundation and a practical example for developers.

## What This Repo Demonstrates

- loading SNOMED CT RF2 releases into IRIS
- combining base and extension content into one runtime dataset
- building derived structures for fast search and hierarchy navigation
- exposing native SNOMED-oriented REST endpoints
- exposing an initial FHIR terminology surface over the same core behavior
- organizing terminology logic so future code systems can be added without rewriting everything

## Current Scope

Today the repository provides:

- a working SNOMED CT ingestion pipeline
- persistent source tables for concepts, descriptions, relationships and refset members
- derived tables for preferred terms and hierarchical closure
- a native REST API under `/terminology/snomed`
- a FHIR R4 terminology surface under `/terminology/fhir/r4`
- a first common service layer intended to support additional terminologies later

This is not yet a full enterprise terminology platform. It is a practical, working base that shows how to structure one on IRIS.

## High-Level Flow

```text
RF2 ZIP files
    |
    v
Load / Build Pipeline
    |
    v
SNOMED source tables + derived tables
    |
    +--> Native REST API
    |
    +--> FHIR Terminology API
```

## Quick Start

1. Build the image:

```bash
docker compose build
```

2. Start the stack:

```bash
docker compose up -d
```

3. Copy the SNOMED CT International release ZIP to `iris/shared/baseIn/`.

4. Copy a national extension ZIP, if used, to `iris/shared/in/`.

5. Let the production process ingest the files and build the runtime structures.

6. Optionally apply SQL tuning from `iris/shared/tune.sql`.

7. Verify the server using the HTTP examples under `docs/http/`.

For the full setup and verification flow, see [docs/getting-started.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/getting-started.md).

## Documentation Map

- [ARCHITECTURE.md](/Users/afuentes/Documents/ISC/workspace/terminology/ARCHITECTURE.md): current implementation shape, runtime flow, target direction
- [docs/getting-started.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/getting-started.md): build, start, load and verify the project
- [docs/how-it-works.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/how-it-works.md): narrative walkthrough for developers new to the repo
- [FHIR_SCOPE.md](/Users/afuentes/Documents/ISC/workspace/terminology/FHIR_SCOPE.md): current FHIR terminology scope and rollout approach
- [CONVENTIONS.md](/Users/afuentes/Documents/ISC/workspace/terminology/CONVENTIONS.md): coding, layering and documentation rules
- [docs/http/snomed-native.http](/Users/afuentes/Documents/ISC/workspace/terminology/docs/http/snomed-native.http): native API request examples
- [docs/http/snomed-fhir-r4.http](/Users/afuentes/Documents/ISC/workspace/terminology/docs/http/snomed-fhir-r4.http): FHIR API request examples
- [docs/sql/snomed-query-examples.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/sql/snomed-query-examples.md): direct SQL examples over the SNOMED model

## Typical Developer Path

If you are new to the project, the shortest useful path is:

1. Read this file to understand the project boundary.
2. Read [docs/getting-started.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/getting-started.md) and run the stack.
3. Use the `.http` files in `docs/http/` to verify the native and FHIR endpoints.
4. Read [docs/how-it-works.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/how-it-works.md) to understand the end-to-end lifecycle.
5. Read [ARCHITECTURE.md](/Users/afuentes/Documents/ISC/workspace/terminology/ARCHITECTURE.md) before making structural changes.
6. Read [CONVENTIONS.md](/Users/afuentes/Documents/ISC/workspace/terminology/CONVENTIONS.md) before contributing code.

## Reference Implementation Goal

The aim of this repository is not only to solve one internal SNOMED use case. It is to show developers a practical implementation pattern for:

- ingesting terminology content on IRIS
- separating load, repository, service and API responsibilities
- keeping terminology-specific logic isolated while introducing a shared service contract
- exposing both native and FHIR-facing interfaces from the same underlying model

That is why the documentation is split into onboarding, architecture, scope and conventions instead of placing everything in a single technical summary.
