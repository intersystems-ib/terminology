Class Terminology.CIE.CIERepository Extends %RegisteredObject
{

Method SearchConcepts(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pQuery As %String = "", pLimit As %Integer = 20, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.SearchResult) As %Status
{
    Set pResult = ##class(Terminology.CIE.DTO.SearchResult).%New()
    Set pResult.Items = ##class(%ListOfObjects).%New()

    Try {
        Set whereList = ""
        Set argCount = 0

        Set sql = "SELECT Code, Description, Version, CodeType, FamilyCode, ChapterCode, ParentCode, HierarchyLevel "_
                  "FROM Terminology_CIE.Code "
        Set endSQL = "ORDER BY Code"

        If pReleaseId'="" {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }

        If pVersion'="" {
            Set whereList = whereList_$ListBuild("Version = ?")
            Do ..AddArgument(.args, .argCount, pVersion)
        }

        If pCodeType'="" {
            Set whereList = whereList_$ListBuild("CodeType = ?")
            Do ..AddArgument(.args, .argCount, pCodeType)
        }

        If pQuery'="" {
            Set whereList = whereList_$ListBuild("%ID %FIND search_index(IXDescriptionNormCIE, ?)")
            Do ..AddArgument(.args, .argCount, pQuery)
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

            Set item = ##class(Terminology.CIE.DTO.SearchItem).%New()
            Set item.Code = rset.%Get("Code")
            Set item.Description = rset.%Get("Description")
            Set item.Version = rset.%Get("Version")
            Set item.CodeType = rset.%Get("CodeType")
            Set item.FamilyCode = rset.%Get("FamilyCode")
            Set item.ChapterCode = rset.%Get("ChapterCode")
            Set item.ParentCode = rset.%Get("ParentCode")
            Set item.HierarchyLevel = rset.%Get("HierarchyLevel")
            Do pResult.Items.Insert(item)

            Set added = added + 1
        }

        Set pResult.Count = pResult.Items.Count()
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetCodeByCode(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", Output pResult As Terminology.CIE.DTO.CodeResult) As %Status
{
    Set pResult = ##class(Terminology.CIE.DTO.CodeResult).%New()

    Try {
        Set whereList = ""
        Set argCount = 0

        Set sql = "SELECT Code, Description, Version, CodeType, ParentCode, ChapterCode, FamilyCode, HierarchyLevel, "_
                  "NodeFinal, Active, Manifestation, Perinatal, Pediatric, Obstetric, Adult, Female, Male, "_
                  "PoaExempt, DpNotPrincipal, Vcdp "_
                  "FROM Terminology_CIE.Code "

        If pReleaseId'="" {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }
        If pVersion'="" {
            Set whereList = whereList_$ListBuild("Version = ?")
            Do ..AddArgument(.args, .argCount, pVersion)
        }
        If pCodeType'="" {
            Set whereList = whereList_$ListBuild("CodeType = ?")
            Do ..AddArgument(.args, .argCount, pCodeType)
        }
        If pCode'="" {
            Set whereList = whereList_$ListBuild("Code = ?")
            Do ..AddArgument(.args, .argCount, pCode)
        }

        Set query = ..BuildQuery(sql, whereList, "")
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        If rset.%Next() {
            Set pResult.Code = rset.%Get("Code")
            Set pResult.Description = rset.%Get("Description")
            Set pResult.Version = rset.%Get("Version")
            Set pResult.CodeType = rset.%Get("CodeType")
            Set pResult.ParentCode = rset.%Get("ParentCode")
            Set pResult.ChapterCode = rset.%Get("ChapterCode")
            Set pResult.FamilyCode = rset.%Get("FamilyCode")
            Set pResult.HierarchyLevel = rset.%Get("HierarchyLevel")
            Set pResult.NodeFinal = rset.%Get("NodeFinal")
            Set pResult.Active = rset.%Get("Active")
            Set pResult.Manifestation = rset.%Get("Manifestation")
            Set pResult.Perinatal = rset.%Get("Perinatal")
            Set pResult.Pediatric = rset.%Get("Pediatric")
            Set pResult.Obstetric = rset.%Get("Obstetric")
            Set pResult.Adult = rset.%Get("Adult")
            Set pResult.Female = rset.%Get("Female")
            Set pResult.Male = rset.%Get("Male")
            Set pResult.PoaExempt = rset.%Get("PoaExempt")
            Set pResult.DpNotPrincipal = rset.%Get("DpNotPrincipal")
            Set pResult.Vcdp = rset.%Get("Vcdp")
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetChildren(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.HierarchyResult) As %Status
{
    Quit ..GetHierarchyList(pReleaseId, pVersion, pCodeType, pCode, "children", 0, 0, pLimit, pOffset, .pResult)
}

Method GetAncestors(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pIncludeSelf As %Boolean = 0, pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.HierarchyResult) As %Status
{
    Quit ..GetHierarchyList(pReleaseId, pVersion, pCodeType, pCode, "ancestors", pIncludeSelf, pMaxDepth, pLimit, pOffset, .pResult)
}

Method GetDescendants(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", pIncludeSelf As %Boolean = 0, pMaxDepth As %Integer = 0, pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.HierarchyResult) As %Status
{
    Quit ..GetHierarchyList(pReleaseId, pVersion, pCodeType, pCode, "descendants", pIncludeSelf, pMaxDepth, pLimit, pOffset, .pResult)
}

Method GetFamilies(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pLimit As %Integer = 100, pOffset As %Integer = 0, Output pResult As Terminology.CIE.DTO.FamilyResult) As %Status
{
    Set pResult = ##class(Terminology.CIE.DTO.FamilyResult).%New()
    Set pResult.Items = ##class(%ListOfObjects).%New()

    Try {
        Set whereList = ""
        Set argCount = 0

        Set sql = "SELECT FamilyCode, Description, ChapterCode, RangeStart, RangeEnd "_
                  "FROM Terminology_CIE.Family "
        Set endSQL = "ORDER BY FamilyCode"

        If pReleaseId'="" {
            Set whereList = whereList_$ListBuild("ReleaseId = ?")
            Do ..AddArgument(.args, .argCount, pReleaseId)
        }
        If pVersion'="" {
            Set whereList = whereList_$ListBuild("Version = ?")
            Do ..AddArgument(.args, .argCount, pVersion)
        }
        If pCodeType'="" {
            Set whereList = whereList_$ListBuild("CodeType = ?")
            Do ..AddArgument(.args, .argCount, pCodeType)
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

            Set item = ##class(Terminology.CIE.DTO.FamilyItem).%New()
            Set item.FamilyCode = rset.%Get("FamilyCode")
            Set item.Description = rset.%Get("Description")
            Set item.ChapterCode = rset.%Get("ChapterCode")
            Set item.RangeStart = rset.%Get("RangeStart")
            Set item.RangeEnd = rset.%Get("RangeEnd")
            Do pResult.Items.Insert(item)

            Set added = added + 1
        }

        Set pResult.Count = pResult.Items.Count()
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method ValidateCode(pReleaseId As %String = "", pVersion As %Integer = "", pCodeType As %String = "", pCode As %String = "", Output pResult As Terminology.CIE.DTO.ValidateCodeResult) As %Status
{
    Set pResult = ##class(Terminology.CIE.DTO.ValidateCodeResult).%New()

    Try {
        Set codeResult = ""
        Set tSC = ..GetCodeByCode(pReleaseId, pVersion, pCodeType, pCode, .codeResult)
        $$$ThrowOnError(tSC)

        If $IsObject(codeResult), codeResult.Code'="" {
            Set pResult.Exists = 1
            Set pResult.Active = $Select(codeResult.Active="":1,1:codeResult.Active)
            Set pResult.Code = codeResult.Code
            Set pResult.Description = codeResult.Description
            Set pResult.Version = codeResult.Version
            Set pResult.CodeType = codeResult.CodeType
        } Else {
            Set pResult.Exists = 0
            Set pResult.Active = 0
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetHierarchyList(pReleaseId As %String, pVersion As %Integer, pCodeType As %String, pCode As %String, pMode As %String, pIncludeSelf As %Boolean, pMaxDepth As %Integer, pLimit As %Integer, pOffset As %Integer, Output pResult As Terminology.CIE.DTO.HierarchyResult) As %Status [ Private ]
{
    Set pResult = ##class(Terminology.CIE.DTO.HierarchyResult).%New()
    Set pResult.Items = ##class(%ListOfObjects).%New()

    Try {
        Set whereList = ""
        Set argCount = 0

        If pMode="children" {
            Set sql = "SELECT c.Code, c.Description, c.ParentCode, 1 AS Depth, c.HierarchyLevel "_
                      "FROM Terminology_CIE.Code c "
            Set whereList = whereList_$ListBuild("c.ParentCode = ?")
            Do ..AddArgument(.args, .argCount, pCode)
            Set endSQL = "ORDER BY c.Code"
        } ElseIf pMode="ancestors" {
            Set sql = "SELECT c.Code, c.Description, c.ParentCode, h.Depth, c.HierarchyLevel "_
                      "FROM Terminology_CIE.HierarchyEdge h "_
                      "INNER JOIN Terminology_CIE.Code c "_
                      "ON c.ReleaseId = h.ReleaseId AND c.Version = h.Version AND c.CodeType = h.CodeType AND c.Code = h.ParentCode "
            Set whereList = whereList_$ListBuild("h.ChildCode = ?")
            Do ..AddArgument(.args, .argCount, pCode)
            Set endSQL = "ORDER BY h.Depth, c.Code"
        } Else {
            Set sql = "SELECT c.Code, c.Description, c.ParentCode, h.Depth, c.HierarchyLevel "_
                      "FROM Terminology_CIE.HierarchyEdge h "_
                      "INNER JOIN Terminology_CIE.Code c "_
                      "ON c.ReleaseId = h.ReleaseId AND c.Version = h.Version AND c.CodeType = h.CodeType AND c.Code = h.ChildCode "
            Set whereList = whereList_$ListBuild("h.ParentCode = ?")
            Do ..AddArgument(.args, .argCount, pCode)
            Set endSQL = "ORDER BY h.Depth, c.Code"
        }

        If pMode="children" {
            If pReleaseId'="" {
                Set whereList = whereList_$ListBuild("c.ReleaseId = ?")
                Do ..AddArgument(.args, .argCount, pReleaseId)
            }
            If pVersion'="" {
                Set whereList = whereList_$ListBuild("c.Version = ?")
                Do ..AddArgument(.args, .argCount, pVersion)
            }
            If pCodeType'="" {
                Set whereList = whereList_$ListBuild("c.CodeType = ?")
                Do ..AddArgument(.args, .argCount, pCodeType)
            }
        } Else {
            If pReleaseId'="" {
                Set whereList = whereList_$ListBuild("h.ReleaseId = ?")
                Do ..AddArgument(.args, .argCount, pReleaseId)
            }
            If pVersion'="" {
                Set whereList = whereList_$ListBuild("h.Version = ?")
                Do ..AddArgument(.args, .argCount, pVersion)
            }
            If pCodeType'="" {
                Set whereList = whereList_$ListBuild("h.CodeType = ?")
                Do ..AddArgument(.args, .argCount, pCodeType)
            }
            If pMaxDepth>0 {
                Set whereList = whereList_$ListBuild("h.Depth <= ?")
                Do ..AddArgument(.args, .argCount, pMaxDepth)
            }
        }

        Set query = ..BuildQuery(sql, whereList, endSQL)
        Set tSC = ..ExecuteQuery(query, .args, argCount, .rset)
        $$$ThrowOnError(tSC)

        If pIncludeSelf, (pMode'="children") {
            Set self = ##class(Terminology.CIE.DTO.HierarchyItem).%New()
            Set self.Code = pCode
            Set self.Description = ..GetDescription(pReleaseId, pVersion, pCodeType, pCode)
            Set self.ParentCode = ""
            Set self.Depth = 0
            Set self.HierarchyLevel = ..GetHierarchyLevel(pReleaseId, pVersion, pCodeType, pCode)
            Do pResult.Items.Insert(self)
        }

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

            Set item = ##class(Terminology.CIE.DTO.HierarchyItem).%New()
            Set item.Code = rset.%Get("Code")
            Set item.Description = rset.%Get("Description")
            Set item.ParentCode = rset.%Get("ParentCode")
            Set item.Depth = rset.%Get("Depth")
            Set item.HierarchyLevel = rset.%Get("HierarchyLevel")
            Do pResult.Items.Insert(item)

            Set added = added + 1
        }

        Set pResult.Count = pResult.Items.Count()
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetDescription(pReleaseId As %String, pVersion As %Integer, pCodeType As %String, pCode As %String) As %String [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT Description FROM Terminology_CIE.Code WHERE ReleaseId = ? AND Version = ? AND CodeType = ? AND Code = ?"
    Set sc = stmt.%Prepare(sql) Quit ""
    Set rs = stmt.%Execute(pReleaseId, pVersion, pCodeType, pCode)
    If rs.%Next() Quit rs.%Get("Description")
    Quit ""
}

Method GetHierarchyLevel(pReleaseId As %String, pVersion As %Integer, pCodeType As %String, pCode As %String) As %Integer [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT HierarchyLevel FROM Terminology_CIE.Code WHERE ReleaseId = ? AND Version = ? AND CodeType = ? AND Code = ?"
    Set sc = stmt.%Prepare(sql) Quit 0
    Set rs = stmt.%Execute(pReleaseId, pVersion, pCodeType, pCode)
    If rs.%Next() Quit +rs.%Get("HierarchyLevel")
    Quit 0
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

Method AddArgument(ByRef pArgs, ByRef pArgCount As %Integer, pValue = "") As %Status [ Private ]
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
