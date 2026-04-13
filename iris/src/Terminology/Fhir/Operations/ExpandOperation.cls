/// Implements the ValueSet/$expand FHIR operation for the terminology server.
Class Terminology.Fhir.Operations.ExpandOperation Extends HS.FHIRServer.API.OperationHandler
{

/// Preserves built-in operations and registers ValueSet/$expand.
ClassMethod AddSupportedOperations(pMap As %DynamicObject)
{
    Do ##class(HS.FHIRServer.Storage.BuiltInOperations).AddSupportedOperations(pMap)
    Do pMap.%Set("expand", "http://hl7.org/fhir/OperationDefinition/ValueSet-expand")
}

/// Handles [base]/ValueSet/$expand.
ClassMethod FHIRTypeOpExpand(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    Do ..ProcessValueSetExpand(pService, pRequest, pResponse, "ValueSet", "")
}

/// Handles [base]/ValueSet/{id}/$expand.
ClassMethod FHIRInstanceOpExpand(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    Do ..ProcessValueSetExpand(pService, pRequest, pResponse, "ValueSet", pRequest.Id)
}

/// Keeps the FHIR layer thin by validating request semantics and delegating expansion retrieval.
/// ValueSet expansion is currently implemented for SNOMED refsets, LOINC groups and ICD families.
ClassMethod ProcessValueSetExpand(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response, pResourceType As %String, pResourceId As %String = "")
{
    If pResourceType'="ValueSet" {
        $$$ThrowFHIR($$$HSFHIRErrLastnInvalidResourceType, pResourceType, $$$OutcomeInvalid(400))
    }

    Do pService.interactions.AddQueriedResourceTypes($LB(pResourceType))

    Set tSC = ..ParseExpandInputs(pRequest, .inputs)
    $$$ThrowOnError(tSC)

    Set tSC = ..ResolveExpandContext(pResourceId, inputs.url, inputs.version, inputs.displayLanguage, .context)
    $$$ThrowOnError(tSC)

    Set tSC = ##class(Terminology.Core.TermService).%New().ExpandValueSet(
        context.system,
        context.valueSetId,
        context.version,
        context.lang,
        context.dialect,
        inputs.count,
        inputs.offset,
        .valueSetInfo,
        .members
    )
    $$$ThrowOnError(tSC)

    If ('$IsObject(valueSetInfo)) || (valueSetInfo.Id = "") {
        $$$ThrowFHIR($$$HSFHIRErrResourceNotFound, "ValueSet", context.valueSetId, $$$OutcomeInvalid(404))
    }

    Set response = ..BuildExpandResponse(valueSetInfo, context.systemUri, members, inputs.offset)
    Set pResponse.Status = 200
    Set pResponse.Json = response
}

/// Supports a narrow MVP parameter set for GET-based expand requests.
ClassMethod ParseExpandInputs(pRequest As HS.FHIRServer.API.Data.Request, Output pInputs As %DynamicObject) As %Status [ Private ]
{
    Set pInputs = ##class(%DynamicObject).%New()
    Do pInputs.%Set("url", "")
    Do pInputs.%Set("version", "")
    Do pInputs.%Set("displayLanguage", "")
    Do pInputs.%Set("count", 100)
    Do pInputs.%Set("offset", 0)

    For index=1:1:$ListLength($LB("url","version","displayLanguage","count","offset")) {
        Set paramName = $List($LB("url","version","displayLanguage","count","offset"), index)
        Set paramCount = pRequest.GetParameterCount(paramName)
        If paramCount>1 {
            $$$ThrowFHIR($$$HSFHIRErrInvalidParameterValue, paramName, "", $$$OutcomeInvalid(400))
        }
        If paramCount=1 {
            Set paramValue = pRequest.GetParameterValue(paramName, 1, .modifier)
            If modifier '= "" {
                $$$ThrowFHIR($$$HSFHIRErrInvalidParameterValue, paramName, paramValue, $$$OutcomeInvalid(400))
            }
            If (paramName = "count") || (paramName = "offset") {
                If (paramValue = "") || (+paramValue '= paramValue) || (+paramValue < 0) {
                    $$$ThrowFHIR($$$HSFHIRErrInvalidParameterValue, paramName, paramValue, $$$OutcomeInvalid(400))
                }
                Do pInputs.%Set(paramName, +paramValue)
            } Else {
                Do pInputs.%Set(paramName, paramValue)
            }
        }
    }

    Quit $$$OK
}

