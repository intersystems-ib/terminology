Class Terminology.Production.Msg.LoincGetPartsRequest Extends Terminology.Production.Msg.BaseRequest
{

Property LoincNum As %String;

Property ReleaseId As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="LoincGetPartsRequestDefaultData">
<Subscript>"LoincGetPartsRequest"</Subscript>
<Value name="1">
<Value>LoincNum</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Limit</Value>
</Value>
<Value name="4">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>LoincGetPartsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
