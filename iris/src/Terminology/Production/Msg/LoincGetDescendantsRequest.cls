Class Terminology.Production.Msg.LoincGetDescendantsRequest Extends Terminology.Production.Msg.BaseRequest
{

Property Code As %String;

Property ReleaseId As %String;

Property HierarchyType As %String;

Property MaxDepth As %Integer;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="LoincGetDescendantsRequestDefaultData">
<Subscript>"LoincGetDescendantsRequest"</Subscript>
<Value name="1">
<Value>Code</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>HierarchyType</Value>
</Value>
<Value name="4">
<Value>MaxDepth</Value>
</Value>
<Value name="5">
<Value>Limit</Value>
</Value>
<Value name="6">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>LoincGetDescendantsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
