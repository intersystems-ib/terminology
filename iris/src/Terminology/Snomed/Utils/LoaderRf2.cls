Class Terminology.Snomed.Utils.LoaderRf2 Extends %RegisteredObject
{

ClassMethod LoadSnapshot(pDir As %String, pReleaseId As %String, pSystemUri As %String = "http://snomed.info/sct", pEffectiveDate As %Date = "", pSetActive As %Boolean = 1, pSuffixFile As %String = "", pClearRelease As %Boolean = 0, pPreferredTermLang As %String = "") As %Status
{
    Quit ..LoadSnapshotPy(pDir, pReleaseId, pSystemUri, pEffectiveDate, pSetActive, pSuffixFile, pClearRelease, pPreferredTermLang)
}

ClassMethod LoadSnapshotPy(pDir As %String, pReleaseId As %String, pSystemUri As %String, pEffectiveDate As %String, pSetActive As %Boolean, pSuffixFile As %String, pClearRelease As %Boolean = 0, pPreferredTermLang As %String = "es") As %Status [ Language = python ]
{
import os
import glob
import json
import re
import iris

_stmt_cache = {}

def log_info(msg):
    try:
        iris.cls("Ens.Util.Log").LogInfo(
            "Terminology.Snomed.Utils.LoaderRf2",
            "LoadSnapshotPy",
            str(msg)
        )
    except Exception:
        pass

def prepare(sql, context=""):
    cache_key = ("prepare", sql)
    if cache_key in _stmt_cache:
        return _stmt_cache[cache_key]

    try:
        stmt = iris.sql.prepare(sql)
        _stmt_cache[cache_key] = stmt
        return stmt
    except Exception as e:
        log_info(
            "SQL PREPARE ERROR [" + context + "] | SQL: " + str(sql) +
            " | Error: " + str(e)
        )
        raise

def execute_select_df(sql, *params, context=""):
    stmt = prepare(sql, context)
    try:
        rs = stmt.execute(*params)
        return rs.dataframe()
    except Exception as e:
        log_info(
            "SQL SELECT ERROR [" + context + "] | SQL: " + str(sql) +
            " | Params: " + str(params) +
            " | Error: " + str(e)
        )
        raise

def exists_sql(sql, *params, context=""):
    df = execute_select_df(sql, *params, context=context)
    return df.size > 0

def execute_non_query(sql, *params, context=""):
    try:
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
            raise Exception("ExecuteNonQuery devolvió error")
    except Exception as e:
        log_info(
            "NON QUERY ERROR [" + context + "] | SQL: " + str(sql) +
            " | Params: " + str(params) +
            " | Error: " + str(e)
        )
        raise

def get_insert_stmt(context, sql):
    cache_key = ("insert", context)
    if cache_key not in _stmt_cache:
        _stmt_cache[cache_key] = prepare(sql, "insert_" + context)
    return _stmt_cache[cache_key]

def flush_rows(stmt, rows, context="", progress_label="", counter_state=None):
    if not rows:
        return

    inserted_now = 0
    for row in rows:
        try:
            stmt.execute(*row)
            inserted_now += 1
        except Exception as e:
            log_info(
                "ROW INSERT ERROR [" + context + "] | Row: " + str(row) +
                " | Error: " + str(e)
            )
            raise

    if counter_state is not None:
        counter_state["count"] = counter_state.get("count", 0) + inserted_now
        if progress_label:
            log_info(progress_label + ": " + str(counter_state["count"]))

    rows.clear()

def ensure_code_system(system_uri):
    default_name = "SNOMEDCT"
    default_lang = "es"
    default_dialect = "es-ES"
    default_notes = "SNOMED CT code system"

    if exists_sql(
        "SELECT SystemUri FROM Terminology_Core.CodeSystem WHERE SystemUri = ?",
        system_uri,
        context="check_codesystem_exists"
    ):
        execute_non_query(
            "UPDATE Terminology_Core.CodeSystem "
            "SET Name = ?, DefaultLang = ?, DefaultDialect = ?, Notes = ? "
            "WHERE SystemUri = ?",
            default_name,
            default_lang,
            default_dialect,
            default_notes,
            system_uri,
            context="update_codesystem"
        )
    else:
        execute_non_query(
            "INSERT INTO Terminology_Core.CodeSystem "
            "(SystemUri, Name, DefaultLang, DefaultDialect, Notes) "
            "SELECT ?, ?, ?, ?, ?",
            system_uri,
            default_name,
            default_lang,
            default_dialect,
            default_notes,
            context="insert_codesystem"
        )

def ensure_license_notice(system_uri):
    default_notice = "SNOMED CT content is subject to SNOMED International licensing terms."
    default_source = "http://snomed.org/licensing"

    if exists_sql(
        "SELECT SystemUri FROM Terminology_Core.LicenseNotice WHERE SystemUri = ?",
        system_uri,
        context="check_license_exists"
    ):
        execute_non_query(
            "UPDATE Terminology_Core.LicenseNotice "
            "SET NoticeText = ?, Source = ? "
            "WHERE SystemUri = ?",
            default_notice,
            default_source,
            system_uri,
            context="update_license"
        )
    else:
        execute_non_query(
            "INSERT INTO Terminology_Core.LicenseNotice "
            "(SystemUri, NoticeText, Source) "
            "SELECT ?, ?, ?",
            system_uri,
            default_notice,
            default_source,
            context="insert_license"
        )

def resolve_effective_token(effective_date, release_id):
    if effective_date:
        value = str(effective_date).strip()
        if len(value) == 10 and value[4] == "-" and value[7] == "-":
            return value[0:4] + value[5:7] + value[8:10]
        if len(value) == 8 and value.isdigit():
            return value

    if release_id:
        match = re.search(r"(\d{8})", str(release_id))
        if match:
            return match.group(1)

    return ""

def build_snomed_version_uri(system_uri, effective_date, release_id):
    uri = (system_uri or "").strip().rstrip("/")
    if uri == "":
        return ""

    # If caller already passed a fully-versioned SNOMED URI, keep it.
    if re.match(r"^http://snomed\.info/sct/\d+/version/\d{8}$", uri):
        return uri

    # If caller passed an edition URI, append version date when available.
    if re.match(r"^http://snomed\.info/sct/\d+$", uri):
        token = resolve_effective_token(effective_date, release_id)
        if token != "":
            return uri + "/version/" + token
        return uri

    # For non-edition URIs (for example plain http://snomed.info/sct), keep empty.
    return ""

def ensure_release(release_id, system_uri, effective_date, set_active):
    version_uri = build_snomed_version_uri(system_uri, effective_date, release_id)

    if exists_sql(
        "SELECT ReleaseId FROM Terminology_Core.VersionRelease WHERE ReleaseId = ?",
        release_id,
        context="check_release_exists"
    ):
        if effective_date:
            execute_non_query(
                "UPDATE Terminology_Core.VersionRelease "
                "SET SystemUri = ?, VersionUri = ?, EffectiveDate = DATE(?), IsActive = 0 "
                "WHERE ReleaseId = ?",
                system_uri,
                version_uri,
                effective_date,
                release_id,
                context="update_release"
            )
        else:
            execute_non_query(
                "UPDATE Terminology_Core.VersionRelease "
                "SET SystemUri = ?, VersionUri = ?, EffectiveDate = NULL, IsActive = 0 "
                "WHERE ReleaseId = ?",
                system_uri,
                version_uri,
                release_id,
                context="update_release_no_date"
            )
    else:
        if effective_date:
            execute_non_query(
                "INSERT INTO Terminology_Core.VersionRelease "
                "(ReleaseId, SystemUri, VersionUri, EffectiveDate, IsActive) "
                "SELECT ?, ?, ?, DATE(?), 0",
                release_id,
                system_uri,
                version_uri,
                effective_date,
                context="insert_release"
            )
        else:
            execute_non_query(
                "INSERT INTO Terminology_Core.VersionRelease "
                "(ReleaseId, SystemUri, VersionUri, EffectiveDate, IsActive) "
                "SELECT ?, ?, ?, NULL, 0",
                release_id,
                system_uri,
                version_uri,
                context="insert_release_no_date"
            )

    if set_active:
        execute_non_query(
            "UPDATE Terminology_Core.VersionRelease "
            "SET IsActive = 0 "
            "WHERE SystemUri = ?",
            system_uri,
            context="reset_active_all"
        )

        execute_non_query(
            "UPDATE Terminology_Core.VersionRelease "
            "SET IsActive = 1 "
            "WHERE ReleaseId = ?",
            release_id,
            context="set_active"
        )

def load_tsv(file_path, expected_cols=None):
    with open(file_path, "r", encoding="utf-8") as f:
        header = f.readline().rstrip("\n").split("\t")
        if expected_cols and header[:len(expected_cols)] != expected_cols:
            raise Exception(
                f"Cabecera inesperada en {os.path.basename(file_path)}: {header[:10]}"
            )
        for line in f:
            yield line.rstrip("\n").split("\t")

def clean_date_yyyymmdd(value):
    if not value:
        return None
    value = value.strip()
    if len(value) == 8 and value.isdigit():
        return f"{value[0:4]}-{value[4:6]}-{value[6:8]}"
    return None

def to_int(value):
    if value is None:
        return None
    value = value.strip()
    if value == "":
        return None
    return int(value)

def to_bigint(value):
    return to_int(value)

def ensure_dir(path):
    if not os.path.isdir(path):
        raise Exception(f"Directorio no encontrado: {path}")

def find_file(base_dir, pattern):
    matches = glob.glob(os.path.join(base_dir, "**", pattern), recursive=True)
    if matches:
        matches.sort()
        return matches[0]
    return None

def find_files(base_dir, pattern):
    matches = glob.glob(os.path.join(base_dir, "**", pattern), recursive=True)
    return sorted(list(set(matches)))

def find_release_package_info(base_dir):
    files = find_files(base_dir, "release_package_information.json")
    if not files:
        return ""
    return files[0]

def parse_json_object(raw_value):
    if raw_value is None:
        return {}

    if isinstance(raw_value, bytes):
        try:
            text = raw_value.decode("utf-8").strip()
        except Exception:
            return {}
    else:
        text = str(raw_value).strip()

    if text == "":
        return {}

    try:
        parsed = json.loads(text)
    except Exception:
        return {}

    if isinstance(parsed, dict):
        return parsed

    return {}

def get_dataframe_value(df, column_name):
    if getattr(df, "size", 0) <= 0:
        return None

    target = str(column_name).lower()
    for col in list(df.columns):
        if str(col).lower() == target:
            try:
                return df.iloc[0][col]
            except Exception:
                return None

    return None

def normalize_effective_time(value):
    if value is None:
        return ""

    token = str(value).strip()
    if len(token) == 10 and token[4] == "-" and token[7] == "-":
        token = token[0:4] + token[5:7] + token[8:10]

    if len(token) == 8 and token.isdigit():
        return token

    return ""

def build_source_entry(base_dir, system_uri, effective_date):
    source = {
        "systemUri": str(system_uri or ""),
        "effectiveTime": normalize_effective_time(effective_date),
        "packageName": "",
        "packageInfoFile": "",
        "sourceLabel": "rf2"
    }

    info_path = find_release_package_info(base_dir)
    if info_path == "":
        return source

    source["packageInfoFile"] = info_path
    source["packageName"] = os.path.basename(os.path.dirname(info_path))

    try:
        with open(info_path, "r", encoding="utf-8") as f:
            package_info = json.load(f)
    except Exception as e:
        log_info("No se pudo leer release_package_information.json: " + str(e))
        return source

    if isinstance(package_info, dict):
        package_effective = normalize_effective_time(package_info.get("effectiveTime", ""))
        if package_effective != "":
            source["effectiveTime"] = package_effective

        if "International" in source["packageName"]:
            source["sourceLabel"] = "international"
        elif "Spanish" in source["packageName"]:
            source["sourceLabel"] = "spanish"

    return source

def source_key(entry):
    return "|".join([
        str(entry.get("packageName", "")),
        str(entry.get("effectiveTime", "")),
        str(entry.get("systemUri", "")),
        str(entry.get("sourceLabel", ""))
    ])

def update_release_metadata(release_id, system_uri, effective_date, base_dir):
    source = build_source_entry(base_dir, system_uri, effective_date)

    df = execute_select_df(
        "SELECT Metadata FROM Terminology_Core.VersionRelease WHERE ReleaseId = ?",
        release_id,
        context="select_release_metadata"
    )

    metadata = parse_json_object(get_dataframe_value(df, "Metadata"))

    if not isinstance(metadata, dict):
        metadata = {}

    sources = metadata.get("sources", [])
    if not isinstance(sources, list):
        sources = []

    incoming_key = source_key(source)
    replaced = False
    for idx, item in enumerate(sources):
        if isinstance(item, dict) and (source_key(item) == incoming_key):
            sources[idx] = source
            replaced = True
            break

    if not replaced:
        sources.append(source)

    metadata["sources"] = sources
    metadata["lastReleaseId"] = release_id
    metadata["lastSystemUri"] = system_uri
    metadata_text = json.dumps(metadata, ensure_ascii=False)

    execute_non_query(
        "UPDATE Terminology_Core.VersionRelease SET Metadata = ? WHERE ReleaseId = ?",
        metadata_text,
        release_id,
        context="update_release_metadata"
    )

def populate_edition_modules(release_id):
    execute_non_query(
        "INSERT INTO Terminology_Snomed.EditionModule "
        "(ReleaseId, ModuleId, RoleModule) "
        "SELECT ?, c.ModuleId, "
        "CASE "
        "  WHEN c.ModuleId IN (900000000000012004, 900000000000207008, 449080006) THEN 'international' "
        "  ELSE 'extension' "
        "END "
        "FROM ("
        "  SELECT DISTINCT ModuleId "
        "  FROM Terminology_Snomed.Concept "
        "  WHERE ReleaseId = ? AND ModuleId IS NOT NULL"
        ") c "
        "WHERE NOT EXISTS ("
        "  SELECT 1 "
        "  FROM Terminology_Snomed.EditionModule em "
        "  WHERE em.ReleaseId = ? AND em.ModuleId = c.ModuleId"
        ")",
        release_id,
        release_id,
        release_id,
        context="populate_editionmodule"
    )

    try:
        df = execute_select_df(
            "SELECT COUNT(*) AS Cnt FROM Terminology_Snomed.EditionModule WHERE ReleaseId = ?",
            release_id,
            context="count_editionmodule"
        )
        if getattr(df, "size", 0) > 0 and ("Cnt" in df.columns):
            log_info("EditionModules totales: " + str(int(df.iloc[0]["Cnt"])))
    except Exception:
        pass

def resolve_files(base_dir):
    lang_suffix = "-" + pPreferredTermLang if pPreferredTermLang else ""
    files = {
        "concept": find_file(base_dir, "sct2_Concept_" + pSuffixFile + "Snapshot_*.txt"),
        "description": find_file(base_dir, "sct2_Description_" + pSuffixFile + "Snapshot" + lang_suffix + "_*.txt"),
        "relationship": find_file(base_dir, "sct2_Relationship_" + pSuffixFile + "Snapshot_*.txt"),
        "stated_relationship": find_file(base_dir, "sct2_StatedRelationship_" + pSuffixFile + "Snapshot_*.txt"),
        "concrete_values": find_file(base_dir, "sct2_RelationshipConcreteValues_" + pSuffixFile + "Snapshot_*.txt"),
        "text_definition": find_file(base_dir, "sct2_TextDefinition_" + pSuffixFile + "Snapshot" + lang_suffix + "_*.txt"),
        "identifier": find_file(base_dir, "sct2_Identifier_" + pSuffixFile + "Snapshot_*.txt"),
        "owl_expression": find_file(base_dir, "sct2_sRefset_OWLExpression" + pSuffixFile + "Snapshot_*.txt"),
        "language_refsets": find_files(base_dir, "der2_*Language" + pSuffixFile + "Snapshot" + lang_suffix + "_*.txt"),
        "content_refsets": find_files(base_dir, "der2_*" + pSuffixFile + "Snapshot_*.txt"),
        "map_refsets": find_files(base_dir, "der2_*" + pSuffixFile + "Snapshot_*.txt"),
        "metadata_refsets": find_files(base_dir, "der2_*" + pSuffixFile + "Snapshot_*.txt"),
    }

    files["all_refsets"] = sorted(list(set(
        files["language_refsets"] +
        files["content_refsets"] +
        files["map_refsets"] +
        files["metadata_refsets"]
    )))

    return files

ensure_dir(pDir)
log_info("BaseDir de carga: " + str(pDir))
log_info("PreferredTermLang: " + str(pPreferredTermLang))
log_info("ClearRelease: " + str(bool(pClearRelease)))

ensure_code_system(pSystemUri)
ensure_license_notice(pSystemUri)
ensure_release(pReleaseId, pSystemUri, pEffectiveDate, bool(pSetActive))
update_release_metadata(pReleaseId, pSystemUri, pEffectiveDate, pDir)

files = resolve_files(pDir)

concept_file = files["concept"]
desc_file = files["description"]
rel_file = files["relationship"]
refset_files = files["all_refsets"]

log_info("Concept file encontrado: " + str(concept_file))
log_info("Description file encontrado: " + str(desc_file))
log_info("Relationship file encontrado: " + str(rel_file))
log_info("Número de refsets encontrados: " + str(len(refset_files)))

if not concept_file:
    raise Exception("No se encontró sct2_Concept_" + pSuffixFile + "Snapshot_*.txt")
if not desc_file:
    raise Exception("No se encontró sct2_Description_" + pSuffixFile + "Snapshot-" + pPreferredTermLang + "_*.txt")
if not rel_file:
    raise Exception("No se encontró sct2_Relationship_" + pSuffixFile + "Snapshot_*.txt")

if bool(pClearRelease):
    execute_non_query("DELETE FROM Terminology_Snomed.IsaClosure WHERE ReleaseId = ?", pReleaseId, context="delete_isaclosure")
    execute_non_query("DELETE FROM Terminology_Snomed.PreferredTerm WHERE ReleaseId = ?", pReleaseId, context="delete_preferredterm")
    execute_non_query("DELETE FROM Terminology_Snomed.LanguageRefSetConfig WHERE ReleaseId = ?", pReleaseId, context="delete_languagerefsetconfig")
    execute_non_query("DELETE FROM Terminology_Snomed.EditionModule WHERE ReleaseId = ?", pReleaseId, context="delete_editionmodule")
    execute_non_query("DELETE FROM Terminology_Snomed.RefsetMember WHERE ReleaseId = ?", pReleaseId, context="delete_refsetmember")
    execute_non_query("DELETE FROM Terminology_Snomed.Relationship WHERE ReleaseId = ?", pReleaseId, context="delete_relationship")
    execute_non_query("DELETE FROM Terminology_Snomed.Description WHERE ReleaseId = ?", pReleaseId, context="delete_description")
    execute_non_query("DELETE FROM Terminology_Snomed.Concept WHERE ReleaseId = ?", pReleaseId, context="delete_concept")

concept_insert_sql = """
INSERT INTO Terminology_Snomed.Concept
(ReleaseId, ConceptId, Active, ModuleId, DefinitionStatusId, EffectiveTime)
SELECT ?, ?, ?, ?, ?, DATE(?)
"""
expected_concept_cols = ["id", "effectiveTime", "active", "moduleId", "definitionStatusId"]
concept_stmt = get_insert_stmt("concept", concept_insert_sql)
rows = []
concept_counter = {"count": 0}

for cols in load_tsv(concept_file, expected_concept_cols):
    rows.append([
        pReleaseId,
        to_bigint(cols[0]),
        to_int(cols[2]) or 0,
        to_bigint(cols[3]),
        to_bigint(cols[4]),
        clean_date_yyyymmdd(cols[1]),
    ])
    if len(rows) >= 500:
        flush_rows(
            concept_stmt,
            rows,
            context="insert_concept",
            progress_label="Concepts insertados",
            counter_state=concept_counter
        )

flush_rows(
    concept_stmt,
    rows,
    context="insert_concept",
    progress_label="Concepts insertados",
    counter_state=concept_counter
)

populate_edition_modules(pReleaseId)

desc_insert_sql = """
INSERT INTO Terminology_Snomed.Description
(ReleaseId, DescriptionId, ConceptId, Active, TypeId, Lang, Term, CaseSignificanceId, EffectiveTime)
SELECT ?, ?, ?, ?, ?, ?, ?, ?, DATE(?)
"""
expected_desc_cols = [
    "id", "effectiveTime", "active", "moduleId", "conceptId",
    "languageCode", "typeId", "term", "caseSignificanceId"
]
desc_stmt = get_insert_stmt("description", desc_insert_sql)
rows = []
desc_counter = {"count": 0}

for cols in load_tsv(desc_file, expected_desc_cols):
    rows.append([
        pReleaseId,
        to_bigint(cols[0]),
        to_bigint(cols[4]),
        to_int(cols[2]) or 0,
        to_bigint(cols[6]),
        cols[5].strip(),
        cols[7],
        to_bigint(cols[8]),
        clean_date_yyyymmdd(cols[1]),
    ])
    if len(rows) >= 500:
        flush_rows(
            desc_stmt,
            rows,
            context="insert_description",
            progress_label="Descriptions insertadas",
            counter_state=desc_counter
        )

flush_rows(
    desc_stmt,
    rows,
    context="insert_description",
    progress_label="Descriptions insertadas",
    counter_state=desc_counter
)

rel_insert_sql = """
INSERT INTO Terminology_Snomed.Relationship
(ReleaseId, RelationshipId, Active, SourceId, DestinationId, TypeId, CharacteristicTypeId, ModifierId, EffectiveTime)
SELECT ?, ?, ?, ?, ?, ?, ?, ?, DATE(?)
"""
expected_rel_cols = [
    "id", "effectiveTime", "active", "moduleId", "sourceId",
    "destinationId", "relationshipGroup", "typeId", "characteristicTypeId", "modifierId"
]
rel_stmt = get_insert_stmt("relationship", rel_insert_sql)
rows = []
rel_counter = {"count": 0}

for cols in load_tsv(rel_file, expected_rel_cols):
    rows.append([
        pReleaseId,
        to_bigint(cols[0]),
        to_int(cols[2]) or 0,
        to_bigint(cols[4]),
        to_bigint(cols[5]),
        to_bigint(cols[7]),
        to_bigint(cols[8]),
        to_bigint(cols[9]),
        clean_date_yyyymmdd(cols[1]),
    ])
    if len(rows) >= 500:
        flush_rows(
            rel_stmt,
            rows,
            context="insert_relationship",
            progress_label="Relationships insertadas",
            counter_state=rel_counter
        )

flush_rows(
    rel_stmt,
    rows,
    context="insert_relationship",
    progress_label="Relationships insertadas",
    counter_state=rel_counter
)

refset_insert_sql = """
INSERT INTO Terminology_Snomed.RefsetMember
(ReleaseId, RefsetId, MemberId, ReferencedId, Active, EffectiveTime, Extra)
SELECT ?, ?, ?, ?, ?, DATE(?), ?
"""
min_refset_cols = ["id", "effectiveTime", "active", "moduleId", "refsetId", "referencedComponentId"]
refset_stmt = get_insert_stmt("refsetmember", refset_insert_sql)
refset_counter = {"count": 0}

for rf in refset_files:
    log_info("Procesando refset: " + str(rf))
    with open(rf, "r", encoding="utf-8") as f:
        header = f.readline().rstrip("\n").split("\t")
        name_to_idx = {name: idx for idx, name in enumerate(header)}

        if not all(col in name_to_idx for col in min_refset_cols):
            log_info("Refset ignorado por cabecera no compatible: " + str(rf))
            continue

        extra_cols = [col for col in header if col not in min_refset_cols]

        idx_id = name_to_idx["id"]
        idx_eff = name_to_idx["effectiveTime"]
        idx_act = name_to_idx["active"]
        idx_refset = name_to_idx["refsetId"]
        idx_refcomp = name_to_idx["referencedComponentId"]

        rows = []
        for line in f:
            cols = line.rstrip("\n").split("\t")

            extra = {}
            for col in extra_cols:
                idx = name_to_idx[col]
                extra[col] = cols[idx] if idx < len(cols) else ""

            rows.append([
                pReleaseId,
                to_bigint(cols[idx_refset]),
                cols[idx_id],
                to_bigint(cols[idx_refcomp]),
                to_int(cols[idx_act]) or 0,
                clean_date_yyyymmdd(cols[idx_eff]),
                json.dumps(extra, ensure_ascii=False),
            ])

            if len(rows) >= 500:
                flush_rows(
                    refset_stmt,
                    rows,
                    context="insert_refsetmember",
                    progress_label="RefsetMembers insertados",
                    counter_state=refset_counter
                )

        flush_rows(
            refset_stmt,
            rows,
            context="insert_refsetmember",
            progress_label="RefsetMembers insertados",
            counter_state=refset_counter
        )

log_info(
    "Carga completada | Concepts=" + str(concept_counter["count"]) +
    " | Descriptions=" + str(desc_counter["count"]) +
    " | Relationships=" + str(rel_counter["count"]) +
    " | RefsetMembers=" + str(refset_counter["count"])
)

return iris.system.Status.OK()
}

}
