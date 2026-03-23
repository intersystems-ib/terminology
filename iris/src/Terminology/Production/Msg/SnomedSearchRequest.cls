Class Terminology.Production.Msg.SnomedSearchRequest Extends Ens.Request
{

Property Query As %String;

Property ReleaseId As %String;

Property Lang As %String;

Property Dialect As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="SnomedSearchRequestDefaultData">
<Subscript>"SnomedSearchRequest"</Subscript>
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
<Value>Dialect</Value>
</Value>
<Value name="5">
<Value>Limit</Value>
</Value>
<Value name="6">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>SnomedSearchRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
