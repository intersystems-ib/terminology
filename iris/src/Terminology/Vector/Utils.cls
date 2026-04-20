Class Terminology.Vector.Utils Extends %RegisteredObject
{

ClassMethod RebuildBySource(pSource As %String, pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "", pVersion As %String = "", pCodeType As %String = "") As %Status
{
    Quit ..RebuildBySourcePy(pSource, pReleaseId, pLang, pDialect, pVersion, pCodeType)
}

ClassMethod RebuildBySourcePy(pSource As %String, pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "", pVersion As %String = "", pCodeType As %String = "") As %Status [ Language = python ]
{
    import iris

    try:
        source = (str(pSource).strip().upper() if pSource is not None else "")

        if source == "SNOMED":
            tSC = iris.cls("Terminology.Vector.Utils").ClearBySource("SNOMED", pReleaseId)
            if not iris.system.Status.IsOK(tSC):
                return tSC
            return iris.cls("Terminology.Vector.Utils").LoadSnomed(pReleaseId, pLang, pDialect)

        if source == "LOINC":
            tSC = iris.cls("Terminology.Vector.Utils").ClearBySource("LOINC", pReleaseId)
            if not iris.system.Status.IsOK(tSC):
                return tSC
            return iris.cls("Terminology.Vector.Utils").LoadLoinc(pReleaseId, pLang)

        if (source == "ICD") or (source == "CIE"):
            tSC = iris.cls("Terminology.Vector.Utils").ClearBySource("ICD", pReleaseId)
            if not iris.system.Status.IsOK(tSC):
                return tSC
            return iris.cls("Terminology.Vector.Utils").LoadICD(pReleaseId, pVersion, pCodeType)

        return iris.system.Status.Error(5001, "Unsupported source: " + str(pSource))

    except Exception as err:
        return iris.system.Status.Error(5001, str(err))
}

ClassMethod ClearAll() As %Status
{
    Set sql = "DELETE FROM Terminology_Vector.TermEmbedding"
    Set params = "[]"
    Quit ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(sql, params)
}

ClassMethod ClearBySource(pSource As %String, pReleaseId As %String = "") As %Status
{
    Set source = $ZCONVERT($ZSTRIP($Get(pSource),"<>W"),"U")

    If pReleaseId'="" {
        Set sql = "DELETE FROM Terminology_Vector.TermEmbedding WHERE CodeSystem = ? AND ReleaseId = ?"
        Set params = "[ """_$Replace(source,"""","\""")_""", """_$Replace($Get(pReleaseId),"""","\""")_""" ]"
        Quit ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(sql, params)
    }

    Set sql = "DELETE FROM Terminology_Vector.TermEmbedding WHERE CodeSystem = ?"
    Set params = "[ """_$Replace(source,"""","\""")_""" ]"
    Quit ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(sql, params)
}

ClassMethod LoadSnomed(pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "") As %Status
{
    Quit ..LoadSnomedPy(pReleaseId, pLang, pDialect)
}

