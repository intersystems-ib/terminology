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
    // TODO: dialect not used for now
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

/// Applies LOINC subsumption semantics over the closure table.
/// FHIR `CodeSystem/$subsumes` does not carry a hierarchy selector, so LOINC defaults to
/// `COMPONENTBYSYSTEM` until the common contract grows a neutral hierarchy parameter.
Method Subsumes(pReleaseId As %String = "", pView As %String = "", pCodeA As %String = "", pCodeB As %String = "", Output pResult As Terminology.Snomed.DTO.SubsumesResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.SubsumesResult).%New()

    If (pCodeA = "") || (pCodeB = "") {
        Set pResult.Relationship = "not-subsumed"
        Return $$$OK
    }

    If (pCodeA = pCodeB) {
        Set pResult.Relationship = "equivalent"
        Return $$$OK
    }

    Set hierarchyType = $Select(pView'="":pView, 1:"COMPONENTBYSYSTEM")

    Set tSC = ..GetRepository().GetSubsumptionRelation(pReleaseId, hierarchyType, pCodeA, pCodeB, .relationship)
    $$$ThrowOnError(tSC)

    Set pResult.Relationship = relationship
    Return $$$OK
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

/// Returns minimal neutral ValueSet metadata rows over LOINC groups.
Method SearchValueSets(pUrl As %String = "", pId As %String = "", pName As %String = "", pVersion As %String = "", Output pResult As Terminology.Core.DTO.ValueSetListResult) As %Status
{
    Set pResult = ##class(Terminology.Core.DTO.ValueSetListResult).%New()

    Try {
        Set releaseId = pVersion
        Set tSC = ..GetGroups(releaseId, 10000, 0, .groupResult)
        $$$ThrowOnError(tSC)

        If '$IsObject(groupResult) {
            Return $$$OK
        }

        For index=1:1:groupResult.Items.Count() {
            Set group = groupResult.Items.GetAt(index)
            If '$IsObject(group) {
                Continue
            }

            Set valueSetId = ..BuildValueSetId(group.GroupId)
            If (pId '= "") && (valueSetId '= pId) {
                Continue
            }

            Set tSC = ..GetValueSetInfo(group.GroupId, releaseId, .valueSetInfo)
            $$$ThrowOnError(tSC)
            If '$IsObject(valueSetInfo) || (valueSetInfo.Id = "") {
                Continue
            }

            If (pUrl '= "") && (valueSetInfo.Url '= pUrl) {
                Continue
            }

            If (pName '= "") && ($ZCONVERT(valueSetInfo.Name, "L") '= $ZCONVERT(pName, "L")) {
                Continue
            }

            If (pVersion '= "") && (valueSetInfo.Version '= pVersion) {
                Continue
            }

            Do pResult.Items.Insert(valueSetInfo)
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(), 1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns a minimal neutral ValueSet view over a LOINC group.
Method GetValueSetInfo(pValueSetId As %String = "", pReleaseId As %String = "", Output pResult As Terminology.Core.DTO.ValueSetInfo) As %Status
{
    Set pResult = ##class(Terminology.Core.DTO.ValueSetInfo).%New()

    If pValueSetId = "" {
        Return $$$OK
    }

    Set groupId = ..NormalizeValueSetId(pValueSetId)
    If groupId = "" {
        Return $$$OK
    }

    Set codeSystemInfo = ""
    Set tSC = ##class(Terminology.Core.MetadataRepository).%New().GetCodeSystemInfo("http://loinc.org", .codeSystemInfo)
    $$$ThrowOnError(tSC)

    Set activeVersion = ""
    If $IsObject(codeSystemInfo) {
        Set activeVersion = codeSystemInfo.Version
    }

    Set lookupReleaseId = $Select(pReleaseId'="":pReleaseId, 1:activeVersion)
    Set tSC = ..GetRepository().GetGroupById(groupId, lookupReleaseId, .groupInfo)
    $$$ThrowOnError(tSC)
    If '$IsObject(groupInfo) || (groupInfo.GroupId = "") {
        Return $$$OK
    }

    Set pResult.Id = ..BuildValueSetId(groupInfo.GroupId)
    Set pResult.Url = "http://loinc.org/vs/"_groupInfo.GroupId
    Set pResult.Version = lookupReleaseId
    Set pResult.Name = "LoincGroup"_groupInfo.GroupId
    Set pResult.Title = groupInfo.GroupName
    Set pResult.Status = "active"
    Set pResult.Description = $Select(
        groupInfo.GroupName'="":"LOINC group "_groupInfo.GroupName,
        1:"LOINC group "_groupInfo.GroupId
    )
    Return $$$OK
}

/// Implements the common validate-code contract for LOINC.
Method ValidateCode(pReleaseId As %String = "", pCode As %String = "", Output pResult As Terminology.Loinc.DTO.ValidateCodeResult) As %Status
{
    Return ..GetRepository().ValidateCode(pReleaseId, pCode, .pResult)
}

/// Returns the members for a LOINC-backed FHIR ValueSet expansion.
Method ExpandValueSetMembers(pValueSetId As %String = "", pReleaseId As %String = "", pLang As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.GroupMemberResult) As %Status
{
    Set groupId = ..NormalizeValueSetId(pValueSetId)
    Return ..GetGroupMembers(groupId, pReleaseId, pLang, pLimit, pOffset, .pResult)
}

/// LOINC ValueSet ids are prefixed so they do not collide with SNOMED refset ids in FHIR search/read.
Method BuildValueSetId(pGroupId As %String = "") As %String [ Private ]
{
    Return $Select(pGroupId'="":"loinc-group-"_pGroupId, 1:"")
}

/// Accept either the prefixed FHIR id or the raw LOINC group id for internal reuse.
Method NormalizeValueSetId(pValueSetId As %String = "") As %String [ Private ]
{
    If pValueSetId = "" {
        Return ""
    }

    If $Extract($ZCONVERT(pValueSetId, "L"), 1, 12) = "loinc-group-" {
        Return $Extract(pValueSetId, 13, *)
    }

    Return pValueSetId
}

Method GetRepository() As Terminology.Loinc.LoincRepository [ Private ]
{
    Quit ##class(Terminology.Loinc.LoincRepository).%New()
}

}
