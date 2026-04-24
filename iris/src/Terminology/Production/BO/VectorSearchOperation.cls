Class Terminology.Production.BO.VectorSearchOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Terminology.Production.Msg.VectorSearchRequest">
        <Method>HandleSearch</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.VectorCrosswalkRequest">
        <Method>HandleCrosswalk</Method>
    </MapItem>
</MapItems>
}

Method OnMessage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Return $$$ERROR($$$NotImplemented, "Unsupported message type for VectorSearchOperation")
}

Method HandleSearch(pRequest As Terminology.Production.Msg.VectorSearchRequest, Output pResponse As Terminology.Production.Msg.VectorSearchResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.VectorSearchResponse).%New()

    Try {
        Set limit = $Select(pRequest.Limit>0:pRequest.Limit,1:10)
        Set modelName = $Select(pRequest.ModelName'="":pRequest.ModelName,1:"FremyCompany/BioLORD-2023-M")

        Set systemUris = ..ListToDynamicArray(pRequest.SystemUris)
        Set releaseIds = ..ListToDynamicArray(pRequest.ReleaseIds)

        Set payload = ##class(Terminology.Vector.Utils).SearchSimilarMulti(
            pRequest.Query,
            systemUris,
            releaseIds,
            pRequest.Lang,
            limit,
            modelName
        )

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleCrosswalk(pRequest As Terminology.Production.Msg.VectorCrosswalkRequest, Output pResponse As Terminology.Production.Msg.VectorCrosswalkResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.VectorCrosswalkResponse).%New()

    Try {
        Set limit = $Select(pRequest.Limit>0:pRequest.Limit,1:10)
        Set modelName = $Select(pRequest.ModelName'="":pRequest.ModelName,1:"FremyCompany/BioLORD-2023-M")

        Set targetSystemUris = ..ListToDynamicArray(pRequest.TargetSystemUris)
        Set targetReleaseIds = ..ListToDynamicArray(pRequest.TargetReleaseIds)

        Set payload = ##class(Terminology.Vector.Utils).CrosswalkSimilar(
            pRequest.Query,
            pRequest.SourceSystemUri,
            pRequest.SourceCode,
            pRequest.SourceReleaseId,
            targetSystemUris,
            targetReleaseIds,
            pRequest.Lang,
            limit,
            modelName
        )

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

ClassMethod ListToDynamicArray(pList As %ListOfDataTypes) As %DynamicArray [ Private ]
{
    Set arr = []

    If '$IsObject(pList) {
        Quit arr
    }

    For i=1:1:pList.Count() {
        Set value = pList.GetAt(i)
        If value'="" {
            Do arr.%Push(value)
        }
    }

    Quit arr
}

}
