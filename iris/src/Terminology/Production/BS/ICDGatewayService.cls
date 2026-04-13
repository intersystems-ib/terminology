Class Terminology.Production.BS.ICDGatewayService Extends Ens.BusinessService
{

Property TargetConfigName As %String(MAXLEN = 200) [ InitialExpression = "ICDRepositoryOperation" ];

Parameter SETTINGS = "TargetConfigName";

Method OnProcessInput(pInput As Ens.Request, Output pOutput As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Set pOutput = ""

    Try {
        If '$IsObject(pInput) {
            Return $$$ERROR($$$GeneralError, "ICDGatewayService recibió un mensaje nulo o inválido")
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
