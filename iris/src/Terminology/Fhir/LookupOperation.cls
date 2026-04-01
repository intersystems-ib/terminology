/// Implements the CodeSystem/$lookup FHIR operation for the terminology server.
Class Terminology.Fhir.LookupOperation Extends HS.FHIRServer.API.OperationHandler
{

/// Preserves built-in operations and registers CodeSystem/$lookup.
ClassMethod AddSupportedOperations(pMap As %DynamicObject)
{
    Do ##class(HS.FHIRServer.Storage.BuiltInOperations).AddSupportedOperations(pMap)
    Do pMap.%Set("lookup", "http://hl7.org/fhir/OperationDefinition/CodeSystem-lookup")
}

/// Handles [base]/CodeSystem/$lookup.
ClassMethod FHIRTypeOpLookup(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    Do ..ProcessCodeSystemLookup(pService, pRequest, pResponse, "CodeSystem", "")
}

/// Handles [base]/CodeSystem/{id}/$lookup.
ClassMethod FHIRInstanceOpLookup(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    Do ..ProcessCodeSystemLookup(pService, pRequest, pResponse, "CodeSystem", pRequest.Id)
}

/// Keeps the FHIR layer thin by validating request semantics and delegating concept lookup.
ClassMethod ProcessCodeSystemLookup(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response, pResourceType As %String, pResourceId As %String = "")
{
    If pResourceType'="CodeSystem" {
        $$$ThrowFHIR($$$HSFHIRErrLastnInvalidResourceType, pResourceType, $$$OutcomeInvalid(400))
    }

    Do pService.interactions.AddQueriedResourceTypes($LB(pResourceType))

    Set tSC = ..ParseLookupInputs(pRequest, .inputs)
    $$$ThrowOnError(tSC)

    Set tSC = ..ResolveLookupContext(pResourceId, inputs.system, inputs.version, inputs.displayLanguage, .context)
    $$$ThrowOnError(tSC)

    If inputs.code = "" {
        $$$ThrowFHIR($$$GeneralError, "The code parameter is required for CodeSystem/$lookup", $$$OutcomeInvalid(400))
    }

    Set tSC = ##class(Terminology.Core.TermService).%New().LookupCode(
        context.system,
        inputs.code,
        context.version,
        context.lang,
        context.dialect,
        .concept
    )
    $$$ThrowOnError(tSC)

    If ('$IsObject(concept)) || (concept.ConceptId = "") {
        $$$ThrowFHIR($$$HSFHIRErrResourceNotFound, "CodeSystem", context.system_"|"_inputs.code, $$$OutcomeInvalid(404))
    }

    Set response = ..BuildLookupResponse(context, concept)
    Set pResponse.Status = 200
    Set pResponse.Json = response
}

/// Supports a narrow MVP parameter set for GET-based lookup requests.
ClassMethod ParseLookupInputs(pRequest As HS.FHIRServer.API.Data.Request, Output pInputs As %DynamicObject) As %Status [ Private ]
{
    Set pInputs = ##class(%DynamicObject).%New()
    Do pInputs.%Set("code", "")
    Do pInputs.%Set("system", "")
    Do pInputs.%Set("version", "")
    Do pInputs.%Set("displayLanguage", "")

    For index=1:1:$ListLength($LB("code","system","version","displayLanguage")) {
        Set paramName = $List($LB("code","system","version","displayLanguage"), index)
        Set paramCount = pRequest.GetParameterCount(paramName)
        If paramCount>1 {
            $$$ThrowFHIR($$$HSFHIRErrInvalidParameterValue, paramName, "", $$$OutcomeInvalid(400))
        }
        If paramCount=1 {
            Set paramValue = pRequest.GetParameterValue(paramName, 1, .modifier)
            If modifier '= "" {
                $$$ThrowFHIR($$$HSFHIRErrInvalidParameterValue, paramName, paramValue, $$$OutcomeInvalid(400))
            }
            Do pInputs.%Set(paramName, paramValue)
        }
    }

    Quit $$$OK
}

