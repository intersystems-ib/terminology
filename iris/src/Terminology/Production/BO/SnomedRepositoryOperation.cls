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
        Set tSC = stmt.%Prepare(sql)
        If $$$ISERR(tSC) {
            Return tSC
        }
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

        Set sql = "SELECT c.%ID, c.ConceptId, c.Active, c.ModuleId, c.DefinitionStatusId, c.EffectiveTime, pt.Term "_
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
                  "ON pt.ConceptId = c.DescendantId "

        Set endSQL = "ORDER BY pt.Term"

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId

            Set joinList = joinList_$ListBuild("pt.ReleaseId = ?")
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

        If (pRequest.Lang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }

        If (pRequest.Dialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Set tArgs($i(tArgs)) = pRequest.Dialect
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
                  "ON pt.ConceptId = c.DescendantId "

        Set endSQL = "ORDER BY c.Depth, pt.Term"

        If (pRequest.ReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
            Set tArgs($i(tArgs)) = pRequest.ReleaseId

            Set joinList = joinList_$ListBuild("pt.ReleaseId = ?")
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

        If (pRequest.Lang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Set tArgs($i(tArgs)) = pRequest.Lang
        }

        If (pRequest.Dialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Set tArgs($i(tArgs)) = pRequest.Dialect
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

ClassMethod NormalizeTerm(pValue As %String) As %String
{
    Quit $ZCONVERT($Get(pValue),"L")
}

}
