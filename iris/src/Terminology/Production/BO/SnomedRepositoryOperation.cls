Class Terminology.Production.BO.SnomedRepositoryOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

XData MessageMap
{
<MapItems>
    <MapItem MessageType="Terminology.Production.Msg.SnomedSearchRequest">
        <Method>HandleSearch</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedGetConceptRequest">
        <Method>HandleGetConcept</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedGetChildrenRequest">
        <Method>HandleGetChildren</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedGetDescendantsRequest">
        <Method>HandleGetDescendants</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedGetAncestorsRequest">
        <Method>HandleGetAncestors</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedGetDescriptionsRequest">
        <Method>HandleGetDescriptions</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedGetSubsumesRequest">
        <Method>HandleGetSubsumes</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedGetRefsetsRequest">
        <Method>HandleGetRefsets</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedGetRefsetMembersRequest">
        <Method>HandleGetRefsetMembers</Method>
    </MapItem>
    <MapItem MessageType="Terminology.Production.Msg.SnomedValidateCodeRequest">
        <Method>HandleValidateCode</Method>
    </MapItem>
</MapItems>
}

/// Fallback si llega un mensaje no contemplado por el MessageMap
Method OnMessage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Return $$$ERROR($$$NotImplemented, "Tipo de mensaje no soportado por SnomedRepositoryOperation")
}

Method HandleSearch(pRequest As Terminology.Production.Msg.SnomedSearchRequest, Output pResponse As Terminology.Production.Msg.SnomedSearchResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedSearchResponse).%New()

    Try {
        Set tSC = ..GetRepository().SearchConcepts(
            pRequest.ReleaseId,
            pRequest.Lang,
            pRequest.Dialect,
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

Method HandleGetConcept(pRequest As Terminology.Production.Msg.SnomedGetConceptRequest, Output pResponse As Terminology.Production.Msg.SnomedGetConceptResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetConceptResponse).%New()

    Try {
        Set tSC = ..GetRepository().GetConceptByCode(
            pRequest.ConceptId,
            pRequest.ReleaseId,
            pRequest.Lang,
            pRequest.Dialect,
            .payload
        )
        $$$ThrowOnError(tSC)

        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetChildren(pRequest As Terminology.Production.Msg.SnomedGetChildrenRequest, Output pResponse As Terminology.Production.Msg.SnomedGetChildrenResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetChildrenResponse).%New()

    Try {
        Set tSC = ..GetRepository().GetChildren(
            pRequest.ConceptId,
            pRequest.ReleaseId,
            pRequest.View,
            pRequest.Lang,
            pRequest.Dialect,
            .payload
        )
        $$$ThrowOnError(tSC)

        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetDescendants(pRequest As Terminology.Production.Msg.SnomedGetDescendantsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetDescendantsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetDescendantsResponse).%New()

    Try {
        Set tSC = ..GetRepository().GetDescendants(
            pRequest.ConceptId,
            pRequest.ReleaseId,
            pRequest.View,
            pRequest.Lang,
            pRequest.Dialect,
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

Method HandleGetAncestors(pRequest As Terminology.Production.Msg.SnomedGetAncestorsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetAncestorsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetAncestorsResponse).%New()

    Try {
        Set tSC = ..GetRepository().GetAncestors(
            pRequest.ConceptId,
            pRequest.ReleaseId,
            pRequest.View,
            pRequest.Lang,
            pRequest.Dialect,
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

Method HandleGetDescriptions(pRequest As Terminology.Production.Msg.SnomedGetDescriptionsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetDescriptionsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetDescriptionsResponse).%New()

    Try {
        Set tSC = ..GetRepository().GetDescriptions(
            pRequest.ConceptId,
            pRequest.ReleaseId,
            pRequest.Lang,
            pRequest.ActiveOnly,
            pRequest.TypeId,
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

Method HandleGetSubsumes(pRequest As Terminology.Production.Msg.SnomedGetSubsumesRequest, Output pResponse As Terminology.Production.Msg.SnomedGetSubsumesResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetSubsumesResponse).%New()

    Try {
        Set payload = ##class(Terminology.Snomed.DTO.SubsumesResult).%New()

        If (pRequest.CodeA = "") || (pRequest.CodeB = "") {
            Set payload.Relationship = "not-subsumed"
            Set pResponse.Payload = payload
            Return $$$OK
        }

        If (pRequest.CodeA = pRequest.CodeB) {
            Set payload.Relationship = "equivalent"
            Set pResponse.Payload = payload
            Return $$$OK
        }

        Set tSC = ..GetRepository().GetSubsumptionRelation(
            pRequest.ReleaseId,
            pRequest.View,
            pRequest.CodeA,
            pRequest.CodeB,
            .relationship
        )
        $$$ThrowOnError(tSC)

        Set payload.Relationship = relationship
        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetRefsets(pRequest As Terminology.Production.Msg.SnomedGetRefsetsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetRefsetsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetRefsetsResponse).%New()

    Try {
        Set tSC = ..GetRepository().GetRefsets(
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

Method HandleGetRefsetMembers(pRequest As Terminology.Production.Msg.SnomedGetRefsetMembersRequest, Output pResponse As Terminology.Production.Msg.SnomedGetRefsetMembersResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetRefsetMembersResponse).%New()

    Try {
        Set tSC = ..GetRepository().GetRefsetMembers(
            pRequest.RefsetId,
            pRequest.ReleaseId,
            pRequest.Lang,
            pRequest.Dialect,
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

Method HandleValidateCode(pRequest As Terminology.Production.Msg.SnomedValidateCodeRequest, Output pResponse As Terminology.Production.Msg.SnomedValidateCodeResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedValidateCodeResponse).%New()

    Try {
        Set tSC = ..GetRepository().ValidateCode(
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

Method GetRepository() As Terminology.Snomed.SnomedRepository [ Private ]
{
    Quit ##class(Terminology.Snomed.SnomedRepository).%New()
}

}
