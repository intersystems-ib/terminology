Class Terminology.Snomed.DTO.DescriptionListResult Extends Terminology.Snomed.DTO.Base
{

Property Items As list Of Terminology.Snomed.DTO.DescriptionSummary(%JSONFIELDNAME = "items");

Property Count As %Integer(%JSONFIELDNAME = "count");

Storage Default
{
<Data name="DescriptionListResultState">
<Subscript>"DescriptionListResult"</Subscript>
<Value name="1">
<Value>Items</Value>
</Value>
<Value name="2">
<Value>Count</Value>
</Value>
</Data>
<State>DescriptionListResultState</State>
<Type>%Storage.Serial</Type>
}

}