/// Resolves the effective ValueSet id, owning code system and language context from the request target and metadata.
ClassMethod ResolveExpandContext(pResourceId As %String, pUrl As %String, pRequestedVersion As %String, pDisplayLanguage As %String, Output pContext As %DynamicObject) As %Status [ Private ]
{
    Set pContext = ##class(%DynamicObject).%New()
    Set service = ##class(Terminology.Core.TermService).%New()
    Set codeSystemService = ##class(Terminology.Core.TermService).%New()

    Set tSC = ..ResolveValueSetTarget(pResourceId, pUrl, .target)
    $$$ThrowOnError(tSC)
    If ('$IsObject(target)) || (target.valueSetId = "") {
        $$$ThrowFHIR($$$GeneralError, "A ValueSet id or url parameter is required for ValueSet/$expand", $$$OutcomeInvalid(400))
    }

    Set tSC = service.GetValueSetInfo(target.system, target.valueSetId, .valueSetInfo)
    $$$ThrowOnError(tSC)
    If ('$IsObject(valueSetInfo)) || (valueSetInfo.Id = "") {
        $$$ThrowFHIR($$$HSFHIRErrResourceNotFound, "ValueSet", target.valueSetId, $$$OutcomeInvalid(404))
    }

    If (pUrl '= "") && (valueSetInfo.Url '= pUrl) {
        $$$ThrowFHIR($$$GeneralError, "The url parameter does not match the targeted ValueSet resource", $$$OutcomeInvalid(400))
    }

    Set tSC = codeSystemService.GetCodeSystemInfo(target.system, .codeSystemInfo)
    $$$ThrowOnError(tSC)

    Do pContext.%Set("valueSetId", valueSetInfo.Id)
    Do pContext.%Set("system", target.system)
    Do pContext.%Set("systemUri", target.systemUri)
    Do pContext.%Set("version", $Select(pRequestedVersion'="":pRequestedVersion, valueSetInfo.Version'="":valueSetInfo.Version, 1:""))
    Do pContext.%Set("lang", $Select(pDisplayLanguage'="":pDisplayLanguage, $IsObject(codeSystemInfo):codeSystemInfo.DefaultLang, 1:""))
    Do pContext.%Set("dialect", "")

    If $IsObject(codeSystemInfo) && (pContext.%Get("lang") '= "") && (pContext.%Get("lang") = codeSystemInfo.DefaultLang) {
        Do pContext.%Set("dialect", codeSystemInfo.DefaultDialect)
    }

    Quit $$$OK
}

/// Resolves the target ValueSet id and system from either the resource id or canonical url.
ClassMethod ResolveValueSetTarget(pResourceId As %String, pUrl As %String, Output pTarget As %DynamicObject) As %Status [ Private ]
{
    Return ##class(Terminology.Core.TerminologyRegistry).ResolveFhirValueSetTarget(pResourceId, pUrl, .pTarget)
}

/// Supports the current SNOMED refset canonical url form used by this server.
ClassMethod ExtractValueSetIdFromUrl(pUrl As %String = "") As %String [ Private ]
{
    If pUrl = "" {
        Quit ""
    }

    If pUrl["?fhir_vs=refset/" {
        Quit $Piece(pUrl, "?fhir_vs=refset/", 2)
    }

    Quit ""
}

/// Builds a minimal ValueSet resource with an expansion block.
/// Expansion members are mapped from the owning terminology-specific DTOs into common FHIR contains items.
/// FHIR expansions should list codes, not every underlying designation row, so duplicate
/// `system` + `code` pairs are collapsed to one `contains` item.
/// For LOINC, the selected display follows an explicit preference order rather than raw row order.
ClassMethod BuildExpandResponse(pValueSetInfo As Terminology.Core.DTO.ValueSetInfo, pSystemUri As %String, pMembers, pOffset As %Integer = 0) As %DynamicObject [ Private ]
{
    Set response = ##class(Terminology.Fhir.ResourceMapper).BuildValueSet(pValueSetInfo)
    If '$IsObject(response) {
        Set response = ##class(%DynamicObject).%New()
        Do response.%Set("resourceType", "ValueSet")
    }

    Set expansion = ##class(%DynamicObject).%New()
    Set contains = ##class(%DynamicArray).%New()

    Do expansion.%Set("timestamp", $ZDT($H,3,1,3))
    Do expansion.%Set("offset", pOffset)

    If $IsObject(pMembers) {
        For index=1:1:pMembers.Items.Count() {
            Set member = pMembers.Items.GetAt(index)
            If '$IsObject(member) {
                Continue
            }

            Set code = ..GetExpandMemberCode(pSystemUri, member)
            If code = "" {
                Continue
            }

            Set dedupeKey = pSystemUri_"|"_code
            Set candidateDisplay = ..GetExpandMemberDisplay(pSystemUri, member)
            Set candidatePriority = ..GetExpandMemberPriority(pSystemUri, member)
            Set candidateRankOrder = ..GetExpandMemberRankOrder(pSystemUri, member)

            If '$Data(seen(dedupeKey)) {
                Set seen(dedupeKey) = 1
                Set entryCount = $Get(entryCount) + 1
                Set entryOrder(entryCount) = dedupeKey
                Set entryCode(dedupeKey) = code
                Set entryDisplay(dedupeKey) = candidateDisplay
                Set entryPriority(dedupeKey) = candidatePriority
                Set entryRankOrder(dedupeKey) = candidateRankOrder
                Continue
            }

            If ..ShouldReplaceExpandMember(entryPriority(dedupeKey), entryRankOrder(dedupeKey), $Get(entryDisplay(dedupeKey)), candidatePriority, candidateRankOrder, candidateDisplay) {
                Set entryDisplay(dedupeKey) = candidateDisplay
                Set entryPriority(dedupeKey) = candidatePriority
                Set entryRankOrder(dedupeKey) = candidateRankOrder
            }
        }

        For entryIndex=1:1:$Get(entryCount) {
            Set dedupeKey = $Get(entryOrder(entryIndex))
            If dedupeKey = "" {
                Continue
            }

            Set containsItem = ##class(%DynamicObject).%New()
            Do containsItem.%Set("system", pSystemUri)
            Do containsItem.%Set("code", $Get(entryCode(dedupeKey)))
            If $Get(entryDisplay(dedupeKey)) '= "" {
                Do containsItem.%Set("display", $Get(entryDisplay(dedupeKey)))
            }
            Do contains.%Push(containsItem)
        }
        Set totalCount = 0
        Try {
            Set totalCount = +$PROPERTY(pMembers, "TotalCount")
        } Catch ex {
            Set totalCount = 0
        }
        If totalCount=0 {
            Try {
                Set totalCount = +$PROPERTY(pMembers, "Count")
            } Catch ex {
                Set totalCount = 0
            }
        }
        If totalCount>0 {
            Do expansion.%Set("total", totalCount)
        } Else {
            Do expansion.%Set("total", contains.%Size())
        }
    } Else {
        Do expansion.%Set("total", 0)
    }

    Do expansion.%Set("contains", contains)
    Do response.%Set("expansion", expansion)
    Quit response
}

