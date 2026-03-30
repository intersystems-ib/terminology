Class Terminology.Snomed.Utils.BuilderPreferredTerm Extends %RegisteredObject
{

ClassMethod Build(pReleaseId As %String, pLang As %String = "es", pDialect As %String = "es-ES", pLanguageRefsetId As %String = "") As %Status
{
    Set tSC = $$$OK

    Try {
        Do ..LogInfo("Inicio Build | ReleaseId="_pReleaseId_" | Lang="_pLang_" | Dialect="_pDialect_" | LanguageRefsetId="_pLanguageRefsetId)

        If pLanguageRefsetId = "" {
            Do ..LogInfo("Error: PreferredTermLanguageRefsetId no informado")
            Return $$$ERROR($$$GeneralError, "PreferredTermLanguageRefsetId es obligatorio")
        }

        Do ..LogInfo("Paso 1: limpieza de PreferredTerm")
        Set tSC = ..DeleteExistingPreferredTerm(pReleaseId, pLang, pDialect)
        If $$$ISERR(tSC) {
            Do ..LogInfo("Error en Paso 1: "_$System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        Do ..LogInfo("Paso 2: limpieza de PreferredTermStage")
        Set tSC = ..DeleteStage(pReleaseId, pLang, pDialect)
        If $$$ISERR(tSC) {
            Do ..LogInfo("Error en Paso 2: "_$System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        Do ..LogInfo("Paso 3: actualización de LanguageRefSetConfig")
        Set tSC = ..UpsertLanguageRefsetConfig(pReleaseId, pLang, pDialect, pLanguageRefsetId)
        If $$$ISERR(tSC) {
            Do ..LogInfo("Error en Paso 3: "_$System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        Do ..LogInfo("Paso 4: poblando PreferredTermStage")
        Set tSC = ..PopulateStage(pReleaseId, pLang, pDialect, pLanguageRefsetId)
        If $$$ISERR(tSC) {
            Do ..LogInfo("Error en Paso 4: "_$System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        Do ..LogInfo("Paso 5: insertando PreferredTerm desde Stage")
        Set tSC = ..InsertPreferredTermsFromStage(pReleaseId, pLang, pDialect)
        If $$$ISERR(tSC) {
            Do ..LogInfo("Error en Paso 5: "_$System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        Do ..LogInfo("Fin Build OK | ReleaseId="_pReleaseId_" | Lang="_pLang_" | Dialect="_pDialect)
        Return $$$OK

    } Catch ex {
        Do ..LogInfo("Excepción en Build: "_ex.DisplayString())
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

ClassMethod DeleteExistingPreferredTerm(pReleaseId As %String, pLang As %String, pDialect As %String) As %Status
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "DELETE FROM Terminology_Snomed.PreferredTerm "_
              "WHERE ReleaseId = ? AND Lang = ? AND Dialect = ?"

    Set tSC = stmt.%Prepare(sql)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set rset = stmt.%Execute(pReleaseId, pLang, pDialect)
    Return $$$OK
}

ClassMethod DeleteStage(pReleaseId As %String, pLang As %String, pDialect As %String) As %Status
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "DELETE FROM Terminology_Snomed.PreferredTermStage "_
              "WHERE ReleaseId = ? AND Lang = ? AND Dialect = ?"

    Set tSC = stmt.%Prepare(sql)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set rset = stmt.%Execute(pReleaseId, pLang, pDialect)
    Return $$$OK
}

ClassMethod UpsertLanguageRefsetConfig(pReleaseId As %String, pLang As %String, pDialect As %String, pLanguageRefsetId As %String) As %Status
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "DELETE FROM Terminology_Snomed.LanguageRefSetConfig "_
              "WHERE ReleaseId = ? AND Lang = ? AND Dialect = ?"

    Set tSC = stmt.%Prepare(sql)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set rset = stmt.%Execute(pReleaseId, pLang, pDialect)

    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "INSERT INTO Terminology_Snomed.LanguageRefSetConfig "_
              "(ReleaseId, Lang, Dialect, RefsetId) "_
              "SELECT ?, ?, ?, ?"

    Set tSC = stmt.%Prepare(sql)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set rset = stmt.%Execute(pReleaseId, pLang, pDialect, pLanguageRefsetId)
    Return $$$OK
}

ClassMethod PopulateStage(pReleaseId As %String, pLang As %String, pDialect As %String, pLanguageRefsetId As %String) As %Status
{
    Set stmt = ##class(%SQL.Statement).%New()

    Set sql = ""
    Set sql = sql_"INSERT %NOLOCK INTO Terminology_Snomed.PreferredTermStage "
    Set sql = sql_"(ReleaseId, Lang, Dialect, ConceptId, DescriptionId, Term, TermNorm) "
    Set sql = sql_"SELECT "
    Set sql = sql_"?, ?, ?, d.ConceptId, d.DescriptionId, d.Term, %SQLUPPER(d.Term) "
    Set sql = sql_"FROM Terminology_Snomed.Description d "
    Set sql = sql_"INNER JOIN Terminology_Snomed.Concept c "
    Set sql = sql_"ON c.ReleaseId = d.ReleaseId "
    Set sql = sql_"AND c.ConceptId = d.ConceptId "
    Set sql = sql_"INNER JOIN Terminology_Snomed.RefsetMember rm "
    Set sql = sql_"ON rm.ReleaseId = d.ReleaseId "
    Set sql = sql_"AND rm.ReferencedId = d.DescriptionId "
    Set sql = sql_"WHERE d.ReleaseId = ? "
    Set sql = sql_"AND d.Active = 1 "
    Set sql = sql_"AND c.Active = 1 "
    Set sql = sql_"AND d.Lang = ? "
    Set sql = sql_"AND d.TypeId = 900000000000013009 "
    Set sql = sql_"AND rm.Active = 1 "
    Set sql = sql_"AND rm.RefsetId = ? "
    Set sql = sql_"AND d.DescriptionId = ( "
    Set sql = sql_"    SELECT MIN(d2.DescriptionId) "
    Set sql = sql_"    FROM Terminology_Snomed.Description d2 "
    Set sql = sql_"    INNER JOIN Terminology_Snomed.Concept c2 "
    Set sql = sql_"    ON c2.ReleaseId = d2.ReleaseId "
    Set sql = sql_"    AND c2.ConceptId = d2.ConceptId "
    Set sql = sql_"    INNER JOIN Terminology_Snomed.RefsetMember rm2 "
    Set sql = sql_"    ON rm2.ReleaseId = d2.ReleaseId "
    Set sql = sql_"    AND rm2.ReferencedId = d2.DescriptionId "
    Set sql = sql_"    WHERE d2.ReleaseId = d.ReleaseId "
    Set sql = sql_"    AND d2.ConceptId = d.ConceptId "
    Set sql = sql_"    AND d2.Active = 1 "
    Set sql = sql_"    AND c2.Active = 1 "
    Set sql = sql_"    AND d2.Lang = ? "
    Set sql = sql_"    AND d2.TypeId = 900000000000013009 "
    Set sql = sql_"    AND rm2.Active = 1 "
    Set sql = sql_"    AND rm2.RefsetId = ? "
    Set sql = sql_" )"

    Do ..LogInfo("PopulateStage SQL preparado")

    Set tSC = stmt.%Prepare(sql)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set rset = stmt.%Execute(
        pReleaseId,
        pLang,
        pDialect,
        pReleaseId,
        pLang,
        pLanguageRefsetId,
        pLang,
        pLanguageRefsetId
    )

    Return $$$OK
}

ClassMethod InsertPreferredTermsFromStage(pReleaseId As %String, pLang As %String, pDialect As %String) As %Status
{
    Set stmt = ##class(%SQL.Statement).%New()

    Set sql = ""
    Set sql = sql_"INSERT INTO Terminology_Snomed.PreferredTerm "
    Set sql = sql_"(ReleaseId, ConceptId, Lang, Dialect, DescriptionId, Term, TermNorm) "
    Set sql = sql_"SELECT "
    Set sql = sql_"ReleaseId, ConceptId, Lang, Dialect, DescriptionId, Term, TermNorm "
    Set sql = sql_"FROM Terminology_Snomed.PreferredTermStage "
    Set sql = sql_"WHERE ReleaseId = ? "
    Set sql = sql_"AND Lang = ? "
    Set sql = sql_"AND Dialect = ?"

    Do ..LogInfo("InsertPreferredTermsFromStage SQL preparado")

    Set tSC = stmt.%Prepare(sql)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set rset = stmt.%Execute(pReleaseId, pLang, pDialect)
    Return $$$OK
}

ClassMethod LogInfo(pText As %String) As %Status
{
    Do ##class(Ens.Util.Log).LogInfo(
        "Terminology.Snomed.Utils.BuilderPreferredTerm",
        "Build",
        pText
    )
    Return $$$OK
}

}
