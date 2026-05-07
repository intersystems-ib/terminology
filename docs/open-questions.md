# Open Questions

- FHIR:
  Implement `TerminologyCapabilities`.

- SNOMED metadata follow-up:
  metadata tables are now populated during load:
  `Terminology.Core.CodeSystem`, `Terminology.Core.VersionRelease`, `Terminology.Core.LicenseNotice`.
  remaining decisions:
  keep one runtime `ReleaseId` for composed INT+ES snapshots vs split runtime partitions.
  derive edition SCTID automatically from loaded package/module metadata to build standards-based `VersionUri`.
  decide whether `LicenseNotice` should be system-level only or version-specific.

- Shared terminology contract follow-up:
  `Terminology.Core.TermService` now routes shared operations across SNOMED, LOINC and ICD.
  remaining decisions:
  decide whether the neutral contract should stay narrow or grow to cover more terminology-specific behavior.
  review remaining terminology-specific assumptions such as LOINC hierarchy defaults and synthetic FHIR ValueSet ids.
  decide whether ICD should remain modeled as the current ICD-10-specific path or be generalized further in the shared layer.

- FHIR follow-up:
  the current FHIR R4 slice now includes `CodeSystem` and `ValueSet` read/search metadata,
  `CodeSystem/$lookup`, `CodeSystem/$validate-code`, `CodeSystem/$subsumes`,
  and `ValueSet/$expand` for SNOMED, LOINC and ICD.
  Remaining directions to consider:
  implement `ConceptMap/$translate`.
  decide whether to broaden the current MVP beyond the existing narrow read/operation surface.

- Load pipeline:
  Consider moving away from direct Interoperability / BP orchestration.
  Alternative: expose a REST API that starts a load, returns a job id, and lets clients query progress/status later.
