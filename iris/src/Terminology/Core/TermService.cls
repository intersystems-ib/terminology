/// Neutral terminology service entry point.
/// Keeps the common contract small and routes calls to the terminology adapter.
Class Terminology.Core.TermService Extends %RegisteredObject
{

/// Common lookup operation used by higher layers that should not know terminology-specific tables.
Method LookupCode(pSystem As %String = "snomed", pCode As %String = "", pVersion As %String = "", pLang As %String = "", pDialect As %String = "", Output pResult) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "LookupCode", "system="_pSystem_" code="_pCode_" version="_pVersion_" lang="_pLang_" dialect="_pDialect)
    Return ..ResolveAdapter(pSystem).LookupCode(pCode, pVersion, pLang, pDialect, .pResult)
}

/// Common validate-code operation.
/// Output is intentionally untyped because each adapter returns its own DTO shape.
Method ValidateCode(pSystem As %String = "snomed", pVersion As %String = "", pCode As %String = "", Output pResult) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "ValidateCode", "system="_pSystem_" code="_pCode_" version="_pVersion)
    Return ..ResolveAdapter(pSystem).ValidateCode(pVersion, pCode, .pResult)
}

/// Common subsumption operation.
/// Output is intentionally untyped because each adapter may reuse or define its own result DTO.
Method Subsumes(pSystem As %String = "snomed", pVersion As %String = "", pView As %String = "", pCodeA As %String = "", pCodeB As %String = "", Output pResult) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "Subsumes", "system="_pSystem_" version="_pVersion_" view="_pView_" codeA="_pCodeA_" codeB="_pCodeB)
    Return ..ResolveAdapter(pSystem).Subsumes(pVersion, pView, pCodeA, pCodeB, .pResult)
}

/// Common text search operation.
Method SearchConcepts(pSystem As %String = "snomed", pVersion As %String = "", pLang As %String = "", pDialect As %String = "", pQuery As %String = "", pLimit As %Integer = 20, pOffset As %Integer = 0, Output pResult) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "SearchConcepts", "system="_pSystem_" version="_pVersion_" lang="_pLang_" dialect="_pDialect_" limit="_pLimit_" offset="_pOffset_" query="_pQuery)
    Return ..ResolveAdapter(pSystem).SearchConcepts(pVersion, pLang, pDialect, pQuery, pLimit, pOffset, .pResult)
}

/// Returns minimal code system metadata for read-only FHIR resource exposure.
Method GetCodeSystemInfo(pId As %String = "", Output pResult As Terminology.Core.DTO.CodeSystemInfo) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "GetCodeSystemInfo", "id="_pId)
    Set pResult = ##class(Terminology.Core.DTO.CodeSystemInfo).%New()
    Set systemUri = ..ResolveCodeSystemUri(pId)
    If systemUri = "" {
        Return $$$OK
    }

    Set tSC = ##class(Terminology.Core.MetadataRepository).%New().GetCodeSystemInfo(systemUri, .pResult)
    $$$ThrowOnError(tSC)

    If pResult.Url '= "" {
        Set pResult.Id = ..BuildCodeSystemId(pResult.Url)
        If pResult.Name = "" {
            Set pResult.Name = pResult.Id
        }
        If pResult.Title = "" {
            Set pResult.Title = pResult.Name
        }
    }

    Return $$$OK
}

/// Returns minimal value set metadata for read-only FHIR resource exposure.
Method GetValueSetInfo(pSystem As %String = "snomed", pId As %String = "", Output pResult As Terminology.Core.DTO.ValueSetInfo) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "GetValueSetInfo", "system="_pSystem_" id="_pId)
    Return ..ResolveAdapter(pSystem).GetValueSetInfo(pId, "", .pResult)
}

