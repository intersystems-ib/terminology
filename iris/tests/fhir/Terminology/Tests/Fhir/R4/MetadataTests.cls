/// Covers FHIR metadata and cross-terminology discovery behavior.
Class Terminology.Tests.Fhir.R4.MetadataTests Extends Terminology.Tests.Fhir.R4.TestBase
{

/// Verifies metadata and unfiltered CodeSystem search expose both SNOMED and LOINC.
Method TestMetadataAndCodeSystemDiscovery() As %Status
{
    Set tSC = ..InvokeFhirApi("/metadata", .metadataResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR metadata invocation returns OK")
    Do ..AssertEqualsViaMacro("", metadataResponse.%Get("resourceType"), "CapabilityStatement", "Metadata returns a CapabilityStatement")

    Set tSC = ..InvokeFhirApi("/CodeSystem", .searchResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem search invocation returns OK")
    Do ..AssertEqualsViaMacro("", searchResponse.%Get("resourceType"), "Bundle", "CodeSystem search returns a Bundle")

    Set snomedResource = ..FindBundleEntryResourceByProperty(searchResponse, "id", "snomed")
    Do ..AssertNotEqualsViaMacro("", snomedResource, "", "CodeSystem search includes SNOMED")
    Do ..AssertEqualsViaMacro("", snomedResource.%Get("url"), "http://snomed.info/sct", "SNOMED entry exposes the canonical url")

    Set loincResource = ..FindBundleEntryResourceByProperty(searchResponse, "id", "loinc")
    Do ..AssertNotEqualsViaMacro("", loincResource, "", "CodeSystem search includes LOINC")
    Do ..AssertEqualsViaMacro("", loincResource.%Get("url"), "http://loinc.org", "LOINC entry exposes the canonical url")
    Return $$$OK
}

}
