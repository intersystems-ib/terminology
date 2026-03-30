Class Terminology.Snomed.DTO.ConceptListResult Extends Terminology.Snomed.DTO.Base
{

Property Items As list Of Terminology.Snomed.DTO.ConceptSummary(%JSONFIELDNAME = "items");

Property Count As %Integer(%JSONFIELDNAME = "count");

Storage Default
{
<Data name="ConceptListResultState">
<Subscript>"ConceptListResult"</Subscript>
<Value name="1">
<Value>Items</Value>
</Value>
<Value name="2">
<Value>Count</Value>
</Value>
</Data>
<State>ConceptListResultState</State>
<Type>%Storage.Serial</Type>
}

}