/// Returns minimal code system metadata rows for FHIR search-type support.
Method SearchCodeSystems(pUrl As %String = "", pId As %String = "", pName As %String = "", pVersion As %String = "", Output pResult As Terminology.Core.DTO.CodeSystemListResult) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "SearchCodeSystems", "url="_pUrl_" id="_pId_" name="_pName_" version="_pVersion)
    Set pResult = ##class(Terminology.Core.DTO.CodeSystemListResult).%New()
    Set normalizedUrl = ..NormalizeCodeSystemUrl(pUrl)
    Set normalizedName = $ZCONVERT($ZSTRIP(pName, "<>W"), "L")

    // Keep repository query broad and apply normalized filtering here so FHIR parameter
    // encoding/casing variants do not accidentally drop SNOMED metadata rows.
    Set tSC = ##class(Terminology.Core.MetadataRepository).%New().SearchCodeSystems("", "", .searchResult)
    $$$ThrowOnError(tSC)

    If '$IsObject(searchResult) {
        Return $$$OK
    }

    For index=1:1:searchResult.Items.Count() {
        Set item = searchResult.Items.GetAt(index)
        If '$IsObject(item) {
            Continue
        }

        If (normalizedUrl '= "") && (..NormalizeCodeSystemUrl(item.Url) '= normalizedUrl) {
            Continue
        }

        If (normalizedName '= "") && ($ZCONVERT($ZSTRIP(item.Name, "<>W"), "L") '= normalizedName) {
            Continue
        }

        Set item.Id = ..BuildCodeSystemId(item.Url)
        If ..ResolveCodeSystemUri(item.Id) = "" {
            Continue
        }

        If (pId '= "") && ($ZCONVERT(item.Id, "L") '= $ZCONVERT(pId, "L")) {
            Continue
        }

        If (pVersion '= "") && (item.Version '= pVersion) {
            Continue
        }

        If (item.Name = "") {
            Set item.Name = item.Id
        }

        If item.Title = "" {
            Set item.Title = item.Name
        }

        Do pResult.Items.Insert(item)
    }

    Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(), 1:0)
    Return $$$OK
}

/// Returns minimal value set metadata rows for FHIR search-type support.
Method SearchValueSets(pSystem As %String = "snomed", pUrl As %String = "", pId As %String = "", pName As %String = "", pVersion As %String = "", Output pResult As Terminology.Core.DTO.ValueSetListResult) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "SearchValueSets", "system="_pSystem_" url="_pUrl_" id="_pId_" name="_pName_" version="_pVersion)
    Return ..ResolveAdapter(pSystem).SearchValueSets(pUrl, pId, pName, pVersion, .pResult)
}

/// Returns minimal value set metadata and members for the supported terminology-specific FHIR expand paths.
Method ExpandValueSet(pSystem As %String = "snomed", pValueSetId As %String = "", pVersion As %String = "", pLang As %String = "", pDialect As %String = "", pCount As %Integer = 100, pOffset As %Integer = 0, Output pInfo As Terminology.Core.DTO.ValueSetInfo, Output pMembers) As %Status
{
    Do ##class(Terminology.Core.Trace).Log("service", "ExpandValueSet", "system="_pSystem_" valueSetId="_pValueSetId_" version="_pVersion_" lang="_pLang_" dialect="_pDialect_" count="_pCount_" offset="_pOffset)
    Set pInfo = ##class(Terminology.Core.DTO.ValueSetInfo).%New()

    Set tSC = ..ResolveAdapter(pSystem).GetValueSetInfo(pValueSetId, pVersion, .pInfo)
    $$$ThrowOnError(tSC)

    If '$IsObject(pInfo) || (pInfo.Id = "") {
        Return $$$OK
    }

    If ($ZCONVERT(pSystem, "L") = "loinc") || (pSystem = "http://loinc.org") {
        Set pMembers = ##class(Terminology.Loinc.DTO.GroupMemberResult).%New()
        Return ##class(Terminology.Loinc.LoincAdapter).%New().ExpandValueSetMembers(pValueSetId, pInfo.Version, pLang, pCount, pOffset, .pMembers)
    }

    Set pMembers = ##class(Terminology.Snomed.DTO.RefsetMemberListResult).%New()
    Return ##class(Terminology.Snomed.SnomedAdapter).%New().GetRefsetMembers(pValueSetId, pInfo.Version, pLang, pDialect, pCount, pOffset, .pMembers)
}

