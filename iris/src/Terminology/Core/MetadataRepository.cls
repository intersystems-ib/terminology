/// Reads neutral terminology catalog metadata used by API layers.
Class Terminology.Core.MetadataRepository Extends %RegisteredObject
{

/// Returns code system metadata and the active release version when present.
Method GetCodeSystemInfo(pSystemUri As %String = "", Output pResult As Terminology.Core.DTO.CodeSystemInfo) As %Status
{
    Set pResult = ##class(Terminology.Core.DTO.CodeSystemInfo).%New()

    Try {
        If pSystemUri = "" {
            Return $$$OK
        }

        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare("SELECT Name, DefaultLang, DefaultDialect, Notes FROM Terminology_Core.CodeSystem WHERE SystemUri = ?")
        $$$ThrowOnError(tSC)

        Set rset = stmt.%Execute(pSystemUri)
        If rset.%Next() {
            Set pResult.Url = pSystemUri
            Set pResult.Name = rset.%Get("Name")
            Set pResult.Title = rset.%Get("Name")
            Set pResult.Description = rset.%Get("Notes")
            Set pResult.DefaultLang = rset.%Get("DefaultLang")
            Set pResult.DefaultDialect = rset.%Get("DefaultDialect")
        } Else {
            Return $$$OK
        }

        Set pResult.Content = "not-present"
        Set pResult.Status = "draft"

        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare("SELECT TOP 1 ReleaseId, VersionUri FROM Terminology_Core.VersionRelease WHERE SystemUri = ? AND IsActive = 1 ORDER BY EffectiveDate DESC, ReleaseId DESC")
        $$$ThrowOnError(tSC)

        Set rset = stmt.%Execute(pSystemUri)
        If rset.%Next() {
            Set pResult.Version = $Select(rset.%Get("VersionUri")'="":rset.%Get("VersionUri"), 1:rset.%Get("ReleaseId"))
            Set pResult.Status = "active"
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns minimal code system metadata rows for FHIR search/list support.
Method SearchCodeSystems(pUrl As %String = "", pName As %String = "", Output pResult As Terminology.Core.DTO.CodeSystemListResult) As %Status
{
    Set pResult = ##class(Terminology.Core.DTO.CodeSystemListResult).%New()

    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT cs.SystemUri, cs.Name, cs.DefaultLang, cs.DefaultDialect, cs.Notes, vr.ReleaseId, vr.VersionUri "_
                  "FROM Terminology_Core.CodeSystem cs "_
                  "LEFT JOIN Terminology_Core.VersionRelease vr "_
                  "ON vr.SystemUri = cs.SystemUri "_
                  "AND vr.IsActive = 1 "_
                  "AND vr.EffectiveDate = ("_
                  "SELECT MAX(vr2.EffectiveDate) FROM Terminology_Core.VersionRelease vr2 "_
                  "WHERE vr2.SystemUri = cs.SystemUri AND vr2.IsActive = 1"_
                  ") "
        Set endSQL = "ORDER BY cs.SystemUri"

        If pUrl '= "" {
            Set normalizedUrl = $ZSTRIP(pUrl, "<>W")
            Set normalizedNoSlash = normalizedUrl
            If ($EXTRACT(normalizedNoSlash, *) = "/") {
                Set normalizedNoSlash = $EXTRACT(normalizedNoSlash, 1, *-1)
            }
            Set normalizedWithSlash = normalizedNoSlash_"/"

            Set whereList = whereList_$ListBuild("(%SQLUPPER(cs.SystemUri) = %SQLUPPER(?) OR %SQLUPPER(cs.SystemUri) = %SQLUPPER(?))")
            Do ..AddArgument(.args, .argCount, normalizedNoSlash)
            Do ..AddArgument(.args, .argCount, normalizedWithSlash)
        }

        If pName '= "" {
            Set whereList = whereList_$ListBuild("%SQLUPPER(cs.Name) = %SQLUPPER(?)")
            Do ..AddArgument(.args, .argCount, pName)
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        While rset.%Next() {
            Set item = ##class(Terminology.Core.DTO.CodeSystemInfo).%New()
            Set item.Url = rset.%Get("SystemUri")
            Set item.Name = rset.%Get("Name")
            Set item.Title = rset.%Get("Name")
            Set item.Description = rset.%Get("Notes")
            Set item.DefaultLang = rset.%Get("DefaultLang")
            Set item.DefaultDialect = rset.%Get("DefaultDialect")
            Set item.Version = $Select(rset.%Get("VersionUri")'="":rset.%Get("VersionUri"), 1:rset.%Get("ReleaseId"))
            Set item.Status = $Select(item.Version'="":"active", 1:"draft")
            Set item.Content = "not-present"
            Do pResult.Items.Insert(item)
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(), 1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method AddArgument(ByRef pArgs, ByRef pArgCount, pValue As %String) [ Private ]
{
    Set pArgCount = pArgCount + 1
    Set pArgs(pArgCount) = pValue
}

Method BuildQuery(pSelect As %String, pWhereList As %List = "", pEnd As %String = "") As %String [ Private ]
{
    Set query = pSelect
    If pWhereList '= "" {
        Set query = query_" WHERE "_$ListToString(pWhereList, " AND ")
    }
    If pEnd '= "" {
        Set query = query_" "_pEnd
    }
    return query
}

Method ExecuteQuery(pQuery As %String, ByRef pArgs, pArgCount As %Integer, Output pResultSet As %SQL.StatementResult) As %Status [ Private ]
{
    Try {
        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare(pQuery)
        $$$ThrowOnError(tSC)

        If pArgCount>0 {
            Set pResultSet = stmt.%Execute(pArgs...)
        } Else {
            Set pResultSet = stmt.%Execute()
        }

        return $$$OK
    } Catch ex {
        return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

}
