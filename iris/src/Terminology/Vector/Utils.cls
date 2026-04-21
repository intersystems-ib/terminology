Class Terminology.Vector.Utils Extends %RegisteredObject
{

ClassMethod GetSystemUriByRelease(pReleaseId As %String) As %String [ Language = python ]
{
    import iris

    stmt = iris.sql.prepare(
        "SELECT SystemUri "
        "FROM Terminology_Core.VersionRelease "
        "WHERE ReleaseId = ?"
    )
    rs = stmt.execute(pReleaseId)
    df = rs.dataframe()

    if df is None or df.empty:
        raise Exception("SystemUri not found for ReleaseId: " + str(pReleaseId))

    return str(df.iloc[0]["systemuri"])
}

ClassMethod RebuildByRelease(pReleaseId As %String, pType As %String, pLang As %String = "", pDialect As %String = "", pVersion As %String = "", pCodeType As %String = "", pModelName As %String = "FremyCompany/BioLORD-2023-M", pBatchSize As %Integer = 50) As %Status
{
    Quit ..RebuildByReleasePy(
        pReleaseId,
        pType,
        pLang,
        pDialect,
        pVersion,
        pCodeType,
        pModelName,
        pBatchSize
    )
}

ClassMethod RebuildByReleasePy(pReleaseId As %String, pType As %String, pLang As %String = "", pDialect As %String = "", pVersion As %String = "", pCodeType As %String = "", pModelName As %String = "FremyCompany/BioLORD-2023-M", pBatchSize As %Integer = 50) As %Status [ Language = python ]
{
    import os
    import json
    import iris
    import sentence_transformers

    def normalize_type(value):
        return (value or "").strip().upper()

    def ensure_model(name):
        model_dir = "/iris-shared/model/"
        if not os.path.isdir(model_dir):
            model = sentence_transformers.SentenceTransformer(name)
            model.save(model_dir)
        return sentence_transformers.SentenceTransformer(model_dir)

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

    def build_select(type_name, release_id, lang, dialect, version, code_type):
        t = normalize_type(type_name)

        if t == "SNOMED":
            sql = (
                "SELECT ReleaseId, ConceptId AS Code, Lang, Term AS Text "
                "FROM Terminology_Snomed.PreferredTerm "
                "WHERE ReleaseId = ?"
            )
            params = [release_id]

            if lang != "":
                sql += " AND Lang = ?"
                params.append(lang)

            if dialect != "":
                sql += " AND Dialect = ?"
                params.append(dialect)

            return sql, params

        if t == "LOINC":
            sql = (
                "SELECT ReleaseId, LoincNum AS Code, Lang, Display AS Text "
                "FROM Terminology_Loinc.Display "
                "WHERE ReleaseId = ?"
            )
            params = [release_id]

            if lang != "":
                sql += " AND Lang = ?"
                params.append(lang)

            return sql, params

        if t == "ICD":
            sql = (
                "SELECT ReleaseId, Code, '' AS Lang, Description AS Text "
                "FROM Terminology_ICD.Code "
                "WHERE ReleaseId = ?"
            )
            params = [release_id]

            if version != "":
                sql += " AND Version = ?"
                params.append(version)

            if code_type != "":
                sql += " AND CodeType = ?"
                params.append(code_type)

            return sql, params

        raise Exception("Unsupported terminology type: " + str(type_name))

    def insert_batch(rows):
        if not rows:
            return

        selects = []
        params = []

        for i, row in enumerate(rows):
            prefix = "SELECT" if i == 0 else "UNION ALL SELECT"
            selects.append(prefix + " ?,?,?,?,?,?,TO_VECTOR(?,DECIMAL)")
            params.extend([
                row["SystemUri"],
                row["ReleaseId"],
                row["Code"],
                row["Lang"],
                row["Text"],
                row["Model"],
                row["Embedding"]
            ])

        sql = (
            "INSERT INTO Terminology_Vector.TermEmbedding "
            "(SystemUri, ReleaseId, Code, Lang, Text, Model, Embedding) "
            + " ".join(selects)
        )

        execute_non_query(sql, params, "InsertBatch")

    try:
        tSC = iris.cls("Terminology.Vector.Utils").ClearByRelease(pReleaseId)
        if not iris.system.Status.IsOK(tSC):
            return tSC

        system_uri = iris.cls("Terminology.Vector.Utils").GetSystemUriByRelease(pReleaseId)

        sql, params = build_select(
            pType,
            pReleaseId,
            pLang,
            pDialect,
            pVersion,
            pCodeType
        )

        stmt = iris.sql.prepare(sql)
        rs = stmt.execute(*params)
        df = rs.dataframe()

        if df is None or df.empty:
            return iris.system.Status.OK()

        df = df.fillna("")
        model = ensure_model(str(pModelName))
        batch_size = int(pBatchSize) if int(pBatchSize) > 0 else 50

        total = len(df)

        for start in range(0, total, batch_size):
            chunk = df.iloc[start:start + batch_size].copy()
            texts = chunk["text"].astype(str).tolist()
            embeddings = model.encode(texts, normalize_embeddings=True)
            chunk["embedding"] = embeddings.tolist()

            rows = []
            for _, row in chunk.iterrows():
                rows.append({
                    "SystemUri": str(system_uri),
                    "ReleaseId": str(row["releaseid"]),
                    "Code": str(row["code"]),
                    "Lang": str(row["lang"]),
                    "Text": str(row["text"]),
                    "Model": str(pModelName),
                    "Embedding": str(row["embedding"])
                })

            insert_batch(rows)

        return iris.system.Status.OK()

    except Exception as err:
        return iris.system.Status.Error(5001, str(err))
}

ClassMethod ClearAll() As %Status
{
    Set sql = "DELETE FROM Terminology_Vector.TermEmbedding"
    Set params = "[]"
    Quit ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(sql, params)
}

ClassMethod ClearByRelease(pReleaseId As %String) As %Status [ Language = python ]
{
    import json
    import iris

    try:
        system_uri = iris.cls("Terminology.Vector.Utils").GetSystemUriByRelease(pReleaseId)

        params_json = json.dumps([system_uri, pReleaseId], ensure_ascii=False)
        sc = iris.cls("Terminology.Core.SqlUtils").ExecuteNonQuery(
            "DELETE FROM Terminology_Vector.TermEmbedding WHERE SystemUri = ? AND ReleaseId = ?",
            params_json
        )
        return sc
    except Exception as err:
        return iris.system.Status.Error(5001, str(err))
}

ClassMethod SearchSimilar(pText As %String, pSystemUri As %String = "", pReleaseId As %String = "", pLang As %String = "", pTop As %Integer = 10, pModelName As %String = "FremyCompany/BioLORD-2023-M") As %DynamicArray
{
    Set result = []
    Try {
        Set stmt = ##class(%SQL.Statement).%New()
        Set sql = "SELECT TOP ? SystemUri, ReleaseId, Code, Lang, Text, Model "_
                  "FROM Terminology_Vector.TermEmbedding WHERE 1=1 "

        If pSystemUri'="" {
            Set sql = sql_"AND SystemUri = ? "
        }

        If pReleaseId'="" {
            Set sql = sql_"AND ReleaseId = ? "
        }

        If pLang'="" {
            Set sql = sql_"AND Lang = ? "
        }

        Set sql = sql_"ORDER BY VECTOR_DOT_PRODUCT(Embedding, TO_VECTOR(?,DECIMAL)) DESC"
        $$$ThrowOnError(stmt.%Prepare(sql))

        Set vector = ..EncodeText(pText, pModelName)

        If (pSystemUri'="")&&(pReleaseId'="")&&(pLang'="") {
            Set rs = stmt.%Execute(pTop, pSystemUri, pReleaseId, pLang, vector)
        } ElseIf (pSystemUri'="")&&(pReleaseId'="") {
            Set rs = stmt.%Execute(pTop, pSystemUri, pReleaseId, vector)
        } ElseIf (pSystemUri'="")&&(pLang'="") {
            Set rs = stmt.%Execute(pTop, pSystemUri, pLang, vector)
        } ElseIf (pReleaseId'="")&&(pLang'="") {
            Set rs = stmt.%Execute(pTop, pReleaseId, pLang, vector)
        } ElseIf (pSystemUri'="") {
            Set rs = stmt.%Execute(pTop, pSystemUri, vector)
        } ElseIf (pReleaseId'="") {
            Set rs = stmt.%Execute(pTop, pReleaseId, vector)
        } ElseIf (pLang'="") {
            Set rs = stmt.%Execute(pTop, pLang, vector)
        } Else {
            Set rs = stmt.%Execute(pTop, vector)
        }

        While rs.%Next() {
            Set item = {}
            Set item.systemUri = rs.%Get("SystemUri")
            Set item.releaseId = rs.%Get("ReleaseId")
            Set item.code = rs.%Get("Code")
            Set item.lang = rs.%Get("Lang")
            Set item.text = rs.%Get("Text")
            Set item.model = rs.%Get("Model")
            Do result.%Push(item)
        }
    } Catch ex {
    }
    Quit result
}

ClassMethod EncodeText(pText As %String, pModelName As %String = "FremyCompany/BioLORD-2023-M") As %String [ Language = python ]
{
    import os
    import sentence_transformers

    model_dir = "/iris-shared/model/"
    if not os.path.isdir(model_dir):
        model = sentence_transformers.SentenceTransformer(str(pModelName))
        model.save(model_dir)

    model = sentence_transformers.SentenceTransformer(model_dir)
    embedding = model.encode([str(pText)], normalize_embeddings=True)[0]
    return str(embedding.tolist())
}

}