/// Extracts the member code from a SNOMED refset-member DTO or a LOINC group-member DTO.
ClassMethod GetExpandMemberCode(pSystemUri As %String, pMember) As %String [ Private ]
{
    If '$IsObject(pMember) {
        Return ""
    }

    If ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemId(pSystemUri) = "loinc" {
        Return $PROPERTY(pMember, "LoincNum")
    }

    If ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemId(pSystemUri) = "icd-10" {
        Return $PROPERTY(pMember, "Code")
    }

    Return $PROPERTY(pMember, "ConceptId")
}

/// Extracts the display text from a SNOMED refset-member DTO or a LOINC group-member DTO.
ClassMethod GetExpandMemberDisplay(pSystemUri As %String, pMember) As %String [ Private ]
{
    If '$IsObject(pMember) {
        Return ""
    }

    If ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemId(pSystemUri) = "loinc" {
        Return $PROPERTY(pMember, "Display")
    }

    If ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemId(pSystemUri) = "icd-10" {
        Return $PROPERTY(pMember, "Description")
    }

    Return $PROPERTY(pMember, "PreferredTerm")
}

/// Returns the explicit display preference used when one LOINC code has multiple designations.
ClassMethod GetExpandMemberPriority(pSystemUri As %String, pMember) As %Integer [ Private ]
{
    If '$IsObject(pMember) {
        Return 999
    }

    If ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemId(pSystemUri) '= "loinc" {
        Return 1
    }

    Set displayType = $ZCONVERT($PROPERTY(pMember, "DisplayType"), "U")
    If displayType = "LONGCOMMONNAME" {
        Return 1
    }
    If displayType = "SHORTNAME" {
        Return 2
    }
    If displayType = "DISPLAYNAME" {
        Return 3
    }
    If displayType = "CONSUMERNAME" {
        Return 4
    }
    If displayType = "LINGUISTICVARIANT" {
        Return 5
    }

    Return 99
}

/// Uses RankOrder as a stable tie-breaker when two designations share the same semantic priority.
ClassMethod GetExpandMemberRankOrder(pSystemUri As %String, pMember) As %Integer [ Private ]
{
    If '$IsObject(pMember) {
        Return 999999
    }

    If ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemId(pSystemUri) '= "loinc" {
        Return 0
    }

    Return +$PROPERTY(pMember, "RankOrder")
}

/// Chooses the better designation candidate for one expanded code.
ClassMethod ShouldReplaceExpandMember(pCurrentPriority As %Integer, pCurrentRankOrder As %Integer, pCurrentDisplay As %String, pCandidatePriority As %Integer, pCandidateRankOrder As %Integer, pCandidateDisplay As %String) As %Boolean [ Private ]
{
    If pCandidatePriority < pCurrentPriority {
        Return 1
    }

    If pCandidatePriority > pCurrentPriority {
        Return 0
    }

    If pCandidateRankOrder < pCurrentRankOrder {
        Return 1
    }

    If pCandidateRankOrder > pCurrentRankOrder {
        Return 0
    }

    If (pCurrentDisplay = "") && (pCandidateDisplay '= "") {
        Return 1
    }

    If (pCandidateDisplay '= "") && ($ZCONVERT(pCandidateDisplay, "L") < $ZCONVERT(pCurrentDisplay, "L")) {
        Return 1
    }

    Return 0
}

}
