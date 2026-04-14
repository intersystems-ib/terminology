export type TerminologyDefinition = {
  id: "snomed" | "loinc" | "icd";
  name: string;
  subtitle: string;
  releaseLabel: string;
  apiSupportLabel: string;
  actions: string[];
  route: string;
};

export const DEFAULT_SERVER_URL =
  import.meta.env.VITE_API_BASE_URL ?? "http://localhost:52774";

export const TERMINOLOGIES: TerminologyDefinition[] = [
  {
    id: "snomed",
    name: "SNOMED CT",
    subtitle: "Clinical concepts, hierarchy navigation, refsets and FHIR terminology operations.",
    releaseLabel: "SNOMED CT version 20260101",
    apiSupportLabel: "FHIR + Native",
    actions: ["Search", "Lookup", "Hierarchy", "Validate", "FHIR"],
    route: "/terminologies/snomed"
  },
  {
    id: "loinc",
    name: "LOINC",
    subtitle: "Lab and clinical terminology with parts, hierarchy exploration and ValueSet demos.",
    releaseLabel: "LOINC 2.82",
    apiSupportLabel: "FHIR + Native",
    actions: ["Search", "Lookup", "Parts", "Validate", "FHIR"],
    route: "/terminologies/loinc"
  },
  {
    id: "icd",
    name: "ICD",
    subtitle: "Diagnosis and procedure code navigation, validation and family-backed ValueSets.",
    releaseLabel: "ICD-10-ES 2026",
    apiSupportLabel: "FHIR + Native",
    actions: ["Search", "Lookup", "Hierarchy", "Validate", "FHIR"],
    route: "/terminologies/icd"
  }
];
