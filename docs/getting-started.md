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
iris/shared/in/snomed/base/
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

- [iris/shared/sql/sql-tuning-indexes.sql](iris/shared/sql/sql-tuning-indexes.sql)
- [iris/shared/sql/reset-terminology-data.sql](iris/shared/sql/reset-terminology-data.sql)

To load the tuning script in IRIS:

```sql
LOAD SQL FROM FILE '/iris-shared/sql/sql-tuning-indexes.sql' DIALECT 'IRIS' DELIMITER ';'
```

To reset loaded terminology data in IRIS:

```sql
LOAD SQL FROM FILE '/iris-shared/sql/reset-terminology-data.sql' DIALECT 'IRIS' DELIMITER ';'
```

Apply the tuning script only when you want those statements enabled for your environment.
Use the reset script only in local development environments.

## Verify The Server

### Native API Checks

Use:

- [docs/http/snomed-native.http](docs/http/snomed-native.http)

Recommended initial checks:

- search concepts
- get concept by ID
- get ancestors or descendants
- validate a known code

### FHIR API Checks

Use:

- [docs/http/snomed-fhir-r4.http](docs/http/snomed-fhir-r4.http)

Recommended initial checks:

- `CapabilityStatement`
- `CodeSystem/$lookup`
- `CodeSystem/$validate-code`
- `CodeSystem/$subsumes`
- `ValueSet/$expand`

### Direct SQL Checks

Use:

- [docs/sql/snomed-query-examples.md](docs/sql/snomed-query-examples.md)

This is useful when you want to inspect the stored SNOMED and derived data directly.

## Run Unit Tests

The repository includes initial `%UnitTest` suites for:

- `Terminology.Tests.Snomed.*`
- `Terminology.Tests.Loinc.*`
- `Terminology.Tests.Fhir.R4.*`

Notes:

- these tests seed their own synthetic terminology fixture data under dedicated `ReleaseId` values
- the LOINC tests seed their own synthetic release rows under `ReleaseId = UT-LOINC-20260401`
- they can be run with or without a full SNOMED or LOINC catalog already loaded
- they do require the local IRIS stack to be running and the native terminology web application to be available

Open an IRIS terminal in the container:

```bash
docker exec -it iris iris session IRIS
```

If you change test files while the container is already running, copy the updated test tree into the container before rerunning `%UnitTest`:

```bash
docker cp iris/tests/ iris:/opt/irisapp
```

Switch to the terminology namespace and run a suite:

```objectscript
zn "TERMINOLOGY"
set ^UnitTestRoot = "/opt/irisapp/tests"
do ##class(%UnitTest.Manager).RunTest("<suite>", "/nodelete")
```

Use:

- `snomed` to run all tests under `iris/tests/snomed`
- `loinc` to run all tests under `iris/tests/loinc`
- `fhir` to run all tests under `iris/tests/fhir`
- no suite argument to run all tests:

```objectscript
do ##class(%UnitTest.Manager).RunTest(, "/nodelete")
```

The `/nodelete` flag is useful during development because it keeps the loaded test classes available after the run.

## Suggested First Reading Order

After you verify the stack, read:

1. [docs/how-it-works.md](docs/how-it-works.md)
2. [ARCHITECTURE.md](ARCHITECTURE.md)
3. [FHIR_SCOPE.md](FHIR_SCOPE.md)
4. [CONVENTIONS.md](CONVENTIONS.md)

## Troubleshooting Focus Areas

If the system does not behave as expected, start by checking:

- whether the expected ZIP files were copied into the correct shared folders
- whether the production process detected and processed them
- whether preferred term and closure build steps completed
- whether the `releaseId`, `lang` and `dialect` values used in requests match the data actually loaded

The next place to look is [docs/how-it-works.md](docs/how-it-works.md), which explains the flow from release intake to API query handling.
