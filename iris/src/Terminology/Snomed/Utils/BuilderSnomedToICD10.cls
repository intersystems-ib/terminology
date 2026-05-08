Class Terminology.Snomed.Utils.BuilderSnomedToIcd10 Extends %RegisteredObject
{

ClassMethod Build(pInputDir As %String, pReleaseId As %String, pOnlyActive As %Boolean = 1) As %Status
{
    Try {
        Do ..LogInfo("Inicio Build | ReleaseId="_pReleaseId_" | InputDir="_pInputDir)

        If pInputDir="" {
            Return $$$ERROR($$$GeneralError, "pInputDir es obligatorio")
        }

        If pReleaseId="" {
            Return $$$ERROR($$$GeneralError, "pReleaseId es obligatorio")
        }

        Set tSC = ..DeleteExisting(pReleaseId)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Set tSC = ..LoadFromExtractedDirPy(pInputDir, pReleaseId, pOnlyActive)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Do ..LogInfo("Fin Build OK | ReleaseId="_pReleaseId)
        Return $$$OK
    } Catch ex {
        Do ..LogInfo("Excepción en Build: "_ex.DisplayString())
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

ClassMethod DeleteExisting(pReleaseId As %String) As %Status
{
    Set sql = "DELETE FROM Terminology_Mapping.SnomedToIcd10 WHERE ReleaseId = ?"
    Set params = "[ """_$Replace($Get(pReleaseId),"""","\""")_""" ]"
    Quit ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(sql, params)
}

ClassMethod LoadFromExtractedDirPy(pInputDir As %String, pReleaseId As %String, pOnlyActive As %Boolean = 1) As %Status [ Language = python ]
{
    import csv
    import json
    import os
    import iris

    TARGET_PREFIX = "der2_iissscc"

    def log_info(message):
        try:
            iris.cls("Ens.Util.Log").LogInfo(
                "Terminology.Snomed.Utils.BuilderSnomedToIcd10",
                "LoadFromExtractedDirPy",
                str(message)
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

    def find_mapping_file(root_dir):
        if not os.path.isdir(root_dir):
            raise Exception("Input path is not a directory: " + root_dir)

        candidates = []

        for dirpath, _, filenames in os.walk(root_dir):
            normalized_dir = dirpath.replace("\\", "/")

            if "/Snapshot/Refset/Map" not in normalized_dir:
                continue

            for filename in filenames:
                if filename.startswith(TARGET_PREFIX) and filename.endswith(".txt"):
                    candidates.append(os.path.join(dirpath, filename))

        if not candidates:
            raise Exception(
                "No der2_iissscc*.txt file found under Snapshot/Refset/Map in: "
                + root_dir
            )

        candidates.sort()
        return candidates[0]

    def map_equivalence(row):
        correlation_id = (row.get("correlationId") or "").strip()
        category_id = (row.get("mapCategoryId") or "").strip()

        if correlation_id and category_id:
            return correlation_id + "|" + category_id
        if correlation_id:
            return correlation_id
        return category_id

    def insert_batch(rows):
        if not rows:
            return

        max_rows_per_sql = 50

        for start in range(0, len(rows), max_rows_per_sql):
            chunk = rows[start:start + max_rows_per_sql]

            selects = []
            params = []

            for index, row in enumerate(chunk):
                prefix = "SELECT" if index == 0 else "UNION ALL SELECT"
                selects.append(prefix + " ?, ?, ?, ?, ?")
                params.extend(row)

            sql = (
                "INSERT INTO Terminology_Mapping.SnomedToIcd10 "
                "(ReleaseId, SourceConceptId, TargetCode, Equivalence, Rule) "
                + " ".join(selects)
            )

            execute_non_query(sql, params, "InsertSnomedToIcd10Batch")

    try:
        input_dir = str(pInputDir)
        release_id = str(pReleaseId)
        only_active = bool(int(pOnlyActive))

        file_path = find_mapping_file(input_dir)
        log_info("Mapping file found: " + file_path)

        required = [
            "active",
            "referencedComponentId",
            "mapRule",
            "mapAdvice",
            "mapTarget",
            "correlationId",
            "mapCategoryId"
        ]

        inserted = 0
        skipped = 0
        batch = []
        batch_size = 50

        with open(file_path, "r", encoding="utf-8-sig", newline="") as f:
            reader = csv.DictReader(f, delimiter="\t")

            missing = [col for col in required if col not in (reader.fieldnames or [])]
            if missing:
                raise Exception(
                    "Invalid mapping header. Missing columns: " + ", ".join(missing)
                )

            for row in reader:
                active = (row.get("active") or "").strip()
                source_concept_id = (row.get("referencedComponentId") or "").strip()
                target_code = (row.get("mapTarget") or "").strip()
                map_rule = (row.get("mapRule") or "").strip()
                map_advice = (row.get("mapAdvice") or "").strip()

                if only_active and active != "1":
                    skipped += 1
                    continue

                if not source_concept_id or not target_code:
                    skipped += 1
                    continue

                rule = map_rule
                if map_advice:
                    rule = rule + " | " + map_advice if rule else map_advice

                batch.append([
                    release_id,
                    source_concept_id,
                    target_code,
                    map_equivalence(row),
                    rule
                ])

                if len(batch) >= batch_size:
                    insert_batch(batch)
                    inserted += len(batch)
                    batch = []

        if batch:
            insert_batch(batch)
            inserted += len(batch)

        log_info(
            "Mapping load completed | Inserted="
            + str(inserted)
            + " | Skipped="
            + str(skipped)
        )

        return iris.system.Status.OK()

    except Exception as err:
        log_info("Error: " + str(err))
        return iris.system.Status.Error(5001, str(err))
}

ClassMethod LogInfo(pText As %String) As %Status
{
    Do ##class(Ens.Util.Log).LogInfo(
        "Terminology.Snomed.Utils.BuilderSnomedToIcd10",
        "Build",
        pText
    )
    Return $$$OK
}

}
