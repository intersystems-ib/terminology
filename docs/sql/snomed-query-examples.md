# SNOMED SQL Examples

This document draft SQL snippets into a single runnable reference for this repository.

These examples assume:

- `ReleaseId = 'SNOMED CT version 20260101'`
- `View = 'inferred'`
- `PreferredTerm` has already been built
- `IsaClosure` has already been built

The examples below use concrete SNOMED CT concepts:

| Concept | ConceptId |
| --- | --- |
| SNOMED CT Concept | `138875005` |
| Clinical finding | `404684003` |
| Disease | `64572001` |
| Myocardial infarction | `22298006` |

For language-dependent examples, this guide uses the API defaults already present in the project:

- `Lang = 'es'`
- `Dialect = 'es-ES'`

If your environment only loaded the international edition and you did not build Spanish preferred terms, change those filters to the language/dialect that exists in your `Terminology_Snomed.PreferredTerm` table.

## 1. Get a Concept by Code

Returns the concept row plus the preferred term, if one exists for the requested language/dialect.

```sql
SELECT
    c.ConceptId,
    c.Active,
    c.ModuleId,
    c.DefinitionStatusId,
    CONVERT(VARCHAR, c.EffectiveTime) AS EffectiveTime,
    pt.Term AS PreferredTerm
FROM Terminology_Snomed.Concept c
LEFT JOIN Terminology_Snomed.PreferredTerm pt
    ON pt.ConceptId = c.ConceptId
   AND pt.ReleaseId = c.ReleaseId
   AND pt.Lang = 'es'
   AND pt.Dialect = 'es-ES'
WHERE c.ReleaseId = 'SNOMED CT version 20260101'
  AND c.ConceptId = 22298006
  AND c.Active = 1;
```

## 2. Get Descriptions for a Concept

Returns all active descriptions for a concept in a given language.

```sql
SELECT
    d.DescriptionId,
    d.ConceptId,
    d.Active,
    d.TypeId,
    d.Lang,
    d.Term,
    d.CaseSignificanceId,
    CONVERT(VARCHAR, d.EffectiveTime) AS EffectiveTime
FROM Terminology_Snomed.Description d
WHERE d.ReleaseId = 'SNOMED CT version 20260101'
  AND d.ConceptId = 22298006
  AND d.Lang = 'es'
  AND d.Active = 1
ORDER BY d.TypeId, d.Term;
```

Useful description type filters:

- FSN: `900000000000003001`
- Synonym: `900000000000013009`

Example: only synonyms for `22298006`.

```sql
SELECT
    d.DescriptionId,
    d.Term
FROM Terminology_Snomed.Description d
WHERE d.ReleaseId = 'SNOMED CT version 20260101'
  AND d.ConceptId = 22298006
  AND d.Lang = 'es'
  AND d.Active = 1
  AND d.TypeId = 900000000000013009
ORDER BY d.Term;
```

## 3. Get the Preferred Term

### 3.1 Lookup from `PreferredTerm`

This is the fastest runtime form and matches how the repository currently resolves preferred terms.

```sql
SELECT
    pt.ConceptId,
    pt.DescriptionId,
    pt.Lang,
    pt.Dialect,
    pt.Term,
    pt.TermNorm
FROM Terminology_Snomed.PreferredTerm pt
WHERE pt.ReleaseId = 'SNOMED CT version 20260101'
  AND pt.ConceptId = 22298006
  AND pt.Lang = 'es'
  AND pt.Dialect = 'es-ES';
```

### 3.2 Derive the Preferred Term from Source Tables

This follows the same logic as `BuilderPreferredTerm.PopulateStage()`.

In this repository, the production config sets `PreferredTermLanguageRefsetId = 450828004`, so this example uses that refset directly.

```sql
SELECT
    d.ConceptId,
    d.DescriptionId,
    d.Term,
    %SQLUPPER(d.Term) AS TermNorm
FROM Terminology_Snomed.Description d
INNER JOIN Terminology_Snomed.Concept c
    ON c.ReleaseId = d.ReleaseId
   AND c.ConceptId = d.ConceptId
INNER JOIN Terminology_Snomed.RefsetMember rm
    ON rm.ReleaseId = d.ReleaseId
   AND rm.ReferencedId = d.DescriptionId
WHERE d.ReleaseId = 'SNOMED CT version 20260101'
  AND d.Lang = 'es'
  AND rm.RefsetId = 450828004
  AND d.ConceptId = 22298006
  AND d.Active = 1
  AND c.Active = 1
  AND d.TypeId = 900000000000013009
  AND rm.Active = 1
  AND d.DescriptionId = (
      SELECT MIN(d2.DescriptionId)
      FROM Terminology_Snomed.Description d2
      INNER JOIN Terminology_Snomed.Concept c2
          ON c2.ReleaseId = d2.ReleaseId
         AND c2.ConceptId = d2.ConceptId
      INNER JOIN Terminology_Snomed.RefsetMember rm2
          ON rm2.ReleaseId = d2.ReleaseId
         AND rm2.ReferencedId = d2.DescriptionId
      WHERE d2.ReleaseId = d.ReleaseId
        AND d2.ConceptId = d.ConceptId
        AND d2.Lang = d.Lang
        AND d2.Active = 1
        AND c2.Active = 1
        AND d2.TypeId = 900000000000013009
        AND rm2.Active = 1
        AND rm2.RefsetId = rm.RefsetId
  );
```

