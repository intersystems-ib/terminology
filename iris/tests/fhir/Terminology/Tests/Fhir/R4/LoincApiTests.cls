/// Covers the deployed /terminology/fhir/r4 HTTP surface over the synthetic LOINC fixture.
Class Terminology.Tests.Fhir.R4.LoincApiTests Extends Terminology.Tests.Fhir.R4.LoincTestBase
{

/// Verifies LOINC CodeSystem read and search filters over HTTP.
Method TestCodeSystemReadAndSearchFilters() As %Status
{
    Set tSC = ..InvokeFhirApi("/CodeSystem/loinc", .codeSystemResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem read invocation returns OK")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("resourceType"), "CodeSystem", "CodeSystem read returns a CodeSystem resource")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("id"), "loinc", "CodeSystem read returns the LOINC logical id")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("url"), "http://loinc.org", "CodeSystem read returns the LOINC canonical url")

    Set tSC = ..InvokeFhirApi("/CodeSystem?url=http://loinc.org", .searchByUrlResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem search by url invocation returns OK")
    Set firstMatch = ..FindBundleEntryResourceByProperty(searchByUrlResponse, "id", "loinc")
    Do ..AssertNotEqualsViaMacro("", firstMatch, "", "CodeSystem search by url returns LOINC")
    Do ..AssertEqualsViaMacro("", firstMatch.%Get("url"), "http://loinc.org", "CodeSystem search by url returns the LOINC canonical url")

    Set tSC = ..InvokeFhirApi("/CodeSystem?name=LOINC", .searchByNameResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem search by name invocation returns OK")
    Set firstMatch = ..FindBundleEntryResourceByProperty(searchByNameResponse, "id", "loinc")
    Do ..AssertNotEqualsViaMacro("", firstMatch, "", "CodeSystem search by name returns LOINC")
    Return $$$OK
}

/// Verifies LOINC CodeSystem lookup, validate-code and subsumes operations over HTTP.
Method TestCodeSystemOperations() As %Status
{
    Set path = "/CodeSystem/$lookup?system=http://loinc.org&version="_..UrlEncode(..#FixtureReleaseId)_"&code="_..#ParentCode_"&displayLanguage=es"
    Set tSC = ..InvokeFhirApi(path, .lookupResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR lookup invocation returns OK")
    Do ..AssertEqualsViaMacro("", lookupResponse.%Get("resourceType"), "Parameters", "Lookup returns Parameters")
    Set codeParameter = ..GetNamedParameter(lookupResponse, "code")
    Do ..AssertEqualsViaMacro("", codeParameter.%Get("valueString"), ..#ParentCode, "Lookup returns the requested LOINC number")
    Set displayParameter = ..GetNamedParameter(lookupResponse, "display")
    Do ..AssertEqualsViaMacro("", displayParameter.%Get("valueString"), "Hemoglobina en sangre", "Lookup returns the long common name")

    Set path = "/CodeSystem/$validate-code?system=http://loinc.org&version="_..UrlEncode(..#FixtureReleaseId)_"&code="_..#ParentCode
    Set tSC = ..InvokeFhirApi(path, .validateResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR validate-code invocation returns OK")
    Set resultParameter = ..GetNamedParameter(validateResponse, "result")
    Do ..AssertEqualsViaMacro("", resultParameter.%Get("valueBoolean"), 1, "Validate-code returns true for the active LOINC code")

    Set path = "/CodeSystem/$validate-code?system=http://loinc.org&version="_..UrlEncode(..#FixtureReleaseId)_"&code=9999999999-INVALID"
    Set tSC = ..InvokeFhirApi(path, .invalidValidateResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR validate-code invalid invocation returns OK")
    Set resultParameter = ..GetNamedParameter(invalidValidateResponse, "result")
    Do ..AssertEqualsViaMacro("", resultParameter.%Get("valueBoolean"), 0, "Validate-code returns false for a missing LOINC code")

    Set path = "/CodeSystem/$subsumes?system=http://loinc.org&version="_..UrlEncode(..#FixtureReleaseId)_"&codeA="_..#ParentCode_"&codeB="_..#ChildCode
    Set tSC = ..InvokeFhirApi(path, .subsumesResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR subsumes invocation returns OK")
    Set outcomeParameter = ..GetNamedParameter(subsumesResponse, "outcome")
    Do ..AssertEqualsViaMacro("", outcomeParameter.%Get("valueString"), "subsumes", "Subsumes returns the expected LOINC relationship")
    Return $$$OK
}

/// Verifies LOINC ValueSet read, search and expand behavior over HTTP.
Method TestValueSetReadSearchAndExpand() As %Status
{
    Set valueSetId = "loinc-group-"_..#GroupId
    Set valueSetUrl = "http://loinc.org/vs/"_..#GroupId

    Set tSC = ..InvokeFhirApi("/ValueSet/"_valueSetId, .valueSetResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet read invocation returns OK")
    Do ..AssertEqualsViaMacro("", valueSetResponse.%Get("resourceType"), "ValueSet", "ValueSet read returns a ValueSet resource")
    Do ..AssertEqualsViaMacro("", valueSetResponse.%Get("id"), valueSetId, "ValueSet read returns the synthetic LOINC group id")
    Do ..AssertEqualsViaMacro("", valueSetResponse.%Get("url"), valueSetUrl, "ValueSet read returns the LOINC canonical url")

    Set tSC = ..InvokeFhirApi("/ValueSet?_id="_valueSetId, .searchByIdResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet search by id invocation returns OK")
    Set valueSetMatch = ..FindBundleEntryResourceByProperty(searchByIdResponse, "id", valueSetId)
    Do ..AssertNotEqualsViaMacro("", valueSetMatch, "", "ValueSet search by id returns the LOINC group")

    Set tSC = ..InvokeFhirApi("/ValueSet?url="_..UrlEncode(valueSetUrl), .searchByUrlResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet search by url invocation returns OK")
    Set valueSetMatch = ..FindBundleEntryResourceByProperty(searchByUrlResponse, "url", valueSetUrl)
    Do ..AssertNotEqualsViaMacro("", valueSetMatch, "", "ValueSet search by url returns the LOINC group")

    Set tSC = ..InvokeFhirApi("/ValueSet?name=LoincGroup"_..#GroupId, .searchByNameResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet search by name invocation returns OK")
    Set valueSetMatch = ..FindBundleEntryResourceByProperty(searchByNameResponse, "id", valueSetId)
    Do ..AssertNotEqualsViaMacro("", valueSetMatch, "", "ValueSet search by name returns the LOINC group")

    Set path = "/ValueSet/"_valueSetId_"/$expand?version="_..UrlEncode(..#FixtureReleaseId)_"&displayLanguage=es&count=10&offset=0"
    Set tSC = ..InvokeFhirApi(path, .expandByIdResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR expand by id invocation returns OK")
    Set expansion = expandByIdResponse.%Get("expansion")
    Do ..AssertEqualsViaMacro("", expansion.%Get("total"), 1, "Expand by id returns one deduplicated LOINC member")
    Set contains = expansion.%Get("contains")
    Set firstMember = contains.%Get(0)
    Do ..AssertEqualsViaMacro("", firstMember.%Get("code"), ..#ParentCode, "Expand by id returns the expected LOINC code")
    Do ..AssertEqualsViaMacro("", firstMember.%Get("display"), "Hemoglobina en sangre", "Expand by id prefers the long common name")

    Set path = "/ValueSet/$expand?url="_..UrlEncode(valueSetUrl)_"&version="_..UrlEncode(..#FixtureReleaseId)_"&displayLanguage=es&count=10&offset=0"
    Set tSC = ..InvokeFhirApi(path, .expandByUrlResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR expand by url invocation returns OK")
    Set expansion = expandByUrlResponse.%Get("expansion")
    Do ..AssertEqualsViaMacro("", expansion.%Get("total"), 1, "Expand by url returns one deduplicated LOINC member")
    Return $$$OK
}

}
