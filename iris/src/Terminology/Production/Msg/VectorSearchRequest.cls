Class Terminology.Production.Msg.VectorSearchRequest Extends Terminology.Production.Msg.BaseRequest
{

Property Query As %String;

Property Lang As %String;

Property Limit As %Integer;

Property ModelName As %String;

Property SystemUris As list Of %String;

Property ReleaseIds As list Of %String;

Storage Default
{
<Data name="VectorSearchRequestDefaultData">
<Subscript>"VectorSearchRequest"</Subscript>
<Value name="1">
<Value>Query</Value>
</Value>
<Value name="2">
<Value>Lang</Value>
</Value>
<Value name="3">
<Value>Limit</Value>
</Value>
<Value name="4">
<Value>ModelName</Value>
</Value>
<Value name="5">
<Value>SystemUris</Value>
</Value>
<Value name="6">
<Value>ReleaseIds</Value>
</Value>
</Data>
<DefaultData>VectorSearchRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
