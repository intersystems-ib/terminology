Class Terminology.Production.BS.ICDFileService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Parameter SETTINGS = "TargetConfigName,ReleaseId,Version,CodeType,Lang";

Property TargetConfigName As %String(MAXLEN = 200) [ InitialExpression = "ICDLoad" ];

Property ReleaseId As %String;

Property Version As %Integer [ InitialExpression = 10 ];

Property CodeType As %String(MAXLEN = 32) [ InitialExpression = "DIAGNOSIS" ];

Property Lang As %String(MAXLEN = 10) [ InitialExpression = "es" ];

Method OnProcessInput(pInput As %Stream.Object, Output pOutput As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Set pOutput = ""

    Try {
        Set fileName = $Get(pInput.Attributes("Filename"))

        If fileName = "" {
            return $$$ERROR($$$GeneralError,"No se ha recibido el nombre del fichero")
        }

        Set req = ##class(Terminology.Production.Msg.ICDLoadRequest).%New()
        Set req.FilePath = fileName
        Set req.ReleaseId = ..ReleaseId
        Set req.Version = ..Version
        Set req.CodeType = ..CodeType
        Set req.Lang = ..Lang

        $$$LOGINFO("ICDFileService processing file: "_fileName_" | ReleaseId="_req.ReleaseId_" | Version="_req.Version_" | CodeType="_req.CodeType)

        Set tSC = ..SendRequestSync(..TargetConfigName, req, .pOutput)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method IsValidFile(pFilename As %String) As %Boolean
{
    Set name = $ZCONVERT($Get(pFilename),"L")
    Quit $Select($Extract(name,*-3,*)=".txt":1,1:0)
}

}
