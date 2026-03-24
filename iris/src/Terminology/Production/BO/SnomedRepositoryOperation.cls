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
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedSearchResponse).%New()

    Try {
        Set whereList = ""
        Set stmt = ##class(%SQL.Statement).%New()
        Set query = ""
        Set sql = "SELECT %ID, ConceptId, Term "_
                  "FROM Terminology_Snomed.PreferredTerm "                
        Set endSQL = "ORDER BY Term"
        
        if (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }
        if (pRequest.Lang '= "") {
            Set whereList = whereList_$ListBuild("Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }
        if (pRequest.Dialect '= "") {
            Set whereList = whereList_$ListBuild("Dialect = ?")
            Set tArgs($i(tArgs)) = pRequest.Dialect
        }
        if (pRequest.Query '= "") {
            Set termNorm = ..NormalizeTerm(pRequest.Query)
            Set whereList = whereList_$ListBuild("%ID %FIND search_index(IXTermNormFind, ?)")
            Set tArgs($i(tArgs)) = termNorm
        }
        if (whereList '= "") {
            set query = sql_"WHERE "_$LISTTOSTRING(whereList," AND ")_" "_endSQL
        } 
        else {
            set query = sql_" "_endSQL
        }

        set statement = ##class(%SQL.Statement).%New()
                    $$$ThrowOnError(statement.%Prepare(query))
        set rset = statement.%Execute(tArgs...)

        Set items = []
        Set skipped = 0
        Set added = 0
        Set limit = $Select(pRequest.Limit>0:pRequest.Limit,1:20)
        Set offset = $Select(pRequest.Offset>0:pRequest.Offset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = {}
            Set item.conceptId = rset.%Get("ConceptId")
            Set item.preferredTerm = rset.%Get("Term")
            Do items.%Push(item)
            Set added = added + 1
        }

        Set payload = {}
        Set payload.items = items
        Set payload.count = items.%Size()

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetConcept(pRequest As Terminology.Production.Msg.SnomedGetConceptRequest, Output pResponse As Terminology.Production.Msg.SnomedGetConceptResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetConceptResponse).%New()

    Try {
        Set whereList = ""
        Set joinList = ""
        Set query = ""

        Set sql = "SELECT c.%ID, c.ConceptId, c.Active, c.ModuleId, c.DefinitionStatusId, CONVERT(VARCHAR, c.EffectiveTime) AS EffectiveTime, pt.Term "_
                  "FROM Terminology_Snomed.Concept c "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = c.ConceptId "

        Set endSQL = ""

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId

            Set joinList = joinList_$ListBuild("pt.ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.Lang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }

        If (pRequest.Dialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Set tArgs($i(tArgs)) = pRequest.Dialect
        }

        If (pRequest.ConceptId '= "") {
            Set whereList = whereList_$ListBuild("c.ConceptId = ?")
            Set tArgs($i(tArgs)) = pRequest.ConceptId
        }

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList," AND ")
        }

        If (whereList '= "") {
            Set query = sql_" WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        Set payload = {}
        If rset.%Next() {
            Set payload.conceptId = rset.%Get("ConceptId")
            Set payload.active = rset.%Get("Active")
            Set payload.moduleId = rset.%Get("ModuleId")
            Set payload.definitionStatusId = rset.%Get("DefinitionStatusId")
            Set payload.effectiveTime = rset.%Get("EffectiveTime")
            Set payload.preferredTerm = rset.%Get("Term")
        }

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetChildren(pRequest As Terminology.Production.Msg.SnomedGetChildrenRequest, Output pResponse As Terminology.Production.Msg.SnomedGetChildrenResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetChildrenResponse).%New()

    Try {
        Set whereList = ""
        Set joinList = ""
        Set query = ""

        Set sql = "SELECT c.%ID, c.DescendantId AS ConceptId, c.Depth, pt.Term "_
                  "FROM Terminology_Snomed.IsaClosure c "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = c.DescendantId AND c.ReleaseId = pt.ReleaseId "

        Set endSQL = "ORDER BY pt.Term"

        If (pRequest.Lang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }

        If (pRequest.Dialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Set tArgs($i(tArgs)) = pRequest.Dialect
        }

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.View '= "") {
            Set whereList = whereList_$ListBuild("c.View = ?")
            Set tArgs($i(tArgs)) = pRequest.View
        }

        If (pRequest.ConceptId '= "") {
            Set whereList = whereList_$ListBuild("c.AncestorId = ?")
            Set tArgs($i(tArgs)) = pRequest.ConceptId
        }

        Set whereList = whereList_$ListBuild("c.Depth = 1")        

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList," AND ")
        }

        If (whereList '= "") {
            Set query = sql_" WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }
        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        Set items = []
        While rset.%Next() {
            Set item = {}
            Set item.conceptId = rset.%Get("ConceptId")
            Set item.depth = rset.%Get("Depth")
            Set item.preferredTerm = rset.%Get("Term")
            Do items.%Push(item)
        }
        Set payload = {}
        Set payload.items = items
        Set payload.count = items.%Size()

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetDescendants(pRequest As Terminology.Production.Msg.SnomedGetDescendantsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetDescendantsResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetDescendantsResponse).%New()

    Try {
        Set whereList = ""
        Set joinList = ""
        Set query = ""

        Set sql = "SELECT c.%ID, c.DescendantId AS ConceptId, c.Depth, pt.Term "_
                  "FROM Terminology_Snomed.IsaClosure c "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = c.DescendantId AND c.ReleaseId = pt.ReleaseId "

        Set endSQL = "ORDER BY c.Depth, pt.Term"        

        If (pRequest.Lang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }

        If (pRequest.Dialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Set tArgs($i(tArgs)) = pRequest.Dialect
        }

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.View '= "") {
            Set whereList = whereList_$ListBuild("c.View = ?")
            Set tArgs($i(tArgs)) = pRequest.View
        }

        If (pRequest.ConceptId '= "") {
            Set whereList = whereList_$ListBuild("c.AncestorId = ?")
            Set tArgs($i(tArgs)) = pRequest.ConceptId
        }

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList," AND ")
        }

        If (whereList '= "") {
            Set query = sql_" WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        Set items = []
        Set skipped = 0
        Set added = 0
        Set limit = $Select(pRequest.Limit>0:pRequest.Limit,1:100)
        Set offset = $Select(pRequest.Offset>0:pRequest.Offset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = {}
            Set item.conceptId = rset.%Get("ConceptId")
            Set item.depth = rset.%Get("Depth")
            Set item.preferredTerm = rset.%Get("Term")
            Do items.%Push(item)
            Set added = added + 1
        }

        Set payload = {}
        Set payload.items = items
        Set payload.count = items.%Size()

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetAncestors(pRequest As Terminology.Production.Msg.SnomedGetAncestorsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetAncestorsResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetAncestorsResponse).%New()

    Try {
        Set whereList = ""
        Set joinList = ""
        Set query = ""

        Set sql = "SELECT c.%ID, c.AncestorId AS ConceptId, c.Depth, pt.Term "_
                  "FROM Terminology_Snomed.IsaClosure c "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = c.AncestorId AND c.ReleaseId = pt.ReleaseId "

        Set endSQL = "ORDER BY c.Depth, pt.Term"

        If (pRequest.Lang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }

        If (pRequest.Dialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Set tArgs($i(tArgs)) = pRequest.Dialect
        }

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.View '= "") {
            Set whereList = whereList_$ListBuild("c.View = ?")
            Set tArgs($i(tArgs)) = pRequest.View
        }

        If (pRequest.ConceptId '= "") {
            Set whereList = whereList_$ListBuild("c.DescendantId = ?")
            Set tArgs($i(tArgs)) = pRequest.ConceptId
        }

        If ('pRequest.IncludeSelf) {
            Set whereList = whereList_$ListBuild("c.Depth > 0")
        }

        If (pRequest.MaxDepth > 0) {
            Set whereList = whereList_$ListBuild("c.Depth <= ?")
            Set tArgs($i(tArgs)) = pRequest.MaxDepth
        }

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList," AND ")
        }

        If (whereList '= "") {
            Set query = sql_" WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        Set items = []
        Set skipped = 0
        Set added = 0
        Set limit = $Select(pRequest.Limit>0:pRequest.Limit,1:100)
        Set offset = $Select(pRequest.Offset>0:pRequest.Offset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = {}
            Set item.conceptId = rset.%Get("ConceptId")
            Set item.depth = rset.%Get("Depth")
            Set item.preferredTerm = rset.%Get("Term")
            Do items.%Push(item)
            Set added = added + 1
        }

        Set payload = {}
        Set payload.items = items
        Set payload.count = items.%Size()

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetDescriptions(pRequest As Terminology.Production.Msg.SnomedGetDescriptionsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetDescriptionsResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetDescriptionsResponse).%New()

    Try {
        Set whereList = ""
        Set query = ""

        Set sql = "SELECT %ID, DescriptionId, ConceptId, Active, TypeId, Lang, Term, CaseSignificanceId, CONVERT(VARCHAR,EffectiveTime) AS EffectiveTime "_
                  "FROM Terminology_Snomed.Description "

        Set endSQL = "ORDER BY Term"

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.ConceptId '= "") {
            Set whereList = whereList_$ListBuild("ConceptId = ?")
            Set tArgs($i(tArgs)) = pRequest.ConceptId
        }

        If (pRequest.Lang '= "") {
            Set whereList = whereList_$ListBuild("Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }

        If (pRequest.ActiveOnly) {
            Set whereList = whereList_$ListBuild("Active = 1")
        }

        If (pRequest.TypeId '= "") {
            Set whereList = whereList_$ListBuild("TypeId = ?")
            Set tArgs($i(tArgs)) = pRequest.TypeId
        }

        If (whereList '= "") {
            Set query = sql_"WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        Set items = []
        Set skipped = 0
        Set added = 0
        Set limit = $Select(pRequest.Limit>0:pRequest.Limit,1:200)
        Set offset = $Select(pRequest.Offset>0:pRequest.Offset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = {}
            Set item.descriptionId = rset.%Get("DescriptionId")
            Set item.conceptId = rset.%Get("ConceptId")
            Set item.active = rset.%Get("Active")
            Set item.typeId = rset.%Get("TypeId")
            Set item.lang = rset.%Get("Lang")
            Set item.term = rset.%Get("Term")
            Set item.caseSignificanceId = rset.%Get("CaseSignificanceId")
            Set item.effectiveTime = rset.%Get("EffectiveTime")
            Do items.%Push(item)
            Set added = added + 1
        }

        Set payload = {}
        Set payload.items = items
        Set payload.count = items.%Size()

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetSubsumes(pRequest As Terminology.Production.Msg.SnomedGetSubsumesRequest, Output pResponse As Terminology.Production.Msg.SnomedGetSubsumesResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetSubsumesResponse).%New()

    Try {
        Set payload = {}

        If (pRequest.CodeA = "") || (pRequest.CodeB = "") {
            Set payload.relationship = "not-subsumed"
            Set pResponse.Payload = payload
            Return $$$OK
        }

        If (pRequest.CodeA = pRequest.CodeB) {
            Set payload.relationship = "equivalent"
            Set pResponse.Payload = payload
            Return $$$OK
        }

        Set whereList = ""
        Set query = ""
        Set sql = "SELECT %ID "_
                  "FROM Terminology_Snomed.IsaClosure "
        Set endSQL = ""

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.View '= "") {
            Set whereList = whereList_$ListBuild("View = ?")
            Set tArgs($i(tArgs)) = pRequest.View
        }

        Set whereList = whereList_$ListBuild("AncestorId = ?")
        Set tArgs($i(tArgs)) = pRequest.CodeA

        Set whereList = whereList_$ListBuild("DescendantId = ?")
        Set tArgs($i(tArgs)) = pRequest.CodeB

        If (whereList '= "") {
            Set query = sql_"WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        If rset.%Next() {
            Set payload.relationship = "subsumes"
            Set pResponse.Payload = payload
            Return $$$OK
        }

        Kill tArgs
        Set whereList = ""
        Set query = ""

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.View '= "") {
            Set whereList = whereList_$ListBuild("View = ?")
            Set tArgs($i(tArgs)) = pRequest.View
        }

        Set whereList = whereList_$ListBuild("AncestorId = ?")
        Set tArgs($i(tArgs)) = pRequest.CodeB

        Set whereList = whereList_$ListBuild("DescendantId = ?")
        Set tArgs($i(tArgs)) = pRequest.CodeA

        If (whereList '= "") {
            Set query = sql_"WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        If rset.%Next() {
            Set payload.relationship = "subsumed-by"
        } Else {
            Set payload.relationship = "not-subsumed"
        }

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetRefsets(pRequest As Terminology.Production.Msg.SnomedGetRefsetsRequest, Output pResponse As Terminology.Production.Msg.SnomedGetRefsetsResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetRefsetsResponse).%New()

    Try {
        Set whereList = ""
        Set query = ""

        Set sql = "SELECT DISTINCT RefsetId "_
                  "FROM Terminology_Snomed.RefsetMember "

        Set endSQL = "ORDER BY RefsetId"

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (whereList '= "") {
            Set query = sql_"WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        Set items = []
        Set skipped = 0
        Set added = 0
        Set limit = $Select(pRequest.Limit>0:pRequest.Limit,1:100)
        Set offset = $Select(pRequest.Offset>0:pRequest.Offset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = {}
            Set item.refsetId = rset.%Get("RefsetId")
            Do items.%Push(item)
            Set added = added + 1
        }

        Set payload = {}
        Set payload.items = items
        Set payload.count = items.%Size()

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleGetRefsetMembers(pRequest As Terminology.Production.Msg.SnomedGetRefsetMembersRequest, Output pResponse As Terminology.Production.Msg.SnomedGetRefsetMembersResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedGetRefsetMembersResponse).%New()

    Try {
        Set whereList = ""
        Set joinList = ""
        Set query = ""

        Set sql = "SELECT rm.%ID, rm.RefsetId, rm.MemberId, rm.ReferencedId AS ConceptId, pt.Term "_
                  "FROM Terminology_Snomed.RefsetMember rm "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = rm.ReferencedId AND pt.ReleaseId = rm.ReleaseId "

        Set endSQL = "ORDER BY pt.Term, rm.ReferencedId"

        If (pRequest.Lang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }

        If (pRequest.Dialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Set tArgs($i(tArgs)) = pRequest.Dialect
        }

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("rm.ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.RefsetId '= "") {
            Set whereList = whereList_$ListBuild("rm.RefsetId = ?")
            Set tArgs($i(tArgs)) = pRequest.RefsetId
        }

        Set whereList = whereList_$ListBuild("rm.Active = 1")

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList," AND ")
        }

        If (whereList '= "") {
            Set query = sql_" WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        Set items = []
        Set skipped = 0
        Set added = 0
        Set limit = $Select(pRequest.Limit>0:pRequest.Limit,1:100)
        Set offset = $Select(pRequest.Offset>0:pRequest.Offset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = {}
            Set item.refsetId = rset.%Get("RefsetId")
            Set item.memberId = rset.%Get("MemberId")
            Set item.conceptId = rset.%Get("ConceptId")
            Set item.preferredTerm = rset.%Get("Term")
            Do items.%Push(item)
            Set added = added + 1
        }

        Set payload = {}
        Set payload.items = items
        Set payload.count = items.%Size()

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method HandleValidateCode(pRequest As Terminology.Production.Msg.SnomedValidateCodeRequest, Output pResponse As Terminology.Production.Msg.SnomedValidateCodeResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.SnomedValidateCodeResponse).%New()

    Try {
        Set whereList = ""
        Set query = ""

        Set sql = "SELECT %ID, Active "_
                  "FROM Terminology_Snomed.Concept "

        Set endSQL = ""

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId
        }

        If (pRequest.Code '= "") {
            Set whereList = whereList_$ListBuild("ConceptId = ?")
            Set tArgs($i(tArgs)) = pRequest.Code
        }

        If (whereList '= "") {
            Set query = sql_"WHERE "_$ListToString(whereList," AND ")_" "_endSQL
        } Else {
            Set query = sql_" "_endSQL
        }

        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(query))
        Set rset = statement.%Execute(tArgs...)

        Set payload = {}

        If rset.%Next() {
            Set payload.exists = 1
            Set payload.active = rset.%Get("Active")
        } Else {
            Set payload.exists = 0
            Set payload.active = 0
        }

        Set pResponse.Payload = payload
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

ClassMethod NormalizeTerm(pValue As %String) As %String
{
    Quit $ZCONVERT($Get(pValue),"L")
}

}
