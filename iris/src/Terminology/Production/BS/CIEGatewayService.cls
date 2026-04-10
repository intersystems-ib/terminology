Class Terminology.Production.BS.CIEGatewayService Extends Ens.BusinessService
{

Property TargetConfigName As %String(MAXLEN = 200) [ InitialExpression = "CIERepositoryOperation" ];

Parameter SETTINGS = "TargetConfigName";

Method OnProcessInput(pInput As Ens.Request, Output pOutput As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Set pOutput = ""

    Try {
        If '$IsObject(pInput) {
            Return $$$ERROR($$$GeneralError, "CIEGatewayService recibió un mensaje nulo o inválido")
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
