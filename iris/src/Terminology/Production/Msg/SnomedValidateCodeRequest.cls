Class Terminology.Production.Msg.SnomedValidateCodeRequest Extends Terminology.Production.Msg.BaseRequest
{

Property ReleaseId As %String;

Property Code As %String;

Storage Default
{
<Data name="SnomedValidateCodeRequestDefaultData">
<Subscript>"SnomedValidateCodeRequest"</Subscript>
<Value name="1">
<Value>ReleaseId</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
</Data>
<DefaultData>SnomedValidateCodeRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
