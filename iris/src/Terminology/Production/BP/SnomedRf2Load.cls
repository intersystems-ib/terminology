Class Terminology.Production.BP.SnomedRf2Load Extends Ens.BusinessProcess
{

Parameter INVOCATION = "Queue";

Property TempDirectory As %String(MAXLEN = 500) [ InitialExpression = "/tmp/terminology" ];

Property SnomedFileSuffix As %String(MAXLEN = 500) [ InitialExpression = "SpanishExtension" ];

Property BuildPreferredTerm As %Boolean [ InitialExpression = 1 ];

Property PreferredTermLang As %String(MAXLEN = 10) [ InitialExpression = "es" ];

Property PreferredTermDialect As %String(MAXLEN = 20) [ InitialExpression = "es-ES" ];

Property PreferredTermLanguageRefsetId As %String(MAXLEN = 50);

Property BuildIsaClosure As %Boolean [ InitialExpression = 1 ];

Property IsaClosureView As %String(MAXLEN = 20) [ InitialExpression = "inferred" ];

Property IsaTypeId As %String(MAXLEN = 20) [ InitialExpression = "116680003" ];

Property ClearBeforeLoad As %Boolean [ InitialExpression = 0 ];

Parameter SETTINGS = "TempDirectory,SnomedFileSuffix,BuildPreferredTerm,PreferredTermLang,PreferredTermDialect,PreferredTermLanguageRefsetId,BuildIsaClosure,IsaClosureView,IsaTypeId,ClearBeforeLoad";

Method OnRequest(pRequest As Terminology.Production.Msg.SnomedRf2LoadRequest, Output pResponse As Terminology.Production.Msg.SnomedRf2LoadResponse) As %Status
{
    Set tSC = $$$OK

    Set pResponse = ##class(Terminology.Production.Msg.SnomedRf2LoadResponse).%New()
    Set pResponse.ReleaseId = pRequest.ReleaseId
    Set pResponse.FileName = pRequest.FileName

    Try {
        Set inputPath = pRequest.FileName

        If ##class(%File).DirectoryExists(inputPath) {
            Set rf2Dir = inputPath
        } Else {
            Set rf2Dir = ..PrepareInput(inputPath, ..TempDirectory)
        }

        Do ##class(Ens.Util.Log).LogInfo(
            "Terminology.Production.BP.SnomedRf2Load",
            "OnRequest",
            "Inicio importación RF2. ReleaseId="_pRequest.ReleaseId_" Path="_rf2Dir
        )

        Set tSC = ##class(Terminology.Snomed.Utils.LoaderRf2).LoadSnapshot(
            rf2Dir,
            pRequest.ReleaseId,
            pRequest.SystemUri,
            pRequest.EffectiveDate,
            pRequest.SetActive,
            ..SnomedFileSuffix,
            ..ClearBeforeLoad,
            ..PreferredTermLang
        )

        If $$$ISERR(tSC) {
            Set pResponse.Message = "Carga RF2 fallida: "_$System.Status.GetOneErrorText(tSC)
            Return tSC
        }

        Do ##class(Ens.Util.Log).LogInfo(
            "Terminology.Production.BP.SnomedRf2Load",
            "OnRequest",
            "Importación RF2 completada. ReleaseId="_pRequest.ReleaseId
        )

        If ..BuildPreferredTerm {
            If ..PreferredTermLanguageRefsetId = "" {
                Set pResponse.Message = "PreferredTermLanguageRefsetId es obligatorio cuando BuildPreferredTerm=1"
                Return $$$ERROR($$$GeneralError, pResponse.Message)
            }

            Do ##class(Ens.Util.Log).LogInfo(
                "Terminology.Production.BP.SnomedRf2Load",
                "OnRequest",
                "Inicio BuilderPreferredTerm. ReleaseId="_pRequest.ReleaseId_" Lang="_..PreferredTermLang_" Dialect="_..PreferredTermDialect_" LanguageRefsetId="_..PreferredTermLanguageRefsetId
            )

            Set tSC = ##class(Terminology.Snomed.Utils.BuilderPreferredTerm).Build(
                pRequest.ReleaseId,
                ..PreferredTermLang,
                ..PreferredTermDialect,
                ..PreferredTermLanguageRefsetId
            )

            If $$$ISERR(tSC) {
                Set pResponse.Message = "RF2 importado pero PreferredTerm falló: "_$System.Status.GetOneErrorText(tSC)
                Return tSC
            }

            Do ##class(Ens.Util.Log).LogInfo(
                "Terminology.Production.BP.SnomedRf2Load",
                "OnRequest",
                "BuilderPreferredTerm completado. ReleaseId="_pRequest.ReleaseId
            )
        }

        If ..BuildIsaClosure {
            Do ##class(Ens.Util.Log).LogInfo(
                "Terminology.Production.BP.SnomedRf2Load",
                "OnRequest",
                "Inicio BuilderIsaClosure. ReleaseId="_pRequest.ReleaseId_" View="_..IsaClosureView_" IsaTypeId="_..IsaTypeId
            )

            Set tSC = ##class(Terminology.Snomed.Utils.BuilderIsaClosure).Build(
                pRequest.ReleaseId,
                ..IsaClosureView,
                ..IsaTypeId
            )

            If $$$ISERR(tSC) {
                Set pResponse.Message = "RF2 importado y PreferredTerm generado, pero IsaClosure falló: "_$System.Status.GetOneErrorText(tSC)
                Return tSC
            }

            Do ##class(Ens.Util.Log).LogInfo(
                "Terminology.Production.BP.SnomedRf2Load",
                "OnRequest",
                "BuilderIsaClosure completado. ReleaseId="_pRequest.ReleaseId
            )
        }

        Set pResponse.Message = "Carga RF2, generación de PreferredTerm y construcción de IsaClosure completadas correctamente"
        Return $$$OK
    } Catch ex {
        Set tSC = $$$ERROR($$$GeneralError, ex.DisplayString())
        Set pResponse.Message = "Excepción en BP: "_ex.DisplayString()
        Return tSC
    }
}

