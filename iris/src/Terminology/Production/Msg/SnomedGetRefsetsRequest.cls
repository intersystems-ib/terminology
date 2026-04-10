Class Terminology.Production.Msg.SnomedGetRefsetsRequest Extends Terminology.Production.Msg.BaseRequest
{

Property ReleaseId As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="SnomedGetRefsetsRequestDefaultData">
<Subscript>"SnomedGetRefsetsRequest"</Subscript>
<Value name="1">
<Value>ReleaseId</Value>
</Value>
<Value name="2">
<Value>Limit</Value>
</Value>
<Value name="3">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>SnomedGetRefsetsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
