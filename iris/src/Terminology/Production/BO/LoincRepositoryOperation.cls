Class Terminology.Production.BO.LoincRepositoryOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Terminology.Production.Msg.LoincSearchRequest">
        <Method>HandleSearch</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.LoincGetCodeRequest">
        <Method>HandleGetCode</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.LoincGetDisplaysRequest">
        <Method>HandleGetDisplays</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.LoincGetPartsRequest">
        <Method>HandleGetParts</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.LoincGetAncestorsRequest">
        <Method>HandleGetAncestors</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.LoincGetDescendantsRequest">
        <Method>HandleGetDescendants</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.LoincGetGroupsRequest">
        <Method>HandleGetGroups</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.LoincGetGroupMembersRequest">
        <Method>HandleGetGroupMembers</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.LoincValidateCodeRequest">
        <Method>HandleValidateCode</Method>
    </MapItem>
</MapItems>
}

Method OnMessage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Return $$$ERROR($$$NotImplemented, "Unsupported message type for LoincRepositoryOperation")
}

/// Neutral search goes through TermService so the BO stays aligned with the common terminology contract.
Method HandleSearch(pRequest As Terminology.Production.Msg.LoincSearchRequest, Output pResponse As Terminology.Production.Msg.LoincSearchResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincSearchResponse).%New()

    Try {
        Set tSC = ..GetTermService().SearchConcepts(
            "loinc",
            pRequest.ReleaseId,
            pRequest.Lang,
            "",
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

/// Neutral lookup goes through TermService, just like the SNOMED BO pattern.
Method HandleGetCode(pRequest As Terminology.Production.Msg.LoincGetCodeRequest, Output pResponse As Terminology.Production.Msg.LoincGetCodeResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincGetCodeResponse).%New()

    Try {
        Set tSC = ..GetTermService().LookupCode(
            "loinc",
            pRequest.LoincNum,
            pRequest.ReleaseId,
            "",
            "",
            .payload
        )
        $$$ThrowOnError(tSC)

        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// LOINC-native display retrieval remains adapter-only.
Method HandleGetDisplays(pRequest As Terminology.Production.Msg.LoincGetDisplaysRequest, Output pResponse As Terminology.Production.Msg.LoincGetDisplaysResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincGetDisplaysResponse).%New()

    Try {
        Set tSC = ..GetLoincAdapter().GetDisplays(
            pRequest.LoincNum,
            pRequest.ReleaseId,
            pRequest.Lang,
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

/// LOINC-native part retrieval remains adapter-only.
Method HandleGetParts(pRequest As Terminology.Production.Msg.LoincGetPartsRequest, Output pResponse As Terminology.Production.Msg.LoincGetPartsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincGetPartsResponse).%New()

    Try {
        Set tSC = ..GetLoincAdapter().GetParts(
            pRequest.LoincNum,
            pRequest.ReleaseId,
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

/// LOINC-native hierarchy navigation remains adapter-only.
Method HandleGetAncestors(pRequest As Terminology.Production.Msg.LoincGetAncestorsRequest, Output pResponse As Terminology.Production.Msg.LoincGetAncestorsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincGetAncestorsResponse).%New()

    Try {
        Set tSC = ..GetLoincAdapter().GetAncestors(
            pRequest.Code,
            pRequest.ReleaseId,
            pRequest.HierarchyType,
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

/// LOINC-native hierarchy navigation remains adapter-only.
Method HandleGetDescendants(pRequest As Terminology.Production.Msg.LoincGetDescendantsRequest, Output pResponse As Terminology.Production.Msg.LoincGetDescendantsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincGetDescendantsResponse).%New()

    Try {
        Set tSC = ..GetLoincAdapter().GetDescendants(
            pRequest.Code,
            pRequest.ReleaseId,
            pRequest.HierarchyType,
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

/// LOINC-native group listing remains adapter-only.
Method HandleGetGroups(pRequest As Terminology.Production.Msg.LoincGetGroupsRequest, Output pResponse As Terminology.Production.Msg.LoincGetGroupsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincGetGroupsResponse).%New()

    Try {
        Set tSC = ..GetLoincAdapter().GetGroups(
            pRequest.ReleaseId,
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

/// LOINC-native group member retrieval remains adapter-only.
Method HandleGetGroupMembers(pRequest As Terminology.Production.Msg.LoincGetGroupMembersRequest, Output pResponse As Terminology.Production.Msg.LoincGetGroupMembersResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincGetGroupMembersResponse).%New()

    Try {
        Set tSC = ..GetLoincAdapter().GetGroupMembers(
            pRequest.GroupId,
            pRequest.ReleaseId,
            pRequest.Lang,
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

/// Neutral validate-code goes through TermService.
Method HandleValidateCode(pRequest As Terminology.Production.Msg.LoincValidateCodeRequest, Output pResponse As Terminology.Production.Msg.LoincValidateCodeResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.LoincValidateCodeResponse).%New()

    Try {
        Set tSC = ..GetTermService().ValidateCode(
            "loinc",
            pRequest.ReleaseId,
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

Method GetTermService() As Terminology.Core.TermService [ Private ]
{
    Quit ##class(Terminology.Core.TermService).%New()
}

Method GetLoincAdapter() As Terminology.Loinc.LoincAdapter [ Private ]
{
    Quit ##class(Terminology.Loinc.LoincAdapter).%New()
}

}
