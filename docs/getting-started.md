# Getting Started

This guide is for developers who want to run the repository locally, load SNOMED content and verify that the server is working.

## What You Will Do

1. build the container image
2. start the stack
3. load a SNOMED CT international release
4. optionally load a national extension
5. optionally apply SQL tuning
6. verify native and FHIR endpoints

## Prerequisites

Before starting, make sure you have:

- Docker and Docker Compose available
- access to an InterSystems IRIS for Health environment compatible with this repository
- a SNOMED CT International release ZIP
- optionally, a national extension ZIP such as the Spanish edition

## Build The Image

```bash
docker compose build
```

If you want to rebuild without pulling base image updates:

```bash
docker compose build --pull=false
```

## Start The Stack

```bash
docker compose up -d
```

After startup, the container environment should initialize the terminology database and production components.

## Load SNOMED CT International

Place the international ZIP file in:

```text
iris/shared/baseIn/
```

The production process watches that location and will ingest the file.

Notes:

- the environment is configured to create a `TERMINOLOGY-DATA` database with an initial size intended to reduce expansion overhead during load
- the original scratch notes estimated about 3 minutes 40 seconds for this step in the local environment they were written for
- actual timing will depend on your machine, IRIS configuration and release size

## Load A National Extension

Place the extension ZIP file in:

```text
iris/shared/in/
```

The production process will ingest it after detection.

Notes:

- the original scratch notes estimated about 3 minutes 45 seconds for the Spanish edition in one local setup
- actual timing will vary by environment

## Optional SQL Tuning

The repository includes:

- [iris/shared/tune.sql](/Users/afuentes/Documents/ISC/workspace/terminology/iris/shared/tune.sql)

To load it in IRIS:

```sql
LOAD SQL FROM FILE '/shared/tune.sql' DIALECT 'IRIS' DELIMITER ';'
```

Apply this only when you want the tuning statements in that file enabled for your environment.

## Verify The Server

### Native API Checks

Use:

- [docs/http/snomed-native.http](/Users/afuentes/Documents/ISC/workspace/terminology/docs/http/snomed-native.http)

Recommended initial checks:

- search concepts
- get concept by ID
- get ancestors or descendants
- validate a known code

### FHIR API Checks

Use:

- [docs/http/snomed-fhir-r4.http](/Users/afuentes/Documents/ISC/workspace/terminology/docs/http/snomed-fhir-r4.http)

Recommended initial checks:

- `CapabilityStatement`
- `CodeSystem/$lookup`
- `CodeSystem/$validate-code`
- `CodeSystem/$subsumes`
- `ValueSet/$expand`

### Direct SQL Checks

Use:

- [docs/sql/snomed-query-examples.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/sql/snomed-query-examples.md)

This is useful when you want to inspect the stored SNOMED and derived data directly.

## Suggested First Reading Order

After you verify the stack, read:

1. [docs/how-it-works.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/how-it-works.md)
2. [ARCHITECTURE.md](/Users/afuentes/Documents/ISC/workspace/terminology/ARCHITECTURE.md)
3. [FHIR_SCOPE.md](/Users/afuentes/Documents/ISC/workspace/terminology/FHIR_SCOPE.md)
4. [CONVENTIONS.md](/Users/afuentes/Documents/ISC/workspace/terminology/CONVENTIONS.md)

## Troubleshooting Focus Areas

If the system does not behave as expected, start by checking:

- whether the expected ZIP files were copied into the correct shared folders
- whether the production process detected and processed them
- whether preferred term and closure build steps completed
- whether the `releaseId`, `lang` and `dialect` values used in requests match the data actually loaded

The next place to look is [docs/how-it-works.md](/Users/afuentes/Documents/ISC/workspace/terminology/docs/how-it-works.md), which explains the flow from release intake to API query handling.
