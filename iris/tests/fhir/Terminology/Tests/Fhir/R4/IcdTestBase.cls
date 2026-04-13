/// Shared FHIR R4 helper methods combined with the synthetic ICD fixture.
Class Terminology.Tests.Fhir.R4.IcdTestBase Extends Terminology.Tests.ICD.TestBase
{

Parameter CodeSystemUri = "http://id.who.int/icd/release/10";

/// Seeds the ICD native fixture plus the core metadata rows required by the FHIR layer.
Method OnBeforeAllTests() As %Status
{
    Set tSC = ##super()
    If $$$ISERR(tSC) {
        Return tSC
    }

    Return ..EnsureMetadataFixture()
}

/// Removes the ICD FHIR metadata fixture and then the native ICD fixture rows.
Method OnAfterAllTests() As %Status
{
    Set tSC = ..CleanupMetadataFixture()
    If $$$ISERR(tSC) {
        Return tSC
    }

    Return ##super()
}

/// Creates the CodeSystem and active VersionRelease rows needed by FHIR metadata lookups.
Method EnsureMetadataFixture() As %Status
{
    Set tSC = ..CleanupMetadataFixture()
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set codeSystem = ##class(Terminology.Core.CodeSystem).%New()
    Set codeSystem.SystemUri = ..#CodeSystemUri
    Set codeSystem.Name = "ICD10"
    Set codeSystem.DefaultLang = "es"
    Set codeSystem.DefaultDialect = "es-ES"
    Set codeSystem.Notes = "ICD-10 code system"
    Set tSC = codeSystem.%Save()
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set versionRelease = ##class(Terminology.Core.VersionRelease).%New()
    Set versionRelease.ReleaseId = ..#FixtureReleaseId
    Set versionRelease.SystemUri = ..#CodeSystemUri
    Set versionRelease.VersionUri = ""
    Set versionRelease.IsActive = 1
    Set versionRelease.Metadata = ""
    Return versionRelease.%Save()
}

/// Deletes the ICD core metadata rows created for this FHIR suite.
Method CleanupMetadataFixture() As %Status
{
    Set statements = $LB(
        "DELETE FROM Terminology_Core.VersionRelease WHERE SystemUri = ? AND ReleaseId = ?",
        "DELETE FROM Terminology_Core.CodeSystem WHERE SystemUri = ?"
    )

    Set tSC = ..ExecutePreparedUpdate($List(statements, 1), $LB(..#CodeSystemUri, ..#FixtureReleaseId))
    If $$$ISERR(tSC) {
        Return tSC
    }

    Return ..ExecutePreparedUpdate($List(statements, 2), $LB(..#CodeSystemUri))
}

/// Executes one parameterized SQL update statement using the supplied argument list.
Method ExecutePreparedUpdate(pSql As %String, pArgs As %List = "") As %Status
{
    Try {
        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare(pSql)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Set argCount = $ListLength($Get(pArgs))
        If argCount>0 {
            For index=1:1:argCount {
                Set args(index) = $List(pArgs, index)
            }
            Set args = argCount
            Do stmt.%Execute(args...)
        } Else {
            Do stmt.%Execute()
        }

        Return $$$OK
    } Catch ex {
        Return ex.AsStatus()
    }
}

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
