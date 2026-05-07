# Terminology Server on InterSystems IRIS for Health

This repository is a practical example of a terminology server built on InterSystems IRIS for Health.

It is intended both as:

- a working developer reference for terminology services on IRIS
- a partner-facing example that supports architecture conversations, capability discussions and opportunity discovery

The repository is intentionally multi-terminology.
Today it supports SNOMED CT, LOINC and ICD across native and FHIR APIs.
The target direction is to keep adding terminologies through the same architectural model instead of building isolated one-off implementations.

## Why This Repo Exists

This project demonstrates how IRIS for Health can be used as one integrated terminology platform for:

- terminology ingestion and release management
- persistent storage and SQL access
- fast search using IRIS features such as iFind
- native terminology-specific APIs
- FHIR terminology APIs
- interoperability and production-based processing in the same runtime

The goal is not only to expose endpoints.
The goal is to show how to structure a terminology server on IRIS so that each terminology can keep its real complexity while still contributing to one integrated view.

## What This Repo Demonstrates

- SNOMED CT ingestion from RF2 releases
- LOINC ingestion from release packages
- ICD ingestion and native + FHIR API support
- a demo web UI under `ui/` for exploring SNOMED CT, LOINC and ICD through native and FHIR APIs
- terminology-specific source and runtime-optimized storage
- native REST APIs under `/terminology/snomed`, `/terminology/loinc` and `/terminology/icd`
- a shared FHIR R4 terminology surface under `/terminology/fhir/r4`
- a common terminology service layer with adapters and repositories underneath
- search and query optimization patterns on IRIS, including iFind-backed search where appropriate

![Terminology Explorer UI demo](docs/images/terminology-explorer-ui-demo.small.gif)

## Current Scope

Today the repository provides:

- SNOMED CT native and FHIR terminology support
- LOINC native and FHIR terminology support
- ICD native and FHIR terminology support
- terminology-specific ingestion and repository layers
- a common `Terminology.Core.TermService` used to present a more integrated view
- a production-based ingestion model on IRIS for Health

This is not yet a full enterprise terminology platform.
It is a practical reference implementation that shows how to build one on IRIS for Health.

## High-Level Architecture

```text
Terminology releases / packages
    |
    v
IRIS interoperability / production-based intake
    |
    v
Terminology-specific load + build flows
    |
    +--> SNOMED source + derived tables
    |
    +--> LOINC source + derived tables
    |
    +--> ICD source + derived tables
    |
    v
Terminology.Core.TermService
    |
    +--> SNOMED adapter -> SNOMED repository
    |
    +--> LOINC adapter  -> LOINC repository
    |
    +--> ICD adapter    -> ICD repository
    |
    v
Native APIs + FHIR R4 terminology APIs
```

Use this diagram as the onboarding view.
More detailed flow and layering diagrams belong in [ARCHITECTURE.md](ARCHITECTURE.md).

## Why The Architecture Looks Like This

The repository does not force every terminology into one universal physical model.

Instead it separates concerns like this:

- `TermService` defines the shared logical contract
- adapters hold terminology-specific behavior
- repositories isolate SQL and IRIS-specific query optimization
- native and FHIR layers stay focused on protocol concerns

This matters because SNOMED CT and LOINC do not have the same structure, hierarchy semantics or ingestion shape.
The architecture allows each terminology to keep those differences while still exposing one server experience on top of IRIS.

## Quick Start

1. Build the image:

```bash
docker compose build
```

2. Start the stack:

```bash
docker compose up -d
```

3. Load one or both terminologies:

- SNOMED CT packages under `iris/shared/in/snomed/base/` and optionally `iris/shared/in/snomed/extension/`
- LOINC packages under `iris/shared/in/loinc/`
- ICD source files under `iris/shared/in/icd/`

4. Let the production ingest and build the runtime structures.

5. Verify the server using the HTTP examples under `docs/http/`.

6. Optionally run the demo UI from `ui/` using the instructions in [docs/getting-started.md](docs/getting-started.md).

7. Run the unit tests described in [docs/getting-started.md](docs/getting-started.md).

For the full setup and verification flow, see [docs/getting-started.md](docs/getting-started.md).

## Documentation Map

