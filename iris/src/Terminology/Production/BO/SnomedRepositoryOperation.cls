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

/// Fallback for any request type not declared in the MessageMap.
Method OnMessage(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    Return $$$ERROR($$$NotImplemented, "Unsupported message type for SnomedRepositoryOperation")
}

Method RestoreTraceContext(pRequest As Terminology.Production.Msg.BaseRequest) As %Status [ Private ]
{
    Return ##class(Terminology.Core.Trace).RestoreRequestContext(pRequest)
}

/// Neutral operations go through TermService so future FHIR code can reuse the same contract.
/// The BO keeps request/response handling and leaves business behavior to lower layers.
Method HandleSearch(pRequest As Terminology.Production.Msg.SnomedSearchRequest, Output pResponse As Terminology.Production.Msg.SnomedSearchResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedSearchResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetTermService().SearchConcepts(
            "snomed",
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

/// The SNOMED API still returns the same DTO payload, but lookup now flows through TermService.
/// This keeps the BO aligned with the future neutral terminology contract.
Method HandleGetConcept(pRequest As Terminology.Production.Msg.SnomedGetConceptRequest, Output pResponse As Terminology.Production.Msg.SnomedGetConceptResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetConceptResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetTermService().LookupCode(
            "snomed",
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

/// SNOMED-specific navigation remains routed directly to the adapter.
/// These operations are still useful for the current SNOMED API but are not neutral yet.
Method HandleGetChildren(pRequest As Terminology.Production.Msg.SnomedGetChildrenRequest, Output pResponse As Terminology.Production.Msg.SnomedGetChildrenResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetChildrenResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetSnomedAdapter().GetChildren(
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

/// SNOMED-specific navigation remains routed directly to the adapter.
/// The adapter owns SNOMED hierarchy semantics while the repository keeps the SQL.
Method HandleGetDescendants(pRequest As Terminology.Production.Msg.SnomedGetDescendantsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetDescendantsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetDescendantsResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetSnomedAdapter().GetDescendants(
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

/// SNOMED-specific navigation remains routed directly to the adapter.
/// This keeps ancestor rules out of the BO.
Method HandleGetAncestors(pRequest As Terminology.Production.Msg.SnomedGetAncestorsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetAncestorsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetAncestorsResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetSnomedAdapter().GetAncestors(
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

/// Description retrieval is still SNOMED-native and does not belong to the common contract yet.
/// The BO only maps the request and forwards it to the adapter.
Method HandleGetDescriptions(pRequest As Terminology.Production.Msg.SnomedGetDescriptionsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetDescriptionsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetDescriptionsResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetSnomedAdapter().GetDescriptions(
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

/// Subsumption now uses the neutral service contract while preserving the existing payload shape.
/// Empty-code and equivalent-code handling now live in the SNOMED adapter.
Method HandleGetSubsumes(pRequest As Terminology.Production.Msg.SnomedGetSubsumesRequest, Output pResponse As Terminology.Production.Msg.SnomedGetSubsumesResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetSubsumesResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetTermService().Subsumes(
            "snomed",
            pRequest.ReleaseId,
            pRequest.View,
            pRequest.CodeA,
            pRequest.CodeB,
            .payload
        )
        $$$ThrowOnError(tSC)

        Set pResponse.Payload = payload
        Return tSC
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Refset operations stay adapter-only because they are still SNOMED-specific in this MVP.
/// They can move into a common contract later if a neutral model emerges.
Method HandleGetRefsets(pRequest As Terminology.Production.Msg.SnomedGetRefsetsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetRefsetsResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetRefsetsResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetSnomedAdapter().GetRefsets(
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

/// Refset operations stay adapter-only because they are still SNOMED-specific in this MVP.
/// The BO keeps the same response DTO and JSON behavior.
Method HandleGetRefsetMembers(pRequest As Terminology.Production.Msg.SnomedGetRefsetMembersRequest, Output pResponse As Terminology.Production.Msg.SnomedGetRefsetMembersResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetRefsetMembersResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetSnomedAdapter().GetRefsetMembers(
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

/// Validation now uses the neutral service contract while keeping the same external behavior.
/// That makes the current endpoint reusable by a future FHIR validate-code path.
Method HandleValidateCode(pRequest As Terminology.Production.Msg.SnomedValidateCodeRequest, Output pResponse As Terminology.Production.Msg.SnomedValidateCodeResponse) As %Status
{
    Set pResponse = ##class(Terminology.Production.Msg.SnomedValidateCodeResponse).%New()

    Try {
        Set tSC = ..RestoreTraceContext(pRequest)
        $$$ThrowOnError(tSC)
        Set tSC = ..GetTermService().ValidateCode(
            "snomed",
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

/// Small helper to keep the BO focused on message handling and response assignment.
Method GetTermService() As Terminology.Core.TermService [ Private ]
{
    Quit ##class(Terminology.Core.TermService).%New()
}

/// Small helper to keep SNOMED-only endpoints on the adapter side.
Method GetSnomedAdapter() As Terminology.Snomed.SnomedAdapter [ Private ]
{
    Quit ##class(Terminology.Snomed.SnomedAdapter).%New()
}

}
