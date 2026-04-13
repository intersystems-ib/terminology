Class Terminology.Production.BO.ICDRepositoryOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Terminology.Production.Msg.ICDSearchRequest">
        <Method>HandleSearch</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.ICDGetCodeRequest">
        <Method>HandleGetCode</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.ICDGetChildrenRequest">
        <Method>HandleGetChildren</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.ICDGetDescendantsRequest">
        <Method>HandleGetDescendants</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.ICDGetAncestorsRequest">
        <Method>HandleGetAncestors</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.ICDGetFamiliesRequest">
        <Method>HandleGetFamilies</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.ICDValidateCodeRequest">
        <Method>HandleValidateCode</Method>
    </MapItem>
</MapItems>
}

Method OnMessage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Return $$$ERROR($$$NotImplemented, "Unsupported message type for ICDRepositoryOperation")
}

Method RestoreTraceContext(pRequest As Terminology.Production.Msg.BaseRequest) As %Status [ Private ]
{
    Return ##class(Terminology.Core.Trace).RestoreRequestContext(pRequest)
}

Method HandleSearch(pRequest As Terminology.Production.Msg.ICDSearchRequest, Output pResponse As Terminology.Production.Msg.ICDSearchResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.ICDSearchResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetICDAdapter().SearchConcepts(
            pRequest.ReleaseId,
            pRequest.Version,
            pRequest.CodeType,
            pRequest.Query,
            pRequest.Limit,
            pRequest.Offset,
            .payload
        )
        $$$ThrowOnError(tSC)
        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetCode(pRequest As Terminology.Production.Msg.ICDGetCodeRequest, Output pResponse As Terminology.Production.Msg.ICDGetCodeResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.ICDGetCodeResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetICDAdapter().LookupCode(
            pRequest.ReleaseId,
            pRequest.Version,
            pRequest.CodeType,
            pRequest.Code,
            .payload
        )
        $$$ThrowOnError(tSC)
        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetChildren(pRequest As Terminology.Production.Msg.ICDGetChildrenRequest, Output pResponse As Terminology.Production.Msg.ICDGetChildrenResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.ICDGetChildrenResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetICDAdapter().GetChildren(
            pRequest.ReleaseId,
            pRequest.Version,
            pRequest.CodeType,
            pRequest.Code,
            pRequest.Limit,
            pRequest.Offset,
            .payload
        )
        $$$ThrowOnError(tSC)
        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetDescendants(pRequest As Terminology.Production.Msg.ICDGetDescendantsRequest, Output pResponse As Terminology.Production.Msg.ICDGetDescendantsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.ICDGetDescendantsResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetICDAdapter().GetDescendants(
            pRequest.ReleaseId,
            pRequest.Version,
            pRequest.CodeType,
            pRequest.Code,
            pRequest.IncludeSelf,
            pRequest.MaxDepth,
            pRequest.Limit,
            pRequest.Offset,
            .payload
        )
        $$$ThrowOnError(tSC)
        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetAncestors(pRequest As Terminology.Production.Msg.ICDGetAncestorsRequest, Output pResponse As Terminology.Production.Msg.ICDGetAncestorsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.ICDGetAncestorsResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetICDAdapter().GetAncestors(
            pRequest.ReleaseId,
            pRequest.Version,
            pRequest.CodeType,
            pRequest.Code,
            pRequest.IncludeSelf,
            pRequest.MaxDepth,
            pRequest.Limit,
            pRequest.Offset,
            .payload
        )
        $$$ThrowOnError(tSC)
        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetFamilies(pRequest As Terminology.Production.Msg.ICDGetFamiliesRequest, Output pResponse As Terminology.Production.Msg.ICDGetFamiliesResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.ICDGetFamiliesResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetICDAdapter().GetFamilies(
            pRequest.ReleaseId,
            pRequest.Version,
            pRequest.CodeType,
            pRequest.Limit,
            pRequest.Offset,
            .payload
        )
        $$$ThrowOnError(tSC)
        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleValidateCode(pRequest As Terminology.Production.Msg.ICDValidateCodeRequest, Output pResponse As Terminology.Production.Msg.ICDValidateCodeResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.ICDValidateCodeResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetICDAdapter().ValidateCode(
            pRequest.ReleaseId,
            pRequest.Version,
            pRequest.CodeType,
            pRequest.Code,
            .payload
        )
        $$$ThrowOnError(tSC)
        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetICDAdapter() As Terminology.ICD.ICDAdapter [ Private ]
{
    Quit ##class(Terminology.ICD.ICDAdapter).%New()
}

}
