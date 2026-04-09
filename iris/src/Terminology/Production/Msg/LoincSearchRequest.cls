Class Terminology.Production.Msg.LoincSearchRequest Extends Terminology.Production.Msg.BaseRequest
{

Property Query As %String;

Property ReleaseId As %String;

Property Lang As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="LoincSearchRequestDefaultData">
<Subscript>"LoincSearchRequest"</Subscript>
<Value name="1">
<Value>Query</Value>
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
<DefaultData>LoincSearchRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
