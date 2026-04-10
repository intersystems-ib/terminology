# LOINC SQL Examples

This document collects runnable SQL snippets for the `Terminology.Loinc.*` tables in this repository.

These examples assume:

- you have loaded at least one LOINC release
- `Display` has already been built
- `HierarchyEdge` and `Closure` have already been built

Before running the examples, find the loaded LOINC releases:

```sql
SELECT
    ReleaseId,
    SystemUri,
    EffectiveDate,
    IsActive
FROM Terminology_Core.VersionRelease
WHERE SystemUri = 'http://loinc.org'
ORDER BY IsActive DESC, EffectiveDate DESC, ReleaseId;
```

The examples below use:

- `ReleaseId = '2.82'`
- `Lang = 'es'`
- `LoincNum = '718-7'`
- `HierarchyType = 'COMPONENTBYSYSTEM'`

Known derived values used by this repository:

- `DisplayType`: `LONGCOMMONNAME`, `SHORTNAME`, `DISPLAYNAME`, `CONSUMERNAME`, `LINGUISTICVARIANT`
- `HierarchyType`: `COMPONENTBYSYSTEM`, `GROUP`

## 1. Get a LOINC Code by Number

Returns the core row from `Terminology_Loinc.Code`.

```sql
SELECT
    c.LoincNum,
    c.Component,
    c.PropertyCode,
    c.TimeAspct,
    c.SystemCode,
    c.ScaleTyp,
    c.MethodTyp,
    c.ClassCode,
    c.Status,
    c.ShortName,
    c.LongCommonName,
    c.DisplayName,
    c.ConsumerName
FROM Terminology_Loinc.Code c
WHERE c.ReleaseId = '2.82'
  AND c.LoincNum = '718-7';
```

## 2. Get All Displays for a Code

Returns every display row built for a code in the requested language.

```sql
SELECT
    d.LoincNum,
    d.Lang,
    d.DisplayType,
    d.Display,
    d.RankOrder
FROM Terminology_Loinc.Display d
WHERE d.ReleaseId = '2.82'
  AND d.LoincNum = '718-7'
  AND d.Lang = 'es'
ORDER BY d.RankOrder, d.DisplayType, d.Display;
```

## 3. Get the Best Display for a Code

This matches the repository ordering: lowest `RankOrder` first, then `Display`.

```sql
SELECT TOP 1
    d.LoincNum,
    d.Lang,
    d.DisplayType,
    d.Display,
    d.RankOrder
FROM Terminology_Loinc.Display d
WHERE d.ReleaseId = '2.82'
  AND d.LoincNum = '718-7'
  AND d.Lang = 'es'
ORDER BY d.RankOrder, d.Display;
```

## 4. Get Parts for a Code

Returns the part links plus the joined part metadata.

```sql
SELECT
    l.LoincNum,
    l.PartNumber,
    l.PartTypeName,
    l.LinkTypeName,
    l.PropertySlot,
    p.PartName,
    p.PartDisplayName,
    p.Status
FROM Terminology_Loinc.CodePartLink l
LEFT JOIN Terminology_Loinc.Part p
    ON p.ReleaseId = l.ReleaseId
   AND p.PartNumber = l.PartNumber
WHERE l.ReleaseId = '2.82'
  AND l.LoincNum = '718-7'
ORDER BY l.PartTypeName, p.PartDisplayName, l.PartNumber;
```

## 5. Find Codes that Reuse a Given Part

Useful when you want to navigate from a part back to all linked LOINC codes.

```sql
SELECT TOP 50
    l.PartNumber,
    l.LoincNum,
    l.PartTypeName,
    l.LinkTypeName,
    c.LongCommonName
FROM Terminology_Loinc.CodePartLink l
LEFT JOIN Terminology_Loinc.Code c
    ON c.ReleaseId = l.ReleaseId
   AND c.LoincNum = l.LoincNum
WHERE l.ReleaseId = '2.82'
  AND l.PartNumber = 'LP14419-3'
ORDER BY l.LoincNum;
```

Replace `LP14419-3` with a part number that exists in your release if needed.

## 6. Get Direct Hierarchy Edges

`HierarchyEdge` stores direct parent-child relationships.

Example: direct parents of a known descendant in `COMPONENTBYSYSTEM`.

```sql
SELECT
    e.HierarchyType,
    e.ParentCode,
    e.ChildCode,
    e.ParentNodeType,
    e.ChildNodeType,
    e.PathToRoot
FROM Terminology_Loinc.HierarchyEdge e
WHERE e.ReleaseId = '2.82'
  AND e.HierarchyType = 'COMPONENTBYSYSTEM'
  AND e.ChildCode = (
      SELECT TOP 1 e2.ChildCode
      FROM Terminology_Loinc.HierarchyEdge e2
      WHERE e2.ReleaseId = '2.82'
        AND e2.HierarchyType = 'COMPONENTBYSYSTEM'
      ORDER BY e2.ChildCode
  )
ORDER BY e.ParentCode;
```

## 7. Get Ancestors from `Closure`

`Closure` stores the transitive hierarchy with depth.

This example uses a code that is guaranteed to have at least one ancestor in the selected hierarchy.

```sql
SELECT
    c.AncestorCode,
    c.DescendantCode,
    c.Depth
FROM Terminology_Loinc.Closure c
WHERE c.ReleaseId = '2.82'
  AND c.HierarchyType = 'COMPONENTBYSYSTEM'
  AND c.DescendantCode = (
      SELECT TOP 1 c2.DescendantCode
      FROM Terminology_Loinc.Closure c2
      WHERE c2.ReleaseId = '2.82'
        AND c2.HierarchyType = 'COMPONENTBYSYSTEM'
      ORDER BY c2.DescendantCode
  )
ORDER BY c.Depth, c.AncestorCode;
```

