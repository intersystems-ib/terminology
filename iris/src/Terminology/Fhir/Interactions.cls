/// Base customization hook for the Terminology FHIR server.
Class Terminology.Fhir.Interactions Extends HS.FHIRServer.Storage.JsonAdvSQL.Interactions
{

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
        // TODO
    }
    elseif pResourceType="ValueSet" {
        // TODO
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

}
