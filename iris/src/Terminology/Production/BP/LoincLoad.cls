Class Terminology.Production.BP.LoincLoad Extends Ens.BusinessProcess
{

Parameter INVOCATION = "Queue";

Property TempDirectory As %String(MAXLEN = 500) [ InitialExpression = "/iris-shared/tmp/loinc" ];

Property ClearBeforeLoad As %Boolean [ InitialExpression = 0 ];

Property BuildDisplay As %Boolean [ InitialExpression = 1 ];

Property BaseDisplayLang As %String(MAXLEN = 10) [ InitialExpression = "en" ];

Property DisplayLang As %String(MAXLEN = 10) [ InitialExpression = "es" ];

Property LinguisticVariantPrefix As %String(MAXLEN = 50) [ InitialExpression = "esES12" ];

Property BuildHierarchy As %Boolean [ InitialExpression = 1 ];

Property BuildComponentBySystemHierarchy As %Boolean [ InitialExpression = 1 ];

Property BuildGroupHierarchy As %Boolean [ InitialExpression = 1 ];

Property GenerateVectors As %Boolean [ InitialExpression = 0 ];

Parameter SETTINGS = "TempDirectory,ClearBeforeLoad,BuildDisplay,BaseDisplayLang,DisplayLang,LinguisticVariantPrefix,BuildHierarchy,BuildComponentBySystemHierarchy,BuildGroupHierarchy,GenerateVectors";

Method OnRequest(pRequest As Terminology.Production.Msg.LoincLoadRequest, Output pResponse As Terminology.Production.Msg.LoincLoadResponse) As %Status
{
    Set tSC = $$$OK
    Set pResponse = ##class(Terminology.Production.Msg.LoincLoadResponse).%New()
    Set pResponse.ReleaseId = pRequest.ReleaseId
    Set pResponse.FileName = pRequest.FileName

    Try {
        Set inputPath = pRequest.FileName

        If ##class(%File).DirectoryExists(inputPath) {
            Set loincDir = inputPath
        } Else {
            Set loincDir = ..PrepareInput(inputPath, ..TempDirectory)
        }

        Do ##class(Ens.Util.Log).LogInfo("Terminology.Production.BP.LoincLoad","OnRequest","Starting LOINC import. ReleaseId="_pRequest.ReleaseId_" Path="_loincDir)

        Set tSC = ##class(Terminology.Loinc.Utils.Loader).LoadSnapshot(
            loincDir,
            pRequest.ReleaseId,
            pRequest.SystemUri,
            pRequest.EffectiveDate,
            pRequest.SetActive,
            ..ClearBeforeLoad
        )
        If $$$ISERR(tSC) {
            Set pResponse.Message = "LOINC load failed: "_$System.Status.GetOneErrorText(tSC)
            Return tSC
        }

        If ..BuildDisplay {
            Do ##class(Ens.Util.Log).LogInfo(
                "Terminology.Production.BP.LoincLoad",
                "OnRequest",
                "Starting LOINC BuilderDisplay. ReleaseId="_pRequest.ReleaseId_" BaseLang="_..BaseDisplayLang_" VariantLang="_..DisplayLang_" Variant="_..LinguisticVariantPrefix
            )

            Set tSC = ##class(Terminology.Loinc.Utils.BuilderDisplay).Build(
                loincDir,
                pRequest.ReleaseId,
                ..BaseDisplayLang,
                ..DisplayLang,
                ..LinguisticVariantPrefix
            )

            If $$$ISERR(tSC) {
                Set pResponse.Message = "LOINC imported but BuilderDisplay failed: "_$System.Status.GetOneErrorText(tSC)
                Return tSC
            }
        }

        If ..BuildHierarchy {
            Do ##class(Ens.Util.Log).LogInfo(
                "Terminology.Production.BP.LoincLoad",
                "OnRequest",
                "Starting LOINC BuilderHierarchy. ReleaseId="_pRequest.ReleaseId
            )

            Set tSC = ##class(Terminology.Loinc.Utils.BuilderHierarchy).Build(
                loincDir,
                pRequest.ReleaseId,
                ..BuildComponentBySystemHierarchy,
                ..BuildGroupHierarchy
            )

            If $$$ISERR(tSC) {
                Set pResponse.Message = "LOINC imported but BuilderHierarchy failed: "_$System.Status.GetOneErrorText(tSC)
                Return tSC
            }
        }

        If ..GenerateVectors {
            Do ##class(Ens.Util.Log).LogInfo(
                "Terminology.Production.BP.LoincLoad",
                "OnRequest",
                "Starting LOINC vector generation. ReleaseId="_pRequest.ReleaseId
            )

            Set tSC = ##class(Terminology.Vector.Utils).RebuildByRelease(
                pRequest.ReleaseId,
                "LOINC",
                ..DisplayLang,
                ,
                ,
                ,
                "FremyCompany/BioLORD-2023-M"
            )

            If $$$ISERR(tSC) {
                Set pResponse.Message = "LOINC imported but vector generation failed: "_$System.Status.GetOneErrorText(tSC)
                Return tSC
            }
        }

        Set pResponse.Message = "LOINC load completed successfully"
        Return $$$OK
    } Catch ex {
        Set tSC = $$$ERROR($$$GeneralError, ex.DisplayString())
        Set pResponse.Message = "Exception in BP: "_ex.DisplayString()
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
            raise Exception(f"Zip Slip detected: {member}")
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
<Data name="LoincLoadDefaultData">
<Subscript>"LoincLoad"</Subscript>
<Value name="1">
<Value>TempDirectory</Value>
</Value>
<Value name="2">
<Value>ClearBeforeLoad</Value>
</Value>
<Value name="3">
<Value>BuildDisplay</Value>
</Value>
<Value name="4">
<Value>DisplayLang</Value>
</Value>
<Value name="5">
<Value>LinguisticVariantPrefix</Value>
</Value>
<Value name="6">
<Value>BuildHierarchy</Value>
</Value>
<Value name="7">
<Value>BuildComponentBySystemHierarchy</Value>
</Value>
<Value name="8">
<Value>BuildGroupHierarchy</Value>
</Value>
<Value name="9">
<Value>BaseDisplayLang</Value>
</Value>
<Value name="10">
<Value>GenerateVectors</Value>
</Value>
</Data>
<DefaultData>LoincLoadDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
