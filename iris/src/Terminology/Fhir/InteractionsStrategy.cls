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
    do resources.%Push(codeSystem)

    set valueSet = {}
    set valueSet.type = "ValueSet"
    set valueSet.interaction = []
    do valueSet.interaction.%Push({"code":"read"})
    do valueSet.interaction.%Push({"code":"search-type"})
    do resources.%Push(valueSet)

    set rest.resource = resources
    return capabilityStatement
}

}
