# UI MVP Sketch

This document describes a simple web UI for demonstrating the terminology server to partners, customers and developers.

The goal is not to build a full production application.
The goal is to create a clean demo UI that makes it easy to show:

- multiple terminologies on one IRIS platform
- native and FHIR APIs over the same underlying server
- common terminology operations such as search, lookup, hierarchy navigation, validate-code, subsumption and ValueSet expansion

## Design Goals

The UI should be:

- fast to build
- visually polished enough for demos
- simple to explain live
- directly mapped to the existing API examples in `docs/http/`

The UI is a demo explorer, not an administration portal.
Avoid user management, ingestion management and advanced configuration in the first version.

## Current UI

The current MVP UI is already implemented under `ui/`.

Today it includes:

- a login screen using Basic auth against the terminology server
- a home screen with cards for `SNOMED CT`, `LOINC` and `ICD`
- a dedicated workspace for each terminology
- a `Native API | FHIR API` switch inside each workspace
- operation, result and technical-view sections
- collapsible workspace sections
- live request execution against the implemented terminology endpoints

The current UI is intended to be run with the Vite dev server during local development.

## Recommended Stack

Recommended frontend stack:

- `Vite`
- `React`
- `TypeScript`
- `Tailwind CSS`
- `shadcn/ui`
- `React Router`
- `TanStack Query`
- `Zod`

### Why This Stack

This stack is recommended because the main goal is to build a polished demo UI quickly and with low implementation risk.

- `Vite` gives a fast development loop and a simple build setup
- `React` gives the lowest-risk ecosystem for UI components, routing and data fetching
- `TypeScript` keeps request and response models explicit
- `Tailwind CSS` makes it fast to build a clean layout without a large custom CSS investment
- `shadcn/ui` gives a modern UI base for cards, tabs, drawers, dialogs, forms and tables
- `React Router` is enough for a small SPA with login, home and terminology workspaces
- `TanStack Query` fits request-heavy screens with caching, loading states and refetching
- `Zod` helps validate API payloads and avoid silent UI failures during demos

### Why This Over `Vite + Preact + TypeScript`

`Vite + Preact + TypeScript` is still a valid option.
It is lighter, but it is not the best default for this MVP.

The recommended stack stays with React because:

- the ecosystem fit is better for a fast, polished app
- `shadcn/ui` and many other UI building blocks are designed for React
- there is less integration risk with routing, query and component libraries
- bundle size is not the main concern for this demo application

For this project, development speed and low-friction integration matter more than saving a small amount of frontend runtime size.

## Repository Placement

For the MVP, the UI should live in this same repository.

This is a good idea because:

- the UI is tightly coupled to the existing terminology demo story
- API and UI changes can be made together
- local setup stays simple
- there is only one repository to explain, clone and run

For the MVP, a separate UI repository would add coordination overhead without enough benefit.

### Recommended Location

Place the UI at the repository root:

```text
ui/
```

Recommended top-level structure:

```text
/docs
/iris
/ui
README.md
docker-compose.yml
```

Recommended UI structure:

```text
ui/
  src/
  public/
  package.json
  tsconfig.json
  vite.config.ts
  .env.local
  README.md
```

Why `ui/` at the root:

- easy to find
- clearly separate from IRIS backend code
- standard structure for a small frontend application
- simple to maintain as the UI grows

## Development Workflow

The MVP development workflow should be simple and fast.

During development:

- IRIS runs through Docker Compose
- the UI runs as a local Vite development server
- the UI calls the IRIS terminology APIs directly using the configured server URL

### Typical Local Workflow

1. start the IRIS stack
2. start the UI dev server
3. open the UI in the browser
4. log in with IRIS credentials
5. use the UI against the local terminology server

### Start IRIS

From the repository root:

```bash
docker compose up -d
```

### Start The UI

From `ui/`:

```bash
npm install
npm run dev
```

Expected local UI URL:

```text
http://localhost:5173
```

Expected local terminology server URL:

```text
http://localhost:52774
```

### Environment Configuration

The UI should use a small environment configuration file.

Example:

```text
VITE_API_BASE_URL=http://localhost:52774
```

This keeps the server location configurable without changing application code.

### Authentication Workflow

For the MVP:

