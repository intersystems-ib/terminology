# UI

<<<<<<< ours
Frontend MVP for the terminology demo application.

## Local Development

1. Start the IRIS stack from the repo root:
=======
Frontend MVP for the terminology demo application in this repository.

This UI is intended to support partner and customer demos around the terminology server built on InterSystems IRIS for Health.
It presents the repository as a practical example of a multi-terminology server with:

- SNOMED CT
- LOINC
- ICD
- native terminology APIs
- a shared FHIR R4 terminology layer

## What Is Implemented

Current screens:

- login screen using Basic auth against the IRIS terminology server
- home screen with terminology cards
- SNOMED CT workspace
- LOINC workspace
- ICD workspace

Current workspace behavior:

- native and FHIR mode switch
- operation, result and technical view sections
- collapsible sections
- live request execution against the local IRIS server
- raw request and response inspection

## How To Run It In Dev Mode

### 1. Start IRIS

From the repository root:
>>>>>>> theirs

```bash
docker compose up -d
```

<<<<<<< ours
2. Install dependencies:

```bash
npm install
```

3. Start the UI:

```bash
npm run dev
```

The app runs at `http://localhost:5173`.
Use the IRIS server URL `http://localhost:52774` on the login screen by default.
=======
This starts the IRIS-based terminology server used by the UI.

### 2. Start The UI Dev Server

From `ui/`:

```bash
npm install
npm run dev
```

The UI runs at:

```text
http://localhost:5173
```

In dev mode the app is served from `/`.

## How To Log In

The login screen expects the IRIS terminology server URL and a valid IRIS username and password.

Default local server URL:

```text
http://localhost:52774
```

The UI validates credentials through:

```text
GET /terminology/auth/login
```

and then reuses the same Basic auth credentials for later API requests.

Example local credentials:

- username: `superuser`
- password: `SYS`

## Build

### Default Build

To produce a production build for a root-mounted deployment:

```bash
npm run build
```

### Build Output

The generated files are written to:

```text
ui/dist/
```
