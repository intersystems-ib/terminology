Class Terminology.Snomed.BuilderIsaClosure Extends %RegisteredObject
{

ClassMethod Build(pReleaseId As %String, pView As %String = "inferred", pIsaTypeId As %String = "116680003") As %Status
{
    Quit ..BuildPy(pReleaseId, pView, pIsaTypeId)
}

ClassMethod BuildPy(pReleaseId As %String, pView As %String, pIsaTypeId As %String) As %Status [ Language = python ]
{
import json
import sys
import iris
from collections import defaultdict

sys.setrecursionlimit(100000)

INFERRED_CHARACTERISTIC_TYPE_ID = "900000000000011006"
STATED_CHARACTERISTIC_TYPE_ID = "900000000000010007"

def log_info(msg):
    try:
        iris.cls("Ens.Util.Log").LogInfo(
            "Terminology.Snomed.BuilderIsaClosure",
            "BuildPy",
            str(msg)
        )
    except Exception:
        pass

def prepare(sql, context=""):
    try:
        return iris.sql.prepare(sql)
    except Exception as e:
        log_info(
            "SQL PREPARE ERROR [" + context + "] | SQL: " + str(sql) +
            " | Error: " + str(e)
        )
        raise

def query_df(sql, *params, context=""):
    stmt = prepare(sql, context)
    try:
        rs = stmt.execute(*params)
        return rs.dataframe()
    except Exception as e:
        log_info(
            "SQL QUERY ERROR [" + context + "] | SQL: " + str(sql) +
            " | Params: " + str(params) +
            " | Error: " + str(e)
        )
        raise

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

def batch_insert(stmt, rows, batch_size=10000):
    if not rows:
        return
    for i in range(0, len(rows), batch_size):
        chunk = rows[i:i + batch_size]
        for row in chunk:
            stmt.execute(*row)

def resolve_characteristic_type_id(view_name):
    view_name = (view_name or "").strip().lower()
    if view_name == "stated":
        return STATED_CHARACTERISTIC_TYPE_ID
    return INFERRED_CHARACTERISTIC_TYPE_ID

def load_isa_edges(characteristic_type_id):
    return query_df(
        """
        SELECT SourceId, DestinationId
        FROM Terminology_Snomed.Relationship
        WHERE ReleaseId = ?
          AND Active = 1
          AND TypeId = ?
          AND CharacteristicTypeId = ?
        """,
        pReleaseId,
        pIsaTypeId,
        characteristic_type_id,
        context="load_isa_edges"
    )

def build_parent_map(df):
    parents_by_child = defaultdict(set)
    all_nodes = set()

    for _, row in df.iterrows():
        child = str(row["sourceid"])
        parent = str(row["destinationid"])

        parents_by_child[child].add(parent)
        all_nodes.add(child)
        all_nodes.add(parent)

    return parents_by_child, all_nodes

def merge_min_depth(target, source, depth_offset):
    for ancestor_id, depth in source.items():
        new_depth = depth + depth_offset
        old_depth = target.get(ancestor_id)
        if old_depth is None or new_depth < old_depth:
            target[ancestor_id] = new_depth

def compute_ancestors(node_id, parents_by_child, memo, visiting):
    if node_id in memo:
        return memo[node_id]

    if node_id in visiting:
        # protección ante ciclos inesperados
        return {}

    visiting.add(node_id)

    result = {}
    direct_parents = parents_by_child.get(node_id, set())

    for parent_id in direct_parents:
        old_depth = result.get(parent_id)
        if old_depth is None or 1 < old_depth:
            result[parent_id] = 1

        parent_ancestors = compute_ancestors(parent_id, parents_by_child, memo, visiting)
        merge_min_depth(result, parent_ancestors, 1)

    visiting.remove(node_id)
    memo[node_id] = result
    return result

characteristic_type_id = resolve_characteristic_type_id(pView)

log_info(
    "Inicio BuilderIsaClosure | ReleaseId=" + str(pReleaseId) +
    " | View=" + str(pView) +
    " | IsaTypeId=" + str(pIsaTypeId) +
    " | CharacteristicTypeId=" + str(characteristic_type_id)
)

execute_non_query(
    """
    DELETE FROM Terminology_Snomed.IsaClosure
    WHERE ReleaseId = ? AND View = ?
    """,
    pReleaseId,
    pView,
    context="delete_existing_isaclosure"
)

edge_df = load_isa_edges(characteristic_type_id)
log_info("Relaciones IS-A cargadas: " + str(len(edge_df.index)))

if edge_df.size == 0:
    log_info("No hay relaciones IS-A para construir closure")
    return iris.system.Status.OK()

parents_by_child, all_nodes = build_parent_map(edge_df)

log_info("Nodos detectados en grafo IS-A: " + str(len(all_nodes)))

memo = {}
insert_stmt = prepare(
    """
    INSERT INTO Terminology_Snomed.IsaClosure
    (ReleaseId, View, AncestorId, DescendantId, Depth)
    VALUES (?, ?, ?, ?, ?)
    """,
    "prepare_insert_isaclosure"
)

rows = []
processed = 0
inserted = 0

# ordenar da algo más de estabilidad al proceso y a los logs
for node_id in sorted(all_nodes):
    ancestors = compute_ancestors(node_id, parents_by_child, memo, set())

    for ancestor_id, depth in ancestors.items():
        rows.append([
            pReleaseId,
            pView,
            ancestor_id,
            node_id,
            depth
        ])

    processed += 1

    if len(rows) >= 10000:
        batch_insert(insert_stmt, rows)
        inserted += len(rows)
        rows = []

    if processed % 10000 == 0:
        log_info(
            "BuilderIsaClosure progreso | nodos procesados=" + str(processed) +
            " | filas insertadas=" + str(inserted) +
            " | nodos memoizados=" + str(len(memo))
        )

if rows:
    batch_insert(insert_stmt, rows)
    inserted += len(rows)

log_info(
    "BuilderIsaClosure completado | nodos procesados=" + str(processed) +
    " | filas insertadas=" + str(inserted) +
    " | nodos memoizados=" + str(len(memo))
)

return iris.system.Status.OK()
}

}
