Class Terminology.Snomed.DTO.ValidateCodeResult Extends Terminology.Snomed.DTO.Base
{

Property Exists As %Integer(%JSONFIELDNAME = "exists");

Property Active As %Integer(%JSONFIELDNAME = "active");

Storage Default
{
<Data name="ValidateCodeResultState">
<Subscript>"ValidateCodeResult"</Subscript>
<Value name="1">
<Value>Exists</Value>
</Value>
<Value name="2">
<Value>Active</Value>
</Value>
</Data>
<State>ValidateCodeResultState</State>
<Type>%Storage.Serial</Type>
}

}
