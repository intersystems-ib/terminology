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
        "snomed",
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

    Set response = ..BuildExpandResponse(valueSetInfo, members, inputs.offset)
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

/// Resolves the effective ValueSet id, version and language context from the request target and metadata.
ClassMethod ResolveExpandContext(pResourceId As %String, pUrl As %String, pRequestedVersion As %String, pDisplayLanguage As %String, Output pContext As %DynamicObject) As %Status [ Private ]
{
    Set pContext = ##class(%DynamicObject).%New()
    Set service = ##class(Terminology.Core.TermService).%New()
    Set codeSystemService = ##class(Terminology.Core.TermService).%New()

    Set valueSetId = pResourceId
    If valueSetId = "" {
        Set valueSetId = ..ExtractValueSetIdFromUrl(pUrl)
    }

    If valueSetId = "" {
        $$$ThrowFHIR($$$GeneralError, "A ValueSet id or url parameter is required for ValueSet/$expand", $$$OutcomeInvalid(400))
    }

    Set tSC = service.GetValueSetInfo("snomed", valueSetId, .valueSetInfo)
    $$$ThrowOnError(tSC)
    If ('$IsObject(valueSetInfo)) || (valueSetInfo.Id = "") {
        $$$ThrowFHIR($$$HSFHIRErrResourceNotFound, "ValueSet", valueSetId, $$$OutcomeInvalid(404))
    }

    If (pUrl '= "") && (valueSetInfo.Url '= pUrl) {
        $$$ThrowFHIR($$$GeneralError, "The url parameter does not match the targeted ValueSet resource", $$$OutcomeInvalid(400))
    }

    Set tSC = codeSystemService.GetCodeSystemInfo("snomed", .codeSystemInfo)
    $$$ThrowOnError(tSC)

    Do pContext.%Set("valueSetId", valueSetInfo.Id)
    Do pContext.%Set("version", $Select(pRequestedVersion'="":pRequestedVersion, valueSetInfo.Version'="":valueSetInfo.Version, 1:""))
    Do pContext.%Set("lang", $Select(pDisplayLanguage'="":pDisplayLanguage, $IsObject(codeSystemInfo):codeSystemInfo.DefaultLang, 1:""))
    Do pContext.%Set("dialect", "")

    If $IsObject(codeSystemInfo) && (pContext.%Get("lang") '= "") && (pContext.%Get("lang") = codeSystemInfo.DefaultLang) {
        Do pContext.%Set("dialect", codeSystemInfo.DefaultDialect)
    }

    Quit $$$OK
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
ClassMethod BuildExpandResponse(pValueSetInfo As Terminology.Core.DTO.ValueSetInfo, pMembers As Terminology.Snomed.DTO.RefsetMemberListResult, pOffset As %Integer = 0) As %DynamicObject [ Private ]
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

            Set containsItem = ##class(%DynamicObject).%New()
            Do containsItem.%Set("system", "http://snomed.info/sct")
            Do containsItem.%Set("code", member.ConceptId)
            If member.PreferredTerm '= "" {
                Do containsItem.%Set("display", member.PreferredTerm)
            }
            Do contains.%Push(containsItem)
        }
        Do expansion.%Set("total", pMembers.Count)
    } Else {
        Do expansion.%Set("total", 0)
    }

    Do expansion.%Set("contains", contains)
    Do response.%Set("expansion", expansion)
    Quit response
}

}
