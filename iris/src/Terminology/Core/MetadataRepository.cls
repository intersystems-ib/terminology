/// Reads neutral terminology catalog metadata used by API layers.
Class Terminology.Core.MetadataRepository Extends %RegisteredObject
{

/// Returns code system metadata and the active release version when present.
Method GetCodeSystemInfo(pSystemUri As %String = "", Output pResult As Terminology.Core.DTO.CodeSystemInfo) As %Status
{
    Set pResult = ##class(Terminology.Core.DTO.CodeSystemInfo).%New()

    Try {
        If pSystemUri = "" {
            Return $$$OK
        }

        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare("SELECT Name, DefaultLang, DefaultDialect, Notes FROM Terminology_Core.CodeSystem WHERE SystemUri = ?")
        $$$ThrowOnError(tSC)

        Set rset = stmt.%Execute(pSystemUri)
        If rset.%Next() {
            Set pResult.Url = pSystemUri
            Set pResult.Name = rset.%Get("Name")
            Set pResult.Title = rset.%Get("Name")
            Set pResult.Description = rset.%Get("Notes")
            Set pResult.DefaultLang = rset.%Get("DefaultLang")
            Set pResult.DefaultDialect = rset.%Get("DefaultDialect")
        } ElseIf pSystemUri = "http://snomed.info/sct" {
            Set pResult.Url = pSystemUri
            Set pResult.Name = "SNOMEDCT"
            Set pResult.Title = "SNOMED CT"
            Set pResult.Description = "SNOMED CT code system"
        } Else {
            Return $$$OK
        }

        Set pResult.Content = "not-present"
        Set pResult.Status = "draft"

        Set stmt = ##class(%SQL.Statement).%New()
        Set tSC = stmt.%Prepare("SELECT TOP 1 ReleaseId, VersionUri FROM Terminology_Core.VersionRelease WHERE SystemUri = ? AND IsActive = 1 ORDER BY EffectiveDate DESC, ReleaseId DESC")
        $$$ThrowOnError(tSC)

        Set rset = stmt.%Execute(pSystemUri)
        If rset.%Next() {
            Set pResult.Version = $Select(rset.%Get("ReleaseId")'="":rset.%Get("ReleaseId"), 1:rset.%Get("VersionUri"))
            Set pResult.Status = "active"
        }

        Return $$$OK
    } Catch ex {
        Return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}

}