To query a specific code directly, replace the subquery with `AND c.DescendantCode = 'your-code'`.

## 8. Get Descendants from `Closure`

Returns descendants for one ancestor in the selected hierarchy.

For direct execution, this example uses `TOP 50`.

```sql
SELECT TOP 50
    c.AncestorCode,
    c.DescendantCode,
    c.Depth
FROM Terminology_Loinc.Closure c
WHERE c.ReleaseId = '2.82'
  AND c.HierarchyType = 'COMPONENTBYSYSTEM'
  AND c.AncestorCode = (
      SELECT TOP 1 c2.AncestorCode
      FROM Terminology_Loinc.Closure c2
      WHERE c2.ReleaseId = '2.82'
        AND c2.HierarchyType = 'COMPONENTBYSYSTEM'
      ORDER BY c2.AncestorCode
  )
ORDER BY c.Depth, c.DescendantCode;
```

## 9. List LOINC Groups

Returns the groups loaded into `Terminology_Loinc.LoincGroup`.

```sql
SELECT TOP 50
    g.GroupId,
    g.GroupName,
    g.GroupType,
    g.Version
FROM Terminology_Loinc.LoincGroup g
WHERE g.ReleaseId = '2.82'
ORDER BY g.GroupName, g.GroupId;
```

## 10. Get Members of a Group

Returns the group members and one display per LOINC code when available.

```sql
SELECT TOP 100
    gm.GroupId,
    gm.LoincNum,
    d.Display,
    d.DisplayType
FROM Terminology_Loinc.GroupMember gm
LEFT JOIN Terminology_Loinc.Display d
    ON d.ReleaseId = gm.ReleaseId
   AND d.LoincNum = gm.LoincNum
   AND d.Lang = 'es'
   AND d.RankOrder = (
       SELECT MIN(d2.RankOrder)
       FROM Terminology_Loinc.Display d2
       WHERE d2.ReleaseId = gm.ReleaseId
         AND d2.LoincNum = gm.LoincNum
         AND d2.Lang = 'es'
   )
WHERE gm.ReleaseId = '2.82'
  AND gm.GroupId = (
      SELECT TOP 1 gm2.GroupId
      FROM Terminology_Loinc.GroupMember gm2
      WHERE gm2.ReleaseId = '2.82'
      ORDER BY gm2.GroupId
  )
ORDER BY gm.LoincNum;
```

To inspect a specific group, replace the subquery with `AND gm.GroupId = 'your-group-id'`.

## 11. Validate a Code

Checks whether the code exists and whether its status is `ACTIVE`.

```sql
SELECT
    CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS ExistsFlag,
    MAX(CASE WHEN %SQLUPPER(Status) = 'ACTIVE' THEN 1 ELSE 0 END) AS ActiveFlag,
    MAX(Status) AS Status
FROM Terminology_Loinc.Code
WHERE ReleaseId = '2.82'
  AND LoincNum = '718-7';
```

## 12. Search by Display Text

Uses the `Display` table and the iFind index `IXDisplayNormFind`.

### 12.1 Exact-Term iFind Search

This matches the current repository search approach.

```sql
SELECT TOP 50
    d.LoincNum,
    d.Display,
    d.DisplayType,
    d.RankOrder
FROM Terminology_Loinc.Display d
WHERE d.ReleaseId = '2.82'
  AND d.Lang = 'es'
  AND %ID %FIND search_index(IXDisplayNormFind, 'hemo')
ORDER BY d.RankOrder, d.Display;
```

This is token-oriented search:

- `hemo` can match `Hemo sintetasa`
- `ferro` does not match `Ferroquelatasa`

### 12.2 Wildcard iFind Search

If you want to experiment with wildcard search over the same `%iFind.Index.Basic` index, use `*` in the search term:

```sql
SELECT TOP 50
    d.LoincNum,
    d.Display,
    d.DisplayType,
    d.RankOrder
FROM Terminology_Loinc.Display d
WHERE d.ReleaseId = '2.82'
  AND d.Lang = 'es'
  AND %ID %FIND search_index(IXDisplayNormFind, '*ferro*')
ORDER BY d.RankOrder, d.Display;
```

This broader form can match fragments inside a token, such as `ferro` within `Ferroquelatasa`.

If you need a simple fallback without iFind:

```sql
SELECT TOP 50
    d.LoincNum,
    d.Display,
    d.DisplayType,
    d.RankOrder
FROM Terminology_Loinc.Display d
WHERE d.ReleaseId = '2.82'
  AND d.Lang = 'es'
  AND d.DisplayNorm %STARTSWITH %SQLUPPER('hemo')
ORDER BY d.RankOrder, d.Display;
```

## 13. Notes About These Queries

- `Display` is a derived table built from `Code` plus the optional linguistic variant file.
- `HierarchyEdge` is a derived table built from the LOINC accessory hierarchy files.
- `Closure` is also derived. Ancestor and descendant queries depend on it being populated.
- A single LOINC code can have multiple display rows for the same language, so queries often need `ORDER BY RankOrder` or an explicit `DisplayType` filter.
- Group membership lives in `Terminology_Loinc.GroupMember`, while group metadata lives in `Terminology_Loinc.LoincGroup`.
