# Getting Started

This guide is for developers and partners who want to run the repository locally, load terminology content and verify that the server is working.

The repository is intended to be multi-terminology.
Today the practical paths are:

- SNOMED CT
- LOINC
- ICD
- the shared FHIR terminology surface over all three

## What You Will Do

1. build the container image
2. start the stack
3. load one or more terminologies
4. verify native and FHIR behavior
5. use the repo docs to understand the architecture better

## Choose Your Onboarding Path

### Fastest Path To Seeing It Work

1. build and start the stack
2. load one terminology
3. run one native example
4. run one FHIR example

### FHIR-Focused Path

1. build and start the stack
2. load one or more terminologies
3. use `docs/http/snomed-fhir-r4.http`, `docs/http/loinc-fhir-r4.http` and `docs/http/icd-fhir-r4.http`
4. then read [FHIR_SCOPE.md](../FHIR_SCOPE.md)

### Architecture Path

1. build and start the stack
2. verify at least one native and one FHIR request
3. read [docs/how-it-works.md](how-it-works.md)
4. read [ARCHITECTURE.md](../ARCHITECTURE.md)

## Prerequisites

Before starting, make sure you have:

- Docker and Docker Compose available
- access to an InterSystems IRIS for Health environment compatible with this repository
- a SNOMED CT release ZIP if you want to run the SNOMED path
- a LOINC release ZIP if you want to run the LOINC path
- ICD source files if you want to run the ICD path

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

After startup, the container environment should initialize the terminology database, production components and API surfaces.

## Load Terminology Content

### Load SNOMED CT

Place the international ZIP file in:

```text
iris/shared/in/snomed/base/
```

If you want to load an extension, place it in:

```text
iris/shared/in/snomed/extension/
```

Notes:

- the environment is configured to create a `TERMINOLOGY-DATA` database with an initial size intended to reduce expansion overhead during load
- actual timing will depend on your machine, IRIS configuration and release size

### Load LOINC

Place the LOINC ZIP file in:

```text
iris/shared/in/loinc/
```

The production process watches that location and will ingest the file.

### Load ICD

Place the ICD source files in:

```text
iris/shared/in/icd/
```

The production process watches that location and will ingest and build the ICD runtime structures.

## Optional SQL Tuning

The repository includes:

- [iris/shared/sql/sql-tuning-indexes.sql](../iris/shared/sql/sql-tuning-indexes.sql)
- [iris/shared/sql/reset-terminology-data.sql](../iris/shared/sql/reset-terminology-data.sql)

To load the tuning script in IRIS:

```sql
LOAD SQL FROM FILE '/iris-shared/sql/sql-tuning-indexes.sql' DIALECT 'IRIS' DELIMITER ';'
```

To reset loaded terminology data in IRIS:

```sql
--LOAD SQL FROM FILE '/iris-shared/sql/reset-terminology-data.sql' DIALECT 'IRIS' DELIMITER ';'
```

Apply the tuning script only when you want those statements enabled for your environment.
Use the reset script only in local development environments.

## Verify The Server

### Native API Checks

Use:

- [docs/http/snomed-native.http](http/snomed-native.http)
- [docs/http/loinc-native.http](http/loinc-native.http)
- [docs/http/icd-native.http](http/icd-native.http)

Recommended initial checks:

- search
- lookup
- hierarchy navigation
- validate-code

### FHIR API Checks

Use:

- [docs/http/snomed-fhir-r4.http](http/snomed-fhir-r4.http)
- [docs/http/loinc-fhir-r4.http](http/loinc-fhir-r4.http)
- [docs/http/icd-fhir-r4.http](http/icd-fhir-r4.http)

Recommended initial checks:

- `CapabilityStatement`
- `CodeSystem/$lookup`
- `CodeSystem/$validate-code`
- `CodeSystem/$subsumes`
- `ValueSet/$expand`

### Direct SQL Checks

Use:

- [docs/sql/snomed-query-examples.md](sql/snomed-query-examples.md)
- [docs/sql/loinc-query-examples.md](sql/loinc-query-examples.md)

This is useful when you want to inspect stored source and runtime data directly.

## Run Unit Tests

The repository includes initial `%UnitTest` suites for:

- `Terminology.Tests.Snomed.*`
- `Terminology.Tests.Loinc.*`
- `Terminology.Tests.ICD.*`
- `Terminology.Tests.Fhir.R4.*`

Notes:

- these tests seed their own synthetic terminology fixture data under dedicated `ReleaseId` values
- the LOINC tests seed their own synthetic release rows under `ReleaseId = UT-LOINC-20260401`
- the ICD tests seed their own synthetic release rows under `ReleaseId = UT-ICD-20260401`
- the FHIR suite is split into metadata-only tests plus SNOMED-backed, LOINC-backed and ICD-backed API classes
- they can be run with or without a full SNOMED, LOINC or ICD catalog already loaded
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
- `icd` to run all tests under `iris/tests/icd`
- `fhir` to run all tests under `iris/tests/fhir`
- no suite argument to run all tests

```objectscript
do ##class(%UnitTest.Manager).RunTest(, "/nodelete")
```

The `/nodelete` flag is useful during development because it keeps the loaded test classes available after the run.

## Use Request Tracing

The repository includes a simple terminology trace global for debugging native and FHIR request flow:

- `^TSTrace`

Enable tracing in an IRIS terminal:

```objectscript
zn "TERMINOLOGY"
set ^TSTrace("enabled")=1
```

Run a native or FHIR request, then inspect the trace:

```objectscript
zw ^TSTrace
```

Each request is stored under:

- `^TSTrace("req",reqId,...)`

Ordered trace entries are stored under:

- `^TSTrace("req",reqId,"entry",seq,...)`

Typical entries include:

- request start and end
- FHIR or native request context
- service calls
- SQL execution with arguments and elapsed time
- errors

To clear the trace during local debugging:

```objectscript
kill ^TSTrace
```

Then re-enable it when needed:

```objectscript
set ^TSTrace("enabled")=1
```

## What You Should Understand After This Guide

After following this guide, you should understand:

- the repo is a multi-terminology terminology server example on IRIS for Health
- SNOMED CT and LOINC are both first-class examples in the current implementation
- native and FHIR APIs are both part of the intended platform story
- the underlying architecture is meant to support partner discussions as well as implementation work

## Suggested Next Reading Order

1. [docs/how-it-works.md](how-it-works.md)
2. [ARCHITECTURE.md](../ARCHITECTURE.md)
3. [FHIR_SCOPE.md](../FHIR_SCOPE.md)
4. [CONVENTIONS.md](../CONVENTIONS.md)

## Troubleshooting Focus Areas

If the system does not behave as expected, start by checking:

- whether the expected release packages were copied into the correct shared folders
- whether the production process detected and processed them
- whether runtime build steps completed
- whether the `releaseId`, `lang` and `dialect` values used in requests match the data actually loaded

The next place to look is [docs/how-it-works.md](how-it-works.md), which explains the flow from release intake to API query handling.
