Class Terminology.Loinc.Utils.BuilderDisplay Extends %RegisteredObject
{

ClassMethod Build(pDir As %String, pReleaseId As %String, pBaseLang As %String = "en", pLang As %String = "es", pLinguisticVariantPrefix As %String = "") As %Status
{
    Set tSC = $$$OK

    Try {
        Do ..LogInfo("Inicio BuildDisplay | ReleaseId="_pReleaseId_" | BaseLang="_pBaseLang_" | VariantLang="_pLang_" | Prefix="_pLinguisticVariantPrefix)

        Do ..LogInfo("Paso 1: limpieza de Display")
        Set tSC = ..DeleteExisting(pReleaseId, pBaseLang)
        If $$$ISERR(tSC) {
            Do ..LogInfo("Error en Paso 1: "_$System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        If pLang'=pBaseLang {
            Set tSC = ..DeleteExisting(pReleaseId, pLang)
            If $$$ISERR(tSC) {
                Do ..LogInfo("Error limpiando idioma variante: "_$System.Status.GetOneErrorText(tSC))
                Return tSC
            }
        }

        Do ..LogInfo("Paso 2: inserción de displays base")
        Set tSC = ..InsertBaseDisplays(pReleaseId, pBaseLang)
        If $$$ISERR(tSC) {
            Do ..LogInfo("Error en Paso 2: "_$System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        Do ..LogInfo("Paso 3: inserción de ConsumerName")
        Set tSC = ..InsertConsumerDisplays(pReleaseId, pBaseLang)
        If $$$ISERR(tSC) {
            Do ..LogInfo("Error en Paso 3: "_$System.Status.GetOneErrorText(tSC))
            Return tSC
        }

        Do ..LogInfo("Paso 4: resolución de fichero de variante lingüística")
        Set variantFile = ..ResolveLinguisticVariantFile(pDir, pLinguisticVariantPrefix)
        If variantFile'="" {
            Do ..LogInfo("Fichero de variante encontrado: "_variantFile)
            Set tSC = ..InsertVariantDisplays(variantFile, pReleaseId, pLang)
            If $$$ISERR(tSC) {
                Do ..LogInfo("Error en Paso 4: "_$System.Status.GetOneErrorText(tSC))
                Return tSC
            }
        } Else {
            Do ..LogInfo("No se encontró fichero de variante para prefijo: "_pLinguisticVariantPrefix)
        }

        Do ..LogInfo("Fin BuildDisplay OK | ReleaseId="_pReleaseId_" | BaseLang="_pBaseLang_" | VariantLang="_pLang)
        Return $$$OK
    } Catch ex {
        Do ..LogInfo("Excepción en BuildDisplay: "_ex.DisplayString())
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

ClassMethod DeleteExisting(pReleaseId As %String, pLang As %String) As %Status
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "DELETE FROM Terminology_Loinc.Display WHERE ReleaseId = ? AND Lang = ?"

    Set tSC = stmt.%Prepare(sql)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set rset = stmt.%Execute(pReleaseId, pLang)
    Return $$$OK
}

ClassMethod InsertBaseDisplays(pReleaseId As %String, pLang As %String) As %Status
{
    Set tSC = $$$OK

    Set tSC = ..InsertDisplayType(
        pReleaseId,
        pLang,
        "LONGCOMMONNAME",
        "LongCommonName",
        1
    )
    If $$$ISERR(tSC) Return tSC

    Set tSC = ..InsertDisplayType(
        pReleaseId,
        pLang,
        "SHORTNAME",
        "ShortName",
        2
    )
    If $$$ISERR(tSC) Return tSC

    Set tSC = ..InsertDisplayType(
        pReleaseId,
        pLang,
        "DISPLAYNAME",
        "DisplayName",
        3
    )
    If $$$ISERR(tSC) Return tSC

    Return $$$OK
}

ClassMethod InsertConsumerDisplays(pReleaseId As %String, pLang As %String) As %Status
{
    Quit ..InsertDisplayType(
        pReleaseId,
        pLang,
        "CONSUMERNAME",
        "ConsumerName",
        4
    )
}

ClassMethod InsertDisplayType(pReleaseId As %String, pLang As %String, pDisplayType As %String, pSourceField As %String, pRankOrder As %Integer) As %Status
{
    Set stmt = ##class(%SQL.Statement).%New()

    Set sql = ""
    Set sql = sql_"INSERT INTO Terminology_Loinc.Display "
    Set sql = sql_"(ReleaseId, LoincNum, Lang, DisplayType, Display, DisplayNorm, RankOrder) "
    Set sql = sql_"SELECT "
    Set sql = sql_"?, LoincNum, ?, ?, "_pSourceField_", %SQLUPPER("_pSourceField_"), ? "
    Set sql = sql_"FROM Terminology_Loinc.Code "
    Set sql = sql_"WHERE ReleaseId = ? "
    Set sql = sql_"AND "_pSourceField_" IS NOT NULL "
    Set sql = sql_"AND "_pSourceField_" <> ''"

    Do ..LogInfo("InsertDisplayType "_pDisplayType_" SQL preparado")

    Set tSC = stmt.%Prepare(sql)
    If $$$ISERR(tSC) {
        Return tSC
    }

    Set rset = stmt.%Execute(
        pReleaseId,
        pLang,
        pDisplayType,
        pRankOrder,
        pReleaseId
    )

    Return $$$OK
}

ClassMethod ResolveLinguisticVariantFile(pDir As %String, pPrefix As %String) As %String
{
    If pPrefix="" {
        Quit ""
    }

    Set targetName = pPrefix_"LinguisticVariant.csv"
    Set found = ""

    Set tSC = ..FindFileRecursive(pDir, targetName, .found)
    If $$$ISERR(tSC) {
        Quit ""
    }

    Quit found
}

ClassMethod FindFileRecursive(pDir As %String, pTargetName As %String, Output pFound As %String) As %Status
{
    Set pFound = ""

    Try {
        Set normDir = ##class(%File).NormalizeDirectory(pDir)
        If normDir = "" {
            Return $$$ERROR($$$GeneralError, "Directory not found: "_pDir)
        }

        Set stmt = ##class(%SQL.Statement).%New()
        Set sql = "SELECT Name "_
                  "FROM %Library.File_FileSet(?, ?, ?, ?, ?)"

        Set tSC = stmt.%Prepare(sql)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Set rset = stmt.%Execute(normDir, "*", "Name", 1, ";")

        While rset.%Next() {
            Set name = rset.%Get("Name")
            If (name = ".") || (name = "..") {
                Continue
            }

            Set fullPath = ##class(%File).NormalizeFilename(name, normDir)

            If ##class(%File).DirectoryExists(fullPath) {
                Set tSC = ..FindFileRecursive(fullPath, pTargetName, .pFound)
                If $$$ISERR(tSC) {
                    Return tSC
                }
                If pFound'="" {
                    Return $$$OK
                }
            } ElseIf ##class(%File).GetFilename(fullPath) = pTargetName {
                Set pFound = fullPath
                Return $$$OK
            }
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

ClassMethod InsertVariantDisplays(pFilePath As %String, pReleaseId As %String, pLang As %String) As %Status
{
    Try {
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set tSC = stream.LinkToFile(pFilePath)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Set stream.TranslateTable = "UTF8"
        Do stream.Rewind()
        If $$$ISERR(tSC) {
            Return tSC
        }

        Do stream.Rewind()

        Set headerLine = stream.ReadLine()
        If $Extract(headerLine,1)=$Char(65279) {
            Set headerLine = $Extract(headerLine,2,*)
        }
        If headerLine="" {
            Do ..LogInfo("Variant file is empty: "_pFilePath)
            Return $$$OK
        }

        Set header = ..ParseCsvLine(headerLine)

        Set idxLoinc = ..FindHeaderIndex(header, "LOINC_NUM")
        Set idxText = ..FindHeaderIndex(header, "COMPONENT")

        If idxLoinc<1 {
            Do ..LogInfo("LOINC_NUM column not found in variant file: "_pFilePath)
            Return $$$ERROR($$$GeneralError, "LOINC_NUM column not found in variant file: "_pFilePath)
        }

        If idxText<1 {
            Do ..LogInfo("COMPONENT column not found in variant file: "_pFilePath)
            Return $$$ERROR($$$GeneralError, "COMPONENT column not found in variant file: "_pFilePath)
        }

        Do ..LogInfo(
            "InsertVariantDisplays | File="_pFilePath_
            " | idxLoinc="_idxLoinc_
            " | idxText="_idxText
        )

        Set stmt = ##class(%SQL.Statement).%New()
        Set sql = "INSERT INTO Terminology_Loinc.Display "_
                  "(ReleaseId, LoincNum, Lang, DisplayType, Display, DisplayNorm, RankOrder) "_
                  "SELECT ?, ?, ?, ?, ?, %SQLUPPER(?), ?"

        Set tSC = stmt.%Prepare(sql)
        If $$$ISERR(tSC) {
            Return tSC
        }

        Set count = 0
        Set skipped = 0

        While 'stream.AtEnd {
            Set line = stream.ReadLine()
            If $ZSTRIP(line,"<>W")="" {
                Continue
            }

            Set cols = ..ParseCsvLine(line)
            Set colCount = $LISTLENGTH(cols)

            Set loinc = ""
            Set text = ""

            If idxLoinc<=colCount {
                Set loinc = $LISTGET(cols, idxLoinc)
            }

            If idxText<=colCount {
                Set text = $LISTGET(cols, idxText)
            }

            Set loinc = $ZSTRIP(loinc,"<>W")
            Set text = $ZSTRIP(text,"<>W")

            If (loinc="")!(text="") {
                Set skipped = skipped + 1
                Continue
            }

            Set rset = stmt.%Execute(
                pReleaseId,
                loinc,
                pLang,
                "LINGUISTICVARIANT",
                text,
                text,
                0
            )

            Set count = count + 1

            If '(count#500) {
                Do ..LogInfo("Variant displays inserted: "_count_" | skipped="_skipped)
            }
        }

        Do ..LogInfo("Variant displays inserted total: "_count_" | skipped="_skipped)
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

ClassMethod FindHeaderIndex(pHeader As %List, pName As %String) As %Integer
{
    Set count = $LISTLENGTH(pHeader)
    Set idx = 0

    For i=1:1:count {
        If $LISTGET(pHeader, i)=pName {
            Set idx = i
            Quit
        }
    }

    Quit idx
}

ClassMethod ParseCsvLine(pLine As %String) As %List
{
    Set result = ""

    // Eliminar CR final (Windows)
    If $Extract(pLine, *-0) = $Char(13) {
        Set pLine = $Extract(pLine, 1, *-1)
    }

    Set inQuotes = 0
    Set value = ""
    Set len = $Length(pLine)
    Set i = 1

    While i<=len {
        Set ch = $Extract(pLine, i)

        If ch="""" {
            // Comilla escapada ""
            If inQuotes, (i < len), ($Extract(pLine, i+1)="""") {
                Set value = value_""""
                Set i = i + 2
                Continue
            }

            // Toggle estado
            Set inQuotes = 'inQuotes
            Set i = i + 1
            Continue
        }

        // Separador real
        If (ch=",") && ('inQuotes) {
            Set result = result_$LISTBUILD(value)
            Set value = ""
            Set i = i + 1
            Continue
        }

        Set value = value_ch
        Set i = i + 1
    }

    // Último campo
    Set result = result_$LISTBUILD(value)

    Quit result
}

ClassMethod LogInfo(pText As %String) As %Status
{
    Do ##class(Ens.Util.Log).LogInfo(
        "Terminology.Loinc.BuilderDisplay",
        "Build",
        pText
    )
    Return $$$OK
}

}
