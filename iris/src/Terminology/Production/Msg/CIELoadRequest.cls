Class Terminology.Production.Msg.CIELoadRequest Extends Ens.Request
{

Property FilePath As %String(MAXLEN = 200);

Property ReleaseId As %String;

Property Version As %Integer;

Property CodeType As %String;

// DIAGNOSIS / PROCEDURE

Property Lang As %String;

Storage Default
{
<Data name="CIELoadRequestDefaultData">
<Subscript>"CIELoadRequest"</Subscript>
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
<DefaultData>CIELoadRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
