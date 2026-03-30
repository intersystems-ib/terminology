Class Terminology.Snomed.DTO.ConceptSummary Extends Terminology.Snomed.DTO.Base
{

Property ConceptId As %String(%JSONFIELDNAME = "conceptId");

Property PreferredTerm As %String(%JSONFIELDNAME = "preferredTerm", MAXLEN = "");

Property Depth As %Integer(%JSONFIELDNAME = "depth");

Storage Default
{
<Data name="ConceptSummaryState">
<Subscript>"ConceptSummary"</Subscript>
<Value name="1">
<Value>ConceptId</Value>
</Value>
<Value name="2">
<Value>PreferredTerm</Value>
</Value>
<Value name="3">
<Value>Depth</Value>
</Value>
</Data>
<State>ConceptSummaryState</State>
<Type>%Storage.Serial</Type>
}

}
