/// Central registry for terminology identity, aliases and cross-layer capabilities.
Class Terminology.Core.TerminologyRegistry Extends %RegisteredObject
{

/// Resolves any supported terminology alias or canonical uri to the stable logical id used by this server.
ClassMethod GetCodeSystemId(pValue As %String = "") As %String
{
    Set tSC = ..ResolveCodeSystem(pValue, .info)
    If $$$ISERR(tSC) {
        Return ""
    }

    If '$IsObject(info) {
        Return ""
    }

    Return info.%Get("id")
}

/// Resolves any supported terminology alias or logical id to the canonical code system uri stored in metadata.
ClassMethod GetCodeSystemUri(pValue As %String = "") As %String
{
    Set tSC = ..ResolveCodeSystem(pValue, .info)
    If $$$ISERR(tSC) {
        Return ""
    }

    If '$IsObject(info) {
        Return ""
    }

    Return info.%Get("uri")
}

/// Resolves any supported terminology alias to the adapter class that implements the terminology contract.
ClassMethod GetAdapterClass(pValue As %String = "") As %String
{
    Set tSC = ..ResolveCodeSystem(pValue, .info)
    If $$$ISERR(tSC) {
        Return ""
    }

    If '$IsObject(info) {
        Return ""
    }

    Return info.%Get("adapterClass")
}

/// Lists the terminology ids that currently expose ValueSet resources through the FHIR layer.
ClassMethod GetSystemsSupportingFhirValueSets() As %List
{
    Return $LB("snomed","loinc","icd-10")
}

/// Returns the registry definition for a supported terminology after normalizing aliases and canonical forms.
ClassMethod ResolveCodeSystem(pValue As %String = "", Output pInfo As %DynamicObject) As %Status
{
    Set pInfo = ""
    Set normalized = ..NormalizeInput(pValue)
    If normalized = "" {
        Return $$$OK
    }

    For index=1:1:$ListLength(..GetSupportedCodeSystems()) {
        Set codeSystemId = $List(..GetSupportedCodeSystems(), index)
        If ..MatchesAlias(normalized, codeSystemId) {
            Set pInfo = ..BuildDefinition(codeSystemId)
            Return $$$OK
        }
    }

    Return $$$OK
}

/// Resolves the current FHIR ValueSet id/url patterns to one terminology target understood by the service layer.
ClassMethod ResolveFhirValueSetTarget(pResourceId As %String = "", pUrl As %String = "", Output pTarget As %DynamicObject) As %Status
{
    Set pTarget = ##class(%DynamicObject).%New()
    Do pTarget.%Set("valueSetId", "")
    Do pTarget.%Set("system", "")
    Do pTarget.%Set("systemUri", "")

    Set normalizedResourceId = $ZCONVERT($Get(pResourceId), "L")
    Set normalizedUrl = ..NormalizeInput(pUrl)

    If pResourceId '= "" {
        If $Extract(normalizedResourceId, 1, 12) = "loinc-group-" {
            Do pTarget.%Set("valueSetId", pResourceId)
            Do pTarget.%Set("system", "loinc")
            Do pTarget.%Set("systemUri", ..GetCodeSystemUri("loinc"))
            Return $$$OK
        }

        If $Extract(normalizedResourceId, 1, 11) = "icd-family-" {
            Do pTarget.%Set("valueSetId", pResourceId)
            Do pTarget.%Set("system", "icd-10")
            Do pTarget.%Set("systemUri", ..GetCodeSystemUri("icd-10"))
            Return $$$OK
        }

        Do pTarget.%Set("valueSetId", pResourceId)
        Do pTarget.%Set("system", "snomed")
        Do pTarget.%Set("systemUri", ..GetCodeSystemUri("snomed"))
        Return $$$OK
    }

    If normalizedUrl = "" {
        Return $$$OK
    }

    If normalizedUrl["?fhir_vs=refset/" {
        Do pTarget.%Set("valueSetId", $Piece(pUrl, "?fhir_vs=refset/", 2))
        Do pTarget.%Set("system", "snomed")
        Do pTarget.%Set("systemUri", ..GetCodeSystemUri("snomed"))
        Return $$$OK
    }

    If $Extract(normalizedUrl, 1, $Length(..GetLoincValueSetUrlPrefix())) = ..GetLoincValueSetUrlPrefix() {
        Do pTarget.%Set("valueSetId", "loinc-group-"_$Piece(pUrl, ..GetLoincValueSetUrlPrefix(), 2))
        Do pTarget.%Set("system", "loinc")
        Do pTarget.%Set("systemUri", ..GetCodeSystemUri("loinc"))
        Return $$$OK
    }

    If $Extract(normalizedUrl, 1, $Length(..GetIcdFamilyValueSetUrlPrefix())) = ..GetIcdFamilyValueSetUrlPrefix() {
        Do pTarget.%Set("valueSetId", "icd-family-"_$Piece(pUrl, ..GetIcdFamilyValueSetUrlPrefix(), 2))
        Do pTarget.%Set("system", "icd-10")
        Do pTarget.%Set("systemUri", ..GetCodeSystemUri("icd-10"))
    }

    Return $$$OK
}