/// Resolves the effective system, version and language context from the request target and metadata.
ClassMethod ResolveLookupContext(pResourceId As %String, pRequestedSystem As %String, pRequestedVersion As %String, pDisplayLanguage As %String, Output pContext As %DynamicObject) As %Status
{
    Set pContext = ##class(%DynamicObject).%New()
    Set service = ##class(Terminology.Core.TermService).%New()

    Set resourceSystem = ""
    Set metadata = ""
    If pResourceId '= "" {
        Set tSC = service.GetCodeSystemInfo(pResourceId, .metadata)
        $$$ThrowOnError(tSC)

        If ('$IsObject(metadata)) || (metadata.Url = "") {
            $$$ThrowFHIR($$$HSFHIRErrResourceNotFound, "CodeSystem", pResourceId, $$$OutcomeInvalid(404))
        }

        Set resourceSystem = metadata.Url
    }

    Set requestedSystem = ..NormalizeSystem(pRequestedSystem)
    If requestedSystem = "" {
        Set requestedSystem = $Select(resourceSystem'="":resourceSystem, 1:"http://snomed.info/sct")
    }

    If (resourceSystem '= "") && (requestedSystem '= resourceSystem) {
        $$$ThrowFHIR($$$GeneralError, "The system parameter does not match the targeted CodeSystem resource", $$$OutcomeInvalid(400))
    }

    If '$IsObject(metadata) {
        Set tSC = service.GetCodeSystemInfo(requestedSystem, .metadata)
        $$$ThrowOnError(tSC)
    }

    If ('$IsObject(metadata)) || (metadata.Url = "") {
        $$$ThrowFHIR($$$GeneralError, "Unsupported code system for CodeSystem/$lookup: "_requestedSystem, $$$OutcomeInvalid(400))
    }

    Do pContext.%Set("system", metadata.Url)
    Do pContext.%Set("systemName", $Select(metadata.Name'="":metadata.Name, 1:metadata.Id))
    Do pContext.%Set("version", $Select(pRequestedVersion'="":pRequestedVersion, metadata.Version'="":metadata.Version, 1:""))
    Do pContext.%Set("lang", $Select(pDisplayLanguage'="":pDisplayLanguage, 1:metadata.DefaultLang))
    Do pContext.%Set("dialect", "")

    If (pContext.%Get("lang") '= "") && (pContext.%Get("lang") = metadata.DefaultLang) {
        Do pContext.%Set("dialect", metadata.DefaultDialect)
    }

    Quit $$$OK
}

/// Accept the current MVP aliases explicitly while keeping unsupported systems out of the FHIR layer.
ClassMethod NormalizeSystem(pSystem As %String) As %String [ Private ]
{
    If (pSystem = "") || ($ZCONVERT(pSystem, "L") = "snomed") || (pSystem = "http://snomed.info/sct") {
        Quit $Select(pSystem = "":"", 1:"http://snomed.info/sct")
    }

    Quit pSystem
}

/// Builds a minimal Parameters resource for successful lookup responses.
ClassMethod BuildLookupResponse(pContext As %DynamicObject, pConcept As Terminology.Snomed.DTO.ConceptResult) As %DynamicObject [ Private ]
{
    Set response = ##class(%DynamicObject).%New()
    Set parameters = ##class(%DynamicArray).%New()
    Do response.%Set("resourceType", "Parameters")
    Do response.%Set("parameter", parameters)

    If pContext.%Get("systemName") '= "" {
        Do parameters.%Push(..BuildStringParameter("name", pContext.%Get("systemName")))
    }

    If pContext.%Get("version") '= "" {
        Do parameters.%Push(..BuildStringParameter("version", pContext.%Get("version")))
    }

    If pConcept.PreferredTerm '= "" {
        Do parameters.%Push(..BuildStringParameter("display", pConcept.PreferredTerm))
    }

    Quit response
}

ClassMethod BuildStringParameter(pName As %String, pValue As %String) As %DynamicObject
{
    Set parameter = ##class(%DynamicObject).%New()
    Do parameter.%Set("name", pName)
    Do parameter.%Set("valueString", pValue)
    Quit parameter
}

}
