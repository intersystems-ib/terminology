Class Terminology.Snomed.DTO.RefsetListResult Extends Terminology.Snomed.DTO.Base
{

Property Items As list Of Terminology.Snomed.DTO.RefsetSummary(%JSONFIELDNAME = "items");

Property Count As %Integer(%JSONFIELDNAME = "count");

Storage Default
{
<Data name="RefsetListResultState">
<Subscript>"RefsetListResult"</Subscript>
<Value name="1">
<Value>Items</Value>
</Value>
<Value name="2">
<Value>Count</Value>
</Value>
</Data>
<State>RefsetListResultState</State>
<Type>%Storage.Serial</Type>
}

}
