/// Shared LOINC unit test fixture and HTTP helper methods.
Class Terminology.Tests.Loinc.TestBase Extends Terminology.Tests.Snomed.TestBase
{

Parameter FixtureReleaseId = "UT-LOINC-20260401";

Parameter ParentCode = "718-7";

Parameter ChildCode = "4548-4";

Parameter InactiveCode = "777-7";

Parameter GroupId = "LG8749-6";

Parameter PartNumber = "LP12345-6";

Parameter HierarchyType = "COMPONENTBYSYSTEM";

/// Seeds a minimal release-scoped LOINC dataset for the native API tests.
Method OnBeforeAllTests() As %Status
{
    Set tSC = ..CleanupFixture()
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertCode(..#ParentCode, "ACTIVE", "Hemoglobin", "MCnc", "Pt", "Bld", "Qn", "", "CHEM", "Hemoglobina", "Hgb Bld-mCnc", "Hemoglobina en sangre")
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertCode(..#ChildCode, "ACTIVE", "Hemoglobin panel", "Find", "Pt", "Bld", "Nom", "", "PANEL", "Panel de hemoglobina", "Panel de hemoglobina", "Panel de hemoglobina por sistema")
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertCode(..#InactiveCode, "DEPRECATED", "Legacy hemoglobin", "MCnc", "Pt", "Bld", "Qn", "", "CHEM", "Hemoglobina obsoleta", "Hgb obsoleta", "Hemoglobina obsoleta en sangre")
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertDisplay(..#ParentCode, "es", "LONG_COMMON_NAME", "Hemoglobina en sangre", 1)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertDisplay(..#ParentCode, "es", "SHORT_NAME", "Hemoglobina", 2)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertDisplay(..#ChildCode, "es", "LONG_COMMON_NAME", "Panel eritrocitario por sistema", 1)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertPart(..#PartNumber, "COMPONENT", "Hemoglobin", "Hemoglobina", "ACTIVE")
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertCodePartLink(..#ParentCode, ..#PartNumber, "COMPONENT", "Primary", "COMPONENT")
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertClosure(..#ParentCode, ..#ParentCode, 0)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertClosure(..#ChildCode, ..#ChildCode, 0)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertClosure(..#ParentCode, ..#ChildCode, 1)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set tSC = ..InsertGroup(..#GroupId, "Grupo de hemoglobina", "LG", ..#FixtureReleaseId)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Return ..InsertGroupMember(..#GroupId, ..#ParentCode)
}

/// Removes the synthetic release rows created for this test suite.
Method OnAfterAllTests() As %Status
{
    Return ..CleanupFixture()
}

/// Inserts one LOINC code row with enough fields for lookup and validate-code tests.
Method InsertCode(pCode As %String, pStatus As %String, pComponent As %String, pPropertyCode As %String, pTimeAspct As %String, pSystemCode As %String, pScaleTyp As %String, pMethodTyp As %String, pClassCode As %String, pConsumerName As %String, pShortName As %String, pDisplayName As %String) As %Status
{
    Set code = ##class(Terminology.Loinc.Code).%New()
    Set code.ReleaseId = ..#FixtureReleaseId
    Set code.LoincNum = pCode
    Set code.Component = pComponent
    Set code.PropertyCode = pPropertyCode
    Set code.TimeAspct = pTimeAspct
    Set code.SystemCode = pSystemCode
    Set code.ScaleTyp = pScaleTyp
    Set code.MethodTyp = pMethodTyp
    Set code.ClassCode = pClassCode
    Set code.Status = pStatus
    Set code.ConsumerName = pConsumerName
    Set code.ShortName = pShortName
    Set code.LongCommonName = pDisplayName
    Set code.DefinitionDescription = "Synthetic LOINC fixture row for "_pCode
    Set code.DisplayName = pDisplayName
    Return code.%Save()
}

/// Inserts one localized display row used by search and group member tests.
Method InsertDisplay(pCode As %String, pLang As %String, pDisplayType As %String, pDisplay As %String, pRankOrder As %Integer) As %Status
{
    Set display = ##class(Terminology.Loinc.Display).%New()
    Set display.ReleaseId = ..#FixtureReleaseId
    Set display.LoincNum = pCode
    Set display.Lang = pLang
    Set display.DisplayType = pDisplayType
    Set display.Display = pDisplay
    Set display.DisplayNorm = $ZCONVERT(pDisplay, "L")
    Set display.RankOrder = pRankOrder
    Return display.%Save()
}

/// Inserts one LOINC part row.
Method InsertPart(pPartNumber As %String, pPartTypeName As %String, pPartName As %String, pPartDisplayName As %String, pStatus As %String) As %Status
{
    Set part = ##class(Terminology.Loinc.Part).%New()
    Set part.ReleaseId = ..#FixtureReleaseId
    Set part.PartNumber = pPartNumber
    Set part.PartTypeName = pPartTypeName
    Set part.PartName = pPartName
    Set part.PartDisplayName = pPartDisplayName
    Set part.Status = pStatus
    Return part.%Save()
}

/// Inserts one code-to-part link for the native parts endpoint.
Method InsertCodePartLink(pCode As %String, pPartNumber As %String, pPartTypeName As %String, pLinkTypeName As %String, pPropertySlot As %String) As %Status
{
    Set link = ##class(Terminology.Loinc.CodePartLink).%New()
    Set link.ReleaseId = ..#FixtureReleaseId
    Set link.LoincNum = pCode
    Set link.PartNumber = pPartNumber
    Set link.PartTypeName = pPartTypeName
    Set link.LinkTypeName = pLinkTypeName
    Set link.PropertySlot = pPropertySlot
    Return link.%Save()
}

/// Inserts one hierarchy closure row used by native ancestor and descendant checks.
Method InsertClosure(pAncestorCode As %String, pDescendantCode As %String, pDepth As %Integer) As %Status
{
    Set closure = ##class(Terminology.Loinc.Closure).%New()
    Set closure.ReleaseId = ..#FixtureReleaseId
    Set closure.HierarchyType = ..#HierarchyType
    Set closure.AncestorCode = pAncestorCode
    Set closure.DescendantCode = pDescendantCode
    Set closure.Depth = pDepth
    Return closure.%Save()
}

/// Inserts one LOINC group row for group and member endpoints.
Method InsertGroup(pGroupId As %String, pGroupName As %String, pGroupType As %String, pVersion As %String) As %Status
{
    Set group = ##class(Terminology.Loinc.LoincGroup).%New()
    Set group.ReleaseId = ..#FixtureReleaseId
    Set group.GroupId = pGroupId
    Set group.GroupName = pGroupName
    Set group.GroupType = pGroupType
    Set group.Version = pVersion
    Return group.%Save()
}

/// Inserts one LOINC group membership row.
Method InsertGroupMember(pGroupId As %String, pCode As %String) As %Status
{
    Set member = ##class(Terminology.Loinc.GroupMember).%New()
    Set member.ReleaseId = ..#FixtureReleaseId
    Set member.GroupId = pGroupId
    Set member.LoincNum = pCode
    Return member.%Save()
}

/// Deletes all synthetic rows for the dedicated fixture release.
Method CleanupFixture() As %Status
{
    Set statements = $LB(
        "DELETE FROM Terminology_Loinc.GroupMember WHERE ReleaseId = ?",
        "DELETE FROM Terminology_Loinc.LoincGroup WHERE ReleaseId = ?",
        "DELETE FROM Terminology_Loinc.Closure WHERE ReleaseId = ?",
        "DELETE FROM Terminology_Loinc.CodePartLink WHERE ReleaseId = ?",
        "DELETE FROM Terminology_Loinc.Part WHERE ReleaseId = ?",
        "DELETE FROM Terminology_Loinc.Display WHERE ReleaseId = ?",
        "DELETE FROM Terminology_Loinc.Code WHERE ReleaseId = ?"
    )

    For index=1:1:$LISTLENGTH(statements) {
        Set tSC = ..ExecuteUpdate($LISTGET(statements, index), ..#FixtureReleaseId)
        If $$$ISERR(tSC) {
            Return tSC
        }
    }

    Return $$$OK
}

/// Calls the deployed native LOINC API over loopback HTTP and parses the JSON response.
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

/// Maps test helper method names to native LOINC API routes.
Method BuildApiPath(pMethodName As %String, pArg1 As %String = "", pArg2 As %String = "", pParamList As %List = "") As %String
{
    Set basePath = "/terminology/loinc"

    If pMethodName = "Search" {
        Set path = basePath_"/search"
    } ElseIf pMethodName = "GetCode" {
        Set path = basePath_"/codes/"_pArg1
    } ElseIf pMethodName = "GetDisplays" {
        Set path = basePath_"/codes/"_pArg1_"/displays"
    } ElseIf pMethodName = "GetParts" {
        Set path = basePath_"/codes/"_pArg1_"/parts"
    } ElseIf pMethodName = "GetAncestors" {
        Set path = basePath_"/codes/"_pArg1_"/ancestors"
    } ElseIf pMethodName = "GetDescendants" {
        Set path = basePath_"/codes/"_pArg1_"/descendants"
    } ElseIf pMethodName = "GetGroups" {
        Set path = basePath_"/groups"
    } ElseIf pMethodName = "GetGroupMembers" {
        Set path = basePath_"/groups/"_pArg1_"/members"
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

}
