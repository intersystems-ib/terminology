Class Terminology.Production.Msg.BaseRequest Extends Ens.Request
{

Property TraceId As %String;

Property TraceStart As %String;

Storage Default
{
<Data name="BaseRequestDefaultData">
<Subscript>"BaseRequest"</Subscript>
<Value name="1">
<Value>TraceId</Value>
</Value>
<Value name="2">
<Value>TraceStart</Value>
</Value>
</Data>
<DefaultData>BaseRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
