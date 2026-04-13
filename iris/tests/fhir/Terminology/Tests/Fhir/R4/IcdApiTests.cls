/// Covers the deployed /terminology/fhir/r4 HTTP surface over the synthetic ICD fixture.
Class Terminology.Tests.Fhir.R4.IcdApiTests Extends Terminology.Tests.Fhir.R4.IcdTestBase
{

/// Verifies ICD CodeSystem read and search filters over HTTP.
Method TestCodeSystemReadAndSearchFilters() As %Status
{
    Set tSC = ..InvokeFhirApi("/CodeSystem/icd-10", .codeSystemResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem read invocation returns OK")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("resourceType"), "CodeSystem", "CodeSystem read returns a CodeSystem resource")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("id"), "icd-10", "CodeSystem read returns the ICD logical id")
    Do ..AssertEqualsViaMacro("", codeSystemResponse.%Get("url"), ..#CodeSystemUri, "CodeSystem read returns the ICD canonical url")

    Set tSC = ..InvokeFhirApi("/CodeSystem?url="_..UrlEncode(..#CodeSystemUri), .searchByUrlResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem search by url invocation returns OK")
    Set firstMatch = ..FindBundleEntryResourceByProperty(searchByUrlResponse, "id", "icd-10")
    Do ..AssertNotEqualsViaMacro("", firstMatch, "", "CodeSystem search by url returns ICD")

    Set tSC = ..InvokeFhirApi("/CodeSystem?name=ICD10", .searchByNameResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR CodeSystem search by name invocation returns OK")
    Set firstMatch = ..FindBundleEntryResourceByProperty(searchByNameResponse, "id", "icd-10")
    Do ..AssertNotEqualsViaMacro("", firstMatch, "", "CodeSystem search by name returns ICD")
    Return $$$OK
}

/// Verifies ICD CodeSystem lookup, validate-code and subsumes operations over HTTP.
Method TestCodeSystemOperations() As %Status
{
    Set path = "/CodeSystem/$lookup?system="_..UrlEncode(..#CodeSystemUri)_"&version="_..UrlEncode(..#FixtureReleaseId)_"&code="_..#ChildCode
    Set tSC = ..InvokeFhirApi(path, .lookupResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR lookup invocation returns OK")
    Do ..AssertEqualsViaMacro("", lookupResponse.%Get("resourceType"), "Parameters", "Lookup returns Parameters")
    Set codeParameter = ..GetNamedParameter(lookupResponse, "code")
    Do ..AssertEqualsViaMacro("", codeParameter.%Get("valueString"), ..#ChildCode, "Lookup returns the requested ICD code")
    Set displayParameter = ..GetNamedParameter(lookupResponse, "display")
    Do ..AssertEqualsViaMacro("", displayParameter.%Get("valueString"), "Fiebre tifoidea con afectacion pulmonar", "Lookup returns the ICD description")

    Set path = "/CodeSystem/$validate-code?system="_..UrlEncode(..#CodeSystemUri)_"&version="_..UrlEncode(..#FixtureReleaseId)_"&code="_..#ChildCode
    Set tSC = ..InvokeFhirApi(path, .validateResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR validate-code invocation returns OK")
    Set resultParameter = ..GetNamedParameter(validateResponse, "result")
    Do ..AssertEqualsViaMacro("", resultParameter.%Get("valueBoolean"), 1, "Validate-code returns true for the active ICD code")

    Set path = "/CodeSystem/$validate-code?system="_..UrlEncode(..#CodeSystemUri)_"&version="_..UrlEncode(..#FixtureReleaseId)_"&code=INVALID-CODE"
    Set tSC = ..InvokeFhirApi(path, .invalidValidateResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR validate-code invalid invocation returns OK")
    Set resultParameter = ..GetNamedParameter(invalidValidateResponse, "result")
    Do ..AssertEqualsViaMacro("", resultParameter.%Get("valueBoolean"), 0, "Validate-code returns false for a missing ICD code")

    Set path = "/CodeSystem/$subsumes?system="_..UrlEncode(..#CodeSystemUri)_"&version="_..UrlEncode(..#FixtureReleaseId)_"&codeA="_..#ParentCode_"&codeB="_..#ChildCode
    Set tSC = ..InvokeFhirApi(path, .subsumesResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR subsumes invocation returns OK")
    Set outcomeParameter = ..GetNamedParameter(subsumesResponse, "outcome")
    Do ..AssertEqualsViaMacro("", outcomeParameter.%Get("valueString"), "subsumes", "Subsumes returns the expected ICD relationship")
    Return $$$OK
}

/// Verifies ICD family-backed ValueSet read, search and expand behavior over HTTP.
Method TestValueSetReadSearchAndExpand() As %Status
{
    Set valueSetId = "icd-family-"_..#FamilyCode
    Set valueSetUrl = "urn:iris:terminology:valueset:icd:family:"_..#FamilyCode

    Set tSC = ..InvokeFhirApi("/ValueSet/"_valueSetId, .valueSetResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet read invocation returns OK")
    Do ..AssertEqualsViaMacro("", valueSetResponse.%Get("resourceType"), "ValueSet", "ValueSet read returns a ValueSet resource")
    Do ..AssertEqualsViaMacro("", valueSetResponse.%Get("id"), valueSetId, "ValueSet read returns the ICD family id")
    Do ..AssertEqualsViaMacro("", valueSetResponse.%Get("url"), valueSetUrl, "ValueSet read returns the ICD family canonical url")

    Set tSC = ..InvokeFhirApi("/ValueSet?_id="_valueSetId, .searchByIdResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet search by id invocation returns OK")
    Set valueSetMatch = ..FindBundleEntryResourceByProperty(searchByIdResponse, "id", valueSetId)
    Do ..AssertNotEqualsViaMacro("", valueSetMatch, "", "ValueSet search by id returns the ICD family")

    Set tSC = ..InvokeFhirApi("/ValueSet?url="_..UrlEncode(valueSetUrl), .searchByUrlResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet search by url invocation returns OK")
    Set valueSetMatch = ..FindBundleEntryResourceByProperty(searchByUrlResponse, "url", valueSetUrl)
    Do ..AssertNotEqualsViaMacro("", valueSetMatch, "", "ValueSet search by url returns the ICD family")

    Set tSC = ..InvokeFhirApi("/ValueSet?name=ICDFamilyA00A09", .searchByNameResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR ValueSet search by name invocation returns OK")
    Set valueSetMatch = ..FindBundleEntryResourceByProperty(searchByNameResponse, "id", valueSetId)
    Do ..AssertNotEqualsViaMacro("", valueSetMatch, "", "ValueSet search by name returns the ICD family")

    Set path = "/ValueSet/"_valueSetId_"/$expand?version="_..UrlEncode(..#FixtureReleaseId)_"&count=2&offset=1"
    Set tSC = ..InvokeFhirApi(path, .expandByIdResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR expand by id invocation returns OK")
    Set expansion = expandByIdResponse.%Get("expansion")
    Do ..AssertEqualsViaMacro("", expansion.%Get("total"), 4, "Expand by id returns the total ICD family member count")
    Set contains = expansion.%Get("contains")
    Set firstMember = contains.%Get(0)
    Do ..AssertEqualsViaMacro("", firstMember.%Get("code"), ..#ChildCode, "Expand by id paging returns the expected second ICD code")
    Do ..AssertEqualsViaMacro("", firstMember.%Get("display"), "Fiebre tifoidea con afectacion pulmonar", "Expand by id returns the ICD description")

    Set path = "/ValueSet/$expand?url="_..UrlEncode(valueSetUrl)_"&version="_..UrlEncode(..#FixtureReleaseId)_"&count=10&offset=0"
    Set tSC = ..InvokeFhirApi(path, .expandByUrlResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "FHIR expand by url invocation returns OK")
    Set expansion = expandByUrlResponse.%Get("expansion")
    Do ..AssertEqualsViaMacro("", expansion.%Get("total"), 4, "Expand by url returns the total ICD family member count")
    Set contains = expansion.%Get("contains")
    Set firstMember = contains.%Get(0)
    Do ..AssertEqualsViaMacro("", firstMember.%Get("code"), ..#ParentCode, "Expand by url returns the first ICD family member")
    Return $$$OK
}

}
