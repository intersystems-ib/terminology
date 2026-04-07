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

Method GetGroupMembers(pGroupId As %String = "", pReleaseId As %String = "", pLang As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.Loinc.DTO.GroupMemberResult) As %Status
{
    Set pResult = ##class(Terminology.Loinc.DTO.GroupMemberResult).%New()
    Try {
        Set whereList = ""
        Set joinList = ""
        Set argCount = 0

        Set sql = "SELECT gm.%ID, gm.GroupId, gm.LoincNum, d.Display "_
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

Method ExecuteQuery(pQuery As %String, ByRef pArgs, pArgCount As %Integer, Output pResultSet As %SQL.StatementResult) As %Status [ Private ]
{
    Try {
        Set statement = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(statement.%Prepare(pQuery))

        Set pResultSet = $Case(pArgCount,
            0: statement.%Execute(),
            1: statement.%Execute($Get(pArgs(1))),
            2: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2))),
            3: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2)), $Get(pArgs(3))),
            4: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2)), $Get(pArgs(3)), $Get(pArgs(4))),
            5: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2)), $Get(pArgs(3)), $Get(pArgs(4)), $Get(pArgs(5))),
            6: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2)), $Get(pArgs(3)), $Get(pArgs(4)), $Get(pArgs(5)), $Get(pArgs(6))),
            7: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2)), $Get(pArgs(3)), $Get(pArgs(4)), $Get(pArgs(5)), $Get(pArgs(6)), $Get(pArgs(7))),
            8: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2)), $Get(pArgs(3)), $Get(pArgs(4)), $Get(pArgs(5)), $Get(pArgs(6)), $Get(pArgs(7)), $Get(pArgs(8))),
            9: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2)), $Get(pArgs(3)), $Get(pArgs(4)), $Get(pArgs(5)), $Get(pArgs(6)), $Get(pArgs(7)), $Get(pArgs(8)), $Get(pArgs(9))),
            10: statement.%Execute($Get(pArgs(1)), $Get(pArgs(2)), $Get(pArgs(3)), $Get(pArgs(4)), $Get(pArgs(5)), $Get(pArgs(6)), $Get(pArgs(7)), $Get(pArgs(8)), $Get(pArgs(9)), $Get(pArgs(10))),
            : $$$NULLOREF
        )

        If pResultSet=$$$NULLOREF {
            Return $$$ERROR($$$GeneralError, "Too many SQL arguments")
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method AddArgument(ByRef pArgs, ByRef pArgCount As %Integer, pValue As %String = "") As %Status [ Private ]
{
    Set pArgCount = pArgCount + 1
    Set pArgs(pArgCount) = pValue
    Return $$$OK
}

ClassMethod NormalizeTerm(pValue As %String) As %String
{
    Quit $ZCONVERT($Get(pValue),"L")
}

}
