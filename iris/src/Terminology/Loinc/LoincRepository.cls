Class Terminology.Loinc.LoincRepository Extends %RegisteredObject
{

Method SearchConcepts(pReleaseId As %String = "", pLang As %String = "", pQuery As %String = "", pLimit As %Integer = 20, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.SearchResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.SearchResult).%New()
    Try {
        Set whereList = ""
        Set argCount = 0

        Set sql = "SELECT %ID, LoincNum, Display, DisplayType "_
                  "FROM Terminology_Loinc.Display "
        Set endSQL = "ORDER BY RankOrder, Display"

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pLang '= "") {
            Set whereList = whereList_$ListBuild("Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        If (pQuery '= "") {
            Set whereList = whereList_$ListBuild("%ID %FIND search_index(IXDisplayNormFind, ?)")
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

            Set item = ##class(Terminology.Loinc.DTO.SearchItem).%New()
            Set item.LoincNum = rset.%Get("LoincNum")
            Set item.Display = rset.%Get("Display")
            Set item.DisplayType = rset.%Get("DisplayType")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetCodeByCode(pCode As %String = "", pReleaseId As %String = "", Output pResult As Terminology.Loinc.DTO.CodeResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.CodeResult).%New()
    Try {
        Set whereList = ""
        Set argCount = 0

        Set sql = "SELECT %ID, LoincNum, Component, PropertyCode, TimeAspct, SystemCode, ScaleTyp, MethodTyp, "_
                  "ClassCode, Status, ConsumerName, ShortName, LongCommonName, DefinitionDescription, DisplayName "_
                  "FROM Terminology_Loinc.Code "

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pCode '= "") {
            Set whereList = whereList_$ListBuild("LoincNum = ?")
            Do ..AddArgument(.args, .argCount, pCode)
        }

        Set query = ..BuildQuery(sql, whereList, "")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        If rset.%Next() {
            Set pResult.LoincNum = rset.%Get("LoincNum")
            Set pResult.Component = rset.%Get("Component")
            Set pResult.PropertyCode = rset.%Get("PropertyCode")
            Set pResult.TimeAspct = rset.%Get("TimeAspct")
            Set pResult.SystemCode = rset.%Get("SystemCode")
            Set pResult.ScaleTyp = rset.%Get("ScaleTyp")
            Set pResult.MethodTyp = rset.%Get("MethodTyp")
            Set pResult.ClassCode = rset.%Get("ClassCode")
            Set pResult.Status = rset.%Get("Status")
            Set pResult.ConsumerName = rset.%Get("ConsumerName")
            Set pResult.ShortName = rset.%Get("ShortName")
            Set pResult.LongCommonName = rset.%Get("LongCommonName")
            Set pResult.DefinitionDescription = rset.%Get("DefinitionDescription")
            Set pResult.DisplayName = rset.%Get("DisplayName")
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetDisplays(pCode As %String = "", pReleaseId As %String = "", pLang As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.DisplayResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.DisplayResult).%New()
    Try {
        Set whereList = ""
        Set argCount = 0

        Set sql = "SELECT %ID, LoincNum, Lang, DisplayType, Display, RankOrder "_
                  "FROM Terminology_Loinc.Display "
        Set endSQL = "ORDER BY RankOrder, Display"

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pCode '= "") {
            Set whereList = whereList_$ListBuild("LoincNum = ?")
            Do ..AddArgument(.args, .argCount, pCode)
        }

        If (pLang '= "") {
            Set whereList = whereList_$ListBuild("Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set skipped = 0
        Set added = 0
        Set limit = $Select(pLimit>0:pLimit,1:100)
        Set offset = $Select(pOffset>0:pOffset,1:0)

        While rset.%Next() {
            If skipped < offset { Set skipped = skipped + 1 Continue }
            If added >= limit { Continue }

            Set item = ##class(Terminology.Loinc.DTO.DisplayItem).%New()
            Set item.LoincNum = rset.%Get("LoincNum")
            Set item.Lang = rset.%Get("Lang")
            Set item.DisplayType = rset.%Get("DisplayType")
            Set item.Display = rset.%Get("Display")
            Set item.RankOrder = rset.%Get("RankOrder")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetParts(pCode As %String = "", pReleaseId As %String = "", pLimit As %Integer = 200, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.PartResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.PartResult).%New()
    Try {
        Set whereList = ""
        Set argCount = 0

        Set sql = "SELECT l.%ID, l.LoincNum, l.PartNumber, l.PartTypeName, l.LinkTypeName, l.PropertySlot, "_
                  "p.PartName, p.PartDisplayName, p.Status "_
                  "FROM Terminology_Loinc.CodePartLink l "_
                  "LEFT JOIN Terminology_Loinc.Part p "_
                  "ON p.ReleaseId = l.ReleaseId AND p.PartNumber = l.PartNumber "
        Set endSQL = "ORDER BY l.PartTypeName, p.PartDisplayName"

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("l.ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }
        If (pCode '= "") {
            Set whereList = whereList_$ListBuild("l.LoincNum = ?")
            Do ..AddArgument(.args, .argCount, pCode)
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set skipped = 0
        Set added = 0
        Set limit = $Select(pLimit>0:pLimit,1:200)
        Set offset = $Select(pOffset>0:pOffset,1:0)

        While rset.%Next() {
            If skipped < offset { Set skipped = skipped + 1 Continue }
            If added >= limit { Continue }

            Set item = ##class(Terminology.Loinc.DTO.PartItem).%New()
            Set item.LoincNum = rset.%Get("LoincNum")
            Set item.PartNumber = rset.%Get("PartNumber")
            Set item.PartTypeName = rset.%Get("PartTypeName")
            Set item.LinkTypeName = rset.%Get("LinkTypeName")
            Set item.PropertySlot = rset.%Get("PropertySlot")
            Set item.PartName = rset.%Get("PartName")
            Set item.PartDisplayName = rset.%Get("PartDisplayName")
            Set item.Status = rset.%Get("Status")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetAncestors(pCode As %String = "", pReleaseId As %String = "", pHierarchyType As %String = "", pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.ClosureResult) As %Status
{
    Quit ..GetClosureList(pCode, pReleaseId, pHierarchyType, "ancestors", pMaxDepth, pLimit, pOffset, .pResult)
}

Method GetDescendants(pCode As %String = "", pReleaseId As %String = "", pHierarchyType As %String = "", pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.ClosureResult) As %Status
{
    Quit ..GetClosureList(pCode, pReleaseId, pHierarchyType, "descendants", pMaxDepth, pLimit, pOffset, .pResult)
}

Method GetGroups(pReleaseId As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.GroupResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.GroupResult).%New()
    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT %ID, GroupId, GroupName, GroupType, Version "_
                  "FROM Terminology_Loinc.LoincGroup "
        Set endSQL = "ORDER BY GroupName"

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
            If skipped < offset { Set skipped = skipped + 1 Continue }
            If added >= limit { Continue }

            Set item = ##class(Terminology.Loinc.DTO.GroupItem).%New()
            Set item.GroupId = rset.%Get("GroupId")
            Set item.GroupName = rset.%Get("GroupName")
            Set item.GroupType = rset.%Get("GroupType")
            Set item.Version = rset.%Get("Version")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Returns one LOINC group row for ValueSet read/search metadata mapping.
Method GetGroupById(pGroupId As %String = "", pReleaseId As %String = "", Output pResult As Terminology.Loinc.DTO.GroupItem) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.GroupItem).%New()

    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT %ID, GroupId, GroupName, GroupType, Version "_
                  "FROM Terminology_Loinc.LoincGroup "

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pGroupId '= "") {
            Set whereList = whereList_$ListBuild("GroupId = ?")
            Do ..AddArgument(.args, .argCount, pGroupId)
        }

        Set query = ..BuildQuery(sql, whereList, "")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        If rset.%Next() {
            Set pResult.GroupId = rset.%Get("GroupId")
            Set pResult.GroupName = rset.%Get("GroupName")
            Set pResult.GroupType = rset.%Get("GroupType")
            Set pResult.Version = rset.%Get("Version")
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetGroupMembers(pGroupId As %String = "", pReleaseId As %String = "", pLang As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.GroupMemberResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.GroupMemberResult).%New()
    Try {
        Set whereList = ""
        Set joinList = ""
        Set argCount = 0

        Set sql = "SELECT gm.%ID, gm.GroupId, gm.LoincNum, d.DisplayType, d.RankOrder, d.Display "_
                  "FROM Terminology_Loinc.GroupMember gm "_
                  "LEFT JOIN Terminology_Loinc.Display d "_
                  "ON d.ReleaseId = gm.ReleaseId AND d.LoincNum = gm.LoincNum "
        Set endSQL = "ORDER BY d.RankOrder, d.Display, gm.LoincNum"

        If (pLang '= "") {
            Set joinList = joinList_$ListBuild("d.Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }
        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("gm.ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }
        If (pGroupId '= "") {
            Set whereList = whereList_$ListBuild("gm.GroupId = ?")
            Do ..AddArgument(.args, .argCount, pGroupId)
        }

        If (joinList '= "") {
            Set sql = sql_" AND "_$ListToString(joinList, " AND ")
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set skipped = 0
        Set added = 0
        Set limit = $Select(pLimit>0:pLimit,1:100)
        Set offset = $Select(pOffset>0:pOffset,1:0)

        While rset.%Next() {
            If skipped < offset { Set skipped = skipped + 1 Continue }
            If added >= limit { Continue }

            Set item = ##class(Terminology.Loinc.DTO.GroupMemberItem).%New()
            Set item.GroupId = rset.%Get("GroupId")
            Set item.LoincNum = rset.%Get("LoincNum")
            Set item.DisplayType = rset.%Get("DisplayType")
            Set item.RankOrder = rset.%Get("RankOrder")
            Set item.Display = rset.%Get("Display")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetExpandedGroupMembers(pGroupId As %String = "", pReleaseId As %String = "", pLang As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.GroupMemberResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.GroupMemberResult).%New()
    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT gm.%ID, gm.GroupId, gm.LoincNum "_
                  "FROM Terminology_Loinc.GroupMember gm "
        Set endSQL = "ORDER BY gm.LoincNum"

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("gm.ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }
        If (pGroupId '= "") {
            Set whereList = whereList_$ListBuild("gm.GroupId = ?")
            Do ..AddArgument(.args, .argCount, pGroupId)
        }

        Set totalCount = 0
        Set tSC = ..CountGroupMembers(whereList, .args, argCount, .totalCount)
        $$$ThrowOnError(tSC)

        Set limit = $Select(pLimit>0:pLimit,1:100)
        Set offset = $Select(pOffset>0:pOffset,1:0)
        Do ..AddArgument(.args, .argCount, limit)
        Do ..AddArgument(.args, .argCount, offset)

        Set query = ..BuildQuery(sql, whereList, endSQL_" LIMIT ? OFFSET ?")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        While rset.%Next() {
            Set item = ##class(Terminology.Loinc.DTO.GroupMemberItem).%New()
            Set item.GroupId = rset.%Get("GroupId")
            Set item.LoincNum = rset.%Get("LoincNum")

            Set tSC = ..PopulateBestDisplayForMember(item, pReleaseId, pLang)
            $$$ThrowOnError(tSC)

            Do pResult.Items.Insert(item)
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Set pResult.TotalCount = totalCount
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method ValidateCode(pReleaseId As %String = "", pCode As %String = "", Output pResult As Terminology.Loinc.DTO.ValidateCodeResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.ValidateCodeResult).%New()
    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT %ID, Status FROM Terminology_Loinc.Code "

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }
        If (pCode '= "") {
            Set whereList = whereList_$ListBuild("LoincNum = ?")
            Do ..AddArgument(.args, .argCount, pCode)
        }

        Set query = ..BuildQuery(sql, whereList, "")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        If rset.%Next() {
            Set pResult.Exists = 1
            Set pResult.Status = rset.%Get("Status")
            Set pResult.Active = $Select($ZCONVERT(pResult.Status,"L")="active":1,1:0)
        } Else {
            Set pResult.Exists = 0
            Set pResult.Status = ""
            Set pResult.Active = 0
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Determines the directional subsumption relationship using the precomputed LOINC closure table.
Method GetSubsumptionRelation(pReleaseId As %String = "", pHierarchyType As %String = "", pCodeA As %String = "", pCodeB As %String = "", Output pRelationship As %String) As %Status
{
    Set pRelationship = "not-subsumed"

    Try {
        Set effectiveHierarchyType = $Select(pHierarchyType'="":pHierarchyType, 1:"COMPONENTBYSYSTEM")

        Set tSC = ..ClosureRelationExists(pReleaseId, effectiveHierarchyType, pCodeA, pCodeB, .exists)
        $$$ThrowOnError(tSC)

        If exists {
            Set pRelationship = "subsumes"
            Return $$$OK
        }

        Set tSC = ..ClosureRelationExists(pReleaseId, effectiveHierarchyType, pCodeB, pCodeA, .exists)
        $$$ThrowOnError(tSC)

        If exists {
            Set pRelationship = "subsumed-by"
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetClosureList(pCode As %String, pReleaseId As %String, pHierarchyType As %String, pMode As %String, pMaxDepth As %Integer, pLimit As %Integer, pOffset As %Integer, Output pResult As Terminology.Loinc.DTO.ClosureResult) As %Status [ Private ]
{
    Set pResult = ##class(Terminology.Loinc.DTO.ClosureResult).%New()
    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT %ID, AncestorCode, DescendantCode, Depth "_
                  "FROM Terminology_Loinc.Closure "
        Set endSQL = $Select(pMode="ancestors":"ORDER BY Depth, AncestorCode",1:"ORDER BY Depth, DescendantCode")

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }
        If (pHierarchyType '= "") {
            Set whereList = whereList_$ListBuild("HierarchyType = ?")
            Do ..AddArgument(.args, .argCount, pHierarchyType)
        }
        If (pMode="ancestors") {
            Set whereList = whereList_$ListBuild("DescendantCode = ?")
        } Else {
            Set whereList = whereList_$ListBuild("AncestorCode = ?")
        }
        Do ..AddArgument(.args, .argCount, pCode)

        If (pMaxDepth > 0) {
            Set whereList = whereList_$ListBuild("Depth <= ?")
            Do ..AddArgument(.args, .argCount, pMaxDepth)
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        Set skipped = 0
        Set added = 0
        Set limit = $Select(pLimit>0:pLimit,1:100)
        Set offset = $Select(pOffset>0:pOffset,1:0)

        While rset.%Next() {
            If skipped < offset { Set skipped = skipped + 1 Continue }
            If added >= limit { Continue }

            Set item = ##class(Terminology.Loinc.DTO.ClosureItem).%New()
            Set item.AncestorCode = rset.%Get("AncestorCode")
            Set item.DescendantCode = rset.%Get("DescendantCode")
            Set item.Depth = rset.%Get("Depth")
            Do pResult.Items.Insert(item)
            Set added = added + 1
        }

        Set pResult.Count = $Select($IsObject(pResult.Items):pResult.Items.Count(),1:0)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method BuildQuery(pSql As %String, pWhereList As %List = "", pEndSql As %String = "") As %String [ Private ]
{
    If $ListLength($Get(pWhereList))>0 {
        Quit pSql_"WHERE "_$ListToString(pWhereList," AND ")_" "_pEndSql
    }
    Quit pSql_" "_pEndSql
}

Method CountGroupMembers(pWhereList As %List = "", ByRef pArgs, pArgCount As %Integer, Output pTotalCount As %Integer) As %Status [ Private ]
{
    Set pTotalCount = 0
    Try {
        Set sql = "SELECT COUNT(*) AS TotalCount FROM Terminology_Loinc.GroupMember gm "
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

Method PopulateBestDisplayForMember(pItem As Terminology.Loinc.DTO.GroupMemberItem, pReleaseId As %String = "", pLang As %String = "") As %Status [ Private ]
{
    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT TOP 1 DisplayType, RankOrder, Display "_
                  "FROM Terminology_Loinc.Display "
        Set endSQL = "ORDER BY CASE %SQLUPPER(DisplayType) "_
                     "WHEN 'LONGCOMMONNAME' THEN 1 "_
                     "WHEN 'SHORTNAME' THEN 2 "_
                     "WHEN 'DISPLAYNAME' THEN 3 "_
                     "WHEN 'CONSUMERNAME' THEN 4 "_
                     "WHEN 'LINGUISTICVARIANT' THEN 5 "_
                     "ELSE 99 END, RankOrder, Display"

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        Set whereList = whereList_$ListBuild("LoincNum = ?")
        Do ..AddArgument(.args, .argCount, pItem.LoincNum)

        If (pLang '= "") {
            Set whereList = whereList_$ListBuild("Lang = ?")
            Do ..AddArgument(.args, .argCount, pLang)
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        If rset.%Next() {
            Set pItem.DisplayType = rset.%Get("DisplayType")
            Set pItem.RankOrder = rset.%Get("RankOrder")
            Set pItem.Display = rset.%Get("Display")
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method ExecuteQuery(pQuery As %String, ByRef pArgs, pArgCount As %Integer, Output pResultSet As %SQL.StatementResult) As %Status [ Private ]
{
    Try {
        Set traceStart = $ZHOROLOG
        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(pQuery))

        If pArgCount>0 {
            Set pArgs = pArgCount
            Set pResultSet = statement.%Execute(pArgs...)
        } Else {
            Set pResultSet = statement.%Execute()
        }

        Do ##class(Terminology.Core.Trace).LogSQL("Terminology.Loinc.LoincRepository.ExecuteQuery", pQuery, .pArgs, pArgCount, ##class(Terminology.Core.Trace).ElapsedMilliseconds(traceStart))

        Return $$$OK
    } Catch ex {
        Do ##class(Terminology.Core.Trace).LogError("sql", "Terminology.Loinc.LoincRepository.ExecuteQuery", ex.DisplayString())
        Do ##class(Terminology.Core.Trace).LogSQL("Terminology.Loinc.LoincRepository.ExecuteQuery", pQuery, .pArgs, pArgCount, ##class(Terminology.Core.Trace).ElapsedMilliseconds($Get(traceStart)), "ERROR")
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

/// Checks whether one LOINC code appears as an ancestor of another in the selected hierarchy.
Method ClosureRelationExists(pReleaseId As %String, pHierarchyType As %String, pAncestorCode As %String, pDescendantCode As %String, Output pExists As %Boolean) As %Status [ Private ]
{
    Set pExists = 0

    Try {
        Set whereList = ""
        Set argCount = 0
        Set sql = "SELECT %ID FROM Terminology_Loinc.Closure "

        If (pReleaseId '= "") {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If (pHierarchyType '= "") {
            Set whereList = whereList_$ListBuild("HierarchyType = ?")
            Do ..AddArgument(.args, .argCount, pHierarchyType)
        }

        If (pAncestorCode '= "") {
            Set whereList = whereList_$ListBuild("AncestorCode = ?")
            Do ..AddArgument(.args, .argCount, pAncestorCode)
        }

        If (pDescendantCode '= "") {
            Set whereList = whereList_$ListBuild("DescendantCode = ?")
            Do ..AddArgument(.args, .argCount, pDescendantCode)
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

Method AddArgument(ByRef pArgs, ByRef pArgCount As %Integer, pValue As %String = "") As %Status [ Private ]
{
    Set pArgCount = pArgCount + 1
    Set pArgs = pArgCount
    Set pArgs(pArgCount) = pValue
    Return $$$OK
}

ClassMethod NormalizeTerm(pValue As %String) As %String
{
    Quit $ZCONVERT($Get(pValue),"L")
}

}
