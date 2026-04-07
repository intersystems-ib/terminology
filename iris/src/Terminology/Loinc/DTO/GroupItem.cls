Class Terminology.Loinc.DTO.GroupItem Extends Terminology.Loinc.DTO.Base
{

Property GroupId As %String;

Property GroupName As %String(MAXLEN = "");

Property GroupType As %String;

Property Version As %String;

Storage Default
{
<Data name="GroupItemState">
<Subscript>"GroupItem"</Subscript>
<Value name="1">
<Value>GroupId</Value>
</Value>
<Value name="2">
<Value>GroupName</Value>
</Value>
<Value name="3">
<Value>GroupType</Value>
</Value>
<Value name="4">
<Value>Version</Value>
</Value>
</Data>
<State>GroupItemState</State>
<Type>%Storage.Serial</Type>
}

}
