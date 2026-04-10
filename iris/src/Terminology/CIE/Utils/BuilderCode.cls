Class Terminology.CIE.Utils.BuilderCode Extends %RegisteredObject
{

ClassMethod Build(pFilePath As %String, pReleaseId As %String, pVersion As %Integer, pCodeType As %String, pLang As %String = "es") As %Status
{
    Quit ..BuildPy(pFilePath, pReleaseId, pVersion, pCodeType, pLang)
}

ClassMethod BuildPy(pFilePath As %String, pReleaseId As %String, pVersion As %Integer, pCodeType As %String, pLang As %String = "es") As %Status [ Language = python ]
{
    import csv
    import json
    import re
    import iris

    CHAPTER_RE = re.compile(r"^Cap\.\d+$", re.IGNORECASE)
    FAMILY_RE = re.compile(r"^[A-Z]\d\d-[A-Z]\d\d$")
    CODE_RE = re.compile(r"^[A-Z][A-Z0-9]*(\.[A-Z0-9]+)?$")

    def log_info(msg):
        try:
            iris.cls("Ens.Util.Log").LogInfo(
                "Terminology.CIE.Utils.BuilderCode",
                "BuildPy",
                str(msg)
            )
        except Exception:
            pass

    def prepare(sql, context=""):
        try:
            return iris.sql.prepare(sql)
        except Exception as e:
            log_info("SQL PREPARE ERROR [" + context + "] | " + str(e) + " | SQL=" + str(sql))
            raise

    def execute_non_query(sql, *params, context=""):
        try:
            params_json = json.dumps(list(params), ensure_ascii=False)
            sc = iris.cls("Terminology.Core.SqlUtils").ExecuteNonQuery(sql, params_json)
            if not iris.system.Status.IsOK(sc):
                try:
                    iris.cls("Terminology.Core.SqlUtils").LogStatus("ExecuteNonQuery [" + context + "]", sc)
                except Exception:
                    pass
                raise Exception("ExecuteNonQuery devolvió error")
        except Exception as e:
            log_info("NON QUERY ERROR [" + context + "] | Params=" + str(params) + " | " + str(e))
            raise

    def batch_insert(stmt, rows, batch_size=5000):
        if not rows:
            return
        for i in range(0, len(rows), batch_size):
            chunk = rows[i:i + batch_size]
            for row in chunk:
                stmt.execute(*row)

    def normalize_term(value):
        return (value or "").strip().upper()

    def to_bool(value):
        v = (value or "").strip().lower()
        return 1 if v in ("1", "true", "t", "yes", "y", "si", "sí", "x") else 0

    def detect_record_kind(code):
        c = (code or "").strip()
        if not c:
            return ""
        if CHAPTER_RE.match(c):
            return "CHAPTER"
        if FAMILY_RE.match(c):
            return "FAMILY"
        if CODE_RE.match(c):
            return "CODE"
        return "CODE"

    def split_family_range(family_code):
        if "-" not in family_code:
            return "", ""
        parts = family_code.split("-", 1)
        return parts[0].strip(), parts[1].strip()

    def clean_text(value):
        return (value or "").strip()

    def find_header_index(fieldnames, candidates):
        lowered = {str(name).strip().lower(): name for name in fieldnames if name is not None}
        for candidate in candidates:
            key = candidate.strip().lower()
            if key in lowered:
                return lowered[key]
        return None

    def parse_file_rows(file_path):
        with open(file_path, "r", encoding="utf-8-sig", newline="") as f:
            reader = csv.DictReader(f, delimiter="\t")
            headers = reader.fieldnames or []
            if not headers:
                raise Exception("El fichero CIE no tiene cabecera")

            col_code = find_header_index(headers, ["Código", "Codigo", "Code"])
            col_desc = find_header_index(headers, ["Descripción", "Descripcion", "Description"])
            col_node = find_header_index(headers, ["Nodo_Final", "Nodo final", "NodeFinal"])

            col_manifest = find_header_index(headers, ["Manifestación", "Manifestacion"])
            col_perinatal = find_header_index(headers, ["Perinatal"])
            col_pediatric = find_header_index(headers, ["Pediátrico", "Pediatrico"])
            col_obstetric = find_header_index(headers, ["Obstétrico", "Obstetrico"])
            col_adult = find_header_index(headers, ["Adulto"])
            col_female = find_header_index(headers, ["Mujer"])
            col_male = find_header_index(headers, ["Hombre"])
            col_poa = find_header_index(headers, ["Poa_Exento", "POA_ExENTO", "Poa Exento"])
            col_dpnp = find_header_index(headers, ["Dp_no principal", "DP_no principal"])
            col_vcdp = find_header_index(headers, ["Vcdp", "VCDP"])

            if not col_code or not col_desc:
                raise Exception("Cabecera CIE inválida: faltan Código/Descripción")

            current_chapter = ""
            current_family = ""
            row_num = 0

            stage_rows = []
            chapter_rows = []
            family_rows = []
            code_rows = []

            for raw in reader:
                row_num += 1

                code = clean_text(raw.get(col_code, ""))
                desc = clean_text(raw.get(col_desc, ""))

                if not code and not desc:
                    continue

                kind = detect_record_kind(code)

                if kind == "CHAPTER":
                    current_chapter = code
                    current_family = ""
                elif kind == "FAMILY":
                    current_family = code

                node_final = to_bool(raw.get(col_node, "")) if col_node else 0
                manifestation = to_bool(raw.get(col_manifest, "")) if col_manifest else 0
                perinatal = to_bool(raw.get(col_perinatal, "")) if col_perinatal else 0
                pediatric = to_bool(raw.get(col_pediatric, "")) if col_pediatric else 0
                obstetric = to_bool(raw.get(col_obstetric, "")) if col_obstetric else 0
                adult = to_bool(raw.get(col_adult, "")) if col_adult else 0
                female = to_bool(raw.get(col_female, "")) if col_female else 0
                male = to_bool(raw.get(col_male, "")) if col_male else 0
                poa = to_bool(raw.get(col_poa, "")) if col_poa else 0
                dpnp = to_bool(raw.get(col_dpnp, "")) if col_dpnp else 0
                vcdp = to_bool(raw.get(col_vcdp, "")) if col_vcdp else 0

                stage_rows.append([
                    pReleaseId, pVersion, pCodeType, row_num, kind, code, desc,
                    current_chapter, current_family, node_final,
                    manifestation, perinatal, pediatric, obstetric, adult,
                    female, male, poa, dpnp, vcdp
                ])

                if kind == "CHAPTER":
                    chapter_rows.append([
                        pReleaseId, pVersion, pCodeType, code, desc, "", normalize_term(desc)
                    ])
                elif kind == "FAMILY":
                    range_start, range_end = split_family_range(code)
                    family_rows.append([
                        pReleaseId, pVersion, pCodeType, code, desc, normalize_term(desc),
                        current_chapter, range_start, range_end
                    ])
                elif kind == "CODE":
                    code_rows.append({
                        "ReleaseId": pReleaseId,
                        "Version": pVersion,
                        "CodeType": pCodeType,
                        "Code": code,
                        "Description": desc,
                        "DescriptionNorm": normalize_term(desc),
                        "ParentCode": "",
                        "ChapterCode": current_chapter,
                        "FamilyCode": current_family,
                        "HierarchyLevel": 0,
                        "NodeFinal": node_final,
                        "Active": 1,
                        "Manifestation": manifestation,
                        "Perinatal": perinatal,
                        "Pediatric": pediatric,
                        "Obstetric": obstetric,
                        "Adult": adult,
                        "Female": female,
                        "Male": male,
                        "PoaExempt": poa,
                        "DpNotPrincipal": dpnp,
                        "Vcdp": vcdp
                    })

            return stage_rows, chapter_rows, family_rows, code_rows

    def find_immediate_parent(code, code_set):
        if not code:
            return ""
        for i in range(len(code) - 1, 0, -1):
            candidate = code[:i]
            if candidate in code_set:
                return candidate
        return ""

    def resolve_parents_and_levels(code_rows):
        code_set = {row["Code"] for row in code_rows}
        code_map = {row["Code"]: row for row in code_rows}

        for row in code_rows:
            row["ParentCode"] = find_immediate_parent(row["Code"], code_set)

        memo = {}

        def level_for(code):
            if code in memo:
                return memo[code]
            row = code_map.get(code)
            if not row:
                memo[code] = 0
                return 0
            parent = row.get("ParentCode") or ""
            if not parent:
                memo[code] = 1
                return 1
            memo[code] = level_for(parent) + 1
            return memo[code]

        for row in code_rows:
            row["HierarchyLevel"] = level_for(row["Code"])

        return code_rows

    log_info(
        "Inicio CIE BuilderCode | FilePath=" + str(pFilePath) +
        " | ReleaseId=" + str(pReleaseId) +
        " | Version=" + str(pVersion) +
        " | CodeType=" + str(pCodeType) +
        " | Lang=" + str(pLang)
    )

    execute_non_query(
        "DELETE FROM Terminology_CIE.LoadStage WHERE ReleaseId = ? AND Version = ? AND CodeType = ?",
        pReleaseId, pVersion, pCodeType,
        context="delete_stage"
    )
    execute_non_query(
        "DELETE FROM Terminology_CIE.HierarchyEdge WHERE ReleaseId = ? AND Version = ? AND CodeType = ?",
        pReleaseId, pVersion, pCodeType,
        context="delete_hierarchy"
    )
    execute_non_query(
        "DELETE FROM Terminology_CIE.Code WHERE ReleaseId = ? AND Version = ? AND CodeType = ?",
        pReleaseId, pVersion, pCodeType,
        context="delete_code"
    )
    execute_non_query(
        "DELETE FROM Terminology_CIE.Family WHERE ReleaseId = ? AND Version = ? AND CodeType = ?",
        pReleaseId, pVersion, pCodeType,
        context="delete_family"
    )
    execute_non_query(
        "DELETE FROM Terminology_CIE.Chapter WHERE ReleaseId = ? AND Version = ? AND CodeType = ?",
        pReleaseId, pVersion, pCodeType,
        context="delete_chapter"
    )

    stage_rows, chapter_rows, family_rows, code_rows = parse_file_rows(str(pFilePath))
    log_info(
        "Fichero parseado | stage=" + str(len(stage_rows)) +
        " | chapters=" + str(len(chapter_rows)) +
        " | families=" + str(len(family_rows)) +
        " | codes=" + str(len(code_rows))
    )

    code_rows = resolve_parents_and_levels(code_rows)

    stmt_stage = prepare(
        """INSERT INTO Terminology_CIE.LoadStage
        (ReleaseId, Version, CodeType, RowNum, RecordKind, RawCode, RawDescription,
         CurrentChapterCode, CurrentFamilyCode, NodeFinal, Manifestation, Perinatal,
         Pediatric, Obstetric, Adult, Female, Male, PoaExempt, DpNotPrincipal, Vcdp)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
        "insert_stage"
    )

    stmt_chapter = prepare(
        """INSERT INTO Terminology_CIE.Chapter
        (ReleaseId, Version, CodeType, ChapterCode, Description, RangeText, DescriptionNorm)
        VALUES (?,?,?,?,?,?,?)""",
        "insert_chapter"
    )

    stmt_family = prepare(
        """INSERT INTO Terminology_CIE.Family
        (ReleaseId, Version, CodeType, FamilyCode, Description, DescriptionNorm, ChapterCode, RangeStart, RangeEnd)
        VALUES (?,?,?,?,?,?,?,?,?)""",
        "insert_family"
    )

    stmt_code = prepare(
        """INSERT INTO Terminology_CIE.Code
        (ReleaseId, Version, CodeType, Code, Description, DescriptionNorm, ParentCode, ChapterCode, FamilyCode,
         HierarchyLevel, NodeFinal, Active, Manifestation, Perinatal, Pediatric, Obstetric, Adult, Female, Male,
         PoaExempt, DpNotPrincipal, Vcdp)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
        "insert_code"
    )

    batch_insert(stmt_stage, stage_rows)
    batch_insert(stmt_chapter, chapter_rows)
    batch_insert(stmt_family, family_rows)

    code_insert_rows = []
    for row in code_rows:
        code_insert_rows.append([
            row["ReleaseId"], row["Version"], row["CodeType"], row["Code"],
            row["Description"], row["DescriptionNorm"], row["ParentCode"],
            row["ChapterCode"], row["FamilyCode"], row["HierarchyLevel"],
            row["NodeFinal"], row["Active"], row["Manifestation"], row["Perinatal"],
            row["Pediatric"], row["Obstetric"], row["Adult"], row["Female"],
            row["Male"], row["PoaExempt"], row["DpNotPrincipal"], row["Vcdp"]
        ])

    batch_insert(stmt_code, code_insert_rows)

    log_info(
        "BuilderCode completado | chapters=" + str(len(chapter_rows)) +
        " | families=" + str(len(family_rows)) +
        " | codes=" + str(len(code_insert_rows))
    )

    return iris.system.Status.OK()
}

}
