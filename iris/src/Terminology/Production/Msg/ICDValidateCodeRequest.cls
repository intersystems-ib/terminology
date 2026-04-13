Class Terminology.Production.Msg.ICDValidateCodeRequest Extends Ens.Request
{

Property ReleaseId As %String;

Property Version As %Integer;

Property CodeType As %String;

Property Code As %String;

Storage Default
{
<Data name="ICDValidateCodeRequestDefaultData">
<Subscript>"ICDValidateCodeRequest"</Subscript>
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
<DefaultData>ICDValidateCodeRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
