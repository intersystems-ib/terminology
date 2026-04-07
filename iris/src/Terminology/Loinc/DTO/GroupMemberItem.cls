Class Terminology.Loinc.DTO.GroupMemberItem Extends Terminology.Loinc.DTO.Base
{

Property GroupId As %String;

Property LoincNum As %String;

Property Display As %String(MAXLEN = "");

Storage Default
{
<Data name="GroupMemberItemState">
<Subscript>"GroupMemberItem"</Subscript>
<Value name="1">
<Value>GroupId</Value>
</Value>
<Value name="2">
<Value>LoincNum</Value>
</Value>
<Value name="3">
<Value>Display</Value>
</Value>
</Data>
<State>GroupMemberItemState</State>
<Type>%Storage.Serial</Type>
}

}
