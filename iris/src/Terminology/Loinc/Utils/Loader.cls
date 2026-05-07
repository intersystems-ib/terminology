Class Terminology.Loinc.Utils.Loader Extends %RegisteredObject
{

ClassMethod LoadSnapshot(pDir As %String, pReleaseId As %String, pSystemUri As %String = "http://loinc.org", pEffectiveDate As %Date = "", pSetActive As %Boolean = 1, pClearRelease As %Boolean = 0) As %Status
{
    Quit ..LoadSnapshotPy(pDir, pReleaseId, pSystemUri, pEffectiveDate, pSetActive, pClearRelease)
}

ClassMethod LoadSnapshotPy(pDir As %String, pReleaseId As %String, pSystemUri As %String, pEffectiveDate As %String, pSetActive As %Boolean, pClearRelease As %Boolean = 0) As %Status [ Language = python ]
{
import os
import glob
import csv
import json
import iris

_stmt_cache = {}

def log_info(msg):
    try:
        iris.cls("Ens.Util.Log").LogInfo("Terminology.Loinc.Loader","LoadSnapshotPy",str(msg))
    except Exception:
        pass

def prepare(sql, context=""):
    cache_key = ("prepare", sql)
    if cache_key in _stmt_cache:
        return _stmt_cache[cache_key]
    stmt = iris.sql.prepare(sql)
    _stmt_cache[cache_key] = stmt
    return stmt

def execute_select_df(sql, *params, context=""):
    stmt = prepare(sql, context)
    rs = stmt.execute(*params)
    return rs.dataframe()

def exists_sql(sql, *params, context=""):
    df = execute_select_df(sql, *params, context=context)
    return df.size > 0

def execute_non_query(sql, *params, context=""):
    params_json = json.dumps(list(params), ensure_ascii=False)
    sc = iris.cls("Terminology.Core.SqlUtils").ExecuteNonQuery(sql, params_json)
    if not iris.system.Status.IsOK(sc):
        try:
            iris.cls("Terminology.Core.SqlUtils").LogStatus("ExecuteNonQuery [" + context + "]", sc)
        except Exception:
            pass
        raise Exception("ExecuteNonQuery returned error")

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
        stmt.execute(*row)
        inserted_now += 1
    if counter_state is not None:
        counter_state["count"] = counter_state.get("count", 0) + inserted_now
        # if progress_label:
        #    log_info(progress_label + ": " + str(counter_state["count"]))
    rows.clear()

def clean_date_yyyymmdd(value):
    if value is None:
        return None
    value = str(value).strip()
    if value == "":
        return None
    if len(value) == 8 and value.isdigit():
        return f"{value[0:4]}-{value[4:6]}-{value[6:8]}"
    return value

def to_int(value):
    if value is None:
        return None
    value = str(value).strip()
    if value == "":
        return None
    try:
        return int(value)
    except Exception:
        return None

def pick(row, *names):
    for name in names:
        if name in row and row[name] not in (None, ""):
            return row[name]
    return ""

def ensure_dir(path):
    if not os.path.isdir(path):
        raise Exception(f"Directory not found: {path}")

def find_first(pattern):
    hits = glob.glob(pattern, recursive=True)
    if hits:
        hits.sort()
        return hits[0]
    return None

def resolve_files(base_dir):
    return {
        "loinc": find_first(os.path.join(base_dir, "**", "LoincTable", "Loinc.csv")),
        "part": find_first(os.path.join(base_dir, "**", "AccessoryFiles", "PartFile", "Part.csv")),
        "partlink": find_first(os.path.join(base_dir, "**", "AccessoryFiles", "PartFile", "LoincPartLink_Primary.csv")),
        "group": find_first(os.path.join(base_dir, "**", "AccessoryFiles", "GroupFile", "Group.csv")),
        "groupmembers": find_first(os.path.join(base_dir, "**", "AccessoryFiles", "GroupFile", "GroupLoincTerms.csv")),
    }

def ensure_code_system(system_uri):
    default_name = "LOINC"
    default_lang = "es"
    default_dialect = ""
    default_notes = "LOINC code system"
    default_type = "LOINC"

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
            "(SystemUri, Name, DefaultLang, DefaultDialect, Notes, Type) "
            "SELECT ?, ?, ?, ?, ?, ?",
            system_uri,
            default_name,
            default_lang,
            default_dialect,
            default_notes,
            default_type,
            context="insert_codesystem"
        )

def ensure_release(release_id, system_uri, effective_date, set_active):
    if exists_sql("SELECT ReleaseId FROM Terminology_Core.VersionRelease WHERE ReleaseId = ?", release_id, context="check_release_exists"):
        if effective_date:
            execute_non_query(
                "UPDATE Terminology_Core.VersionRelease SET SystemUri = ?, EffectiveDate = DATE(?), IsActive = 0 WHERE ReleaseId = ?",
                system_uri, effective_date, release_id, context="update_release"
            )
        else:
            execute_non_query(
                "UPDATE Terminology_Core.VersionRelease SET SystemUri = ?, EffectiveDate = NULL, IsActive = 0 WHERE ReleaseId = ?",
                system_uri, release_id, context="update_release_no_date"
            )
    else:
        if effective_date:
            execute_non_query(
                "INSERT INTO Terminology_Core.VersionRelease (ReleaseId, SystemUri, EffectiveDate, IsActive) SELECT ?, ?, DATE(?), 0",
                release_id, system_uri, effective_date, context="insert_release"
            )
        else:
            execute_non_query(
                "INSERT INTO Terminology_Core.VersionRelease (ReleaseId, SystemUri, EffectiveDate, IsActive) SELECT ?, ?, NULL, 0",
                release_id, system_uri, context="insert_release_no_date"
            )

    if set_active:
        execute_non_query(
            "UPDATE Terminology_Core.VersionRelease SET IsActive = 0 WHERE SystemUri = ?",
            system_uri, context="reset_active_all"
        )
        execute_non_query(
            "UPDATE Terminology_Core.VersionRelease SET IsActive = 1 WHERE ReleaseId = ?",
            release_id, context="set_active"
        )

def read_csv_rows(path):
    with open(path, "r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            yield {k.strip(): (v if v is not None else "") for k, v in row.items()}

ensure_dir(pDir)
log_info("BaseDir: " + str(pDir))

ensure_code_system(pSystemUri)
ensure_release(pReleaseId, pSystemUri, pEffectiveDate, bool(pSetActive))

files = resolve_files(pDir)
for k, v in files.items():
    log_info(k + ": " + str(v))

if not files["loinc"]:
    raise Exception("LoincTable/Loinc.csv not found")

if bool(pClearRelease):
    execute_non_query("DELETE FROM Terminology_Loinc.Display WHERE ReleaseId = ?", pReleaseId, context="delete_display")
    execute_non_query("DELETE FROM Terminology_Loinc.GroupMember WHERE ReleaseId = ?", pReleaseId, context="delete_groupmember")
    execute_non_query("DELETE FROM Terminology_Loinc.LoincGroup WHERE ReleaseId = ?", pReleaseId, context="delete_group")
    execute_non_query("DELETE FROM Terminology_Loinc.CodePartLink WHERE ReleaseId = ?", pReleaseId, context="delete_partlink")
    execute_non_query("DELETE FROM Terminology_Loinc.Part WHERE ReleaseId = ?", pReleaseId, context="delete_part")
    execute_non_query("DELETE FROM Terminology_Loinc.Code WHERE ReleaseId = ?", pReleaseId, context="delete_code")

code_columns = [
    "ReleaseId",
    "LoincNum",
    "Component",
    "PropertyCode",
    "TimeAspct",
    "SystemCode",
    "ScaleTyp",
    "MethodTyp",
    "ClassCode",
    "VersionLastChanged",
    "ChangeType",
    "DefinitionDescription",
    "Status",
    "ConsumerName",
    "ClassType",
    "Formula",
    "ExampleAnswers",
    "SurveyQuestText",
    "SurveyQuestSrc",
    "UnitsRequired",
    "RelatedNames2",
    "ShortName",
    "OrderObs",
    "Hl7FieldSubfieldId",
    "ExternalCopyrightNotice",
    "ExampleUnits",
    "LongCommonName",
    "ExampleUCUMUnits",
    "StatusReason",
    "StatusText",
    "ChangeReasonPublic",
    "CommonTestRank",
    "CommonOrderRank",
    "Hl7AttachmentStructure",
    "ExternalCopyrightLink",
    "PanelType",
    "AskAtOrderEntry",
    "AssociatedObservations",
    "VersionFirstReleased",
    "ValidHL7AttachmentRequest",
    "DisplayName"
]

code_sql = (
    "INSERT INTO Terminology_Loinc.Code "
    "(" + ",".join(code_columns) + ") "
    "SELECT " + ",".join(["?"] * len(code_columns))
)

code_stmt = get_insert_stmt("code", code_sql)
rows = []
counter = {"count": 0}

log_info("LOINC Code column count: " + str(len(code_columns)))
log_info("LOINC Code insert SQL: " + code_sql)

for row in read_csv_rows(files["loinc"]):
    values = [
        pReleaseId,
        pick(row, "LOINC_NUM"),
        pick(row, "COMPONENT"),
        pick(row, "PROPERTY"),
        pick(row, "TIME_ASPCT"),
        pick(row, "SYSTEM"),
        pick(row, "SCALE_TYP"),
        pick(row, "METHOD_TYP"),
        pick(row, "CLASS"),
        pick(row, "VersionLastChanged"),
        pick(row, "CHNG_TYPE"),
        pick(row, "DefinitionDescription"),
        pick(row, "STATUS"),
        pick(row, "CONSUMER_NAME"),
        to_int(pick(row, "CLASSTYPE")),
        pick(row, "FORMULA"),
        pick(row, "EXMPL_ANSWERS"),
        pick(row, "SURVEY_QUEST_TEXT"),
        pick(row, "SURVEY_QUEST_SRC"),
        pick(row, "UNITSREQUIRED"),
        pick(row, "RELATEDNAMES2"),
        pick(row, "SHORTNAME"),
        pick(row, "ORDER_OBS"),
        pick(row, "HL7_FIELD_SUBFIELD_ID"),
        pick(row, "EXTERNAL_COPYRIGHT_NOTICE"),
        pick(row, "EXAMPLE_UNITS"),
        pick(row, "LONG_COMMON_NAME"),
        pick(row, "EXAMPLE_UCUM_UNITS"),
        pick(row, "STATUS_REASON"),
        pick(row, "STATUS_TEXT"),
        pick(row, "CHANGE_REASON_PUBLIC"),
        to_int(pick(row, "COMMON_TEST_RANK")),
        to_int(pick(row, "COMMON_ORDER_RANK")),
        pick(row, "HL7_ATTACHMENT_STRUCTURE"),
        pick(row, "EXTERNAL_COPYRIGHT_LINK"),
        pick(row, "PanelType"),
        pick(row, "AskAtOrderEntry"),
        pick(row, "AssociatedObservations"),
        pick(row, "VersionFirstReleased"),
        pick(row, "ValidHL7AttachmentRequest"),
        pick(row, "DisplayName")
    ]

    if len(values) != len(code_columns):
        raise Exception(
            "LOINC Code row length mismatch. "
            "Expected=" + str(len(code_columns)) +
            " Actual=" + str(len(values)) +
            " | LOINC_NUM=" + str(pick(row, "LOINC_NUM"))
        )

    rows.append(values)

    if len(rows) >= 500:
        flush_rows(code_stmt, rows, "insert_code", "Codes inserted", counter)

flush_rows(code_stmt, rows, "insert_code", "Codes inserted", counter)

if files["part"]:
    part_sql = """
    INSERT INTO Terminology_Loinc.Part
    (ReleaseId, PartNumber, PartTypeName, PartName, PartDisplayName, Status)
    SELECT ?,?,?,?,?,?
    """
    part_stmt = get_insert_stmt("part", part_sql)
    rows = []
    counter = {"count": 0}
    for row in read_csv_rows(files["part"]):
        rows.append([
            pReleaseId,
            pick(row, "PartNumber", "PARTNUMBER"),
            pick(row, "PartTypeName", "PARTTYPENAME"),
            pick(row, "PartName", "PARTNAME"),
            pick(row, "PartDisplayName", "PARTDISPLAYNAME"),
            pick(row, "Status", "STATUS")
        ])
        if len(rows) >= 500:
            flush_rows(part_stmt, rows, "insert_part", "Parts inserted", counter)
    flush_rows(part_stmt, rows, "insert_part", "Parts inserted", counter)

if files["partlink"]:
    link_sql = """
    INSERT INTO Terminology_Loinc.CodePartLink
    (ReleaseId, LoincNum, PartNumber, PartTypeName, LinkTypeName, PropertySlot)
    SELECT ?,?,?,?,?,?
    """
    link_stmt = get_insert_stmt("partlink", link_sql)
    rows = []
    counter = {"count": 0}
    for row in read_csv_rows(files["partlink"]):
        rows.append([
            pReleaseId,
            pick(row, "LoincNumber", "LOINCNUMBER", "LoincNum", "LOINC_NUM"),
            pick(row, "PartNumber", "PARTNUMBER"),
            pick(row, "PartTypeName", "PARTTYPENAME"),
            pick(row, "LinkTypeName", "LINKTYPENAME"),
            pick(row, "Property", "PropertySlot", "PROPERTY")
        ])
        if len(rows) >= 500:
            flush_rows(link_stmt, rows, "insert_partlink", "CodePartLinks inserted", counter)
    flush_rows(link_stmt, rows, "insert_partlink", "CodePartLinks inserted", counter)

if files["group"]:
    group_sql = """
    INSERT INTO Terminology_Loinc.LoincGroup
    (ReleaseId, GroupId, GroupName, GroupType, Version)
    SELECT ?,?,?,?,?
    """
    group_stmt = get_insert_stmt("group", group_sql)
    rows = []
    counter = {"count": 0}
    for row in read_csv_rows(files["group"]):
        rows.append([
            pReleaseId,
            pick(row, "GroupId", "GROUPID"),
            pick(row, "Group", "GroupName", "GROUPNAME"),
            pick(row, "GroupType", "GROUPTYPE"),
            pick(row, "Version", "VERSION")
        ])
        if len(rows) >= 500:
            flush_rows(group_stmt, rows, "insert_group", "Groups inserted", counter)
    flush_rows(group_stmt, rows, "insert_group", "Groups inserted", counter)

if files["groupmembers"]:
    gm_sql = """
    INSERT INTO Terminology_Loinc.GroupMember
    (ReleaseId, GroupId, LoincNum)
    SELECT ?,?,?
    """
    gm_stmt = get_insert_stmt("groupmember", gm_sql)
    rows = []
    counter = {"count": 0}
    for row in read_csv_rows(files["groupmembers"]):
        rows.append([
            pReleaseId,
            pick(row, "GroupId", "GROUPID"),
            pick(row, "LoincNumber", "LOINCNUMBER", "LoincNum", "LOINC_NUM")
        ])
        if len(rows) >= 500:
            flush_rows(gm_stmt, rows, "insert_groupmember", "GroupMembers inserted", counter)
    flush_rows(gm_stmt, rows, "insert_groupmember", "GroupMembers inserted", counter)

log_info("LOINC load completed")
return iris.system.Status.OK()
}

}
