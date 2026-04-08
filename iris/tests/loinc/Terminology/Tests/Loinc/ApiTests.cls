/// Covers the deployed native /terminology/loinc HTTP surface.
Class Terminology.Tests.Loinc.ApiTests Extends Terminology.Tests.Loinc.TestBase
{

/// Verifies native search, code lookup, displays and parts responses over HTTP.
Method TestSearchLookupDisplaysAndParts() As %Status
{
    Set params = $LB("releaseId", ..#FixtureReleaseId, "q", "hemoglobina", "lang", "es", "limit", 20, "offset", 0)
    Set tSC = ..InvokeApi("Search", "", "", params, .searchResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "Search API invocation returns OK")
    Do ..AssertEqualsViaMacro("", searchResponse.%Get("Count"), 2, "Search endpoint returns both synthetic hemoglobin displays")
    Set searchItem = ..GetArrayItem(searchResponse, "Items", 0)
    Do ..AssertEqualsViaMacro("", searchItem.%Get("LoincNum"), ..#ParentCode, "Search endpoint returns the parent code first")
    Do ..AssertEqualsViaMacro("", searchItem.%Get("Display"), "Hemoglobina en sangre", "Search endpoint returns the Spanish display")

    Set params = $LB("releaseId", ..#FixtureReleaseId)
    Set tSC = ..InvokeApi("GetCode", ..#ParentCode, "", params, .codeResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "GetCode API invocation returns OK")
    Do ..AssertEqualsViaMacro("", codeResponse.%Get("LoincNum"), ..#ParentCode, "GetCode returns the requested LOINC number")
    Do ..AssertEqualsViaMacro("", codeResponse.%Get("DisplayName"), "Hemoglobina en sangre", "GetCode returns the display name")
    Do ..AssertEqualsViaMacro("", codeResponse.%Get("Status"), "ACTIVE", "GetCode returns the active status")

    Set params = $LB("releaseId", ..#FixtureReleaseId, "lang", "es", "limit", 100, "offset", 0)
    Set tSC = ..InvokeApi("GetDisplays", ..#ParentCode, "", params, .displayResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "GetDisplays API invocation returns OK")
    Do ..AssertEqualsViaMacro("", displayResponse.%Get("Count"), 2, "GetDisplays returns both localized displays")
    Set displayItem = ..GetArrayItem(displayResponse, "Items", 0)
    Do ..AssertEqualsViaMacro("", displayItem.%Get("DisplayType"), "LONG_COMMON_NAME", "GetDisplays orders by rank")
    Do ..AssertEqualsViaMacro("", displayItem.%Get("Display"), "Hemoglobina en sangre", "GetDisplays returns the preferred display text")

    Set params = $LB("releaseId", ..#FixtureReleaseId, "limit", 200, "offset", 0)
    Set tSC = ..InvokeApi("GetParts", ..#ParentCode, "", params, .partResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "GetParts API invocation returns OK")
    Do ..AssertEqualsViaMacro("", partResponse.%Get("Count"), 1, "GetParts returns the linked synthetic part")
    Set partItem = ..GetArrayItem(partResponse, "Items", 0)
    Do ..AssertEqualsViaMacro("", partItem.%Get("PartNumber"), ..#PartNumber, "GetParts returns the expected part number")
    Do ..AssertEqualsViaMacro("", partItem.%Get("PartDisplayName"), "Hemoglobina", "GetParts resolves the part display name")
    Return $$$OK
}

/// Verifies native closure, group and member responses over HTTP.
Method TestHierarchyAndGroupsEndpoints() As %Status
{
    Set params = $LB("releaseId", ..#FixtureReleaseId, "hierarchyType", ..#HierarchyType, "maxDepth", 10, "limit", 100, "offset", 0)
    Set tSC = ..InvokeApi("GetAncestors", ..#ChildCode, "", params, .ancestorsResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "GetAncestors API invocation returns OK")
    Do ..AssertTrueViaMacro("", (ancestorsResponse.%Get("Count") > 0), "GetAncestors returns at least one closure row")
    Set ancestorParent = ..FindArrayItemByProperty(ancestorsResponse, "Items", "AncestorCode", ..#ParentCode)
    Do ..AssertNotEqualsViaMacro("", ancestorParent, "", "GetAncestors includes the synthetic parent")

    Set tSC = ..InvokeApi("GetDescendants", ..#ParentCode, "", params, .descendantsResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "GetDescendants API invocation returns OK")
    Do ..AssertTrueViaMacro("", (descendantsResponse.%Get("Count") > 0), "GetDescendants returns at least one closure row")
    Set descendantChild = ..FindArrayItemByProperty(descendantsResponse, "Items", "DescendantCode", ..#ChildCode)
    Do ..AssertNotEqualsViaMacro("", descendantChild, "", "GetDescendants includes the synthetic child")

    Set params = $LB("releaseId", ..#FixtureReleaseId, "limit", 100, "offset", 0)
    Set tSC = ..InvokeApi("GetGroups", "", "", params, .groupsResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "GetGroups API invocation returns OK")
    Do ..AssertEqualsViaMacro("", groupsResponse.%Get("Count"), 1, "GetGroups returns the synthetic group")
    Set groupItem = ..GetArrayItem(groupsResponse, "Items", 0)
    Do ..AssertEqualsViaMacro("", groupItem.%Get("GroupId"), ..#GroupId, "GetGroups returns the example group id")
    Do ..AssertEqualsViaMacro("", groupItem.%Get("GroupName"), "Grupo de hemoglobina", "GetGroups returns the example group name")

    Set params = $LB("releaseId", ..#FixtureReleaseId, "lang", "es", "limit", 100, "offset", 0)
    Set tSC = ..InvokeApi("GetGroupMembers", ..#GroupId, "", params, .membersResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "GetGroupMembers API invocation returns OK")
    Do ..AssertEqualsViaMacro("", membersResponse.%Get("Count"), 2, "GetGroupMembers returns one row per matching Spanish display")
    Set memberItem = ..FindArrayItemByProperty(membersResponse, "Items", "DisplayType", "LONG_COMMON_NAME")
    Do ..AssertNotEqualsViaMacro("", memberItem, "", "GetGroupMembers includes the long common name row")
    Do ..AssertEqualsViaMacro("", memberItem.%Get("LoincNum"), ..#ParentCode, "GetGroupMembers returns the referenced LOINC number")
    Do ..AssertEqualsViaMacro("", memberItem.%Get("Display"), "Hemoglobina en sangre", "GetGroupMembers resolves the Spanish long common name")
    Return $$$OK
}

/// Returns the first array item whose property matches the requested value.
Method FindArrayItemByProperty(pObject As %DynamicObject, pProperty As %String, pFieldName As %String, pExpectedValue As %String) As %DynamicObject
{
    Set array = pObject.%Get(pProperty)
    If '$IsObject(array) {
        Return ""
    }

    For index=0:1:(array.%Size()-1) {
        Set item = array.%Get(index)
        If $IsObject(item) && (item.%Get(pFieldName) = pExpectedValue) {
            Return item
        }
    }

    Return ""
}

/// Verifies native validate-code semantics for active, inactive and missing codes.
Method TestValidateCodeEndpoint() As %Status
{
    Set params = $LB("releaseId", ..#FixtureReleaseId, "code", ..#ParentCode)
    Set tSC = ..InvokeApi("ValidateCode", "", "", params, .activeResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "ValidateCode API invocation returns OK for active code")
    Do ..AssertEqualsViaMacro("", activeResponse.%Get("Exists"), 1, "Active code exists at the API")
    Do ..AssertEqualsViaMacro("", activeResponse.%Get("Active"), 1, "Active code is marked active")
    Do ..AssertEqualsViaMacro("", activeResponse.%Get("Status"), "ACTIVE", "Active code exposes its source status")

    Set params = $LB("releaseId", ..#FixtureReleaseId, "code", ..#InactiveCode)
    Set tSC = ..InvokeApi("ValidateCode", "", "", params, .inactiveResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "ValidateCode API invocation returns OK for inactive code")
    Do ..AssertEqualsViaMacro("", inactiveResponse.%Get("Exists"), 1, "Inactive code still exists at the API")
    Do ..AssertEqualsViaMacro("", inactiveResponse.%Get("Active"), 0, "Inactive code is not active")
    Do ..AssertEqualsViaMacro("", inactiveResponse.%Get("Status"), "DEPRECATED", "Inactive code exposes its source status")

    Set params = $LB("releaseId", ..#FixtureReleaseId, "code", "9999-9")
    Set tSC = ..InvokeApi("ValidateCode", "", "", params, .missingResponse, .httpStatus)
    Do ..AssertStatusOKViaMacro("", tSC, "ValidateCode API invocation returns OK for missing code")
    Do ..AssertEqualsViaMacro("", missingResponse.%Get("Exists"), 0, "Missing code does not exist at the API")
    Do ..AssertEqualsViaMacro("", missingResponse.%Get("Active"), 0, "Missing code is not active")
    Return $$$OK
}

}
