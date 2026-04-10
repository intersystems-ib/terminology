Class Terminology.Production.Msg.LoincGetAncestorsRequest Extends Terminology.Production.Msg.BaseRequest
{

Property Code As %String;

Property ReleaseId As %String;

Property HierarchyType As %String;

Property MaxDepth As %Integer;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="LoincGetAncestorsRequestDefaultData">
<Subscript>"LoincGetAncestorsRequest"</Subscript>
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
<DefaultData>LoincGetAncestorsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
