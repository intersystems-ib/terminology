Class Terminology.Production.Msg.CIEValidateCodeRequest Extends Ens.Request
{

Property ReleaseId As %String;

Property Version As %Integer;

Property CodeType As %String;

Property Code As %String;

Storage Default
{
<Data name="CIEValidateCodeRequestDefaultData">
<Subscript>"CIEValidateCodeRequest"</Subscript>
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
</Data>
<DefaultData>CIEValidateCodeRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