- the user logs in once using IRIS username and password
- the app validates those credentials with a lightweight request
- the app reuses the same Basic auth credentials for all later requests

This is acceptable for a controlled demo application.

Suggested storage approach for the MVP:

- keep credentials in memory during the session
- optionally allow session storage if needed for page refresh convenience

Current implementation detail:

- the UI currently stores the session in `sessionStorage`
- the login validation request currently uses `GET /terminology/auth/login`

### Why Not Serve The UI From IRIS Immediately

For the MVP, do not make UI hosting inside IRIS a requirement.

Keeping the frontend as a Vite app during development is better because:

- frontend iteration is faster
- UI and backend concerns stay cleanly separated
- there is less deployment complexity while the MVP is changing quickly

Later, if needed, the built static assets can be served by IRIS or packaged differently.

## High-Level Flow

The app should follow this path:

1. login to the IRIS terminology server
2. show the available terminologies
3. let the user click one terminology card
4. open a terminology workspace for that terminology
5. let the user switch between native and FHIR execution in the same workspace
6. show both the user-friendly result and the raw request/response

## Screen 1: Login

The first screen should be a simple connection form.

Fields:

- `Server URL`
- `Username`
- `Password`

Example values:

- `Server URL`: `http://localhost:52774`
- `Username`: `superuser`
- `Password`: `SYS`

### Login Behavior

Initial MVP authentication can use Basic authentication against IRIS.

The UI flow should be:

1. user enters server URL, username and password
2. app sends a lightweight verification request using Basic auth
3. if the request succeeds, the app stores the connection info in memory for the session
4. all later requests reuse the same username and password

### Suggested Verification URL

Use a lightweight terminology auth request for login validation:

```text
GET {serverUrl}/terminology/auth/login
Authorization: Basic <base64(username:password)>
Accept: application/json
```

Example:

```text
GET http://localhost:52774/terminology/auth/login
```

This is a good login check because:

- it confirms the terminology server is reachable
- it confirms the credentials are valid
- it keeps the UI login flow separate from the FHIR metadata surface

### UI Route

```text
/login
```

## Screen 2: Home

After successful login, the user lands on the home screen.

### Purpose

This screen should quickly answer:

- which terminologies are available
- which releases are loaded
- what kinds of demos can be shown

### Layout

Top area:

- app title, for example `IRIS Terminology Explorer`
- connected server URL
- signed-in username
- logout button

Main area:

- one card for `SNOMED`
- one card for `LOINC`
- one card for `ICD`

Optional card details:

- terminology name
- short description
- example release/version
- example supported actions

Example action labels on each card:

- `Search`
- `Lookup`
- `Hierarchy`
- `Validate`
- `FHIR`

### UI Route

```text
/
```

or

```text
/home
```

## What Happens When You Click a Terminology Card

Clicking a terminology card should open a dedicated terminology workspace.

Examples:

- click `SNOMED` -> `/terminologies/snomed`
- click `LOINC` -> `/terminologies/loinc`
- click `ICD` -> `/terminologies/icd`

This is the most important navigation step in the app.
The terminology card is not just a link to static information.
It opens a live workspace where users can run demo actions against the server.

## Screen 3: Terminology Workspace

Each terminology should have one main workspace page.

### Core Idea

The user stays inside one terminology screen and can switch between:

- `Native API`
- `FHIR API`

This is better than separating native and FHIR into different applications or major flows.
The demo story is stronger when the user sees:

- same terminology
- same use case
- same platform
- two API surfaces

### Workspace Layout

Header:

- terminology name
- selected release/version
- API mode toggle: `Native | FHIR`

Main content:

- top search or action bar
- left results panel
- right detail panel
- bottom or side raw request/response drawer

### Shared Workspace Tabs

The terminology workspace should expose actions as tabs or segmented controls.

Recommended tabs:

- `Search`
- `Lookup`
- `Hierarchy`
- `Validate`
- `Subsumes`
- `ValueSet`

Not every terminology needs exactly the same behavior in every tab, but the UI structure should stay consistent.

## How the Workspace Should Work After Clicking a Card

### 1. Load Workspace Context

When the user clicks a terminology card, the app should:

