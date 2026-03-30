Class Terminology.Snomed.DTO.RefsetMemberListResult Extends Terminology.Snomed.DTO.Base
{

Property Items As list Of Terminology.Snomed.DTO.RefsetMemberSummary(%JSONFIELDNAME = "items");

Property Count As %Integer(%JSONFIELDNAME = "count");

Storage Default
{
<Data name="RefsetMemberListResultState">
<Subscript>"RefsetMemberListResult"</Subscript>
<Value name="1">
<Value>Items</Value>
</Value>
<Value name="2">
<Value>Count</Value>
</Value>
</Data>
<State>RefsetMemberListResultState</State>
<Type>%Storage.Serial</Type>
}

}
