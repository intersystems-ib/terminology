/// Shared SNOMED unit test fixture and HTTP helper methods.
Class Terminology.Tests.Snomed.TestBase Extends %UnitTest.TestCase
{

Parameter FixtureReleaseId = "UT-SNOMED-20260401";

Parameter ParentConceptId = 100000000001;

Parameter ChildConceptId = 100000000002;

Parameter InactiveConceptId = 100000000003;

Parameter ParentDescriptionId = 200000000001;

Parameter ChildDescriptionId = 200000000002;

Parameter InactiveDescriptionId = 200000000003;

Parameter RefsetId = 199000000001;

/// Seeds a minimal release-scoped SNOMED dataset for the native API and service tests.
Method OnBeforeAllTests() As %Status
{
    Set tSC = ..CleanupFixture()
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertConcept(..#ParentConceptId, 1, ..#ParentDescriptionId, "Concepto padre sintetico")
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertConcept(..#ChildConceptId, 1, ..#ChildDescriptionId, "Concepto hijo sintetico")
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertConcept(..#InactiveConceptId, 0, ..#InactiveDescriptionId, "Concepto inactivo sintetico")
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertClosure(..#ParentConceptId, ..#ParentConceptId, 0)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertClosure(..#ChildConceptId, ..#ChildConceptId, 0)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertClosure(..#InactiveConceptId, ..#InactiveConceptId, 0)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertClosure(..#ParentConceptId, ..#ChildConceptId, 1)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertRefsetMember(..#RefsetId, "utm-1", ..#ChildConceptId, 1)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertRefsetMember(..#RefsetId, "utm-2", ..#ParentConceptId, 0)
    Return tSC
}

/// Removes the synthetic release rows created for this test suite.
Method OnAfterAllTests() As %Status
{
    Return ..CleanupFixture()
}

/// Inserts one concept plus its matching Spanish description and preferred term.
Method InsertConcept(pConceptId As %String, pActive As %Integer, pDescriptionId As %String, pTerm As %String) As %Status
{
    Set concept = ##class(Terminology.Snomed.Concept).%New()
    Set concept.ReleaseId = ..#FixtureReleaseId
    Set concept.ConceptId = pConceptId
    Set concept.Active = pActive
    Set concept.ModuleId = 900000000000207008
    Set concept.DefinitionStatusId = 900000000000074008
    Set concept.EffectiveTime = $ZDATEH("2026-04-01", 3)
    Set tSC = concept.%Save()
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set description = ##class(Terminology.Snomed.Description).%New()
    Set description.ReleaseId = ..#FixtureReleaseId
    Set description.DescriptionId = pDescriptionId
    Set description.ConceptId = pConceptId
    Set description.Active = pActive
    Set description.TypeId = 900000000000013009
    Set description.Lang = "es"
    Set description.Term = pTerm
    Set description.CaseSignificanceId = 900000000000448009
    Set description.EffectiveTime = $ZDATEH("2026-04-01", 3)
    Set tSC = description.%Save()
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set preferred = ##class(Terminology.Snomed.PreferredTerm).%New()
    Set preferred.ReleaseId = ..#FixtureReleaseId
    Set preferred.ConceptId = pConceptId
    Set preferred.Lang = "es"
    Set preferred.Dialect = "es-ES"
    Set preferred.DescriptionId = pDescriptionId
    Set preferred.Term = pTerm
    Set preferred.TermNorm = $ZCONVERT(pTerm, "L")
    Return preferred.%Save()
}

/// Inserts one inferred closure row used by hierarchy and subsumption tests.
Method InsertClosure(pAncestorId As %String, pDescendantId As %String, pDepth As %Integer) As %Status
{
    Set closure = ##class(Terminology.Snomed.IsaClosure).%New()
    Set closure.ReleaseId = ..#FixtureReleaseId
    Set closure.View = "inferred"
    Set closure.AncestorId = pAncestorId
    Set closure.DescendantId = pDescendantId
    Set closure.Depth = pDepth
    Return closure.%Save()
}

/// Inserts one refset membership row for expand-like native API checks.
Method InsertRefsetMember(pRefsetId As %String, pMemberId As %String, pReferencedId As %String, pActive As %Integer) As %Status
{
    Set member = ##class(Terminology.Snomed.RefsetMember).%New()
    Set member.ReleaseId = ..#FixtureReleaseId
    Set member.RefsetId = pRefsetId
    Set member.MemberId = pMemberId
    Set member.ReferencedId = pReferencedId
    Set member.Active = pActive
    Set member.EffectiveTime = $ZDATEH("2026-04-01", 3)
    Set member.Extra = ""
    Return member.%Save()
}

/// Deletes all synthetic rows for the dedicated fixture release.
Method CleanupFixture() As %Status
{
    Set statements = $LB(
        "DELETE FROM Terminology_Snomed.RefsetMember WHERE ReleaseId = ?", 
        "DELETE FROM Terminology_Snomed.IsaClosure WHERE ReleaseId = ?", 
        "DELETE FROM Terminology_Snomed.PreferredTerm WHERE ReleaseId = ?", 
        "DELETE FROM Terminology_Snomed.Description WHERE ReleaseId = ?", 
        "DELETE FROM Terminology_Snomed.Concept WHERE ReleaseId = ?"
    )

    For index=1:1:$LISTLENGTH(statements) {
        Set tSC = ..ExecuteUpdate($LISTGET(statements, index), ..#FixtureReleaseId)
        If $$$ISERR(tSC) {
            Return tSC
        }
    }

    Return $$$OK
}

/// Executes one parameterized SQL update statement.
Method ExecuteUpdate(pSql As %String, pValue As %String) As %Status
{
    Try {
        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare(pSql)
        If $$$ISERR(tSC) {
            Return tSC
        }
        Do stmt.%Execute(pValue)
        Return $$$OK
    } Catch ex {
        Return ex.AsStatus()
    }
}

/// Calls the deployed native SNOMED API over loopback HTTP and parses the JSON response.
Method InvokeApi(pMethodName As %String, pArg1 As %String = "", pArg2 As %String = "", pParamList As %List = "", Output pResponseObject As %DynamicObject, Output pHttpStatus As %String) As %Status
{
    Set pResponseObject = {}
    Set pHttpStatus = ""
    Set path = ..BuildApiPath(pMethodName, pArg1, pArg2, pParamList)
    If path = "" {
        Return $$$ERROR($$$GeneralError, "Unsupported API method for test helper: "_pMethodName)
    }

    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "127.0.0.1"
        Set request.Port = 52773
        Set request.Https = 0
        Set request.ContentType = "application/json"
        Set request.Username = "superuser"
        Set request.Password = "SYS"
        
        Set tSC = request.Get(path)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Set response = request.HttpResponse
        If '$IsObject(response) {
            Return $$$ERROR($$$GeneralError, "No HTTP response returned by "_pMethodName)
        }

        Set pHttpStatus = response.StatusLine
        Set payload = ..ReadHttpResponseBody(response)
        If (response.StatusCode < 200) || (response.StatusCode > 299) {
            Return $$$ERROR($$$GeneralError, "HTTP "_response.StatusCode_" returned by "_pMethodName_": "_payload)
        }

        If payload '= "" {
            Set pResponseObject = ##class(%DynamicObject).%FromJSON(payload)
        }

        Return $$$OK
    } Catch ex {
        Return ex.AsStatus()
    }
}

/// Maps test helper method names to native SNOMED API routes.
Method BuildApiPath(pMethodName As %String, pArg1 As %String = "", pArg2 As %String = "", pParamList As %List = "") As %String
{
    Set basePath = "/terminology/snomed"

    If pMethodName = "Search" {
        Set path = basePath_"/search"
    } ElseIf pMethodName = "GetConcept" {
        Set path = basePath_"/concepts/"_pArg1
    } ElseIf pMethodName = "GetChildren" {
        Set path = basePath_"/concepts/"_pArg1_"/children"
    } ElseIf pMethodName = "GetSubsumes" {
        Set path = basePath_"/subsumes/"_pArg1_"/"_pArg2
    } ElseIf pMethodName = "GetRefsets" {
        Set path = basePath_"/refsets"
    } ElseIf pMethodName = "GetRefsetMembers" {
        Set path = basePath_"/refsets/"_pArg1_"/members"
    } ElseIf pMethodName = "ValidateCode" {
        Set path = basePath_"/validate-code"
    } Else {
        Return ""
    }

    Set query = ..BuildQueryString(pParamList)
    If query '= "" {
        Set path = path_"?"_query
    }

    Return path
}

/// Builds a query string from alternating key/value list items.
Method BuildQueryString(pParamList As %List = "") As %String
{
    Set query = ""

    For index=1:2:$LISTLENGTH(pParamList) {
        Set key = $LISTGET(pParamList, index)
        Set value = $LISTGET(pParamList, index + 1)
        If query '= "" {
            Set query = query_"&"
        }
        Set query = query_..UrlEncode(key)_"="_..UrlEncode(value)
    }

    Return query
}

/// Applies the small subset of URL encoding needed by the current test parameters.
Method UrlEncode(pValue As %String = "") As %String
{
    Set text = $Get(pValue)
    Set text = $Replace(text, "%", "%25")
    Set text = $Replace(text, " ", "%20")
    Set text = $Replace(text, "?", "%3F")
    Set text = $Replace(text, "&", "%26")
    Set text = $Replace(text, "=", "%3D")
    Set text = $Replace(text, "/", "%2F")
    Return text
}

/// Reads the full HTTP response body into one string.
Method ReadHttpResponseBody(pResponse As %Net.HttpResponse) As %String
{
    Set text = ""
    If '$IsObject(pResponse) {
        Return text
    }

    If $IsObject(pResponse.Data) {
        While 'pResponse.Data.AtEnd {
            Set text = text_pResponse.Data.Read()
        }
    }

    Return text
}

/// Returns one item from a JSON array property by zero-based index.
Method GetArrayItem(pObject As %DynamicObject, pProperty As %String, pIndex As %Integer = 0) As %DynamicObject
{
    Set array = pObject.%Get(pProperty)
    If '$IsObject(array) {
        Return ""
    }

    Return array.%Get(pIndex)
}

}
