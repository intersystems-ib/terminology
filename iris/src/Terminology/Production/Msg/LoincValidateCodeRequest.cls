Class Terminology.Production.Msg.LoincValidateCodeRequest Extends Terminology.Production.Msg.BaseRequest
{

Property ReleaseId As %String;

Property Code As %String;

Storage Default
{
<Data name="LoincValidateCodeRequestDefaultData">
<Subscript>"LoincValidateCodeRequest"</Subscript>
<Value name="1">
<Value>ReleaseId</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
</Data>
<DefaultData>LoincValidateCodeRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
