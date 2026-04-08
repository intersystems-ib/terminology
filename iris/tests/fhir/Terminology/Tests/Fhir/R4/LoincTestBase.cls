/// Shared FHIR R4 helper methods combined with the synthetic LOINC fixture.
Class Terminology.Tests.Fhir.R4.LoincTestBase Extends Terminology.Tests.Loinc.TestBase
{

/// Calls the deployed FHIR R4 API over loopback HTTP and parses the JSON response.
Method InvokeFhirApi(pPath As %String, Output pResponseObject As %DynamicObject, Output pHttpStatus As %String) As %Status
{
    Set pResponseObject = {}
    Set pHttpStatus = ""

    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "127.0.0.1"
        Set request.Port = 52773
        Set request.Https = 0
        Set request.ContentType = "application/fhir+json"
        Do request.SetHeader("Accept", "application/fhir+json")
        Set request.Username = "superuser"
        Set request.Password = "SYS"

        Set tSC = request.Get("/terminology/fhir/r4"_pPath)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Set response = request.HttpResponse
        If '$IsObject(response) {
            Return $$$ERROR($$$GeneralError, "No HTTP response returned by FHIR API")
        }

        Set pHttpStatus = response.StatusLine
        Set payload = ..ReadHttpResponseBody(response)
        If (response.StatusCode < 200) || (response.StatusCode > 299) {
            Return $$$ERROR($$$GeneralError, "HTTP "_response.StatusCode_" returned by FHIR API: "_payload)
        }

        If payload '= "" {
            Set pResponseObject = ##class(%DynamicObject).%FromJSON(payload)
        }

        Return $$$OK
    } Catch ex {
        Return ex.AsStatus()
    }
}

/// Returns the first Parameters.parameter item with the requested name.
Method GetNamedParameter(pObject As %DynamicObject, pName As %String) As %DynamicObject
{
    If '$IsObject(pObject) {
        Return ""
    }

    Set parameters = pObject.%Get("parameter")
    If '$IsObject(parameters) {
        Return ""
    }

    For index=0:1:(parameters.%Size()-1) {
        Set item = parameters.%Get(index)
        If $IsObject(item) && (item.%Get("name") = pName) {
            Return item
        }
    }

    Return ""
}

/// Returns the first Bundle.entry.resource item whose property matches the requested value.
Method FindBundleEntryResourceByProperty(pBundle As %DynamicObject, pPropertyName As %String, pExpectedValue As %String) As %DynamicObject
{
    If '$IsObject(pBundle) {
        Return ""
    }

    Set entry = pBundle.%Get("entry")
    If '$IsObject(entry) {
        Return ""
    }

    For index=0:1:(entry.%Size()-1) {
        Set resource = entry.%Get(index).%Get("resource")
        If $IsObject(resource) && (resource.%Get(pPropertyName) = pExpectedValue) {
            Return resource
        }
    }

    Return ""
}

}
