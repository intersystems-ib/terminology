Class Terminology.Snomed.LoaderRf2 Extends %RegisteredObject
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
import iris

_stmt_cache = {}

def log_info(msg):
    try:
        iris.cls("Ens.Util.Log").LogInfo(
            "Terminology.Snomed.LoaderRf2",
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

def ensure_release(release_id, system_uri, effective_date, set_active):
    if exists_sql(
        "SELECT ReleaseId FROM Terminology_Core.VersionRelease WHERE ReleaseId = ?",
        release_id,
        context="check_release_exists"
    ):
        if effective_date:
            execute_non_query(
                "UPDATE Terminology_Core.VersionRelease "
                "SET SystemUri = ?, EffectiveDate = DATE(?), IsActive = 0 "
                "WHERE ReleaseId = ?",
                system_uri,
                effective_date,
                release_id,
                context="update_release"
            )
        else:
            execute_non_query(
                "UPDATE Terminology_Core.VersionRelease "
                "SET SystemUri = ?, EffectiveDate = NULL, IsActive = 0 "
                "WHERE ReleaseId = ?",
                system_uri,
                release_id,
                context="update_release_no_date"
            )
    else:
        if effective_date:
            execute_non_query(
                "INSERT INTO Terminology_Core.VersionRelease "
                "(ReleaseId, SystemUri, EffectiveDate, IsActive) "
                "SELECT ?, ?, DATE(?), 0",
                release_id,
                system_uri,
                effective_date,
                context="insert_release"
            )
        else:
            execute_non_query(
                "INSERT INTO Terminology_Core.VersionRelease "
                "(ReleaseId, SystemUri, EffectiveDate, IsActive) "
                "SELECT ?, ?, NULL, 0",
                release_id,
                system_uri,
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

ensure_release(pReleaseId, pSystemUri, pEffectiveDate, bool(pSetActive))

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
