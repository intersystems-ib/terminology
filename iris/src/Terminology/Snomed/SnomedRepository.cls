/// SNOMED SQL/data access layer.
/// All database queries for the current SNOMED API should stay in this class.
Class Terminology.Snomed.SnomedRepository Extends %RegisteredObject
{

/// Searches preferred terms using the derived search table.
Method SearchConcepts(pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "", pQuery As %String = "", pLimit As %Integer = 20, pOffset As %Integer = 0, Output pResult As Terminology.Snomed.DTO.SearchResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.SearchResult).%New()

    Try {
        Set whereList = ""
        Set argCount = 0
        // PreferredTerm search expects the derived search index IXTermNormFind to support
        // normalized free-text lookup without scanning the full term table.
        Set sql = "SELECT %ID, ConceptId, Term "_
                  "FROM Terminology_Snomed.PreferredTerm "
        Set endSQL = "ORDER BY Term"

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pLang '= "") {
            Set whereList = whereList_$ListBuild("Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        If (pDialect '= "") {
            Set whereList = whereList_$ListBuild("Dialect = ?")
            Do ..AddArgument(.args, .argCount, pDialect)
        }

        If (pQuery '= "") {
            Set whereList = whereList_$ListBuild("%ID %FIND search_index(IXTermNormFind, ?)")
            Do ..AddArgument(.args, .argCount, ..NormalizeTerm(pQuery))
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set skipped = 0
        Set added = 0
        Set limit = $Select(pLimit>0:pLimit,1:20)
        Set offset = $Select(pOffset>0:pOffset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = ##class(Terminology.Snomed.DTO.ConceptSummary).%New()
            Set item.ConceptId = rset.%Get("ConceptId")
            Set item.PreferredTerm = rset.%Get("Term")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns the concept row plus its preferred term for the requested language/dialect.
Method GetConceptByCode(pConceptId As %String = "", pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "", Output pResult As Terminology.Snomed.DTO.ConceptResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.ConceptResult).%New()

    Try {
        Set whereList = ""
        Set joinList = ""
        Set argCount = 0

        // PreferredTerm is joined by concept and release so lookup uses the derived term table
        // rather than recomputing designation preferences at request time.
        Set sql = "SELECT c.%ID, c.ConceptId, c.Active, c.ModuleId, c.DefinitionStatusId, CONVERT(VARCHAR, c.EffectiveTime) AS EffectiveTime, pt.Term "_
                  "FROM Terminology_Snomed.Concept c "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = c.ConceptId "

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
        }

        If (pLang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        If (pDialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Do ..AddArgument(.args, .argCount, pDialect)
        }

        If (pReleaseId '= "") {
            Set joinList = joinList_$ListBuild("pt.ReleaseId = c.ReleaseId")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pConceptId '= "") {
            Set whereList = whereList_$ListBuild("c.ConceptId = ?")
            Do ..AddArgument(.args, .argCount, pConceptId)
        }

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList, " AND ")
        }

        Set query = ..BuildQuery(sql, whereList, "")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        If rset.%Next() {
            Set pResult.ConceptId = rset.%Get("ConceptId")
            Set pResult.Active = rset.%Get("Active")
            Set pResult.ModuleId = rset.%Get("ModuleId")
            Set pResult.DefinitionStatusId = rset.%Get("DefinitionStatusId")
            Set pResult.EffectiveTime = rset.%Get("EffectiveTime")
            Set pResult.PreferredTerm = rset.%Get("Term")
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns direct children from the closure table.
Method GetChildren(pConceptId As %String = "", pReleaseId As %String = "", pView As %String = "", pLang As %String = "", pDialect As %String = "", Output pResult As Terminology.Snomed.DTO.ConceptListResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.ConceptListResult).%New()

    Try {
        Set tSC = ..GetHierarchyList(pConceptId, pReleaseId, pView, pLang, pDialect, "children", 0, 0, .pResult)
        $$$ThrowOnError(tSC)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns descendants from the closure table with pagination applied in memory.
Method GetDescendants(pConceptId As %String = "", pReleaseId As %String = "", pView As %String = "", pLang As %String = "", pDialect As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Snomed.DTO.ConceptListResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.ConceptListResult).%New()

    Try {
        Set tSC = ..GetHierarchyList(pConceptId, pReleaseId, pView, pLang, pDialect, "descendants", pOffset, pLimit, .pResult)
        $$$ThrowOnError(tSC)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns ancestors from the closure table, optionally including the concept itself.
Method GetAncestors(pConceptId As %String = "", pReleaseId As %String = "", pView As %String = "", pLang As %String = "", pDialect As %String = "", pIncludeSelf As %Integer = 0, pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Snomed.DTO.ConceptListResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.ConceptListResult).%New()

    Try {
        Set whereList = ""
        Set joinList = ""
        Set argCount = 0

        // This query relies on IsaClosure indexes over ReleaseId/View/DescendantId/Depth to keep
        // ancestor traversal bounded and avoid recursive joins at request time.
        Set sql = "SELECT c.%ID, c.AncestorId AS ConceptId, c.Depth, pt.Term "_
                  "FROM Terminology_Snomed.IsaClosure c "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = c.AncestorId AND c.ReleaseId = pt.ReleaseId "
        Set endSQL = "ORDER BY c.Depth, pt.Term"

        If (pLang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        If (pDialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Do ..AddArgument(.args, .argCount, pDialect)
        }

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pView '= "") {
            Set whereList = whereList_$ListBuild("c.View = ?")
            Do ..AddArgument(.args, .argCount, pView)
        }

        If (pConceptId '= "") {
            Set whereList = whereList_$ListBuild("c.DescendantId = ?")
            Do ..AddArgument(.args, .argCount, pConceptId)
        }

        If ('pIncludeSelf) {
            Set whereList = whereList_$ListBuild("c.Depth > 0")
        }

        If (pMaxDepth > 0) {
            Set whereList = whereList_$ListBuild("c.Depth <= ?")
            Do ..AddArgument(.args, .argCount, pMaxDepth)
        }

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList, " AND ")
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set tSC = ..MapConceptListResult(.rset, $Select(pLimit>0:pLimit,1:100), $Select(pOffset>0:pOffset,1:0), .pResult)
        $$$ThrowOnError(tSC)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns description rows for a concept with simple filtering by language, active flag and type.
Method GetDescriptions(pConceptId As %String = "", pReleaseId As %String = "", pLang As %String = "", pActiveOnly As %Integer = 0, pTypeId As %String = "", pLimit As %Integer = 200, pOffset As %Integer = 0, Output pResult As Terminology.Snomed.DTO.DescriptionListResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.DescriptionListResult).%New()

    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT %ID, DescriptionId, ConceptId, Active, TypeId, Lang, Term, CaseSignificanceId, CONVERT(VARCHAR,EffectiveTime) AS EffectiveTime "_
                  "FROM Terminology_Snomed.Description "
        Set endSQL = "ORDER BY Term"

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pConceptId '= "") {
            Set whereList = whereList_$ListBuild("ConceptId = ?")
            Do ..AddArgument(.args, .argCount, pConceptId)
        }

        If (pLang '= "") {
            Set whereList = whereList_$ListBuild("Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        If (pActiveOnly) {
            Set whereList = whereList_$ListBuild("Active = 1")
        }

        If (pTypeId '= "") {
            Set whereList = whereList_$ListBuild("TypeId = ?")
            Do ..AddArgument(.args, .argCount, pTypeId)
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set skipped = 0
        Set added = 0
        Set limit = $Select(pLimit>0:pLimit,1:200)
        Set offset = $Select(pOffset>0:pOffset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = ##class(Terminology.Snomed.DTO.DescriptionSummary).%New()
            Set item.DescriptionId = rset.%Get("DescriptionId")
            Set item.ConceptId = rset.%Get("ConceptId")
            Set item.Active = rset.%Get("Active")
            Set item.TypeId = rset.%Get("TypeId")
            Set item.Lang = rset.%Get("Lang")
            Set item.Term = rset.%Get("Term")
            Set item.CaseSignificanceId = rset.%Get("CaseSignificanceId")
            Set item.EffectiveTime = rset.%Get("EffectiveTime")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Determines the directional subsumption relationship using the precomputed closure table.
Method GetSubsumptionRelation(pReleaseId As %String = "", pView As %String = "", pCodeA As %String = "", pCodeB As %String = "", Output pRelationship As %String) As %Status
{
    Set pRelationship = "not-subsumed"

    Try {
        Set tSC = ..ClosureRelationExists(pReleaseId, pView, pCodeA, pCodeB, .exists)
        $$$ThrowOnError(tSC)

        If exists {
            Set pRelationship = "subsumes"
            Return $$$OK
        }

        Set tSC = ..ClosureRelationExists(pReleaseId, pView, pCodeB, pCodeA, .exists)
        $$$ThrowOnError(tSC)

        If exists {
            Set pRelationship = "subsumed-by"
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Lists active refset identifiers available for a release.
Method GetRefsets(pReleaseId As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Snomed.DTO.RefsetListResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.RefsetListResult).%New()

    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT DISTINCT RefsetId "_
                  "FROM Terminology_Snomed.RefsetMember "
        Set endSQL = "ORDER BY RefsetId"

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set skipped = 0
        Set added = 0
        Set limit = $Select(pLimit>0:pLimit,1:100)
        Set offset = $Select(pOffset>0:pOffset,1:0)

        While rset.%Next() {
            If skipped < offset {
                Set skipped = skipped + 1
                Continue
            }

            If added >= limit {
                Continue
            }

            Set item = ##class(Terminology.Snomed.DTO.RefsetSummary).%New()
            Set item.RefsetId = rset.%Get("RefsetId")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns active members of a refset and resolves their preferred term when available.
Method GetRefsetMembers(pRefsetId As %String = "", pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Snomed.DTO.RefsetMemberListResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.RefsetMemberListResult).%New()

    Try {
        Set whereList = ""
        Set joinList = ""
        Set argCount = 0

        // Refset members resolve their display through PreferredTerm so member expansion uses the
        // same language/dialect term derivation as concept lookup and navigation endpoints.
        Set sql = "SELECT rm.%ID, rm.RefsetId, rm.MemberId, rm.ReferencedId AS ConceptId, pt.Term "_
                  "FROM Terminology_Snomed.RefsetMember rm "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = rm.ReferencedId AND pt.ReleaseId = rm.ReleaseId "
        Set endSQL = "ORDER BY pt.Term, rm.ReferencedId"

        If (pLang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        If (pDialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Do ..AddArgument(.args, .argCount, pDialect)
        }

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("rm.ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pRefsetId '= "") {
            Set whereList = whereList_$ListBuild("rm.RefsetId = ?")
            Do ..AddArgument(.args, .argCount, pRefsetId)
        }

        Set whereList = whereList_$ListBuild("rm.Active = 1")

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList, " AND ")
        }

        Set totalCount = 0
        Set tSC = ..CountRefsetMembers(whereList, joinList, .args, argCount, .totalCount)
        $$$ThrowOnError(tSC)

        Set limit = $Select(pLimit>0:pLimit,1:100)
        Set offset = $Select(pOffset>0:pOffset,1:0)
        Do ..AddArgument(.args, .argCount, limit)
        Do ..AddArgument(.args, .argCount, offset)

        Set query = ..BuildQuery(sql, whereList, endSQL_" LIMIT ? OFFSET ?")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        While rset.%Next() {
            Set item = ##class(Terminology.Snomed.DTO.RefsetMemberSummary).%New()
            Set item.RefsetId = rset.%Get("RefsetId")
            Set item.MemberId = rset.%Get("MemberId")
            Set item.ConceptId = rset.%Get("ConceptId")
            Set item.PreferredTerm = rset.%Get("Term")
            Do pResult.Items.Insert(item)
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Set pResult.TotalCount = totalCount
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method CountRefsetMembers(pWhereList As %List = "", pJoinList As %List = "", ByRef pArgs, pArgCount As %Integer, Output pTotalCount As %Integer) As %Status [ Private ]
{
    Set pTotalCount = 0

    Try {
        Set sql = "SELECT COUNT(*) AS TotalCount "_
                  "FROM Terminology_Snomed.RefsetMember rm "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = rm.ReferencedId AND pt.ReleaseId = rm.ReleaseId "

        If (pJoinList '= "") {
            Set sql = sql_" AND "_$ListToString(pJoinList, " AND ")
        }

        Set query = ..BuildQuery(sql, pWhereList, "")
        Set tSC = ..ExecuteQuery(query, .pArgs, pArgCount, .rset)
        $$$ThrowOnError(tSC)

        If rset.%Next() {
            Set pTotalCount = +rset.%Get("TotalCount")
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Checks whether a refset identifier exists in the loaded SNOMED refset member data.
Method RefsetExists(pRefsetId As %String = "", pReleaseId As %String = "", Output pExists As %Boolean) As %Status
{
    Set pExists = 0

    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT TOP 1 RefsetId FROM Terminology_Snomed.RefsetMember "

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pRefsetId '= "") {
            Set whereList = whereList_$ListBuild("RefsetId = ?")
            Do ..AddArgument(.args, .argCount, pRefsetId)
        }

        Set query = ..BuildQuery(sql, whereList, "")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set pExists = rset.%Next()
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Checks whether a concept exists in the requested release and whether it is active.
Method ValidateCode(pReleaseId As %String = "", pCode As %String = "", Output pResult As Terminology.Snomed.DTO.ValidateCodeResult) As %Status
{
    Set pResult = ##class(Terminology.Snomed.DTO.ValidateCodeResult).%New()

    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT %ID, Active "_
                  "FROM Terminology_Snomed.Concept "

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pCode '= "") {
            Set whereList = whereList_$ListBuild("ConceptId = ?")
            Do ..AddArgument(.args, .argCount, pCode)
        }

        Set query = ..BuildQuery(sql, whereList, "")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        If rset.%Next() {
            Set pResult.Exists = 1
            Set pResult.Active = rset.%Get("Active")
        } Else {
            Set pResult.Exists = 0
            Set pResult.Active = 0
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Shared hierarchy query helper for children and descendants.
Method GetHierarchyList(pConceptId As %String, pReleaseId As %String, pView As %String, pLang As %String, pDialect As %String, pMode As %String, pOffset As %Integer, pLimit As %Integer, Output pResult As Terminology.Snomed.DTO.ConceptListResult) As %Status [ Private ]
{
    Try {
        Set whereList = ""
        Set joinList = ""
        Set argCount = 0

        // IsaClosure is the precomputed transitive closure. These queries expect indexes on
        // ReleaseId/View/AncestorId or DescendantId so hierarchy traversal stays fast.
        If (pMode = "ancestors") {
            Set selectId = "c.AncestorId"
            Set filterField = "c.DescendantId"
        } Else {
            Set selectId = "c.DescendantId"
            Set filterField = "c.AncestorId"
        }

        Set sql = "SELECT c.%ID, "_selectId_" AS ConceptId, c.Depth, pt.Term "_
                  "FROM Terminology_Snomed.IsaClosure c "_
                  "LEFT JOIN Terminology_Snomed.PreferredTerm pt "_
                  "ON pt.ConceptId = "_selectId_" AND c.ReleaseId = pt.ReleaseId "

        Set endSQL = $Select(pMode="children":"ORDER BY pt.Term",1:"ORDER BY c.Depth, pt.Term")

        If (pLang '= "") {
            Set joinList = joinList_$ListBuild("pt.Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        If (pDialect '= "") {
            Set joinList = joinList_$ListBuild("pt.Dialect = ?")
            Do ..AddArgument(.args, .argCount, pDialect)
        }

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pView '= "") {
            Set whereList = whereList_$ListBuild("c.View = ?")
            Do ..AddArgument(.args, .argCount, pView)
        }

        If (pConceptId '= "") {
            Set whereList = whereList_$ListBuild(filterField_" = ?")
            Do ..AddArgument(.args, .argCount, pConceptId)
        }

        If (pMode = "children") {
            Set whereList = whereList_$ListBuild("c.Depth = 1")
        }

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList, " AND ")
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set tSC = ..MapConceptListResult(.rset, $Select(pLimit>0:pLimit,1:100), $Select(pOffset>0:pOffset,1:0), .pResult)
        $$$ThrowOnError(tSC)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method MapConceptListResult(ByRef pRset, pLimit As %Integer, pOffset As %Integer, Output pResult As Terminology.Snomed.DTO.ConceptListResult) As %Status [ Private ]
{
    Try {
        Set skipped = 0
        Set added = 0

        While pRset.%Next() {
            If skipped < pOffset {
                Set skipped = skipped + 1
                Continue
            }

            If (pLimit > 0) && (added >= pLimit) {
                Continue
            }

            Set item = ##class(Terminology.Snomed.DTO.ConceptSummary).%New()
            Set item.ConceptId = pRset.%Get("ConceptId")
            Set item.Depth = pRset.%Get("Depth")
            Set item.PreferredTerm = pRset.%Get("Term")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method ClosureRelationExists(pReleaseId As %String, pView As %String, pAncestorId As %String, pDescendantId As %String, Output pExists As %Boolean) As %Status [ Private ]
{
    Set pExists = 0

    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT %ID FROM Terminology_Snomed.IsaClosure "

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pView '= "") {
            Set whereList = whereList_$ListBuild("View = ?")
            Do ..AddArgument(.args, .argCount, pView)
        }

        Set whereList = whereList_$ListBuild("AncestorId = ?")
        Do ..AddArgument(.args, .argCount, pAncestorId)

        Set whereList = whereList_$ListBuild("DescendantId = ?")
        Do ..AddArgument(.args, .argCount, pDescendantId)

        Set query = ..BuildQuery(sql, whereList, "")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set pExists = rset.%Next()
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method AddArgument(ByRef pArgs, ByRef pArgCount As %Integer, pValue As %String = "") As %Status [ Private ]
{
    Set pArgCount = pArgCount + 1
    Set pArgs = pArgCount
    Set pArgs(pArgCount) = pValue
    Return $$$OK
}

Method BuildQuery(pSql As %String, pWhereList As %List = "", pEndSQL As %String = "") As %String [ Private ]
{
    Set query = pSql

    If (pWhereList '= "") {
        Set query = query_" WHERE "_$ListToString(pWhereList, " AND ")
    }

    If (pEndSQL '= "") {
        Set query = query_" "_pEndSQL
    }

    Quit query
}

Method ExecuteQuery(pSql As %String, ByRef pArgs, pArgCount As %Integer, Output pRset) As %Status [ Private ]
{
    Try {
        Set traceStart = $ZHOROLOG
        Set stmt = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(stmt.%Prepare(pSql))

        If pArgCount=0 {
            Set pRset = stmt.%Execute()
        } Else {
            Set pRset = stmt.%Execute(pArgs...)
        }

        Do ##class(Terminology.Core.Trace).LogSQL("Terminology.Snomed.SnomedRepository.ExecuteQuery", pSql, .pArgs, pArgCount, ##class(Terminology.Core.Trace).ElapsedMilliseconds(traceStart))

        Return $$$OK
    } Catch ex {
        Do ##class(Terminology.Core.Trace).LogError("sql", "Terminology.Snomed.SnomedRepository.ExecuteQuery", ex.DisplayString())
        Do ##class(Terminology.Core.Trace).LogSQL("Terminology.Snomed.SnomedRepository.ExecuteQuery", pSql, .pArgs, pArgCount, ##class(Terminology.Core.Trace).ElapsedMilliseconds($Get(traceStart)), "ERROR")
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method NormalizeTerm(pValue As %String) As %String [ Private ]
{
    Quit $ZCONVERT($Get(pValue), "L")
}

}
