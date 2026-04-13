/// Base customization hook for the Terminology FHIR server.
Class Terminology.Fhir.Interactions Extends HS.FHIRServer.Storage.Json.Interactions
{

Parameter OperationHandlerClass = "Terminology.Fhir.Operations.TerminologyOperations";

/// Starts one trace scope per incoming FHIR request before delegating to the base server behavior.
Method OnBeforeRequest(pFHIRService As HS.FHIRServer.API.Service, pFHIRRequest As HS.FHIRServer.API.Data.Request, pTimeout As %Integer)
{
    Do ##super(pFHIRService, pFHIRRequest, pTimeout)
    Do ##class(Terminology.Core.Trace).StartRequest(
        "fhir",
        "request",
        "interaction="_pFHIRRequest.Interaction_" type="_pFHIRRequest.Type_" operation="_pFHIRRequest.OperationName_" scope="_pFHIRRequest.OperationScope_" id="_pFHIRRequest.Id_" method="_pFHIRRequest.RequestMethod_" path="_pFHIRRequest.RequestPath
    )
}

/// Completes the request trace with the HTTP status after the FHIR handler finishes.
Method OnAfterRequest(pFHIRService As HS.FHIRServer.API.Service, pFHIRRequest As HS.FHIRServer.API.Data.Request, pFHIRResponse As HS.FHIRServer.API.Data.Response)
{
    Do ##class(Terminology.Core.Trace).Log("fhir", "response", "status="_pFHIRResponse.Status)
    Do ##class(Terminology.Core.Trace).EndRequest("fhir", "request-end", "status="_pFHIRResponse.Status)
    Do ##super(pFHIRService, pFHIRRequest, .pFHIRResponse)
}

/// Handles direct read support for metadata-backed CodeSystem and ValueSet resources before falling back to the base server.
Method Read(pResourceType As %String, pResourceId As %String, pVersionId As %String = "") As %DynamicObject
{
    Try {
        Do ##class(Terminology.Core.Trace).Log("fhir", "Read", "resourceType="_pResourceType_" id="_pResourceId_" versionId="_pVersionId)
        if pResourceType="CodeSystem" {
            set tSC = ##class(Terminology.Core.TermService).%New().GetCodeSystemInfo(pResourceId, .info)
            $$$ThrowOnError(tSC)

            set resource = ##class(Terminology.Fhir.ResourceMapper).BuildCodeSystem(info)
            if $IsObject(resource) {
                return resource
            }
        }
        elseif pResourceType="ValueSet" {
            set tSC = ..GetValueSetInfoAnySystem(pResourceId, .info)
            $$$ThrowOnError(tSC)

            set resource = ##class(Terminology.Fhir.ResourceMapper).BuildValueSet(info)
            if $IsObject(resource) {
                return resource
            }
        }

        Set resource = ##super(pResourceType, pResourceId, pVersionId)
        return resource
    } Catch ex {
        Do ##class(Terminology.Core.Trace).LogError("fhir", "Read", ex.DisplayString())
        Throw ex
    }
}

/// @API
/// This method performs the requested search for resources and returns a HS.FHIRServer.Util.SearchResult
/// with the selected resource information.  If the query specifies _include or _revinclude parameters, then
/// resources of type other than 'pResourceType' will be part of the result set.  Included resources will
/// be denoted in the result set 'Mode' column with the value 'include'
/// @Input pResourceType  The 'resourceType' of the resource to be searched
/// @Input pCompartmentType If not "", indicates a compartment search of the specified Compartment Type and Id
/// @Input pCompartmentId The ID of the resource comartment being searched
/// @Input pParameters A HS.FHIRServer.API.Data.QueryParameters describing the query parameters specified for the search
/// @Input pSortKeys (ByRef) A multi-dimensional structure describing any sorting to be performed on the result set.   The
/// structure of pSortKeys is an array of sort keys indexed 1-n:
///   pSortKeys(n) = 1 for ascending, 0 for descending
///   pSortKeys(n, "SearchParam") = An HS.FHIRServer.SearchParam object whose value is used to sort.
/// @Return A HS.FHIRServer.Util.SearchResult object containing one row for each selected resource.  
/// @Throws The implementation must report errors via $$$ThrowStatus.
/// Intercepts CodeSystem and ValueSet search so the FHIR layer can expose terminology metadata without persistent FHIR resources.
Method Search(pResourceType As %String, pCompartment As %String, pCompartmentId As %String, pParameters As HS.FHIRServer.API.Data.QueryParameters = "", ByRef pSortKeys = "") As HS.FHIRServer.Util.SearchResult
{
    Try {
        Do ##class(Terminology.Core.Trace).Log("fhir", "Search", "resourceType="_pResourceType_" compartment="_pCompartment_" compartmentId="_pCompartmentId)
        if pResourceType="CodeSystem" {
            Set result = ..SearchMetadataResources("CodeSystem", pParameters)
            return result
        }
        elseif pResourceType="ValueSet" {
            Set result = ..SearchMetadataResources("ValueSet", pParameters)
            return result
        }

        Set result = ##super(pResourceType, pCompartment, pCompartmentId, pParameters, .pSortKeys)
        return result
    } Catch ex {
        Do ##class(Terminology.Core.Trace).LogError("fhir", "Search", ex.DisplayString())
        Throw ex
    }
}

