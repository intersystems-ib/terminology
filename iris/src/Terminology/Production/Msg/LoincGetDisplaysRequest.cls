Class Terminology.Production.Msg.LoincGetDisplaysRequest Extends Terminology.Production.Msg.BaseRequest
{

Property LoincNum As %String;

Property ReleaseId As %String;

Property Lang As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="LoincGetDisplaysRequestDefaultData">
<Subscript>"LoincGetDisplaysRequest"</Subscript>
<Value name="1">
<Value>LoincNum</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Lang</Value>
</Value>
<Value name="4">
<Value>Limit</Value>
</Value>
<Value name="5">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>LoincGetDisplaysRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