1. navigate to the terminology route
2. load default terminology-specific settings
3. select a default API mode
4. load example values so the screen is immediately demoable

Suggested defaults:

- default API mode: `Native`
- default tab: `Search`
- default example release/version based on local configuration

### 2. Show Terminology-Specific Example Inputs

Each terminology workspace should prefill a few known-good values.

Examples:

SNOMED:

- search text: `infarto`
- concept code: `22298006`
- ancestor code: `64572001`

LOINC:

- search text: `hemo`
- code: `718-7`
- ancestor code: `LP392452-1`

ICD:

- search text: `fiebre`
- code: `A01.0`
- ancestor code: `A01`

This matters for demos because it reduces typing and avoids live demo friction.

### 3. Run an Action

The user chooses a tab, adjusts inputs if needed, and clicks something like:

- `Search`
- `Run Lookup`
- `Validate Code`
- `Check Subsumption`
- `Expand ValueSet`

The app then:

1. builds the correct native or FHIR URL
2. sends the request using the stored Basic auth credentials
3. renders a user-friendly result
4. shows the raw request and response in a drawer

### 4. Switch Between Native and FHIR

Inside the same terminology workspace, the user can switch:

- from `Native`
- to `FHIR`

When the mode changes:

- the visible tabs can stay mostly the same
- the request builder changes
- the request URL shown in the drawer changes
- the response renderer can adjust for native JSON vs FHIR JSON

This lets the UI demonstrate the architecture directly.

## URLs

There are two kinds of URLs to specify:

- frontend UI routes
- backend API endpoints

## Frontend UI Routes

Suggested routes:

```text
/login
/home
/terminologies/snomed
/terminologies/loinc
/terminologies/icd
```

Optional deeper routes later:

```text
/terminologies/snomed/search
/terminologies/snomed/lookup
/terminologies/snomed/hierarchy
/terminologies/loinc/search
/terminologies/icd/validate
```

For the MVP, one route per terminology is enough.
Tabs inside the page can control the active action.

## Backend API Base URLs

Assume the server URL entered on login is:

```text
http://localhost:52774
```

Then the backend base URLs are:

Native:

```text
http://localhost:52774/terminology/snomed
http://localhost:52774/terminology/loinc
http://localhost:52774/terminology/icd
```

FHIR:

```text
http://localhost:52774/terminology/fhir/r4
```

## Example URLs by Terminology

These are the types of URLs the UI should build.

### SNOMED Native

Search:

```text
GET /terminology/snomed/search?q=infarto&releaseId=SNOMED%20CT%20version%2020260101&lang=es&dialect=es-ES&limit=20&offset=0
```

Lookup concept:

```text
GET /terminology/snomed/concepts/22298006?releaseId=SNOMED%20CT%20version%2020260101&lang=es&dialect=es-ES
```

Ancestors:

```text
GET /terminology/snomed/concepts/22298006/ancestors?releaseId=SNOMED%20CT%20version%2020260101&view=inferred&includeSelf=0&maxDepth=10&limit=100&offset=0
```

Validate:

```text
GET /terminology/snomed/validate-code?releaseId=SNOMED%20CT%20version%2020260101&code=22298006
```

Subsumes:

```text
GET /terminology/snomed/subsumes/64572001/22298006?releaseId=SNOMED%20CT%20version%2020260101&view=inferred
```

### SNOMED FHIR

Lookup:

```text
GET /terminology/fhir/r4/CodeSystem/$lookup?system=http://snomed.info/sct&code=22298006&displayLanguage=es
```

Validate:

```text
GET /terminology/fhir/r4/CodeSystem/$validate-code?system=http://snomed.info/sct&code=22298006
```

Subsumes:

```text
GET /terminology/fhir/r4/CodeSystem/$subsumes?system=http://snomed.info/sct&codeA=64572001&codeB=22298006
```

ValueSet expand:

```text
GET /terminology/fhir/r4/ValueSet/$expand?url=http://snomed.info/sct?fhir_vs=refset/900000000000497000&displayLanguage=es&count=10&offset=0
```

### LOINC Native

Search:

```text
GET /terminology/loinc/search?q=hemo&releaseId=2.82&lang=es&limit=20&offset=0
```

Lookup:

