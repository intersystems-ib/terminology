Class Terminology.Loinc.LoincAdapter Extends %RegisteredObject
{

/// Implements the common concept search contract for LOINC.
Method SearchConcepts(pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "", pQuery As %String = "", pLimit As %Integer = 20, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.SearchResult) As %Status
{
    Return ..GetRepository().SearchConcepts(pReleaseId, pLang, pQuery, pLimit, pOffset, .pResult)
}

/// Implements the common lookup contract using the LOINC code query.
Method LookupCode(pCode As %String = "", pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "", Output pResult As Terminology.Loinc.DTO.CodeResult) As %Status
{
    Quit pDialect  // dialect not used for now
    Return ..GetRepository().GetCodeByCode(pCode, pReleaseId, .pResult)
}

/// LOINC-native display retrieval.
Method GetDisplays(pCode As %String = "", pReleaseId As %String = "", pLang As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.DisplayResult) As %Status
{
    Return ..GetRepository().GetDisplays(pCode, pReleaseId, pLang, pLimit, pOffset, .pResult)
}

/// LOINC-native part retrieval.
Method GetParts(pCode As %String = "", pReleaseId As %String = "", pLimit As %Integer = 200, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.PartResult) As %Status
{
    Return ..GetRepository().GetParts(pCode, pReleaseId, pLimit, pOffset, .pResult)
}

/// LOINC-native hierarchy navigation.
Method GetAncestors(pCode As %String = "", pReleaseId As %String = "", pHierarchyType As %String = "", pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.ClosureResult) As %Status
{
    Return ..GetRepository().GetAncestors(pCode, pReleaseId, pHierarchyType, pMaxDepth, pLimit, pOffset, .pResult)
}

/// LOINC-native hierarchy navigation.
Method GetDescendants(pCode As %String = "", pReleaseId As %String = "", pHierarchyType As %String = "", pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.ClosureResult) As %Status
{
    Return ..GetRepository().GetDescendants(pCode, pReleaseId, pHierarchyType, pMaxDepth, pLimit, pOffset, .pResult)
}

/// LOINC-native group listing.
Method GetGroups(pReleaseId As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.GroupResult) As %Status
{
    Return ..GetRepository().GetGroups(pReleaseId, pLimit, pOffset, .pResult)
}

/// LOINC-native group member retrieval.
Method GetGroupMembers(pGroupId As %String = "", pReleaseId As %String = "", pLang As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.GroupMemberResult) As %Status
{
    Return ..GetRepository().GetGroupMembers(pGroupId, pReleaseId, pLang, pLimit, pOffset, .pResult)
}

/// Implements the common validate-code contract for LOINC.
Method ValidateCode(pReleaseId As %String = "", pCode As %String = "", Output pResult As Terminology.Loinc.DTO.ValidateCodeResult) As %Status
{
    Return ..GetRepository().ValidateCode(pReleaseId, pCode, .pResult)
}

Method GetRepository() As Terminology.Loinc.LoincRepository [ Private ]
{
    Quit ##class(Terminology.Loinc.LoincRepository).%New()
}

}
