/// Base customization hook for the Terminology FHIR server.
Class Terminology.Fhir.Interactions Extends HS.FHIRServer.Storage.Json.Interactions
{

Parameter OperationHandlerClass = "Terminology.Fhir.Operations.TerminologyOperations";

Method Read(pResourceType As %String, pResourceId As %String, pVersionId As %String = "") As %DynamicObject
{
    if pResourceType="CodeSystem" {
        set tSC = ##class(Terminology.Core.TermService).%New().GetCodeSystemInfo(pResourceId, .info)
        $$$ThrowOnError(tSC)

        set resource = ##class(Terminology.Fhir.ResourceMapper).BuildCodeSystem(info)
        if $IsObject(resource) {
            quit resource
        }
    }
    elseif pResourceType="ValueSet" {
        set tSC = ##class(Terminology.Core.TermService).%New().GetValueSetInfo("snomed", pResourceId, .info)
        $$$ThrowOnError(tSC)

        set resource = ##class(Terminology.Fhir.ResourceMapper).BuildValueSet(info)
        if $IsObject(resource) {
            quit resource
        }
    }

    quit ##super(pResourceType, pResourceId, pVersionId)
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
Method Search(pResourceType As %String, pCompartment As %String, pCompartmentId As %String, pParameters As HS.FHIRServer.API.Data.QueryParameters = "", ByRef pSortKeys = "") As HS.FHIRServer.Util.SearchResult
{
    if pResourceType="CodeSystem" {
        quit ..SearchMetadataResources("CodeSystem", pParameters)
    }
    elseif pResourceType="ValueSet" {
        quit ..SearchMetadataResources("ValueSet", pParameters)
    }

    quit ##super(pResourceType, pCompartment, pCompartmentId, pParameters, .pSortKeys)
}

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
        Set tSC = service.SearchValueSets("snomed", $Get(filters("url")), $Get(filters("_id")), $Get(filters("name")), $Get(filters("version")), .searchResult)
        $$$ThrowOnError(tSC)
        Set tSC = ..AddValueSetRows(result, searchResult)
        $$$ThrowOnError(tSC)
        Quit result
    }

    Quit result
}

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
