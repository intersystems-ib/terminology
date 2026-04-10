Class Terminology.CIE.DTO.ValidateCodeResult Extends Terminology.CIE.DTO.Base
{

Property Exists As %Boolean;

Property Active As %Boolean;

Property Code As %String;

Property Description As %String;

Property Version As %Integer;

Property CodeType As %String;

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
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Description</Value>
</Value>
<Value name="5">
<Value>Version</Value>
</Value>
<Value name="6">
<Value>CodeType</Value>
</Value>
</Data>
<State>ValidateCodeResultState</State>
<Type>%Storage.Serial</Type>
}

}
