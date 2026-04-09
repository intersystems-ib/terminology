Class Terminology.Production.Msg.LoincGetGroupsRequest Extends Terminology.Production.Msg.BaseRequest
{

Property ReleaseId As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="LoincGetGroupsRequestDefaultData">
<Subscript>"LoincGetGroupsRequest"</Subscript>
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
<DefaultData>LoincGetGroupsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
