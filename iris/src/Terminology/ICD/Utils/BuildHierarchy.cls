Class Terminology.ICD.Utils.BuilderHierarchy Extends %RegisteredObject
{

ClassMethod Build(pReleaseId As %String, pVersion As %Integer, pCodeType As %String) As %Status
{
    Quit ..BuildPy(pReleaseId, pVersion, pCodeType)
}

ClassMethod BuildPy(pReleaseId As %String, pVersion As %Integer, pCodeType As %String) As %Status [ Language = python ]
{
    import iris
    import json

    def log_info(msg):
        try:
            iris.cls("Ens.Util.Log").LogInfo(
                "Terminology.ICD.Utils.BuilderHierarchy",
                "BuildPy",
                str(msg)
            )
        except Exception:
            pass

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
        log_info(
            f"Start hierarchy build | ReleaseId={pReleaseId} | Version={pVersion} | CodeType={pCodeType}"
        )

        execute_non_query(
            "DELETE FROM Terminology_ICD.HierarchyEdge WHERE ReleaseId = ? AND Version = ? AND CodeType = ?",
            [pReleaseId, pVersion, pCodeType],
            "DeleteHierarchy"
        )

        stmt_select = iris.sql.prepare(
            "SELECT Code, ParentCode, HierarchyLevel "
            "FROM Terminology_ICD.Code "
            "WHERE ReleaseId = ? AND Version = ? AND CodeType = ? "
            "ORDER BY HierarchyLevel, Code"
        )
        rs = stmt_select.execute(pReleaseId, pVersion, pCodeType)
        df = rs.dataframe()

        if df is None or df.empty:
            return iris.system.Status.OK()

        df = df.fillna("")

        parent_map = {}
        for _, row in df.iterrows():
            code = str(row["code"]).strip() if row["code"] is not None else ""
            parent_code = str(row["parentcode"]).strip() if row["parentcode"] is not None else ""
            if code == "":
                continue
            parent_map[code] = parent_code

        edge_rows = []

        for child_code, parent_code in parent_map.items():
            if not parent_code:
                continue

            edge_rows.append((
                pReleaseId,
                pVersion,
                pCodeType,
                "CODE",
                parent_code,
                child_code,
                1
            ))

            depth = 2
            current_parent = parent_map.get(parent_code, "") or ""
            visited = {child_code, parent_code}

            while current_parent:
                if current_parent in visited:
                    break

                edge_rows.append((
                    pReleaseId,
                    pVersion,
                    pCodeType,
                    "CODE",
                    current_parent,
                    child_code,
                    depth
                ))

                visited.add(current_parent)
                current_parent = parent_map.get(current_parent, "") or ""
                depth += 1

        insert_sql = (
            "INSERT INTO Terminology_ICD.HierarchyEdge "
            "(ReleaseId, Version, CodeType, HierarchyType, ParentCode, ChildCode, Depth) "
            "VALUES (?,?,?,?,?,?,?)"
        )

        for row in edge_rows:
            execute_non_query(insert_sql, row, "InsertHierarchyEdge")

        log_info(
            f"Hierarchy build completed | Edges={len(edge_rows)}"
        )

        return iris.system.Status.OK()

    except Exception as err:
        return iris.system.Status.Error(5001, str(err))
}

}