/// Leaves the built-in CapabilityStatement handling in place and reserves the terminology mode hook for future work.
Method LoadMetadata() As %DynamicObject
{
    // TerminologyCapabilities
    set mode = $get(%request.Data("mode",1))
    if mode="terminology" {
        // TODO
    }
    // CapabilityStatement
    return ##super()
}

/// Keeps FHIR search-type support thin by delegating metadata lookup to the neutral service layer.
Method SearchMetadataResources(pResourceType As %String, pParameters As HS.FHIRServer.API.Data.QueryParameters = "") As HS.FHIRServer.Util.SearchResult [ Private ]
{
    Set result = ##class(HS.FHIRServer.Util.SearchResult).Create()
    Set tSC = ..ValidateSupportedSearchParameters(pResourceType, pParameters, .filters)
    $$$ThrowOnError(tSC)

    Set service = ##class(Terminology.Core.TermService).%New()
    If pResourceType = "CodeSystem" {
        Set tSC = service.SearchCodeSystems($Get(filters("url")), $Get(filters("_id")), $Get(filters("name")), $Get(filters("version")), .searchResult)
        $$$ThrowOnError(tSC)
        Set tSC = ..AddCodeSystemRows(result, searchResult)
        $$$ThrowOnError(tSC)
        Quit result
    }

    If pResourceType = "ValueSet" {
        Set tSC = ..SearchValueSetsAcrossSystems(service, .filters, .searchResult)
        $$$ThrowOnError(tSC)
        Set tSC = ..AddValueSetRows(result, searchResult)
        $$$ThrowOnError(tSC)
        Quit result
    }

    Quit result
}

/// Converts neutral CodeSystem metadata rows into FHIR search result entries.
Method AddCodeSystemRows(ByRef pSearchResult As HS.FHIRServer.Util.SearchResult, pItems As Terminology.Core.DTO.CodeSystemListResult) As %Status [ Private ]
{
    If '$IsObject(pItems) {
        Quit $$$OK
    }

    For index=1:1:pItems.Items.Count() {
        Set info = pItems.Items.GetAt(index)
        Set resource = ##class(Terminology.Fhir.ResourceMapper).BuildCodeSystem(info)
        If '$IsObject(resource) {
            Continue
        }

        Set resourceId = resource.%Get("id")
        Set versionId = resource.%Get("version")
        Do pSearchResult.AddRow("CodeSystem/"_resourceId, "CodeSystem", resourceId, versionId, "match", "", resource.%ToJSON())
    }

    Quit $$$OK
}

/// Converts neutral ValueSet metadata rows into FHIR search result entries.
Method AddValueSetRows(ByRef pSearchResult As HS.FHIRServer.Util.SearchResult, pItems As Terminology.Core.DTO.ValueSetListResult) As %Status [ Private ]
{
    If '$IsObject(pItems) {
        Quit $$$OK
    }

    For index=1:1:pItems.Items.Count() {
        Set info = pItems.Items.GetAt(index)
        Set resource = ##class(Terminology.Fhir.ResourceMapper).BuildValueSet(info)
        If '$IsObject(resource) {
            Continue
        }

        Set resourceId = resource.%Get("id")
        Set versionId = resource.%Get("version")
        Do pSearchResult.AddRow("ValueSet/"_resourceId, "ValueSet", resourceId, versionId, "match", "", resource.%ToJSON())
    }

    Quit $$$OK
}

