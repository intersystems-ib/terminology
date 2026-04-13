Class Terminology.Production.BP.ICDLoad Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Try {
        // Ajusta esto al tipo de mensaje real que uses
        Set filePath = pRequest.FilePath

        $$$LOGINFO("ICDLoad start "_filePath)

        Set tSC = ##class(Terminology.ICD.Utils.BuilderCode).Build(filePath, pRequest.ReleaseId, pRequest.Version, pRequest.CodeType, pRequest.Lang)
        If $$$ISERR(tSC) Return tSC

        Set tSC = ##class(Terminology.ICD.Utils.BuilderHierarchy).Build(pRequest.ReleaseId, pRequest.Version, pRequest.CodeType)
        If $$$ISERR(tSC) Return tSC

        $$$LOGINFO("ICDLoad end")
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
