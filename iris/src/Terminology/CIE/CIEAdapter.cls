Class Terminology.CIE.CIEAdapter Extends %RegisteredObject
{

Method SearchConcepts(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pQuery As %String = "", pLimit As %Integer = 20, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.SearchResult) As %Status
{
    Return ..GetRepository().SearchConcepts(pReleaseId, pVersion, pCodeType, pQuery, pLimit, pOffset, .pResult)
}

Method LookupCode(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", Output pResult As Terminology.CIE.DTO.CodeResult) As %Status
{
    Return ..GetRepository().GetCodeByCode(pReleaseId, pVersion, pCodeType, pCode, .pResult)
}

Method GetChildren(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.HierarchyResult) As %Status
{
    Return ..GetRepository().GetChildren(pReleaseId, pVersion, pCodeType, pCode, pLimit, pOffset, .pResult)
}

Method GetAncestors(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pIncludeSelf As %Boolean = 0, pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.HierarchyResult) As %Status
{
    Return ..GetRepository().GetAncestors(pReleaseId, pVersion, pCodeType, pCode, pIncludeSelf, pMaxDepth, pLimit, pOffset, .pResult)
}

Method GetDescendants(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pIncludeSelf As %Boolean = 0, pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.HierarchyResult) As %Status
{
    Return ..GetRepository().GetDescendants(pReleaseId, pVersion, pCodeType, pCode, pIncludeSelf, pMaxDepth, pLimit, pOffset, .pResult)
}

Method GetFamilies(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.FamilyResult) As %Status
{
    Return ..GetRepository().GetFamilies(pReleaseId, pVersion, pCodeType, pLimit, pOffset, .pResult)
}

Method ValidateCode(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", Output pResult As Terminology.CIE.DTO.ValidateCodeResult) As %Status
{
    Return ..GetRepository().ValidateCode(pReleaseId, pVersion, pCodeType, pCode, .pResult)
}

Method GetRepository() As Terminology.CIE.CIERepository [ Private ]
{
    Quit ##class(Terminology.CIE.CIERepository).%New()
}

}