/// ValueSet ids are not globally self-describing in the current FHIR surface, so try the
/// supported systems in order and return the first match.
Method GetValueSetInfoAnySystem(pResourceId As %String, Output pInfo As Terminology.Core.DTO.ValueSetInfo) As %Status [ Private ]
{
    Set pInfo = ##class(Terminology.Core.DTO.ValueSetInfo).%New()

    Set supportedSystems = ##class(Terminology.Core.TerminologyRegistry).GetSystemsSupportingFhirValueSets()
    For systemIndex=1:1:$ListLength(supportedSystems) {
        Set system = $List(supportedSystems, systemIndex)
        Set tSC = ##class(Terminology.Core.TermService).%New().GetValueSetInfo(system, pResourceId, .pInfo)
        $$$ThrowOnError(tSC)
        If pInfo.Id '= "" {
            Return $$$OK
        }
    }

    Return $$$OK
}

/// Aggregates ValueSet search results from the supported terminology systems.
Method SearchValueSetsAcrossSystems(pService As Terminology.Core.TermService, ByRef pFilters, Output pResult As Terminology.Core.DTO.ValueSetListResult) As %Status [ Private ]
{
    Set pResult = ##class(Terminology.Core.DTO.ValueSetListResult).%New()

    Set supportedSystems = ##class(Terminology.Core.TerminologyRegistry).GetSystemsSupportingFhirValueSets()
    For systemIndex=1:1:$ListLength(supportedSystems) {
        Set system = $List(supportedSystems, systemIndex)
        Set tSC = pService.SearchValueSets(system, $Get(pFilters("url")), $Get(pFilters("_id")), $Get(pFilters("name")), $Get(pFilters("version")), .systemResult)
        $$$ThrowOnError(tSC)

        If '$IsObject(systemResult) {
            Continue
        }

        For itemIndex=1:1:systemResult.Items.Count() {
            Do pResult.Items.Insert(systemResult.Items.GetAt(itemIndex))
        }
    }

    Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(), 1:0)
    Return $$$OK
}

/// Rejects unsupported search parameters and extracts the narrow filter set currently supported for metadata resources.
Method ValidateSupportedSearchParameters(pResourceType As %String, pParameters As HS.FHIRServer.API.Data.QueryParameters = "", Output pFilters) As %Status [ Private ]
{
    Kill pFilters

    If '$IsObject(pParameters) {
        Quit $$$OK
    }

    Set searchParameters = pParameters.ExtractSearchParameters()
    If '$IsObject(searchParameters) {
        Quit $$$OK
    }

    Set supportedCount = 0
    For index=1:1:$ListLength($LB("url","_id","name","version")) {
        Set name = $List($LB("url","_id","name","version"), index)
        Set supportedCount = supportedCount + pParameters.GetParameterCount(name)
    }

    If searchParameters.Count() > supportedCount {
        Quit $$$ERROR($$$NotImplemented, "Unsupported "_pResourceType_" search parameter in request")
    }

    Set pFilters("url") = ..GetSingleSearchParameterValue(pParameters, "url")
    Set pFilters("_id") = ..GetSingleSearchParameterValue(pParameters, "_id")
    Set pFilters("name") = ..GetSingleSearchParameterValue(pParameters, "name")
    Set pFilters("version") = ..GetSingleSearchParameterValue(pParameters, "version")
    Quit $$$OK
}

/// Reads one supported search parameter value and rejects modifiers that the metadata searches do not implement.
Method GetSingleSearchParameterValue(pParameters As HS.FHIRServer.API.Data.QueryParameters, pName As %String) As %String [ Private ]
{
    If '$IsObject(pParameters) {
        Quit ""
    }

    If pParameters.GetParameterCount(pName)=0 {
        Quit ""
    }

    Set value = pParameters.GetOneParameterValue(pName, .modifier)
    If modifier '= "" {
        Set tSC = $$$ERROR($$$NotImplemented, "Unsupported search modifier on "_pName_": "_modifier)
        $$$ThrowOnError(tSC)
    }

    Quit value
}

}
