/// Maps neutral terminology metadata DTOs into minimal FHIR resources.
Class Terminology.Fhir.ResourceMapper Extends %RegisteredObject
{

/// Builds a minimal CodeSystem resource for the current MVP read support.
ClassMethod BuildCodeSystem(pInfo As Terminology.Core.DTO.CodeSystemInfo) As %DynamicObject
{
    If '$IsObject(pInfo) || (pInfo.Id = "") {
        Quit ""
    }

    Set resource = {}
    Set resource.resourceType = "CodeSystem"
    Set resource.id = pInfo.Id
    Set resource.url = pInfo.Url

    If pInfo.Version '= "" {
        Set resource.version = pInfo.Version
    }

    If pInfo.Name '= "" {
        Set resource.name = ..ToFhirName(pInfo.Name)
    }

    If pInfo.Title '= "" {
        Set resource.title = pInfo.Title
    }

    Set resource.status = $Select(pInfo.Status'="":pInfo.Status, 1:"active")
    Set resource.content = $Select(pInfo.Content'="":pInfo.Content, 1:"not-present")

    If pInfo.Description '= "" {
        Set resource.description = pInfo.Description
    }

    Quit resource
}

/// Builds a minimal ValueSet resource for the current MVP read support.
ClassMethod BuildValueSet(pInfo As Terminology.Core.DTO.ValueSetInfo) As %DynamicObject
{
    If '$IsObject(pInfo) || (pInfo.Id = "") {
        Quit ""
    }

    Set resource = {}
    Set resource.resourceType = "ValueSet"
    Set resource.id = pInfo.Id
    Set resource.url = pInfo.Url

    If pInfo.Version '= "" {
        Set resource.version = pInfo.Version
    }

    If pInfo.Name '= "" {
        Set resource.name = ..ToFhirName(pInfo.Name)
    }

    If pInfo.Title '= "" {
        Set resource.title = pInfo.Title
    }

    Set resource.status = $Select(pInfo.Status'="":pInfo.Status, 1:"active")

    If pInfo.Description '= "" {
        Set resource.description = pInfo.Description
    }

    Quit resource
}

/// Keeps generated FHIR `name` values within the simple token format expected by the spec.
ClassMethod ToFhirName(pValue As %String = "") As %String [ Private ]
{
    Set normalized = $ZSTRIP(pValue, "<>W")
    Set normalized = $TRANSLATE(normalized, " -./,:;()[]{}")
    If normalized = "" {
        Quit "TerminologyResource"
    }
    Quit normalized
}

}