/// Explicit adapter resolution keeps the current implementation simple while making
/// the routing point obvious for future terminologies.
/// The return type is generic because the adapters do not share one concrete class.
Method ResolveAdapter(pSystem As %String = "snomed") As %RegisteredObject [ Private ]
{
    Set normalized = ..NormalizeCodeSystemUrl(pSystem)

    If (normalized = "") || ($ZCONVERT(normalized, "L") = "snomed") || ($ZCONVERT(normalized, "L") = "http://snomed.info/sct") {
        Quit ##class(Terminology.Snomed.SnomedAdapter).%New()
    }

    If ($ZCONVERT(normalized, "L") = "loinc") || ($ZCONVERT(normalized, "L") = "http://loinc.org") {
        Quit ##class(Terminology.Loinc.LoincAdapter).%New()
    }

    If ($ZCONVERT(normalized, "L") = "cie")
        || ($ZCONVERT(normalized, "L") = "cie10")
        || ($ZCONVERT(normalized, "L") = "cie-10")
        || ($ZCONVERT(normalized, "L") = "icd10")
        || ($ZCONVERT(normalized, "L") = "icd-10")
        || ($ZCONVERT(normalized, "L") = "http://hl7.org/fhir/sid/icd-10") {
        Quit ##class(Terminology.ICD.ICDAdapter).%New()
    }

    Set tSC = $$$ERROR($$$NotImplemented, "Unsupported terminology system: "_pSystem)
    $$$ThrowOnError(tSC)
}

/// Keeps the current single-system FHIR ids explicit until multiple code systems are modeled.
Method BuildCodeSystemId(pSystemUri As %String = "") As %String [ Private ]
{
    If pSystemUri = "http://snomed.info/sct" {
        Return "snomed"
    }
    If pSystemUri = "http://loinc.org" {
        Return "loinc"
    }
    

    Return $ZCONVERT(pSystemUri, "L")
}

/// Resolves the current MVP FHIR logical id to a code system canonical url.
Method ResolveCodeSystemUri(pId As %String = "") As %String [ Private ]
{
    Set normalized = ..NormalizeCodeSystemUrl(pId)
    If (normalized = "") || ($ZCONVERT(normalized, "L") = "snomed") || ($ZCONVERT(normalized, "L") = "http://snomed.info/sct") {
        Return "http://snomed.info/sct"
    }
    If ($ZCONVERT(normalized, "L") = "loinc") || ($ZCONVERT(normalized, "L") = "http://loinc.org") {
        Return "http://loinc.org"
    }
    If ($ZCONVERT(normalized, "L") = "cie")
        || ($ZCONVERT(normalized, "L") = "cie10")
        || ($ZCONVERT(normalized, "L") = "cie-10")
        || ($ZCONVERT(normalized, "L") = "icd10")
        || ($ZCONVERT(normalized, "L") = "icd-10")
        || ($ZCONVERT(normalized, "L") = "http://hl7.org/fhir/sid/icd-10") {
        Return "http://hl7.org/fhir/sid/icd-10"
    }
    Return ""
}

Method NormalizeCodeSystemUrl(pValue As %String = "") As %String [ Private ]
{
    Set normalized = $ZSTRIP(pValue, "<>W")

    If normalized = "" {
        Return ""
    }

    If $Find(normalized, "|") {
        Set normalized = $Piece(normalized, "|", 1)
    }

    If ($Extract(normalized, *) = "/") {
        Set normalized = $Extract(normalized, 1, *-1)
    }

    If $ZCONVERT(normalized, "L") = "http://snomed.info/sct" {
        Return "http://snomed.info/sct"
    }

    If $ZCONVERT(normalized, "L") = "snomed" {
        Return "snomed"
    }

    If $ZCONVERT(normalized, "L") = "http://loinc.org" {
        Return "http://loinc.org"
    }

    If $ZCONVERT(normalized, "L") = "loinc" {
        Return "loinc"
    }

    If ($ZCONVERT(normalized, "L") = "cie")
        || ($ZCONVERT(normalized, "L") = "cie10")
        || ($ZCONVERT(normalized, "L") = "cie-10")
        || ($ZCONVERT(normalized, "L") = "icd10")
        || ($ZCONVERT(normalized, "L") = "icd-10")
        || ($ZCONVERT(normalized, "L") = "http://hl7.org/fhir/sid/icd-10") {
        Return "http://hl7.org/fhir/sid/icd-10"
    }

    Return normalized
}

}
