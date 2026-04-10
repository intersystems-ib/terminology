Class Terminology.Production.BO.CIERepositoryOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Terminology.Production.Msg.CIESearchRequest">
        <Method>HandleSearch</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.CIEGetCodeRequest">
        <Method>HandleGetCode</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.CIEGetChildrenRequest">
        <Method>HandleGetChildren</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.CIEGetDescendantsRequest">
        <Method>HandleGetDescendants</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.CIEGetAncestorsRequest">
        <Method>HandleGetAncestors</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.CIEGetFamiliesRequest">
        <Method>HandleGetFamilies</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.CIEValidateCodeRequest">
        <Method>HandleValidateCode</Method>
    </MapItem>
</MapItems>
}

Method OnMessage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Return $$$ERROR($$$NotImplemented, "Unsupported message type for CIERepositoryOperation")
}

Method HandleSearch(pRequest As Terminology.Production.Msg.CIESearchRequest, Output pResponse As Terminology.Production.Msg.CIESearchResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.CIESearchResponse).%New()

    Try {
        Set tSC = ..GetCIEAdapter().SearchConcepts(
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

Method HandleGetCode(pRequest As Terminology.Production.Msg.CIEGetCodeRequest, Output pResponse As Terminology.Production.Msg.CIEGetCodeResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.CIEGetCodeResponse).%New()

    Try {
        Set tSC = ..GetCIEAdapter().LookupCode(
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

Method HandleGetChildren(pRequest As Terminology.Production.Msg.CIEGetChildrenRequest, Output pResponse As Terminology.Production.Msg.CIEGetChildrenResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.CIEGetChildrenResponse).%New()

    Try {
        Set tSC = ..GetCIEAdapter().GetChildren(
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

Method HandleGetDescendants(pRequest As Terminology.Production.Msg.CIEGetDescendantsRequest, Output pResponse As Terminology.Production.Msg.CIEGetDescendantsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.CIEGetDescendantsResponse).%New()

    Try {
        Set tSC = ..GetCIEAdapter().GetDescendants(
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

Method HandleGetAncestors(pRequest As Terminology.Production.Msg.CIEGetAncestorsRequest, Output pResponse As Terminology.Production.Msg.CIEGetAncestorsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.CIEGetAncestorsResponse).%New()

    Try {
        Set tSC = ..GetCIEAdapter().GetAncestors(
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

Method HandleGetFamilies(pRequest As Terminology.Production.Msg.CIEGetFamiliesRequest, Output pResponse As Terminology.Production.Msg.CIEGetFamiliesResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.CIEGetFamiliesResponse).%New()

    Try {
        Set tSC = ..GetCIEAdapter().GetFamilies(
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

Method HandleValidateCode(pRequest As Terminology.Production.Msg.CIEValidateCodeRequest, Output pResponse As Terminology.Production.Msg.CIEValidateCodeResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.CIEValidateCodeResponse).%New()

    Try {
        Set tSC = ..GetCIEAdapter().ValidateCode(
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

Method GetCIEAdapter() As Terminology.CIE.CIEAdapter [ Private ]
{
    Quit ##class(Terminology.CIE.CIEAdapter).%New()
}

}
