/// Wires the Terminology FHIR interactions into the server strategy.
Class Terminology.Fhir.InteractionsStrategy Extends HS.FHIRServer.Storage.JsonAdvSQL.InteractionsStrategy
{

Parameter StrategyKey = "Terminology.Fhir";

Parameter InteractionsClass = "Terminology.Fhir.Interactions";

/// @API<br>
/// Return a CapabilityStatement metadata resource. The returned content is derived from
/// a strategy-specific means of formulating a CapabilityStatement. An example use of the
/// output might be to store the CapabilityStatement for a given Service.<br>
/// This method should not be confused with the Interactions class LoadMetadata() method,
/// which retrieves the stored CapabilityStatement for the current Service.
/// 
/// IMPORTANT! after changing this method you should call:
///   do ##class(HS.FHIRServer.ConsoleSetup).UpdateCapabilityStatement()
/// 
Method GetMetadataResource() As %DynamicObject
{
    set capabilityStatement = ##super()
    set capabilityStatement.name = "TerminologyFhirServerCapabilityStatement"
    set capabilityStatement.title = "Terminology FHIR Server CapabilityStatement"
    set capabilityStatement.publisher = "InterSystems Developer Community"
    do capabilityStatement.%Set("experimental", 1, "boolean")
    set capabilityStatement.description = "FHIR terminology server for reusable terminology services on InterSystems IRIS for Health."
    set capabilityStatement.purpose = "Expose a narrow FHIR terminology MVP over the current implementation while keeping the architecture ready for additional terminologies."
    if '$IsObject(capabilityStatement.implementation) {
        set capabilityStatement.implementation = {}
    }
    set capabilityStatement.implementation.description = "Terminology FHIR Server"
    if '$IsObject(capabilityStatement.software) {
        set capabilityStatement.software = {}
    }
    set capabilityStatement.software.name = "Terminology FHIR Server"

    if '$IsObject(capabilityStatement.rest) {
        set capabilityStatement.rest = []
    }

    if capabilityStatement.rest.%Size()=0 {
        do capabilityStatement.rest.%Push({})
    }

    set rest = capabilityStatement.rest.%Get(0)
    if '$IsObject(rest.resource) {
        set rest.resource = []
    }

    set resources = []

    set codeSystem = {}
    set codeSystem.type = "CodeSystem"
    set codeSystem.interaction = []
    do codeSystem.interaction.%Push({"code":"read"})
    do codeSystem.interaction.%Push({"code":"search-type"})
    set codeSystem.searchParam = []
    do codeSystem.searchParam.%Push({"name":"url","type":"uri"})
    do codeSystem.searchParam.%Push({"name":"_id","type":"token"})
    do codeSystem.searchParam.%Push({"name":"name","type":"string"})
    do codeSystem.searchParam.%Push({"name":"version","type":"token"})
    set codeSystem.operation = []
    do codeSystem.operation.%Push({"name":"lookup","definition":"http://hl7.org/fhir/OperationDefinition/CodeSystem-lookup"})
    do codeSystem.operation.%Push({"name":"validate-code","definition":"http://hl7.org/fhir/OperationDefinition/CodeSystem-validate-code"})
    do codeSystem.operation.%Push({"name":"subsumes","definition":"http://hl7.org/fhir/OperationDefinition/CodeSystem-subsumes"})
    do resources.%Push(codeSystem)

    set valueSet = {}
    set valueSet.type = "ValueSet"
    set valueSet.interaction = []
    do valueSet.interaction.%Push({"code":"read"})
    do valueSet.interaction.%Push({"code":"search-type"})
    set valueSet.searchParam = []
    do valueSet.searchParam.%Push({"name":"url","type":"uri"})
    do valueSet.searchParam.%Push({"name":"_id","type":"token"})
    do valueSet.searchParam.%Push({"name":"name","type":"string"})
    do valueSet.searchParam.%Push({"name":"version","type":"token"})
    do resources.%Push(valueSet)

    set rest.resource = resources
    do rest.%Remove("operation")
    return capabilityStatement
}

}
