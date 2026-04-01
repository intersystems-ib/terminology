/// Implements the CodeSystem/$validate-code FHIR operation for the terminology server.
Class Terminology.Fhir.ValidateCodeOperation Extends HS.FHIRServer.API.OperationHandler
{

/// Preserves built-in operations and registers CodeSystem/$validate-code.
ClassMethod AddSupportedOperations(pMap As %DynamicObject)
{
    Do ##class(HS.FHIRServer.Storage.BuiltInOperations).AddSupportedOperations(pMap)
    Do pMap.%Set("validate-code", "http://hl7.org/fhir/OperationDefinition/CodeSystem-validate-code")
}

/// Handles [base]/CodeSystem/$validate-code.
ClassMethod FHIRTypeOpValidatecode(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    Do ..ProcessCodeSystemValidateCode(pService, pRequest, pResponse, "CodeSystem", "")
}

/// Handles [base]/CodeSystem/{id}/$validate-code.
ClassMethod FHIRInstanceOpValidatecode(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    Do ..ProcessCodeSystemValidateCode(pService, pRequest, pResponse, "CodeSystem", pRequest.Id)
}

/// Keeps the FHIR layer thin by validating request semantics and delegating code validation.
ClassMethod ProcessCodeSystemValidateCode(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response, pResourceType As %String, pResourceId As %String = "")
{
    If pResourceType'="CodeSystem" {
        $$$ThrowFHIR($$$HSFHIRErrLastnInvalidResourceType, pResourceType, $$$OutcomeInvalid(400))
    }

    Do pService.interactions.AddQueriedResourceTypes($LB(pResourceType))

    Set tSC = ..ParseValidateCodeInputs(pRequest, .inputs)
    $$$ThrowOnError(tSC)

    Set tSC = ##class(Terminology.Fhir.LookupOperation).ResolveLookupContext(pResourceId, inputs.system, inputs.version, "", .context)
    $$$ThrowOnError(tSC)

    If inputs.code = "" {
        $$$ThrowFHIR($$$GeneralError, "The code parameter is required for CodeSystem/$validate-code", $$$OutcomeInvalid(400))
    }

    Set tSC = ##class(Terminology.Core.TermService).%New().ValidateCode(
        context.system,
        context.version,
        inputs.code,
        .validation
    )
    $$$ThrowOnError(tSC)

    If (inputs.display '= "") && validation.Exists && validation.Active {
        Set tSC = ##class(Terminology.Core.TermService).%New().LookupCode(
            context.system,
            inputs.code,
            context.version,
            context.lang,
            context.dialect,
            .concept
        )
        $$$ThrowOnError(tSC)
    }

    Set response = ..BuildValidateCodeResponse(inputs, validation, $Get(concept))
    Set pResponse.Status = 200
    Set pResponse.Json = response
}

/// Supports a narrow MVP parameter set for GET-based validate-code requests.
ClassMethod ParseValidateCodeInputs(pRequest As HS.FHIRServer.API.Data.Request, Output pInputs As %DynamicObject) As %Status [ Private ]
{
    Set pInputs = ##class(%DynamicObject).%New()
    Do pInputs.%Set("code", "")
    Do pInputs.%Set("system", "")
    Do pInputs.%Set("version", "")
    Do pInputs.%Set("display", "")

    For index=1:1:$ListLength($LB("code","system","version","display")) {
        Set paramName = $List($LB("code","system","version","display"), index)
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

/// Builds a minimal Parameters resource for successful validate-code responses.
ClassMethod BuildValidateCodeResponse(pInputs As %DynamicObject, pValidation As Terminology.Snomed.DTO.ValidateCodeResult, pConcept = "") As %DynamicObject [ Private ]
{
    Set response = ##class(%DynamicObject).%New()
    Set parameters = ##class(%DynamicArray).%New()
    Set result = 0
    Set message = ""

    If pValidation.Exists && pValidation.Active {
        Set result = 1
        Set message = "Code is valid in the code system."
    } ElseIf pValidation.Exists {
        Set message = "Code exists but is inactive in the code system."
    } Else {
        Set message = "Code was not found in the code system."
    }

    If (pInputs.%Get("display") '= "") && $IsObject(pConcept) && (pConcept.PreferredTerm '= pInputs.%Get("display")) {
        Set result = 0
        Set message = "The display does not match the preferred term for the code."
    }

    Do response.%Set("resourceType", "Parameters")
    Do response.%Set("parameter", parameters)
    Do parameters.%Push(..BuildBooleanParameter("result", result))
    Do parameters.%Push(##class(Terminology.Fhir.LookupOperation).BuildStringParameter("message", message))

    If pInputs.%Get("display") '= "" {
        Do parameters.%Push(##class(Terminology.Fhir.LookupOperation).BuildStringParameter("display", pInputs.%Get("display")))
    }

    Quit response
}

ClassMethod BuildBooleanParameter(pName As %String, pValue As %Boolean) As %DynamicObject [ Private ]
{
    Set parameter = ##class(%DynamicObject).%New()
    Do parameter.%Set("name", pName)
    Do parameter.%Set("valueBoolean", pValue)
    Quit parameter
}

}