```text
GET /terminology/loinc/codes/718-7?releaseId=2.82
```

Ancestors:

```text
GET /terminology/loinc/codes/718-7/ancestors?releaseId=2.82&hierarchyType=COMPONENTBYSYSTEM&maxDepth=10&limit=100&offset=0
```

Validate:

```text
GET /terminology/loinc/validate-code?releaseId=2.82&code=718-7
```

### LOINC FHIR

Lookup:

```text
GET /terminology/fhir/r4/CodeSystem/$lookup?system=http://loinc.org&code=718-7&displayLanguage=es
```

Validate:

```text
GET /terminology/fhir/r4/CodeSystem/$validate-code?system=http://loinc.org&code=718-7
```

Subsumes:

```text
GET /terminology/fhir/r4/CodeSystem/$subsumes?system=http://loinc.org&codeA=LP392452-1&codeB=718-7
```

ValueSet expand:

```text
GET /terminology/fhir/r4/ValueSet/$expand?url=http://loinc.org/vs/LG51020-2&displayLanguage=es&count=10&offset=0
```

### ICD Native

Search:

```text
GET /terminology/icd/search?q=fiebre&releaseId=ICD-10-ES%202026&version=10&codeType=DIAGNOSIS&limit=20&offset=0
```

Lookup:

```text
GET /terminology/icd/codes/A01.0?releaseId=ICD-10-ES%202026&version=10&codeType=DIAGNOSIS
```

Ancestors:

```text
GET /terminology/icd/codes/A01.0/ancestors?releaseId=ICD-10-ES%202026&version=10&codeType=DIAGNOSIS&includeSelf=0&maxDepth=10&limit=100&offset=0
```

Validate:

```text
GET /terminology/icd/validate-code?releaseId=ICD-10-ES%202026&version=10&codeType=DIAGNOSIS&code=A01.0
```

### ICD FHIR

Lookup:

```text
GET /terminology/fhir/r4/CodeSystem/$lookup?system=http://id.who.int/icd/release/10&code=A01.0
```

Validate:

```text
GET /terminology/fhir/r4/CodeSystem/$validate-code?system=http://id.who.int/icd/release/10&code=A01.0
```

Subsumes:

```text
GET /terminology/fhir/r4/CodeSystem/$subsumes?system=http://id.who.int/icd/release/10&codeA=A01&codeB=A01.0
```

ValueSet expand:

```text
GET /terminology/fhir/r4/ValueSet/$expand?url=urn:iris:terminology:valueset:icd:family:A00-A09&count=10&offset=0
```

## Per-Terminology Workspace Behavior

The behavior after clicking a card should be predictable.

### SNOMED Workspace

Tabs:

- `Search`
- `Concept`
- `Hierarchy`
- `Validate`
- `Subsumes`
- `Refsets / ValueSets`

Good demo story:

1. search for `infarto`
2. open concept `22298006`
3. inspect ancestors or descendants
4. validate the code
5. switch to FHIR and run `$lookup` or `$subsumes`

### LOINC Workspace

Tabs:

- `Search`
- `Code`
- `Parts`
- `Hierarchy`
- `Validate`
- `ValueSets`

Good demo story:

1. search for `hemo`
2. open code `718-7`
3. inspect parts and hierarchy
4. validate the code
5. switch to FHIR and expand a LOINC group ValueSet

### ICD Workspace

Tabs:

- `Search`
- `Code`
- `Hierarchy`
- `Validate`
- `Subsumes`
- `ValueSets`

Good demo story:

1. search for `fiebre`
2. open `A01.0`
3. inspect ancestors and descendants
4. validate the code
5. switch to FHIR and expand an ICD family ValueSet

## Request and Response Drawer

Every workspace should include a collapsible technical drawer.

It should show:

- full request URL
- HTTP method
- request headers
- active API mode
- response status
- raw JSON response

This is important because the UI is also a conversation aid for discussing implementation on IRIS.

## Suggested MVP Build Order

1. login screen with Basic auth verification
2. home page with terminology cards
3. SNOMED workspace
4. shared request/response drawer
5. LOINC workspace
6. ICD workspace
7. FHIR mode support inside each workspace

This order gives a fast path to a usable demo while keeping the architecture coherent.
