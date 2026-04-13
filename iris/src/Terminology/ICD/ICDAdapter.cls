Class Terminology.ICD.ICDAdapter Extends %RegisteredObject
{

Method SearchConcepts(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pQuery As %String = "", pLimit As %Integer = 20, pOffset As %Integer = 0, Output pResult As Terminology.ICD.DTO.SearchResult) As %Status
{
    Return ..GetRepository().SearchConcepts(pReleaseId, pVersion, pCodeType, pQuery, pLimit, pOffset, .pResult)
}

Method LookupCode(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", Output pResult As Terminology.ICD.DTO.CodeResult) As %Status
{
    Return ..GetRepository().GetCodeByCode(pReleaseId, pVersion, pCodeType, pCode, .pResult)
}

Method GetChildren(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.ICD.DTO.HierarchyResult) As %Status
{
    Return ..GetRepository().GetChildren(pReleaseId, pVersion, pCodeType, pCode, pLimit, pOffset, .pResult)
}

Method GetAncestors(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pIncludeSelf As %Boolean = 0, pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.ICD.DTO.HierarchyResult) As %Status
{
    Return ..GetRepository().GetAncestors(pReleaseId, pVersion, pCodeType, pCode, pIncludeSelf, pMaxDepth, pLimit, pOffset, .pResult)
}

Method GetDescendants(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pIncludeSelf As %Boolean = 0, pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.ICD.DTO.HierarchyResult) As %Status
{
    Return ..GetRepository().GetDescendants(pReleaseId, pVersion, pCodeType, pCode, pIncludeSelf, pMaxDepth, pLimit, pOffset, .pResult)
}

Method GetFamilies(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.ICD.DTO.FamilyResult) As %Status
{
    Return ..GetRepository().GetFamilies(pReleaseId, pVersion, pCodeType, pLimit, pOffset, .pResult)
}

Method SearchValueSets(pUrl As %String = "", pId As %String = "", pName As %String = "", pVersion As %String = "", Output pResult As Terminology.Core.DTO.ValueSetListResult) As %Status
{
    Set pResult = ##class(Terminology.Core.DTO.ValueSetListResult).%New()

    Try {
        Set releaseId = pVersion
        Set tSC = ..GetFamilies(releaseId, ..ResolveIcdVersionNumber(), "DIAGNOSIS", 10000, 0, .familyResult)
        $$$ThrowOnError(tSC)

        If '$IsObject(familyResult) {
            Return $$$OK
        }

        For index=1:1:familyResult.Items.Count() {
            Set family = familyResult.Items.GetAt(index)
            If '$IsObject(family) {
                Continue
            }

            Set valueSetId = ..BuildValueSetId(family.FamilyCode)
            If (pId '= "") && (valueSetId '= pId) {
                Continue
            }

            Set tSC = ..GetValueSetInfo(family.FamilyCode, releaseId, .valueSetInfo)
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

Method GetValueSetInfo(pValueSetId As %String = "", pReleaseId As %String = "", Output pResult As Terminology.Core.DTO.ValueSetInfo) As %Status
{
    Set pResult = ##class(Terminology.Core.DTO.ValueSetInfo).%New()

    If pValueSetId = "" {
        Return $$$OK
    }

    Set familyCode = ..NormalizeValueSetId(pValueSetId)
    If familyCode = "" {
        Return $$$OK
    }

    Set codeSystemInfo = ""
    Set tSC = ##class(Terminology.Core.MetadataRepository).%New().GetCodeSystemInfo(##class(Terminology.Core.TerminologyRegistry).GetCodeSystemUri("icd-10"), .codeSystemInfo)
    $$$ThrowOnError(tSC)

    Set activeVersion = ""
    If $IsObject(codeSystemInfo) {
        Set activeVersion = codeSystemInfo.Version
    }

    Set lookupReleaseId = $Select(pReleaseId'="":pReleaseId, 1:activeVersion)
    Set tSC = ..GetRepository().GetFamilyByCode(familyCode, lookupReleaseId, ..ResolveIcdVersionNumber(), "DIAGNOSIS", .familyInfo)
    $$$ThrowOnError(tSC)
    If '$IsObject(familyInfo) || (familyInfo.FamilyCode = "") {
        Return $$$OK
    }

    Set pResult.Id = ..BuildValueSetId(familyInfo.FamilyCode)
    Set pResult.Url = ..BuildValueSetUrl(familyInfo.FamilyCode)
    Set pResult.Version = lookupReleaseId
    Set pResult.Name = "ICDFamily"_familyInfo.FamilyCode
    Set pResult.Title = familyInfo.Description
    Set pResult.Status = "active"
    Set pResult.Description = $Select(
        familyInfo.Description'="":"ICD family "_familyInfo.Description,
        1:"ICD family "_familyInfo.FamilyCode
    )
    Return $$$OK
}

Method ValidateCode(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", Output pResult As Terminology.ICD.DTO.ValidateCodeResult) As %Status
{
    Return ..GetRepository().ValidateCode(pReleaseId, pVersion, pCodeType, pCode, .pResult)
}

Method Subsumes(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCodeA As %String = "", pCodeB As %String = "", Output pResult As Terminology.Snomed.DTO.SubsumesResult) As %Status
{
    Return ..GetRepository().Subsumes(pReleaseId, pVersion, pCodeType, pCodeA, pCodeB, .pResult)
}

Method ExpandValueSetMembers(pValueSetId As %String = "", pReleaseId As %String = "", pLang As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.ICD.DTO.SearchResult) As %Status
{
    Set familyCode = ..NormalizeValueSetId(pValueSetId)
    Return ..GetRepository().GetFamilyMembers(familyCode, pReleaseId, ..ResolveIcdVersionNumber(), "DIAGNOSIS", pLimit, pOffset, .pResult)
}

Method BuildValueSetId(pFamilyCode As %String = "") As %String [ Private ]
{
    Return $Select(pFamilyCode'="":"icd-family-"_pFamilyCode, 1:"")
}

Method BuildValueSetUrl(pFamilyCode As %String = "") As %String [ Private ]
{
    Return $Select(pFamilyCode'="":##class(Terminology.Core.TerminologyRegistry).GetIcdFamilyValueSetUrlPrefix()_pFamilyCode, 1:"")
}

Method NormalizeValueSetId(pValueSetId As %String = "") As %String [ Private ]
{
    If pValueSetId = "" {
        Return ""
    }

    If $Extract($ZCONVERT(pValueSetId, "L"), 1, 11) = "icd-family-" {
        Return $Extract(pValueSetId, 12, *)
    }

    Return pValueSetId
}

Method ResolveIcdVersionNumber() As %Integer [ Private ]
{
    Return 10
}

Method GetRepository() As Terminology.ICD.ICDRepository [ Private ]
{
    Quit ##class(Terminology.ICD.ICDRepository).%New()
}

}
