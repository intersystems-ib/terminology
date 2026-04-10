Class Terminology.Production.Msg.CIEGetChildrenRequest Extends Ens.Request
{

Property ReleaseId As %String;

Property Version As %Integer;

Property CodeType As %String;

Property Code As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="CIEGetChildrenRequestDefaultData">
<Subscript>"CIEGetChildrenRequest"</Subscript>
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
<Value>Limit</Value>
</Value>
<Value name="6">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>CIEGetChildrenRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