- [ARCHITECTURE.md](ARCHITECTURE.md): architecture, layer rationale and target direction
- [docs/getting-started.md](docs/getting-started.md): build, start, load, verify the project and use `^TSTrace` for request debugging
- [ui/README.md](ui/README.md): run the demo UI with the Vite dev server and build it for deployment
- [docs/how-it-works.md](docs/how-it-works.md): narrative walkthrough for developers and partners new to the repo, including terminology request tracing
- [FHIR_SCOPE.md](FHIR_SCOPE.md): current FHIR terminology scope and rollout approach
- [CONVENTIONS.md](CONVENTIONS.md): coding, layering and documentation rules
- [docs/http/snomed-native.http](docs/http/snomed-native.http): SNOMED native API examples
- [docs/http/loinc-native.http](docs/http/loinc-native.http): LOINC native API examples
- [docs/http/icd-native.http](docs/http/icd-native.http): ICD native API examples
- [docs/http/snomed-fhir-r4.http](docs/http/snomed-fhir-r4.http): SNOMED FHIR examples
- [docs/http/loinc-fhir-r4.http](docs/http/loinc-fhir-r4.http): LOINC FHIR examples
- [docs/http/icd-fhir-r4.http](docs/http/icd-fhir-r4.http): ICD FHIR examples
- [docs/sql/snomed-query-examples.md](docs/sql/snomed-query-examples.md): direct SQL examples for SNOMED
- [docs/sql/loinc-query-examples.md](docs/sql/loinc-query-examples.md): direct SQL examples for LOINC
- [docs/sql/icd-query-examples.md](docs/sql/icd-query-examples.md): direct SQL examples for ICD

## Suggested Reading Paths

### Fastest Path To Seeing It Work

1. Read this file.
2. Follow [docs/getting-started.md](docs/getting-started.md).
3. Run one native example and one FHIR example for SNOMED, LOINC or ICD.

### Architecture Path

1. Read this file.
2. Read [ARCHITECTURE.md](ARCHITECTURE.md).
3. Read [docs/how-it-works.md](docs/how-it-works.md).
4. Then inspect `Terminology.Core.TermService`, one adapter and one repository per terminology.

### Partner Conversation Path

1. Read this file for the platform framing.
2. Read [ARCHITECTURE.md](ARCHITECTURE.md) for the design rationale.
3. Use the `.http` files in `docs/http/` to anchor the discussion in working behavior.

## Reference Implementation Goal

The aim of this repository is to help developers and partners answer questions like:

- what does a terminology server on IRIS for Health look like in practice?
- how do you support more than one terminology without flattening them into a fake universal schema?
- how do native APIs and FHIR APIs share the same underlying behavior?
- where can IRIS features such as interoperability, integrated persistence, SQL and iFind add value?

Future exploration may include additional search and discovery patterns on IRIS, including possible use of vector database features for selected terminology-server functions where they add real value.

The documentation is split into onboarding, architecture, scope and conventions so the repository can support both implementation work and higher-level partner conversations.

## Vector Search and Semantic Crosswalk

The repository now includes a vector-based semantic layer that complements the existing terminology services.

This layer enables:

* free-text semantic search across one or multiple terminologies
* semantic crosswalk between different code systems
* approximate concept matching across languages and models

## What This Adds

The vector layer extends the current capabilities with:

* embedding-based similarity search using `sentence-transformers`
* precomputed vectors stored in `Terminology_Vector.TermEmbedding`
* HNSW indexing for fast nearest-neighbour retrieval
* integration with the existing interoperability production model

## API Endpoints

The vector functionality is exposed under:

```text
/terminology/vector
```

## Semantic Search

Search using natural language across one or more terminologies:

```http
GET /terminology/vector/search?q=neumonia adquirida en la comunidad
```
Example with filters

```http
GET /terminology/vector/search?q=fiebre tifoidea&systemUri=http://snomed.info/sct&systemUri=http://hl7.org/fhir/sid/icd-10-es&limit=10
```
Supported filters:

- `systemUri`
- `releaseId`
- `lang`
- `limit`

## Crosswalk Between Terminologies

Find semantically similar concepts across different systems.

From a code:
```http
GET /terminology/vector/crosswalk?sourceSystemUri=http://snomed.info/sct&sourceReleaseId=SNOMED-ES-20250131&sourceCode=233604007&targetSystemUri=http://hl7.org/fhir/sid/icd-10-es
```
From free text:
```http
GET /terminology/vector/crosswalk?q=glucosa en sangre&targetSystemUri=http://loinc.org
```

## How it works

The vectorization pipeline:

- extracts text from terminology-specific tables:
    - SNOMED → PreferredTerm
    - LOINC → Display
    - ICD/CIE → Code
- generates embeddings using sentence-transformers
- stores vectors explicitly using TO_VECTOR(..., DECIMAL)
- performs similarity search using:
```SQL
VECTOR_DOT_PRODUCT(Embedding, query_vector)
```

## Design Principles

The vector layer follows the same architecture as the rest of the repository:

- REST API → Business Service → Business Operation → Utils
- terminology-agnostic processing based on ReleaseId and metadata
- no hardcoded system logic in vectorization
- reuse of IRIS SQL and interoperability capabilities

## Important Notes
- results are based on semantic similarity, not curated mappings
- this is not a replacement for official terminology mappings
- quality depends on the embedding model used

## Future Direction

Planned extensions include:

- hybrid keyword + vector search
- FHIR integration ($translate, $lookup)
- configurable similarity thresholds
- support for multiple embedding models per use case