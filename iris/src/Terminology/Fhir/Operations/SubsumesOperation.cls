/// Implements the CodeSystem/$subsumes FHIR operation for the terminology server.
Class Terminology.Fhir.Operations.SubsumesOperation Extends HS.FHIRServer.API.OperationHandler
{

/// Preserves built-in operations and registers CodeSystem/$subsumes.
ClassMethod AddSupportedOperations(pMap As %DynamicObject)
{
    Do ##class(HS.FHIRServer.Storage.BuiltInOperations).AddSupportedOperations(pMap)
    Do pMap.%Set("subsumes", "http://hl7.org/fhir/OperationDefinition/CodeSystem-subsumes")
}

/// Handles [base]/CodeSystem/$subsumes.
ClassMethod FHIRTypeOpSubsumes(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    Do ..ProcessCodeSystemSubsumes(pService, pRequest, pResponse, "CodeSystem", "")
}

/// Handles [base]/CodeSystem/{id}/$subsumes.
ClassMethod FHIRInstanceOpSubsumes(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    Do ..ProcessCodeSystemSubsumes(pService, pRequest, pResponse, "CodeSystem", pRequest.Id)
}

/// Keeps the FHIR layer thin by validating request semantics and delegating subsumption logic.
ClassMethod ProcessCodeSystemSubsumes(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response, pResourceType As %String, pResourceId As %String = "")
{
    If pResourceType'="CodeSystem" {
        $$$ThrowFHIR($$$HSFHIRErrLastnInvalidResourceType, pResourceType, $$$OutcomeInvalid(400))
    }

    Do pService.interactions.AddQueriedResourceTypes($LB(pResourceType))

    Set tSC = ..ParseSubsumesInputs(pRequest, .inputs)
    $$$ThrowOnError(tSC)

    Set tSC = ##class(Terminology.Fhir.Operations.LookupOperation).ResolveLookupContext(pResourceId, inputs.system, inputs.version, "", .context)
    $$$ThrowOnError(tSC)

    If (inputs.codeA = "") || (inputs.codeB = "") {
        $$$ThrowFHIR($$$GeneralError, "The codeA and codeB parameters are required for CodeSystem/$subsumes", $$$OutcomeInvalid(400))
    }

    Set tSC = ##class(Terminology.Core.TermService).%New().Subsumes(
        context.system,
        context.version,
        "",
        inputs.codeA,
        inputs.codeB,
        .subsumesResult
    )
    $$$ThrowOnError(tSC)

    Set response = ..BuildSubsumesResponse(subsumesResult)
    Set pResponse.Status = 200
    Set pResponse.Json = response
}

/// Supports a narrow MVP parameter set for GET-based subsumes requests.
ClassMethod ParseSubsumesInputs(pRequest As HS.FHIRServer.API.Data.Request, Output pInputs As %DynamicObject) As %Status [ Private ]
{
    Set pInputs = ##class(%DynamicObject).%New()
    Do pInputs.%Set("codeA", "")
    Do pInputs.%Set("codeB", "")
    Do pInputs.%Set("system", "")
    Do pInputs.%Set("version", "")

    For index=1:1:$ListLength($LB("codeA","codeB","system","version")) {
        Set paramName = $List($LB("codeA","codeB","system","version"), index)
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

/// Builds a minimal Parameters resource for successful subsumes responses.
/// The operation only needs the normalized relationship string, so the DTO is left untyped.
ClassMethod BuildSubsumesResponse(pResult) As %DynamicObject [ Private ]
{
    Set response = ##class(%DynamicObject).%New()
    Set parameters = ##class(%DynamicArray).%New()

    Do response.%Set("resourceType", "Parameters")
    Do response.%Set("parameter", parameters)
    Do parameters.%Push(##class(Terminology.Fhir.Operations.LookupOperation).BuildStringParameter("outcome", pResult.Relationship))

    Quit response
}

}
