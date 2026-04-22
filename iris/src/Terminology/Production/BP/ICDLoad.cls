Class Terminology.Production.BP.ICDLoad Extends Ens.BusinessProcess
{

Property GenerateVectors As %Boolean [ InitialExpression = 0 ];

Parameter SETTINGS = "GenerateVectors";

Method OnRequest(pRequest As Terminology.Production.Msg.ICDLoadRequest, Output pResponse As Ens.Response) As %Status
{
    Try {
        Set filePath = pRequest.FilePath

        $$$LOGINFO("ICDLoad start "_filePath)

        Set tSC = ##class(Terminology.ICD.Utils.BuilderCode).Build(filePath, pRequest.ReleaseId, pRequest.Version, pRequest.CodeType, pRequest.Lang)
        If $$$ISERR(tSC) Return tSC

        Set tSC = ##class(Terminology.ICD.Utils.BuilderHierarchy).Build(pRequest.ReleaseId, pRequest.Version, pRequest.CodeType)
        If $$$ISERR(tSC) Return tSC

        Set tSC = ..EnsureCoreMetadata(pRequest.ReleaseId, pRequest.Version, pRequest.Lang)
        If $$$ISERR(tSC) Return tSC

        If ..GenerateVectors {
            Set tSC = ##class(Terminology.Vector.Utils).RebuildByRelease(pRequest.ReleaseId, "ICD", pRequest.Lang, ,pRequest.Version, pRequest.CodeType)
            If $$$ISERR(tSC) Return tSC
        }
        $$$LOGINFO("ICDLoad end")
        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method EnsureCoreMetadata(pReleaseId As %String, pVersion As %Integer, pLang As %String = "es") As %Status [ Private ]
{
    Try {
        Set systemUri = ..GetSystemUri(pVersion)
        Set codeSystemName = ..GetCodeSystemName(pVersion)
        Set defaultLang = $Select(pLang'="":pLang,1:"es")
        Set defaultDialect = $Select($ZCONVERT(defaultLang, "L")="es":"es-ES",1:"")
        Set notes = "ICD-"_pVersion_" code system"
        Set defaultType = "ICD"

        Set params = ##class(%DynamicArray).%New()
        Do params.%Push(codeSystemName)
        Do params.%Push(defaultLang)
        Do params.%Push(defaultDialect)
        Do params.%Push(notes)
        Do params.%Push(defaultType)
        Do params.%Push(systemUri)
        Set tSC = ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(
            "UPDATE Terminology_Core.CodeSystem "_
            "SET Name = ?, DefaultLang = ?, DefaultDialect = ?, Notes = ?, Type = ? "_
            "WHERE SystemUri = ?",
            params.%ToJSON()
        )
        If $$$ISERR(tSC) Return tSC

        Set params = ##class(%DynamicArray).%New()
        Do params.%Push(systemUri)
        Do params.%Push(codeSystemName)
        Do params.%Push(defaultLang)
        Do params.%Push(defaultDialect)
        Do params.%Push(notes)
        Do params.%Push(defaultType)
        Do params.%Push(systemUri)
        Set tSC = ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(
            "INSERT INTO Terminology_Core.CodeSystem "_
            "(SystemUri, Name, DefaultLang, DefaultDialect, Notes, Type) "_
            "SELECT ?, ?, ?, ?, ?, ? "_
            "WHERE NOT EXISTS (SELECT 1 FROM Terminology_Core.CodeSystem WHERE SystemUri = ?)",
            params.%ToJSON()
        )
        If $$$ISERR(tSC) Return tSC

        Set params = ##class(%DynamicArray).%New()
        Do params.%Push(systemUri)
        Do params.%Push("")
        Do params.%Push(pReleaseId)
        Set tSC = ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(
            "UPDATE Terminology_Core.VersionRelease "_
            "SET SystemUri = ?, VersionUri = ?, EffectiveDate = NULL, IsActive = 0 "_
            "WHERE ReleaseId = ?",
            params.%ToJSON()
        )
        If $$$ISERR(tSC) Return tSC

        Set params = ##class(%DynamicArray).%New()
        Do params.%Push(pReleaseId)
        Do params.%Push(systemUri)
        Do params.%Push("")
        Do params.%Push(pReleaseId)
        Set tSC = ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(
            "INSERT INTO Terminology_Core.VersionRelease "_
            "(ReleaseId, SystemUri, VersionUri, EffectiveDate, IsActive) "_
            "SELECT ?, ?, ?, NULL, 0 "_
            "WHERE NOT EXISTS (SELECT 1 FROM Terminology_Core.VersionRelease WHERE ReleaseId = ?)",
            params.%ToJSON()
        )
        If $$$ISERR(tSC) Return tSC

        Set params = ##class(%DynamicArray).%New()
        Do params.%Push(systemUri)
        Set tSC = ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(
            "UPDATE Terminology_Core.VersionRelease SET IsActive = 0 WHERE SystemUri = ?",
            params.%ToJSON()
        )
        If $$$ISERR(tSC) Return tSC

        Set params = ##class(%DynamicArray).%New()
        Do params.%Push(pReleaseId)
        Set tSC = ##class(Terminology.Core.SqlUtils).ExecuteNonQuery(
            "UPDATE Terminology_Core.VersionRelease SET IsActive = 1 WHERE ReleaseId = ?",
            params.%ToJSON()
        )
        If $$$ISERR(tSC) Return tSC

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

Method GetCodeSystemName(pVersion As %Integer) As %String [ Private ]
{
    If pVersion>0 {
        Return "ICD"_pVersion
    }

    Return "ICD"
}

Method GetSystemUri(pVersion As %Integer) As %String [ Private ]
{
    If pVersion>0 {
        Return "http://id.who.int/icd/release/"_pVersion
    }

    Return "http://id.who.int/icd/release"
}

Storage Default
{
<Data name="ICDLoadDefaultData">
<Subscript>"ICDLoad"</Subscript>
<Value name="1">
<Value>GenerateVectors</Value>
</Value>
</Data>
<DefaultData>ICDLoadDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
