# Open Questions

- SNOMED load pipeline:
  Consider moving away from direct Interoperability / BP orchestration.
  Alternative: expose a REST API that starts a load, returns a job id, and lets clients query progress/status later.

- FHIR:
  Implement `TerminologyCapabilities`.

- SNOMED metadata follow-up:
  metadata tables are now populated during load:
  `Terminology.Core.CodeSystem`, `Terminology.Core.VersionRelease`, `Terminology.Core.LicenseNotice`.
  remaining decisions:
  keep one runtime `ReleaseId` for composed INT+ES snapshots vs split runtime partitions.
  derive edition SCTID automatically from loaded package/module metadata to build standards-based `VersionUri`.
  decide whether `LicenseNotice` should be system-level only or version-specific.

- LOINC follow-up:
  the first native LOINC slice is now present, with developer examples in
  `docs/http/loinc-native.http` and `docs/sql/loinc-query-examples.md`.
  Remaining directions to consider:
  add LOINC-focused tests.
  extend basic FHIR support over the shared terminology contract.
  review `Terminology.Core` and remove or isolate remaining SNOMED-specific assumptions.
  decide how much hierarchy/navigation should be exposed beyond the current closure-based endpoints.
