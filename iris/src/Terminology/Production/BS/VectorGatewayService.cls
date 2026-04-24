Class Terminology.Production.BS.VectorGatewayService Extends Ens.BusinessService
{

Property TargetConfigName As %String(MAXLEN = 200) [ InitialExpression = "VectorSearchOperation" ];

Parameter SETTINGS = "TargetConfigName";

Method OnProcessInput(pInput As Ens.Request, Output pOutput As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Set pOutput = ""

    Try {
        If '$IsObject(pInput) {
            Return $$$ERROR($$$GeneralError, "VectorGatewayService received a null or invalid request")
        }

        Set tSC = ..SendRequestSync(..TargetConfigName, pInput, .pOutput)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

}
