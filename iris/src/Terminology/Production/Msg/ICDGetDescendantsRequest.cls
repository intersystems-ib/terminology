Class Terminology.Production.Msg.ICDGetDescendantsRequest Extends Ens.Request
{

Property ReleaseId As %String;

Property Version As %Integer;

Property CodeType As %String;

Property Code As %String;

Property IncludeSelf As %Boolean;

Property MaxDepth As %Integer;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="ICDGetDescendantsRequestDefaultData">
<Subscript>"ICDGetDescendantsRequest"</Subscript>
<Value name="1">
<Value>ReleaseId</Value>
</Value>
<Value name="2">
<Value>Version</Value>
</Value>
<Value name="3">
<Value>CodeType</Value>
</Value>
<Value name="4">
<Value>Code</Value>
</Value>
<Value name="5">
<Value>IncludeSelf</Value>
</Value>
<Value name="6">
<Value>MaxDepth</Value>
</Value>
<Value name="7">
<Value>Limit</Value>
</Value>
<Value name="8">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>ICDGetDescendantsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
