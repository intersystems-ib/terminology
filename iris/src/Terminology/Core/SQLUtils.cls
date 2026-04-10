Class Terminology.Core.SqlUtils Extends %RegisteredObject
{

ClassMethod ExecuteNonQuery(pSql As %String, pParamsJson As %String = "[]") As %Status
{
    Set tSC = $$$OK

    Try {
        Set traceStart = $ZHOROLOG
        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare(pSql)
        If $$$ISERR(tSC) {
            Do ##class(Terminology.Core.Trace).LogError("sql", "Terminology.Core.SqlUtils.ExecuteNonQuery prepare failed", $System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        Set params = ##class(%DynamicArray).%FromJSON(pParamsJson)
        Set paramCount = params.%Size()

        Kill sqlArgs
        Set sqlArgs = paramCount
        For i=1:1:paramCount {
            Set sqlArgs(i) = params.%Get(i-1)
        }

        If paramCount>0 {
            Set rset = stmt.%Execute(sqlArgs...)
        } Else {
            Set rset = stmt.%Execute()
        }

        Do ##class(Terminology.Core.Trace).Log("sql", "Terminology.Core.SqlUtils.ExecuteNonQuery", "elapsedMs="_##class(Terminology.Core.Trace).ElapsedMilliseconds(traceStart)_" paramsJson="_pParamsJson_" sql="_pSql)

        Return $$$OK
    } Catch ex {
        Do ##class(Terminology.Core.Trace).LogError("sql", "Terminology.Core.SqlUtils.ExecuteNonQuery", "elapsedMs="_##class(Terminology.Core.Trace).ElapsedMilliseconds($Get(traceStart))_" paramsJson="_pParamsJson_" sql="_pSql_" error="_ex.DisplayString())
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

ClassMethod LogStatus(pContext As %String, pSC As %Status) As %Status
{
    Do ##class(Ens.Util.Log).LogInfo(
        "Terminology.Core.SqlUtils",
        "LogStatus",
        pContext_": "_$System.Status.GetOneErrorText(pSC)
    )
    Return $$$OK
}

}
