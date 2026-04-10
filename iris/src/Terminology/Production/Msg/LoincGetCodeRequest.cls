Class Terminology.Production.Msg.LoincGetCodeRequest Extends Terminology.Production.Msg.BaseRequest
{

Property LoincNum As %String;

Property ReleaseId As %String;

Storage Default
{
<Data name="LoincGetCodeRequestDefaultData">
<Subscript>"LoincGetCodeRequest"</Subscript>
<Value name="1">
<Value>LoincNum</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
</Data>
<DefaultData>LoincGetCodeRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