ClassMethod LoadSnomedPy(pReleaseId As %String = "", pLang As %String = "", pDialect As %String = "") As %Status [ Language = python ]
{
    import iris
    import json

    def execute_non_query(sql, params, context=""):
        params_json = json.dumps(list(params), ensure_ascii=False)
        sc = iris.cls("Terminology.Core.SqlUtils").ExecuteNonQuery(sql, params_json)
        if not iris.system.Status.IsOK(sc):
            try:
                iris.cls("Terminology.Core.SqlUtils").LogStatus(
                    "ExecuteNonQuery [" + context + "]",
                    sc
                )
            except Exception:
                pass
            raise Exception("ExecuteNonQuery failed in " + context)

    try:
        sql = (
            "SELECT %ID AS TermId, ReleaseId, ConceptId AS Code, Lang, Dialect, Term AS Description "
            "FROM Terminology_Snomed.PreferredTerm WHERE 1=1"
        )
        params = []

        if pReleaseId != "":
            sql = sql + " AND ReleaseId = ?"
            params.append(pReleaseId)

        if pLang != "":
            sql = sql + " AND Lang = ?"
            params.append(pLang)

        if pDialect != "":
            sql = sql + " AND Dialect = ?"
            params.append(pDialect)

        stmt = iris.sql.prepare(sql)
        rs = stmt.execute(*params)
        df = rs.dataframe()

        if df is None or df.empty:
            return iris.system.Status.OK()

        df = df.fillna("")

        insert_sql = (
            "INSERT INTO Terminology_Vector.TermEmbedding "
            "(CodeSystem, ReleaseId, Code, Lang, Description) "
            "VALUES (?,?,?,?,?)"
        )

        for _, row in df.iterrows():
            execute_non_query(
                insert_sql,
                [
                    "SNOMED",
                    str(row["releaseid"]),
                    str(row["code"]),
                    str(row["lang"]),
                    str(row["description"])
                ],
                "InsertSnomed"
            )

        return iris.system.Status.OK()

    except Exception as err:
        return iris.system.Status.Error(5001, str(err))
}

ClassMethod LoadLoinc(pReleaseId As %String = "", pLang As %String = "") As %Status
{
    Quit ..LoadLoincPy(pReleaseId, pLang)
}

ClassMethod LoadLoincPy(pReleaseId As %String = "", pLang As %String = "") As %Status [ Language = python ]
{
    import iris
    import json

    def execute_non_query(sql, params, context=""):
        params_json = json.dumps(list(params), ensure_ascii=False)
        sc = iris.cls("Terminology.Core.SqlUtils").ExecuteNonQuery(sql, params_json)
        if not iris.system.Status.IsOK(sc):
            try:
                iris.cls("Terminology.Core.SqlUtils").LogStatus(
                    "ExecuteNonQuery [" + context + "]",
                    sc
                )
            except Exception:
                pass
            raise Exception("ExecuteNonQuery failed in " + context)

    try:
        sql = (
            "SELECT %ID AS TermId, ReleaseId, LoincNum AS Code, Lang, Display AS Description "
            "FROM Terminology_Loinc.Display WHERE 1=1"
        )
        params = []

        if pReleaseId != "":
            sql = sql + " AND ReleaseId = ?"
            params.append(pReleaseId)

        if pLang != "":
            sql = sql + " AND Lang = ?"
            params.append(pLang)

        stmt = iris.sql.prepare(sql)
        rs = stmt.execute(*params)
        df = rs.dataframe()

        if df is None or df.empty:
            return iris.system.Status.OK()

        df = df.fillna("")

        insert_sql = (
            "INSERT INTO Terminology_Vector.TermEmbedding "
            "(CodeSystem, ReleaseId, Code, Lang, Description) "
            "VALUES (?,?,?,?,?)"
        )

        for _, row in df.iterrows():
            execute_non_query(
                insert_sql,
                [
                    "LOINC",
                    str(row["releaseid"]),
                    str(row["code"]),
                    str(row["lang"]),
                    str(row["description"])
                ],
                "InsertLoinc"
            )

        return iris.system.Status.OK()

    except Exception as err:
        return iris.system.Status.Error(5001, str(err))
}

ClassMethod LoadICD(pReleaseId As %String = "", pVersion As %String = "", pCodeType As %String = "") As %Status
{
    Quit ..LoadICDPy(pReleaseId, pVersion, pCodeType)
}

