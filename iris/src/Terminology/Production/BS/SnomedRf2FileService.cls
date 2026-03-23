Class Terminology.Production.BS.SnomedRf2FileService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Property TargetConfigName As %String(MAXLEN = 200) [ InitialExpression = "SnomedRf2LoadBP" ];

Property ReleaseId As %String(MAXLEN = 64);

Property SystemUri As %String(MAXLEN = 200) [ InitialExpression = "http://snomed.info/sct" ];

Property EffectiveDate As %String(MAXLEN = 10);

Property SetActive As %Boolean [ InitialExpression = 1 ];

Parameter SETTINGS = "TargetConfigName,ReleaseId,SystemUri,EffectiveDate,SetActive";

Method OnProcessInput(pInput As %Stream.FileBinary, Output pOutput As %RegisteredObject) As %Status
{
    Set sc = $$$OK
    Set pOutput = ""

    Try {
        Set fileName = $Get(pInput.Attributes("Filename"))
        If fileName = "" {
            return $$$ERROR($$$GeneralError,"No se ha recibido el nombre del fichero")
        }

        Set req = ##class(Terminology.Production.Msg.SnomedRf2LoadRequest).%New()
        Set req.FileName = fileName
        Set req.Directory = ..Adapter.FilePath
        Set req.ReleaseId = ..ReleaseId
        Set req.SystemUri = ..SystemUri
        Set req.EffectiveDate = ..EffectiveDate
        Set req.SetActive = ..SetActive

        Set rsp = ""
        Set sc = ..SendRequestSync(..TargetConfigName, req, .rsp)
        If $$$ISERR(sc) {
            return sc
        }

        Set pOutput = rsp
        return $$$OK
    }
    Catch ex {
        return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

}