/// Returns the canonical prefix used by the current LOINC FHIR ValueSet url form.
ClassMethod GetLoincValueSetUrlPrefix() As %String
{
    Return "http://loinc.org/vs/"
}

/// Returns the server-defined canonical prefix used by ICD family-backed FHIR ValueSet urls.
ClassMethod GetIcdFamilyValueSetUrlPrefix() As %String
{
    Return "urn:iris:terminology:valueset:icd:family:"
}

/// Enumerates the terminology ids known to the registry.
ClassMethod GetSupportedCodeSystems() As %List [ Private ]
{
    Return $LB("snomed","loinc","icd-10")
}

/// Builds the full registry definition for one known terminology id.
ClassMethod BuildDefinition(pCodeSystemId As %String) As %DynamicObject [ Private ]
{
    Set info = ##class(%DynamicObject).%New()

    If pCodeSystemId = "snomed" {
        Do info.%Set("id", "snomed")
        Do info.%Set("uri", "http://snomed.info/sct")
        Do info.%Set("adapterClass", "Terminology.Snomed.SnomedAdapter")
        Do info.%Set("supportsFhirCodeSystem", 1)
        Do info.%Set("supportsFhirValueSet", 1)
        Return info
    }

    If pCodeSystemId = "loinc" {
        Do info.%Set("id", "loinc")
        Do info.%Set("uri", "http://loinc.org")
        Do info.%Set("adapterClass", "Terminology.Loinc.LoincAdapter")
        Do info.%Set("supportsFhirCodeSystem", 1)
        Do info.%Set("supportsFhirValueSet", 1)
        Return info
    }

    If pCodeSystemId = "icd-10" {
        Do info.%Set("id", "icd-10")
        Do info.%Set("uri", "http://id.who.int/icd/release/10")
        Do info.%Set("adapterClass", "Terminology.ICD.ICDAdapter")
        Do info.%Set("supportsFhirCodeSystem", 1)
        Do info.%Set("supportsFhirValueSet", 1)
        Return info
    }

    Return info
}

/// Checks whether the normalized input matches any accepted alias for the given terminology id.
ClassMethod MatchesAlias(pNormalized As %String, pCodeSystemId As %String) As %Boolean [ Private ]
{
    Set aliases = ..GetAliases(pCodeSystemId)

    For index=1:1:$ListLength(aliases) {
        If pNormalized = ..NormalizeInput($List(aliases, index)) {
            Return 1
        }
    }

    Return 0
}

/// Returns every accepted logical id, alias and canonical uri for one terminology.
ClassMethod GetAliases(pCodeSystemId As %String) As %List [ Private ]
{
    If pCodeSystemId = "snomed" {
        Return $LB("snomed","http://snomed.info/sct")
    }

    If pCodeSystemId = "loinc" {
        Return $LB("loinc","http://loinc.org")
    }

    If pCodeSystemId = "icd-10" {
        Return $LB("cie","cie10","cie-10","icd10","icd-10","http://hl7.org/fhir/sid/icd-10","http://id.who.int/icd/release/10")
    }

    Return ""
}

/// Normalizes free-form input before alias comparison by trimming, lowercasing and removing version suffixes.
ClassMethod NormalizeInput(pValue As %String = "") As %String [ Private ]
{
    Set normalized = $ZSTRIP($Get(pValue), "<>W")

    If normalized = "" {
        Return ""
    }

    If $Find(normalized, "|") {
        Set normalized = $Piece(normalized, "|", 1)
    }

    If $Extract(normalized, *) = "/" {
        Set normalized = $Extract(normalized, 1, *-1)
    }

    Return $ZCONVERT(normalized, "L")
}

}
