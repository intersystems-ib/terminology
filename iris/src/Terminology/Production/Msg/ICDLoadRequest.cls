Class Terminology.Production.Msg.ICDLoadRequest Extends Ens.Request
{

Property FilePath As %String(MAXLEN = 200);

Property ReleaseId As %String;

Property Version As %Integer;

Property CodeType As %String;

Property Lang As %String;

Storage Default
{
<Data name="ICDLoadRequestDefaultData">
<Subscript>"ICDLoadRequest"</Subscript>
<Value name="1">
<Value>FilePath</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Version</Value>
</Value>
<Value name="4">
<Value>CodeType</Value>
</Value>
<Value name="5">
<Value>Lang</Value>
</Value>
</Data>
<DefaultData>ICDLoadRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
