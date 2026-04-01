# Conventions

## General development rule

Prefer:
- small, explicit classes
- stable names
- thin API layer
- business logic in service layer
- SQL isolated in repository layer
- short, meaningful descriptive comments on classes, methods and persistent properties when they help a developer understand intent quickly

Avoid:
- mixing API, business logic and SQL in the same class
- "generic" abstractions with no immediate use
- SNOMED assumptions inside common classes
- redundant comments that only restate the code

## Commenting conventions

Use short descriptive comments to improve readability and maintenance:

- add a meaningful class comment when responsibility is not obvious from the name alone
- add a meaningful method comment when the method contains non-trivial intent, business rules or important side effects
- add a meaningful comment on persistent properties when the stored meaning, lifecycle or constraints are not obvious
- keep comments brief and focused on intent, behavior or persistence semantics
- prefer comments that help another developer understand why the code exists or how it should be used

## Naming conventions

### Packages
Use stable package names based on responsibility:

- `Terminology.Core.*`
- `Terminology.Snomed.*`
- `Terminology.Fhir.*`
- `Terminology.Loinc.*`
- `Terminology.Mapping.*`

### Class naming
Use class names that make responsibility obvious:

- `...Api`
- `...Service`
- `...Adapter`
- `...Repository`
- `...LoadService`
- `...BuildService`

Examples:
- `Terminology.Fhir.CodeSystemApi`
- `Terminology.Core.TermService`
- `Terminology.Snomed.SnomedAdapter`
- `Terminology.Snomed.SnomedRepository`

## Layering rules

### API layer
Responsibilities:
- request parsing
- response shaping
- error mapping
- calling services

Must not:
- build SQL
- know table internals
- contain terminology-specific branching unless it is the terminology-specific API itself

### Service layer
Responsibilities:
- business orchestration
- terminology routing
- common operation contracts
- validation of input semantics

### Repository layer
Responsibilities:
- SQL
- result mapping
- persistence access
- IRIS-specific optimization

### Load/build layer
Responsibilities:
- loading source files
- staging / normalization
- derived table generation
- release/version tracking

## SQL conventions

- Put SQL access in repository classes only
- Prefer explicit methods per use case
- Comment non-trivial joins
- Document what each query returns
- Document expected indexes or performance assumptions
- Keep one query per clear business purpose

Examples of acceptable repository methods:
- `GetConceptByCode`
- `GetPreferredTermsByConcept`
- `GetChildren`
- `GetAncestors`
- `GetDescendants`
- `CodeExistsAndActive`
- `SearchDescriptions`

## FHIR conventions

- FHIR classes must use common terminology service contracts
- FHIR endpoint code must not directly read SNOMED tables
- FHIR naming should align with operation names:
  - `$lookup`
  - `$validate-code`
  - `$subsumes`
  - `$expand`
  - `$translate`
- custom FHIR operation classes should inherit from `HS.FHIRServer.API.OperationHandler`
- custom IRIS FHIR operations should be implemented in operation-specific classes such as `Terminology.Fhir.Operations.LookupOperation`
- `Terminology.Fhir.Operations.TerminologyOperations` should act as the aggregator class wired into `OperationHandlerClass`
- follow the InterSystems custom operation extension chain pattern:
  - each operation-specific class owns a single FHIR operation where practical
  - each operation-specific class owns its FHIR dispatch methods and helper methods
  - the aggregator class wires the operation classes together and normalizes hyphenated operation names for dispatch when needed

## Documentation conventions

When Codex creates or updates code, also update the relevant docs:
- architecture changes -> `ARCHITECTURE.md`
- scope changes -> `FHIR_SCOPE.md`
- roadmap changes -> `ROADMAP.md`
- unresolved design issues -> `docs/open-questions.md`

## Repository organization conventions

- store manual `.http` request files used for developer API checks under `docs/http/`
- keep request files grouped by API/domain with stable descriptive names such as `snomed.http` and `fhir-snomed.http`
- keep these files out of the repository root and out of `iris/src/` because they are developer support assets, not runtime code
- add a short `README.md` in `docs/http/` only when shared setup details such as base URLs, auth or client-specific usage need to be explained

## Testing conventions

For each important capability, aim for:
- 1 happy path
- 1 invalid input case
- 1 not found/inactive case
- 1 language/version-sensitive case where relevant

Priority test areas:
- lookup
- validate-code
- subsumes
- search
- preferred term selection

## Commit conventions

Prefer small commits with clear intent:
- `docs: map current SNOMED query flow`
- `refactor: isolate subsumes SQL in repository`
- `feat: add FHIR lookup service contract`
- `test: add lookup and validate-code cases`

## Instructions for Codex

When asked to change code:
1. read `ARCHITECTURE.md`
2. read `CONVENTIONS.md`
3. read `FHIR_SCOPE.md` if the change touches FHIR
4. avoid broad refactors unless requested
5. explain assumptions in comments or docs
6. preserve current working SNOMED behavior unless explicitly changing it
