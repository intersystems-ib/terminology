/// Connects the Terminology FHIR repository manager to the custom strategy.
Class Terminology.Fhir.RepoManager Extends HS.FHIRServer.Storage.Json.RepoManager
{

Parameter StrategyKey = "Terminology.Fhir";

Parameter StrategyClass = "Terminology.Fhir.InteractionsStrategy";

}
