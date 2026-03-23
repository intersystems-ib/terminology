Class Terminology.Core.SqlUtils Extends %RegisteredObject
{

ClassMethod ExecuteNonQuery(pSql As %String, pParamsJson As %String = "[]") As %Status
{
    Set tSC = $$$OK

    Try {
        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare(pSql)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Set params = ##class(%DynamicArray).%FromJSON(pParamsJson)
        Set paramCount = params.%Size()

        If paramCount=0 {
            Set rset = stmt.%Execute()
        } ElseIf paramCount=1 {
            Set rset = stmt.%Execute(params.%Get(0))
        } ElseIf paramCount=2 {
            Set rset = stmt.%Execute(params.%Get(0), params.%Get(1))
        } ElseIf paramCount=3 {
            Set rset = stmt.%Execute(params.%Get(0), params.%Get(1), params.%Get(2))
        } ElseIf paramCount=4 {
            Set rset = stmt.%Execute(params.%Get(0), params.%Get(1), params.%Get(2), params.%Get(3))
        } ElseIf paramCount=5 {
            Set rset = stmt.%Execute(params.%Get(0), params.%Get(1), params.%Get(2), params.%Get(3), params.%Get(4))
        } ElseIf paramCount=6 {
            Set rset = stmt.%Execute(params.%Get(0), params.%Get(1), params.%Get(2), params.%Get(3), params.%Get(4), params.%Get(5))
        } ElseIf paramCount=7 {
            Set rset = stmt.%Execute(params.%Get(0), params.%Get(1), params.%Get(2), params.%Get(3), params.%Get(4), params.%Get(5), params.%Get(6))
        } ElseIf paramCount=8 {
            Set rset = stmt.%Execute(params.%Get(0), params.%Get(1), params.%Get(2), params.%Get(3), params.%Get(4), params.%Get(5), params.%Get(6), params.%Get(7))
        } Else {
            Return $$$ERROR($$$GeneralError, "Número de parámetros no soportado en ExecuteNonQuery")
        }

        Return $$$OK
    } Catch ex {
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
