/// Implements the CodeSystem/$lookup FHIR operation for the terminology server.
Class Terminology.Fhir.Operations.LookupOperation Extends HS.FHIRServer.API.OperationHandler
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
/// The returned DTO is terminology-specific, so the response mapping resolves code and display fields
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

    Set conceptCode = ..GetLookupResultCode(context, concept)
    If conceptCode = "" {
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
        Set requestedSystem = $Select(resourceSystem'="":resourceSystem, 1:##class(Terminology.Core.TerminologyRegistry).GetCodeSystemUri("snomed"))
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
    If pSystem = "" {
        Return ""
    }

    Set canonicalUri = ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemUri(pSystem)
    If canonicalUri '= "" {
        Return canonicalUri
    }

    Return pSystem
}

/// Builds a minimal Parameters resource for successful lookup responses.
/// Code and display are resolved through helpers because SNOMED and LOINC use different DTO fields.
ClassMethod BuildLookupResponse(pContext As %DynamicObject, pConcept) As %DynamicObject [ Private ]
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

    Set code = ..GetLookupResultCode(pContext, pConcept)
    If code '= "" {
        Do parameters.%Push(..BuildStringParameter("code", code))
    }

    If pContext.%Get("system") '= "" {
        Do parameters.%Push(..BuildStringParameter("system", pContext.%Get("system")))
    }

    Set display = ..GetLookupResultDisplay(pContext, pConcept)
    If display '= "" {
        Do parameters.%Push(..BuildStringParameter("display", display))
    }

    Quit response
}

/// Extracts the code value from the terminology-specific lookup DTO.
ClassMethod GetLookupResultCode(pContext As %DynamicObject, pConcept) As %String
{
    If '$IsObject(pConcept) {
        Return ""
    }

    Set systemId = ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemId(pContext.%Get("system"))

    // LOINC lookup DTOs expose the code as `LoincNum`, while SNOMED uses `ConceptId`.
    If systemId = "loinc" {
        Return ..GetPropertySafely(pConcept, "LoincNum")
    }

    If systemId = "icd-10" {
        Return ..GetPropertySafely(pConcept, "Code")
    }

    Return ..GetPropertySafely(pConcept, "ConceptId")
}

/// Extracts the best display value from the terminology-specific lookup DTO.
ClassMethod GetLookupResultDisplay(pContext As %DynamicObject, pConcept) As %String
{
    If '$IsObject(pConcept) {
        Return ""
    }

    Set systemId = ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemId(pContext.%Get("system"))

    // LOINC does not provide one preferred-term field, so prefer the most user-facing labels first.
    If systemId = "loinc" {
        Set display = ..GetPropertySafely(pConcept, "LongCommonName")
        If display '= "" {
            Return display
        }

        Set display = ..GetPropertySafely(pConcept, "DisplayName")
        If display '= "" {
            Return display
        }

        Set display = ..GetPropertySafely(pConcept, "ShortName")
        If display '= "" {
            Return display
        }

        Return ..GetPropertySafely(pConcept, "ConsumerName")
    }

    If systemId = "icd-10" {
        Return ..GetPropertySafely(pConcept, "Description")
    }

    Return ..GetPropertySafely(pConcept, "PreferredTerm")
}

/// Convenience helper for callers that only have the DTO instance and not the lookup context.
ClassMethod GetLookupResultDisplayFromConcept(pConcept) As %String
{
    Set context = ##class(%DynamicObject).%New()

    If '$IsObject(pConcept) {
        Return ""
    }

    // Validate-code may only have the lookup DTO instance, so infer the terminology from the class name.
    Set className = $Get(pConcept.%ClassName(1))
    If className["Terminology.Loinc." {
        Do context.%Set("system", ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemUri("loinc"))
    } ElseIf className["Terminology.ICD." {
        Do context.%Set("system", ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemUri("icd-10"))
    } Else {
        Do context.%Set("system", ##class(Terminology.Core.TerminologyRegistry).GetCodeSystemUri("snomed"))
    }

    Return ..GetLookupResultDisplay(context, pConcept)
}

/// Reads an optional property without forcing callers to care which DTO class was returned.
ClassMethod GetPropertySafely(pObject, pPropertyName As %String) As %String [ Private ]
{
    Try {
        Return $PROPERTY(pObject, pPropertyName)
    } Catch ex {
        Return ""
    }
}

/// Builds one string-valued Parameters.entry object for FHIR operation responses.
ClassMethod BuildStringParameter(pName As %String, pValue As %String) As %DynamicObject
{
    Set parameter = ##class(%DynamicObject).%New()
    Do parameter.%Set("name", pName)
    Do parameter.%Set("valueString", pValue)
    Return parameter
}

}
