Class Terminology.Production.Msg.VectorCrosswalkRequest Extends Terminology.Production.Msg.BaseRequest
{

Property Query As %String;

Property SourceSystemUri As %String;

Property SourceCode As %String;

Property SourceReleaseId As %String;

Property Lang As %String;

Property Limit As %Integer;

Property ModelName As %String;

Property TargetSystemUris As list Of %String;

Property TargetReleaseIds As list Of %String;

Storage Default
{
<Data name="VectorCrosswalkRequestDefaultData">
<Subscript>"VectorCrosswalkRequest"</Subscript>
<Value name="1">
<Value>Query</Value>
</Value>
<Value name="2">
<Value>SourceSystemUri</Value>
</Value>
<Value name="3">
<Value>SourceCode</Value>
</Value>
<Value name="4">
<Value>SourceReleaseId</Value>
</Value>
<Value name="5">
<Value>Lang</Value>
</Value>
<Value name="6">
<Value>Limit</Value>
</Value>
<Value name="7">
<Value>ModelName</Value>
</Value>
<Value name="8">
<Value>TargetSystemUris</Value>
</Value>
<Value name="9">
<Value>TargetReleaseIds</Value>
</Value>
</Data>
<DefaultData>VectorCrosswalkRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