Method PrepareInput(pInputPath As %String, pTempDirectory As %String) As %String [ Language = python ]
{
import os
import zipfile
import uuid

def get_extension(path):
    filename = os.path.basename(path)
    if "." not in filename:
        return ""
    return filename.split(".")[-1].lower()

def safe_extract(zip_ref, path):
    base_path = os.path.abspath(path)

    for member in zip_ref.namelist():
        member_path = os.path.abspath(os.path.join(path, member))
        if not member_path.startswith(base_path):
            raise Exception(f"Zip Slip detectado: {member}")

    zip_ref.extractall(path)

ext = get_extension(pInputPath)

if ext != "zip":
    return pInputPath

base_dir = pTempDirectory or "/tmp/terminology"
os.makedirs(base_dir, exist_ok=True)

out_dir = os.path.join(base_dir, str(uuid.uuid4()))
os.makedirs(out_dir, exist_ok=True)

with zipfile.ZipFile(pInputPath, "r") as zip_ref:
    safe_extract(zip_ref, out_dir)

return out_dir
}

Storage Default
{
<Data name="SnomedRf2LoadDefaultData">
<Subscript>"SnomedRf2Load"</Subscript>
<Value name="1">
<Value>TempDirectory</Value>
</Value>
<Value name="2">
<Value>SnomedFileSuffix</Value>
</Value>
<Value name="3">
<Value>BuildPreferredTerm</Value>
</Value>
<Value name="4">
<Value>PreferredTermLang</Value>
</Value>
<Value name="5">
<Value>PreferredTermDialect</Value>
</Value>
<Value name="6">
<Value>PreferredTermLanguageRefsetId</Value>
</Value>
<Value name="7">
<Value>BuildIsaClosure</Value>
</Value>
<Value name="8">
<Value>IsaClosureView</Value>
</Value>
<Value name="9">
<Value>IsaTypeId</Value>
</Value>
<Value name="10">
<Value>ClearBeforeLoad</Value>
</Value>
</Data>
<DefaultData>SnomedRf2LoadDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
