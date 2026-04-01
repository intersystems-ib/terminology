/// Aggregates terminology-specific FHIR operation classes for the server strategy.
Class Terminology.Fhir.Operations.TerminologyOperations Extends (Terminology.Fhir.Operations.LookupOperation, Terminology.Fhir.Operations.ValidateCodeOperation, Terminology.Fhir.Operations.SubsumesOperation, Terminology.Fhir.Operations.ExpandOperation)
{

/// Enumerates the operations supported by this terminology server operation chain.
ClassMethod AddSupportedOperations(pMap As %DynamicObject)
{
    Do ##class(Terminology.Fhir.Operations.LookupOperation).AddSupportedOperations(pMap)
    Do ##class(Terminology.Fhir.Operations.ValidateCodeOperation).AddSupportedOperations(pMap)
    Do ##class(Terminology.Fhir.Operations.SubsumesOperation).AddSupportedOperations(pMap)
    Do ##class(Terminology.Fhir.Operations.ExpandOperation).AddSupportedOperations(pMap)
}

/// @API
/// This is the entry point, called from the FHIR Service instance. The default processing
/// will further dispatch the request to a ClassMethod in this class to process the requested
/// $Operation (see class documentation for details)
/// <br> Note, This method may be overridden if the programmer would rather not use the provided
/// dispatch mechanism.
ClassMethod ProcessOperation(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    // Normalize hyphenated FHIR operation names to the IRIS dispatch method naming pattern.
    // (e.g. validate-code will call FHIR<Scope>OpValidatecode)
    Set pRequest.OperationName = $tr(pRequest.OperationName, "-", "")

    return ##super(pService, pRequest, pResponse)
}

}
