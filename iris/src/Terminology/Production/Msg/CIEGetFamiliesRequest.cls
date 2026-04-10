Class Terminology.Production.Msg.CIEGetFamiliesRequest Extends Ens.Request
{

Property ReleaseId As %String;

Property Version As %Integer;

Property CodeType As %String;

Property Limit As %Integer;

Property Offset As %Integer;

Storage Default
{
<Data name="CIEGetFamiliesRequestDefaultData">
<Subscript>"CIEGetFamiliesRequest"</Subscript>
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
<Value>Limit</Value>
</Value>
<Value name="5">
<Value>Offset</Value>
</Value>
</Data>
<DefaultData>CIEGetFamiliesRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
