Class Terminology.Snomed.DTO.RefsetSummary Extends Terminology.Snomed.DTO.Base
{

Property RefsetId As %String(%JSONFIELDNAME = "refsetId");

Storage Default
{
<Data name="RefsetSummaryState">
<Subscript>"RefsetSummary"</Subscript>
<Value name="1">
<Value>RefsetId</Value>
</Value>
</Data>
<State>RefsetSummaryState</State>
<Type>%Storage.Serial</Type>
}

}