## 4. Get Direct Children

Returns direct children of `64572001 | Disease`.

```sql
SELECT
    c.DescendantId AS ConceptId,
    c.Depth,
    pt.Term AS PreferredTerm
FROM Terminology_Snomed.IsaClosure c
LEFT JOIN Terminology_Snomed.PreferredTerm pt
    ON pt.ConceptId = c.DescendantId
   AND pt.ReleaseId = c.ReleaseId
   AND pt.Lang = 'es'
   AND pt.Dialect = 'es-ES'
WHERE c.ReleaseId = 'SNOMED CT version 20260101'
  AND c.View = 'inferred'
  AND c.AncestorId = 64572001
  AND c.Depth = 1
ORDER BY pt.Term;
```

## 5. Get Ancestors

Returns ancestors of `22298006 | Myocardial infarction`.

```sql
SELECT
    c.AncestorId AS ConceptId,
    c.Depth,
    pt.Term AS PreferredTerm
FROM Terminology_Snomed.IsaClosure c
LEFT JOIN Terminology_Snomed.PreferredTerm pt
    ON pt.ConceptId = c.AncestorId
   AND pt.ReleaseId = c.ReleaseId
   AND pt.Lang = 'es'
   AND pt.Dialect = 'es-ES'
WHERE c.ReleaseId = 'SNOMED CT version 20260101'
  AND c.View = 'inferred'
  AND c.DescendantId = 22298006
  AND c.Depth > 0
  AND c.Depth <= 10
ORDER BY c.Depth, pt.Term;
```

Remove `AND c.Depth > 0` if you want to include the concept itself.

## 6. Get Descendants

Returns descendants of `404684003 | Clinical finding`.

For direct execution, this example uses `TOP 50` to avoid dumping a very large result set.

```sql
SELECT TOP 50
    c.DescendantId AS ConceptId,
    c.Depth,
    pt.Term AS PreferredTerm
FROM Terminology_Snomed.IsaClosure c
LEFT JOIN Terminology_Snomed.PreferredTerm pt
    ON pt.ConceptId = c.DescendantId
   AND pt.ReleaseId = c.ReleaseId
   AND pt.Lang = 'es'
   AND pt.Dialect = 'es-ES'
WHERE c.ReleaseId = 'SNOMED CT version 20260101'
  AND c.View = 'inferred'
  AND c.AncestorId = 404684003
ORDER BY c.Depth, pt.Term;
```

## 7. Test Subsumption

Checks whether `64572001 | Disease` subsumes `22298006 | Myocardial infarction`.

Expected result: `subsumes`.

```sql
SELECT
    CASE
        WHEN 64572001 = 22298006 THEN 'equivalent'
        WHEN EXISTS (
            SELECT 1
            FROM Terminology_Snomed.IsaClosure c
            WHERE c.ReleaseId = 'SNOMED CT version 20260101'
              AND c.View = 'inferred'
              AND c.AncestorId = 64572001
              AND c.DescendantId = 22298006
        ) THEN 'subsumes'
        WHEN EXISTS (
            SELECT 1
            FROM Terminology_Snomed.IsaClosure c
            WHERE c.ReleaseId = 'SNOMED CT version 20260101'
              AND c.View = 'inferred'
              AND c.AncestorId = 22298006
              AND c.DescendantId = 64572001
        ) THEN 'subsumed-by'
        ELSE 'not-subsumed'
    END AS Relationship;
```

## 8. Validate a Code

Checks whether the concept exists and whether it is active in the selected release.

```sql
SELECT
    CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS ExistsFlag,
    MAX(COALESCE(c.Active, 0)) AS ActiveFlag
FROM Terminology_Snomed.Concept c
WHERE c.ReleaseId = 'SNOMED CT version 20260101'
  AND c.ConceptId = 22298006;
```

## 9. Search by Term

Uses the `PreferredTerm` table and the iFind index `IXTermNormFind`.

```sql
SELECT
    pt.ConceptId,
    pt.Term AS PreferredTerm
FROM Terminology_Snomed.PreferredTerm pt
WHERE pt.ReleaseId = 'SNOMED CT version 20260101'
  AND pt.Lang = 'es'
  AND pt.Dialect = 'es-ES'
  AND %ID %FIND search_index(IXTermNormFind, 'infarto')
ORDER BY pt.Term;
```

If you need a simple fallback without iFind:

```sql
SELECT
    pt.ConceptId,
    pt.Term AS PreferredTerm
FROM Terminology_Snomed.PreferredTerm pt
WHERE pt.ReleaseId = 'SNOMED CT version 20260101'
  AND pt.Lang = 'es'
  AND pt.Dialect = 'es-ES'
  AND pt.TermNorm %STARTSWITH %SQLUPPER('infarto')
ORDER BY pt.Term;
```

## 10. Notes About These Queries

- `PreferredTerm` is a derived table. If it has not been built for the requested `Lang` and `Dialect`, the joins will return `NULL` terms or no search results.
- `IsaClosure` is also derived. Hierarchy queries and subsumption checks depend on it being populated for the requested `View`.
- The repository uses `PreferredTerm` for runtime lookups instead of deriving preferred terms on every request.
- The repository uses `IsaClosure` for hierarchy navigation instead of reading `Relationship` recursively at runtime.
