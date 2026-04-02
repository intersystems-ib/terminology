/// Covers the deployed /terminology/fhir/r4 HTTP surface with the synthetic SNOMED fixture.
Class Terminology.Tests.Fhir.R4.ApiTests Extends Terminology.Tests.Fhir.R4.TestBase
{

/// Verifies metadata and CodeSystem read behavior over HTTP.
Method TestMetadataAndCodeSystemRead() As %Status
{
    Set tSC = ..InvokeFhirApi("/metadata", .metadataResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR metadata invocation returns OK")
    Do ..AssertEqualsViaMacro("", metadataResponse.%Get("resourceType"), "CapabilityStatement", "Metadata returns a CapabilityStatement")

    Set tSC = ..InvokeFhirApi("/CodeSystem/snomed", .codeSystemResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem read invocation returns OK")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("resourceType"), "CodeSystem", "CodeSystem read returns a CodeSystem resource")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("id"), "snomed", "CodeSystem read returns the SNOMED logical id")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("url"), "http://snomed.info/sct", "CodeSystem read returns the SNOMED canonical url")
    Return $$$OK
}

/// Verifies CodeSystem search by canonical url and name.
Method TestCodeSystemSearchFilters() As %Status
{
    Set tSC = ..InvokeFhirApi("/CodeSystem?url=http://snomed.info/sct", .searchByUrlResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem search by url invocation returns OK")
    Do ..AssertEqualsViaMacro("", searchByUrlResponse.%Get("resourceType"), "Bundle", "CodeSystem search by url returns a Bundle")
    Do ..AssertEqualsViaMacro("", searchByUrlResponse.%Get("total"), 1, "CodeSystem search by url returns one resource")
    Set entry = searchByUrlResponse.%Get("entry")
    Set firstMatch = entry.%Get(0).%Get("resource")
    Do ..AssertEqualsViaMacro("", firstMatch.%Get("resourceType"), "CodeSystem", "CodeSystem search by url returns a CodeSystem")
    Do ..AssertEqualsViaMacro("", firstMatch.%Get("id"), "snomed", "CodeSystem search by url returns the SNOMED logical id")
    Do ..AssertEqualsViaMacro("", firstMatch.%Get("url"), "http://snomed.info/sct", "CodeSystem search by url returns the SNOMED canonical url")

    Set tSC = ..InvokeFhirApi("/CodeSystem?name=SNOMEDCT", .searchByNameResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem search by name invocation returns OK")
    Do ..AssertEqualsViaMacro("", searchByNameResponse.%Get("resourceType"), "Bundle", "CodeSystem search by name returns a Bundle")
    Do ..AssertEqualsViaMacro("", searchByNameResponse.%Get("total"), 1, "CodeSystem search by name returns one resource")
    Set entry = searchByNameResponse.%Get("entry")
    Set firstMatch = entry.%Get(0).%Get("resource")
    Do ..AssertEqualsViaMacro("", firstMatch.%Get("resourceType"), "CodeSystem", "CodeSystem search by name returns a CodeSystem")
    Do ..AssertEqualsViaMacro("", firstMatch.%Get("id"), "snomed", "CodeSystem search by name returns the SNOMED logical id")
    Do ..AssertEqualsViaMacro("", firstMatch.%Get("url"), "http://snomed.info/sct", "CodeSystem search by name returns the SNOMED canonical url")
    Return $$$OK
}

/// Verifies CodeSystem lookup, validate-code and subsumes operations over HTTP.
Method TestCodeSystemOperations() As %Status
{
    Set path = "/CodeSystem/$lookup?system=http://snomed.info/sct&version="_..UrlEncode(..#FixtureReleaseId)_"&code="_..#ChildConceptId_"&displayLanguage=es"
    Set tSC = ..InvokeFhirApi(path, .lookupResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR lookup invocation returns OK")
    Do ..AssertEqualsViaMacro("", lookupResponse.%Get("resourceType"), "Parameters", "Lookup returns Parameters")
    Set displayParameter = ..GetNamedParameter(lookupResponse, "display")
    Do ..AssertEqualsViaMacro("", displayParameter.%Get("valueString"), "Concepto hijo sintetico", "Lookup returns the preferred term")

    Set path = "/CodeSystem/$validate-code?system=http://snomed.info/sct&version="_..UrlEncode(..#FixtureReleaseId)_"&code="_..#ChildConceptId
    Set tSC = ..InvokeFhirApi(path, .validateResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR validate-code invocation returns OK")
    Set resultParameter = ..GetNamedParameter(validateResponse, "result")
    Do ..AssertEqualsViaMacro("", resultParameter.%Get("valueBoolean"), 1, "Validate-code returns true for the active concept")

    Set path = "/CodeSystem/$subsumes?system=http://snomed.info/sct&version="_..UrlEncode(..#FixtureReleaseId)_"&codeA="_..#ParentConceptId_"&codeB="_..#ChildConceptId
    Set tSC = ..InvokeFhirApi(path, .subsumesResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR subsumes invocation returns OK")
    Set outcomeParameter = ..GetNamedParameter(subsumesResponse, "outcome")
    Do ..AssertEqualsViaMacro("", outcomeParameter.%Get("valueString"), "subsumes", "Subsumes returns the expected relationship")
    Return $$$OK
}

/// Verifies ValueSet read and expand behavior over HTTP.
Method TestValueSetReadAndExpand() As %Status
{
    Set tSC = ..InvokeFhirApi("/ValueSet/"_..#RefsetId, .valueSetResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet read invocation returns OK")
    Do ..AssertEqualsViaMacro("", valueSetResponse.%Get("resourceType"), "ValueSet", "ValueSet read returns a ValueSet resource")
    Do ..AssertEqualsViaMacro("", valueSetResponse.%Get("id"), ..#RefsetId, "ValueSet read returns the synthetic refset id")

    Set path = "/ValueSet/"_..#RefsetId_"/$expand?version="_..UrlEncode(..#FixtureReleaseId)_"&displayLanguage=es&count=10&offset=0"
    Set tSC = ..InvokeFhirApi(path, .expandResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR expand invocation returns OK")
    Do ..AssertEqualsViaMacro("", expandResponse.%Get("resourceType"), "ValueSet", "Expand returns a ValueSet resource")
    Set expansion = expandResponse.%Get("expansion")
    Do ..AssertEqualsViaMacro("", expansion.%Get("total"), 1, "Expand returns one active member for the fixture version")
    Set contains = expansion.%Get("contains")
    Set firstMember = contains.%Get(0)
    Do ..AssertEqualsViaMacro("", firstMember.%Get("code"), ..#ChildConceptId, "Expand returns the referenced concept code")
    Do ..AssertEqualsViaMacro("", firstMember.%Get("display"), "Concepto hijo sintetico", "Expand returns the preferred term")
    Return $$$OK
}

}
