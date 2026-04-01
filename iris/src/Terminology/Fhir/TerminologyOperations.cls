/// Aggregates terminology-specific FHIR operation classes for the server strategy.
Class Terminology.Fhir.TerminologyOperations Extends (Terminology.Fhir.LookupOperation, Terminology.Fhir.ValidateCodeOperation, Terminology.Fhir.SubsumesOperation)
{

/// Enumerates the operations supported by this terminology server operation chain.
ClassMethod AddSupportedOperations(pMap As %DynamicObject)
{
    Do ##class(Terminology.Fhir.LookupOperation).AddSupportedOperations(pMap)
    Do ##class(Terminology.Fhir.ValidateCodeOperation).AddSupportedOperations(pMap)
    Do ##class(Terminology.Fhir.SubsumesOperation).AddSupportedOperations(pMap)
}

/// @API
/// This is the entry point, called from the FHIR Service instance. The default processing
/// will further dispatch the request to a ClassMethod in this class to process the requested
/// $Operation (see class documentation for details)
/// <br> Note, This method may be overridden if the programmer would rather not use the provided
/// dispatch mechanism.
ClassMethod ProcessOperation(pService As HS.FHIRServer.API.Service, pRequest As HS.FHIRServer.API.Data.Request, pResponse As HS.FHIRServer.API.Data.Response)
{
    // fix: remove hyphens from operation name
    Set pRequest.OperationName = $tr(pRequest.OperationName, "-", "")

    return ##super(pService, pRequest, pResponse)
}

}