ClassMethod LoadICDPy(pReleaseId As %String = "", pVersion As %String = "", pCodeType As %String = "") As %Status [ Language = python ]
{
    import iris
    import json

    def execute_non_query(sql, params, context=""):
        params_json = json.dumps(list(params), ensure_ascii=False)
        sc = iris.cls("Terminology.Core.SqlUtils").ExecuteNonQuery(sql, params_json)
        if not iris.system.Status.IsOK(sc):
            try:
                iris.cls("Terminology.Core.SqlUtils").LogStatus(
                    "ExecuteNonQuery [" + context + "]",
                    sc
                )
            except Exception:
                pass
            raise Exception("ExecuteNonQuery failed in " + context)

    try:
        sql = (
            "SELECT %ID AS TermId, ReleaseId, Code, '' AS Lang, Description "
            "FROM Terminology_ICD.Code WHERE 1=1"
        )
        params = []

        if pReleaseId != "":
            sql = sql + " AND ReleaseId = ?"
            params.append(pReleaseId)

        if pVersion != "":
            sql = sql + " AND Version = ?"
            params.append(pVersion)

        if pCodeType != "":
            sql = sql + " AND CodeType = ?"
            params.append(pCodeType)

        stmt = iris.sql.prepare(sql)
        rs = stmt.execute(*params)
        df = rs.dataframe()

        if df is None or df.empty:
            return iris.system.Status.OK()

        df = df.fillna("")

        insert_sql = (
            "INSERT INTO Terminology_Vector.TermEmbedding "
            "(CodeSystem, ReleaseId, Code, Lang, Description) "
            "VALUES (?,?,?,?,?)"
        )

        for _, row in df.iterrows():
            execute_non_query(
                insert_sql,
                [
                    "ICD",
                    str(row["releaseid"]),
                    str(row["code"]),
                    "",
                    str(row["description"])
                ],
                "InsertICD"
            )

        return iris.system.Status.OK()

    except Exception as err:
        return iris.system.Status.Error(5001, str(err))
}

ClassMethod SearchSimilar(pText As %String, pCodeSystem As %String = "", pReleaseId As %String = "", pLang As %String = "", pTop As %Integer = 10) As %DynamicArray
{
    Set result = []
    Try {
        Set sql = "SELECT TOP ? CodeSystem, ReleaseId, Code, Lang, Description "_
                  "FROM Terminology_Vector.TermEmbedding WHERE 1=1 "

        If pCodeSystem'="" {
            Set sql = sql_"AND CodeSystem = ? "
        }

        If pReleaseId'="" {
            Set sql = sql_"AND ReleaseId = ? "
        }

        If pLang'="" {
            Set sql = sql_"AND Lang = ? "
        }

        Set sql = sql_"ORDER BY VECTOR_DOT_PRODUCT(DescriptionEmbedding, EMBEDDING(?,'sentence-transformers-config')) DESC"

        Set stmt = ##class(%SQL.Statement).%New()
        $$$ThrowOnError(stmt.%Prepare(sql))

        If (pCodeSystem'="")&&(pReleaseId'="")&&(pLang'="") {
            Set rs = stmt.%Execute(pTop, pCodeSystem, pReleaseId, pLang, pText)
        } ElseIf (pCodeSystem'="")&&(pReleaseId'="") {
            Set rs = stmt.%Execute(pTop, pCodeSystem, pReleaseId, pText)
        } ElseIf (pCodeSystem'="")&&(pLang'="") {
            Set rs = stmt.%Execute(pTop, pCodeSystem, pLang, pText)
        } ElseIf (pReleaseId'="")&&(pLang'="") {
            Set rs = stmt.%Execute(pTop, pReleaseId, pLang, pText)
        } ElseIf (pCodeSystem'="") {
            Set rs = stmt.%Execute(pTop, pCodeSystem, pText)
        } ElseIf (pReleaseId'="") {
            Set rs = stmt.%Execute(pTop, pReleaseId, pText)
        } ElseIf (pLang'="") {
            Set rs = stmt.%Execute(pTop, pLang, pText)
        } Else {
            Set rs = stmt.%Execute(pTop, pText)
        }

        While rs.%Next() {
            Set item = {}
            Set item.codeSystem = rs.%Get("CodeSystem")
            Set item.releaseId = rs.%Get("ReleaseId")
            Set item.code = rs.%Get("Code")
            Set item.lang = rs.%Get("Lang")
            Set item.description = rs.%Get("Description")
            Do result.%Push(item)
        }
    } Catch ex {
    }
    Quit result
}

}
